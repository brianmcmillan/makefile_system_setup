# ~/Documents/GitHub/makefile_system_setup/makefile
#
# Setup a macOS computer with a basic python development environment.
# NOTE: Updating OS software, installing xcode and Homebrew should be done 
# on first installation or as needed. 
#-------------------------------------------------------------------------
# make all                  Executes the default make task.
# make help                 List of all makefile tasks.
# make installcheck         Run the project installation test suite.
# make install              Run installation steps (may include pre-install, normal-install, post-install steps).
# make check                Executes all test suites.
# make documentation        Builds the documentation files for the build. (e.g. schema docs, data flow diagrams)
# make uninstall            Uninstalls the project.


############################################################################
# Macros                                                                   #
############################################################################
define help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(word 1, $(MAKEFILE_LIST)) | sort | \
	awk 'BEGIN {FS = ":.*?## "};\
	{printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
endef

define test-file
	@# tests the file in the <target>
	@#<target>(colon)(space)<path/to/directory> 
	@[[ -f $@ ]] \
	&& true \
	|| echo $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")    [FAIL]    $(NAME)     \"testing for $< did not find $@\" 
endef

define test-dependent-file
	@# tests the file in the <first dependency>
	@[[ -f $< ]] \
	&& true \
	|| echo $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")    [WARNING]    $@     \"testing for $< did not find $<\" 
endef

define uninstall-file
	@# <target>(colon)(space)<path/to/file(s)>
	@rm -f $^ || true
	@echo $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")    [INFO]    $@     \"Files removed - $^\"
endef

define uninstall-file-list
	@#<target>(colon)(space)FILE=<list of file(s)>
	@#<target>(colon)(space)
	@rm -f $(FILES)
	@echo $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")    [INFO]    $@     \"Files removed - $(FILES)\"
endef

define directory-listing
	@#<path/to/directory_listing.txt>(colon)(space).FORCE
	@$(TREE) --prune > $@
	@echo $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")    [INFO]    $@    \"Created directory list at $@\"
endef

define makefile-graph
	@$(NODEGRAPH) --direction LR | $(GRAPHVIZDOT) -Tpng > $@
	@echo $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")    [INFO]    $@    \"Created makefile diagram at $@\"
endef

############################################################################
# Variables                                                                #
############################################################################
# Application variables
HOMEBREW-PACKAGES := coreutils zlib openssl readline xz git tree gawk pyenv pyenv-virtualenv makefile2graph graphviz
PYTHON-VERSION := 3.10.2
PROJECT-PATH := $(shell pwd)
PROJECT-NAME := $(notdir $(shell pwd))

# Program locations (which <utility>)
SHELL := /bin/bash
BREW := /usr/local/bin/brew
TREE := /usr/local/bin/tree
GRAPHVIZDOT := /usr/local/bin/dot
PYENVDIR := ~/.pyenv/versions/$(PYTHON-VERSION)/envs/$(PROJECT-NAME)/bin
PYTHON := $(PYENVDIR)/python
PIP := $(PYENVDIR)/pip
NODEGRAPH := $(PYENVDIR)/makefile2dot

#######################################
all: installcheck initial-documentation ## Executes the default make task.

.FORCE: 

# .PHONY: all help documentation initial-documentation list-variables \
# installcheck check test-gitignore test-README.md test-brew_packages_base.txt test-brew_packages_installed.txt install \
# update update-macos install-xcode update-homebrew uninstall uninstall-files

############################################################################
# Documentation                                                            #
############################################################################
documentation: test-makefile_graph.png test-directory_listing.txt ## Builds the documentation files for the build. (e.g. schema docs, data flow diagrams)

initial-documentation: test-directory_listing.txt help

help: ## List of all makefile tasks.
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(word 1, $(MAKEFILE_LIST)) | sort | \
	awk 'BEGIN {FS = ":.*?## "};\
	{printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' 

directory_listing.txt: .FORCE
	$(directory-listing)

makefile_graph.png: .FORCE
	$(makefile-graph)

list-variables: 
	@echo PYENVDIR - $(PYENVDIR)
	@echo PYTHON - $(PYTHON)
	@echo PIP - $(PIP)

############################################################################
# Tests                                                                    #
############################################################################
installcheck: test-gitignore test-directory_listing.txt test-README.md ## Run the pre-installation test suite.

check: installcheck test-brew_packages_base.txt test-brew_packages_installed.txt test-requirements.txt test-makefile_graph.png ## Executes all test suites.

test-gitignore: .gitignore
	$(test-dependent-file)

test-README.md: README.md
	$(test-dependent-file)

test-directory_listing.txt: directory_listing.txt
	$(test-dependent-file)

test-brew_packages_base.txt: brew_packages_base.txt
	$(test-dependent-file)

test-brew_packages_installed.txt: brew_packages_installed.txt
	$(test-dependent-file)

test-requirements.txt: requirements.txt
	$(test-dependent-file)

test-makefile_graph.png: makefile_graph.png
	$(test-dependent-file)


############################################################################
# Installation - Base Software                                             #
############################################################################
install: install-pip-packages .gitignore check ## Run once when setting up a new system.

install-xcode: update-macos
	@sudo xcode-select --install || true
	@echo $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")    [INFO]    $@    \"xcode installed\" 

install-homebrew: install-xcode
	@/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	@echo $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")    [INFO]    $@    \"Homebrew software installed\" 

install-brew-packages: install-homebrew
	@$(BREW) install $(HOMEBREW-PACKAGES)
	@echo $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")    [INFO]    $@    \"Homebrew packages installed - $(HOMEBREW-PACKAGES)\"

brew_packages_base.txt: install-brew-packages .FORCE
	@(echo "$(HOMEBREW-PACKAGES)" | sed -e 's/ /\n/g') > $@
	@echo $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")    [INFO]    $@    \"Created $@\" 

brew_packages_installed.txt: brew_packages_base.txt .FORCE
	$(BREW) list --versions > $@
	@echo $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")    [INFO]    $@    \"Created $@\"

# https://github.com/pyenv/pyenv/wiki#suggested-build-environment
# https://github.com/pyenv/pyenv/#basic-github-checkout
# Reference: https://faun.pub/pyenv-multi-version-python-development-on-mac-578736fb91aa

install-python-global-virtualenv: install-brew-packages
	@pyenv install $(PYTHON-VERSION)
	@pyenv global $(PYTHON-VERSION)
	@echo $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")    [INFO]    $@    \"Python $(PYTHON-VERSION) installed with pyenv\" 
	@$(shell pyenv which pip) install --upgrade pip
	@echo $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")    [INFO]    $@    \"Python location - $(shell pyenv which python)\" 
	@echo $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")    [INFO]    $@    \"PIP location - $(shell pyenv which pip)\" 

install-python-local-virtualenv: install-python-global-virtualenv
	@pyenv virtualenv $(PYTHON-VERSION) $(PROJECT-NAME)
	@pyenv local $(PROJECT-NAME)
	@echo $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")    [INFO]    $@    \"Python location - $(shell pyenv which python)\" 
	@echo $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")    [INFO]    $@    \"PIP location - $(shell pyenv which pip)\"

# Utility tasks to update shell profiles on macOS.
# WARNING: These will be appended to the profiles and duplicates will need to be manually removed. 
#update-bash-profile:
# echo 'eval "$(pyenv init -)"' >> ~/.bashrc
# echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.profile
# echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.profile
# echo 'eval "$(pyenv init --path)"' >> ~/.profile
# echo 'if [ -n "$PS1" -a -n "$BASH_VERSION" ]; then source ~/.bashrc; fi' >> ~/.profile
# echo 'if which pyenv-virtualenv-init > /dev/null; then eval "$(pyenv virtualenv-init -)"; fi' >>  ~/.profile
#
############################################################################

.gitignore: 
	@echo ".DS_Store" > $@
	@echo ".DS_Store?" >> $@
	@echo "*.DS_Store" >> $@
	@echo $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")    [INFO]    $@    \"Created $@\"

# Python pip packages
# To upgrade - Edit requirements_base.txt with the new projects and/or versions
# then run 'make update-pip-packages'.
requirements_base.txt: .FORCE
	@echo makefile2dot==1.0.2 > $@
	@echo pygraphviz==1.9 >> $@

requirements.txt: requirements_base.txt
	@$(shell pyenv which pip) freeze > $@
	@echo $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")    [INFO]    $@    \"Python pip packages installed - requirements.txt\"

install-pip-packages: requirements_base.txt install-python-local-virtualenv
	@$(shell pyenv which pip) install --upgrade pip
	@$(shell pyenv which pip) install -r $<
	@$(shell pyenv which pip) freeze > requirements.txt
	@echo $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")    [INFO]    $@    \"Python pip packages installed - requirements.txt\"


############################################################################
# Update                                                                   #
############################################################################
update: update-homebrew update-pip-packages check ## Updates base software (OS, Homebrew, python, pip)

update-macos: 
	@softwareupdate --all --install --force
	@echo $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")    [INFO]    $@    \"macOS software updated\" 

update-homebrew: 
	@$(BREW) update
	@$(BREW) upgrade
	@$(BREW) install $(HOMEBREW-PACKAGES)
	@(echo "$(HOMEBREW-PACKAGES)" | sed -e 's/ /\n/g') > brew_packages_base.txt
	$(BREW) list --versions > brew_packages_installed.txt
	@echo $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")    [INFO]    $@    \"Homebrew software updated\" 

update-pip-packages: requirements_base.txt
	@$(shell pyenv which pip) install --upgrade pip
	@$(shell pyenv which pip) install -r $<
	@$(shell pyenv which pip) freeze > requirements.txt
	@echo $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")    [INFO]    $@    \"Python pip packages upgraded - requirements.txt\"


############################################################################
# Uninstall                                                                #
############################################################################
uninstall: uninstall-files uninstall-virtualenv ## Uninstalls the project files.

uninstall-files: FILES=.gitignore brew_packages_*.txt directory_listing.txt makefile_graph.png requirements_base.txt requirements.txt .python-version
uninstall-files: 
	$(uninstall-file-list)

uninstall-virtualenv:	
	@pyenv virtualenv-delete $(PROJECT-NAME)
	@echo $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")    [INFO]    $@    \"Virtual environment removed - $(PROJECT-NAME)\"
	@echo $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")    [INFO]    $@    \"Pyenv - $(shell pyenv versions)"\

# WARNING: Uninstalling Homebrew *WILL* affect outher applications
# uninstall-homebrew: .FORCE
# 	@/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall.sh)"
# 	@echo $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")    [INFO]    $@    \"Homebrew uninstalled\"
