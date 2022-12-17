#!/bin/bash

version=0.0.1

# Check to verify MacOS
if [[ $OSTYPE == 'darwin'* ]]; then
  echo 'macOS'
fi

# Update MacOS
softwareupdate --all --install --force


## Initial installation ###############################################

# Install Xcode 
sudo xcode-select --install || true

# Install Homebrew package manager
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install base brew packages
brew install coreutils zlib openssl readline xz git tree gawk pyenv pyenv-virtualenv makefile2graph graphviz


linuxify_formulas=(
    # GNU programs non-existing in macOS
    "watch"
    "wget"
    "wdiff"
    # "gdb" intel only
    "autoconf"

    # GNU programs whose BSD counterpart is installed in macOS
    "coreutils"
    "binutils"
    "diffutils"
    "ed"
    "findutils"
    "gawk"
    "gnu-indent"
    "gnu-sed"
    "gnu-tar"
    "gnu-which"
    "grep"
    "gzip"
    "screen"

    # GNU programs existing in macOS which are outdated
    "bash"
    "emacs"
    "gpatch"
    "less"
    "m4"
    "make"
    "nano"
    "bison"

    # BSD programs existing in macOS which are outdated
    "flex"

    # Other common/preferred programs in GNU/Linux distributions
    "libressl"
    "file-formula"
    "git"
    "openssh"
    "perl"
    "python"
    "rsync"
    "unzip"
    "vim"
)


brew list --versions > brew_packages_installed.txt


## Upgrade installed software ##########################################
softwareupdate --all --install --force

brew update && brew upgrade






brew_packages_base.txt: install-brew-packages .FORCE
	@(echo "$(HOMEBREW-PACKAGES)" | sed -e 's/ /\n/g') > $@
	@echo $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")    [INFO]    $@    \"Created $@\" 

brew_packages_installed.txt: brew_packages_base.txt .FORCE
	$(BREW) list --versions > $@
	@echo $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")    [INFO]    $@    \"Created $@\"


# installing packaged applications
installer -pkg /path/to/application.pkg -target /Applications
installer -pkg /path/to/application.mpkg -target /Applications -dumplog /Volumes/Server/Share/installer.log