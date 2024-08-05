# Innomerphey Custom-formulas

## How do I install these formulae?

`brew install innomerphey/custom-formulas/<formula>`

Or `brew tap innomerphey/custom-formulas` and then `brew install <formula>`.

Or, in a [`brew bundle`](https://github.com/Homebrew/homebrew-bundle) `Brewfile`:

```ruby
tap "innomerphey/custom-formulas"
brew "<formula>"
```

## Documentation

`brew help`, `man brew` or check [Homebrew's documentation](https://docs.brew.sh).

No available formula with the name "openssl@1.0". Did you mean openssl@3.0, openssl@1.1 or openssl@3?
python-build: use openssl from homebrew
python-build: use readline from homebrew
Downloading Python-2.7.18.tar.xz...

brew install openssl or openssl@1.1 ??

```
brew install openssl@1.1 bzip2 libffi readline sqlite xz zlib
brew install asdf
echo -e "\n. $(brew --prefix asdf)/libexec/asdf.sh" >> ${ZDOTDIR:-~}/.zshrc
asdf install python 2.7.18
asdf install python 3.12.0
asdf global python 2.7.18  3.12.0
python -V &&  python2 -V &&  python3 -V
sudo rm /usr/local/bin/python2
sudo ln -s $(asdf where python)/bin/python2 /usr/local/bin/python2
and chek the link
ls -l /usr/local/bin/python2
/usr/local/bin/python2 --version

add python to path in .zshrc 
export PATH="/opt/homebrew/opt/python@2.7/bin:$PATH"   #check if needed

brew install innomerphey/custom-formulas/oracle-jdk@8.411



pip2 install Cython==0.24
pip2 install setuptools==44.1.1

brew install innomerphey/custom-formulas/cassandra@3.7.0  
brew services start innomerphey/custom-formulas/cassandra@3.7.0


```
