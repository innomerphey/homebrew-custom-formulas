#noinspection RubyResolve,SpellCheckingInspection
cask "oracle-jdk@8.411" do
  arch arm: "aarch64"

  version "8u411"
  sha256 arm:   "d4d3e4ced023c7717e81c05d372e37e3787a2c1c17847a68210a95c7a9367214"

  url "https://javadl.oracle.com/webapps/download/AutoDL?BundleId=249841_43d62d619be4e416215729597d70b8ac"
  name "Oracle Java Standard Edition Development Kit"
  desc "JDK from Oracle"
  homepage "https://www.oracle.com/java/technologies/downloads/"

  livecheck do
    url "https://www.oracle.com/java/technologies/javase/emb8u411-relnotes.html"
    regex(/<li>\s*JDK\s*v?(\d+(?:\.\d+)*)/i)
  end

  depends_on macos: ">= :mojave"

  pkg "JDK #{version}.pkg"

  uninstall pkgutil: "com.oracle.jdk-#{version}"

  # No zap stanza required

  caveats do
    license "https://www.oracle.com/downloads/licenses/javase-license1.html#licenseContent"
  end
end

# https://sites.google.com/view/java-se-download-url-converter
# 8u411 intel https://javadl.oracle.com/webapps/download/AutoDL?BundleId=249843_43d62d619be4e416215729597d70b8ac

