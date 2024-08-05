# noinspection RubyResolve,SpellCheckingInspection
# brew reinstall --debug innomerphey/custom-formulas/cassandra@3.7.0
class CassandraAT370 < Formula
  desc "Eventually consistent, distributed key-value store"
  homepage "https://cassandra.apache.org"
  url "https://archive.apache.org/dist/cassandra/3.7/apache-cassandra-3.7-bin.tar.gz"
  sha256 "335f5344c4e6b98ec51324d821fa06e99101145ac6e83b5f6ede8c0ca5d15748"
  license "Apache-2.0"
  depends_on :macos
  depends_on arch: :arm64

  bottle do
    sha256 cellar: :any_skip_relocation, sierra: "35a653410f7c3c96c96812befd642b02d39fc41be4fbaf70e56fdf9366a47ec5"
    sha256 cellar: :any_skip_relocation, el_capitan: "8094fd82942fa2bd3e0206c489d3169d618f3fa9bba5995353a92d1117f19eb9"
    sha256 cellar: :any_skip_relocation, yosemite: "49475a2e7daab60e5854b1514d50dd7cd4a943c5ec593dffc7b4243fe4798b23"
    sha256 cellar: :any_skip_relocation, mavericks: "c9f0fcbd738f3ecfd2eff5c654d1f385a617f3fa7a07e5c5b4344856bfa7da24"
  end

  resource "setuptools" do
    url "https://files.pythonhosted.org/packages/b2/40/4e00501c204b457f10fe410da0c97537214b2265247bc9a5bc6edd55b9e4/setuptools-44.1.1.zip"
    sha256 "c67aa55db532a0dadc4d2e20ba9961cbd3ccc84d544e9029699822542b5a476b"
  end

  resource "Cython" do
    url "https://files.pythonhosted.org/packages/b1/51/bd5ef7dff3ae02a2c6047aa18d3d06df2fb8a40b00e938e7ea2f75544cac/Cython-0.24.tar.gz"
    sha256 "6de44d8c482128efc12334641347a9c3e5098d807dd3c69e867fa8f84ec2a3f1"
  end

  resource "futures" do
    url "https://files.pythonhosted.org/packages/55/db/97c1ca37edab586a1ae03d6892b6633d8eaa23b23ac40c7e5bbc55423c78/futures-3.0.5.tar.gz"
    sha256 "0542525145d5afc984c88f914a0c85c77527f65946617edb5274f72406f981df"
  end

  resource "six" do
    url "https://files.pythonhosted.org/packages/b3/b2/238e2590826bfdd113244a40d9d3eb26918bd798fc187e2360a8367068db/six-1.10.0.tar.gz"
    sha256 "105f8d68616f8248e24bf0e9372ef04d3cc10104f1980f54d57b2ce73a5ad56a"
  end

  resource "thrift" do
    url "https://files.pythonhosted.org/packages/ae/58/35e3f0cd290039ff862c2c9d8ae8a76896665d70343d833bdc2f748b8e55/thrift-0.9.3.tar.gz"
    sha256 "dfbc3d3bd19d396718dab05abaf46d93ae8005e2df798ef02e32793cd963877e"
  end

  resource "cql" do
    url "https://files.pythonhosted.org/packages/0b/15/523f6008d32f05dd3c6a2e7c2f21505f0a785b6dc8949cad325306858afc/cql-1.4.0.tar.gz"
    sha256 "7857c16d8aab7b736ab677d1016ef8513dedb64097214ad3a50a6c550cb7d6e0"
  end

  resource "cassandra-driver" do
    url "https://files.pythonhosted.org/packages/de/d0/38682a3bc9d581444e2106366ceaaa684bff4b2b5977e5f85b6014f7b6cc/cassandra-driver-3.5.0.tar.gz"
    sha256 "924ea4f3458d39fad54eab5e2f0f5b98ccc636d1ee415f869f66c5163d405e0f"
  end

  resource "virtualenv" do
    url "https://files.pythonhosted.org/packages/1c/c2/7516ea983fc37cec2128e7cb0b2b516125a478f8fc633b8f5dfa849f13f7/virtualenv-16.7.12.tar.gz"
    sha256 "1ca09a8a1684ba15915eebb30bb73988f7af47ae31f48544cc872d2d560c1738"
  end

  def install
    (var / "lib/cassandra").mkpath
    (var / "log/cassandra").mkpath

  # Define Python paths
    user = ENV["USER"]
    pypath = "/Users/#{user}/.asdf/installs/python/2.7.18/lib/python2.7/site-packages"
    python2_path = "/usr/local/bin/python2"

  # Set up environment paths
    ENV.prepend_create_path "PYTHONPATH", pypath
    ENV.prepend_create_path "PYTHONPATH", libexec / "vendor/lib/python2.7/site-packages"
    ENV.prepend_path "PYTHONPATH", libexec / "lib/python2.7/site-packages"
    ENV.prepend_path "PATH", "/usr/libexec"
    ENV["PYTHON"] = python2_path

  # Ensure site-packages directory exists
    (libexec / "lib/python2.7/site-packages").mkpath

    # Set up and use a virtual environment
    resource("virtualenv").stage do
      system python2_path, "setup.py", "install", "--prefix=#{libexec}"
      system python2_path, "-m", "virtualenv", libexec / "vendor"
    end

    # Use the pip from the virtual environment
    venv_pip = libexec / "vendor/bin/pip"

    # Install setuptools inside the virtualenv
    resource("setuptools").stage do
      system venv_pip, "install", "."
    end

  # Install all other Python resources using the virtual environment's pip
    resources.each do |r|
      next if r.name == "virtualenv" || r.name == "setuptools"
      r.stage do
        system venv_pip, "install", "."
      end
    end

    inreplace "conf/cassandra.yaml", "/var/lib/cassandra", var / "lib/cassandra"
    inreplace "conf/cassandra-env.sh", "/lib/", "/"
    inreplace "bin/cassandra", "-Dcassandra.logdir=$CASSANDRA_HOME/logs",
              "-Dcassandra.logdir=#{var}/log/cassandra"

    inreplace "bin/cassandra.in.sh" do |s|
      s.gsub! "CASSANDRA_HOME=\"`dirname \"$0\"`/..\"",
              "CASSANDRA_HOME=\"#{libexec}\""
      # Store configs in etc, outside of keg
      s.gsub! "CASSANDRA_CONF=\"$CASSANDRA_HOME/conf\"",
              "CASSANDRA_CONF=\"#{etc}/cassandra\""
      # Jars installed to prefix, no longer in a lib folder
      s.gsub! "\"$CASSANDRA_HOME\"/lib/*.jar",
              "\"$CASSANDRA_HOME\"/*.jar"
      # The jammm Java agent is not in a lib/ subdir either:
      s.gsub! "JAVA_AGENT=\"$JAVA_AGENT -javaagent:$CASSANDRA_HOME/lib/jamm-",
              "JAVA_AGENT=\"$JAVA_AGENT -javaagent:$CASSANDRA_HOME/jamm-"
      # Storage path
      s.gsub! "cassandra_storagedir=\"$CASSANDRA_HOME/data\"",
              "cassandra_storagedir=\"#{var}/lib/cassandra\""

      java_home = `/usr/libexec/java_home -v 1.8`.strip
      s.gsub! "#JAVA_HOME=/usr/local/jdk6",
              "JAVA_HOME=\"#{java_home}\""
    end
    
    rm Dir["bin/*.bat", "bin/*.ps1"]

    # This breaks on `brew uninstall cassandra && brew install cassandra`
    # https://github.com/Homebrew/homebrew/pull/38309
    pkgetc.install Dir["conf/*"]

  # Install files, carefully avoiding bin/bin issues
  libexec.install Dir["*.txt", "{interface,javadoc,pylib,lib/licenses}"]
  (libexec/"bin").install Dir["bin/*"] # Install contents of bin directly

    libexec.install Dir["lib/*.jar"]

    pkgshare.install [libexec / "bin/cassandra.in.sh", libexec / "bin/stop-server"]
    inreplace Dir[
                libexec / "bin/cassandra*",
                libexec / "bin/debug-cql",
                libexec / "bin/nodetool",
                libexec / "bin/sstable*",
              ], %r{`dirname "?\$0"?`/cassandra.in.sh},
              pkgshare / "cassandra.in.sh"
    

    # Make sure tools are installed
    rm Dir[buildpath / "tools/bin/*.bat"] # Delete before install to avoid copying useless files
    (libexec / "tools").install Dir[buildpath / "tools/lib/*.jar"]

    # Tools use different cassandra.in.sh and should be changed differently
    mv buildpath / "tools/bin/cassandra.in.sh", buildpath / "tools/bin/cassandra-tools.in.sh"
    inreplace buildpath / "tools/bin/cassandra-tools.in.sh" do |s|
      # Tools have slightly different path to CASSANDRA_HOME
      s.gsub! "CASSANDRA_HOME=\"`dirname $0`/../..\"", "CASSANDRA_HOME=\"#{libexec}\""
      # Store configs in etc, outside of keg
      s.gsub! "CASSANDRA_CONF=\"$CASSANDRA_HOME/conf\"", "CASSANDRA_CONF=\"#{etc}/cassandra\""
      # Core Jars installed to prefix, no longer in a lib folder
      s.gsub! "\"$CASSANDRA_HOME\"/lib/*.jar", "\"$CASSANDRA_HOME\"/*.jar"
      # Tools Jars are under tools folder
      s.gsub! "\"$CASSANDRA_HOME\"/tools/lib/*.jar", "\"$CASSANDRA_HOME\"/tools/*.jar"
      # Storage path
      s.gsub! "cassandra_storagedir=\"$CASSANDRA_HOME/data\"", "cassandra_storagedir=\"#{var}/lib/cassandra\""
    end

    pkgshare.install [buildpath / "tools/bin/cassandra-tools.in.sh"]

    # Update tools script files
    inreplace Dir[buildpath / "tools/bin/*"],
              "`dirname \"$0\"`/cassandra.in.sh",
              pkgshare / "cassandra-tools.in.sh"

    # Make sure tools are available
    bin.install Dir[buildpath / "tools/bin/*"]
    bin.write_exec_script Dir[libexec / "bin/*"]

    # rm %W[#{bin}/cqlsh #{bin}/cqlsh.py] # Remove existing exec scripts
    # (bin / "cqlsh").write_env_script libexec / "bin/cqlsh", PATH: "#{libexec}/vendor/bin:$PATH", PYTHONPATH: ENV["PYTHONPATH"]
    # (bin / "cqlsh.py").write_env_script libexec / "bin/cqlsh.py", PATH: "#{libexec}/vendor/bin:$PATH", PYTHONPATH: ENV["PYTHONPATH"]
    # (bin / "cqlsh").write_env_script libexec / "bin/cqlsh", PATH: "#{venv_bin}:$PATH"

  # Rewrite the shebang for cqlsh.py
    python_interpreter = "#{libexec}/vendor/bin/python2"
    inreplace libexec/"bin/cqlsh.py", %r{^#!.*$}, "#!#{python_interpreter}"

  # Ensure cqlsh uses the virtual environment
    (bin / "cqlsh").write_env_script libexec / "bin/cqlsh", PATH: "#{libexec}/vendor/bin:$PATH"
  end

  service do
    run [opt_bin / "cassandra", "-f"]
    keep_alive true
    working_dir var / "lib/cassandra"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/cassandra -v")

    output = shell_output("#{bin}/cqlsh localhost 2>&1", 1)
    assert_match "Connection error", output
  end
end
