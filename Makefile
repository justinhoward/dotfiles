##Justin's dotfiles
##───────────────────────────────────────────────────────────────────────
##Clone this repository into the home directory
##
##git clone git@github.com:justinhoward/dotfiles.git ~/.dotfiles
##
##Then run "make install" to install dotfile modules

.PHONY: install
install: ## Install modules
	./scripts/install.sh

.PHONY: update
update: ## Run module update scripts
	./scripts/update.sh

.PHONY: check
check: lint

.PHONY: lint
lint: ## Check files with shellcheck
	git ls-files | grep '\.sh$$' | xargs shellcheck -e SC1071

.PHONY: help
.DEFAULT_GOAL := help
# Credit to https://github.com/IllustratedMan-code/make-help
help: ## Show this help
	@sed -ne "s/^##\(.*\)/\1/p" $(MAKEFILE_LIST)
	@printf "────────────────────────`tput bold``tput setaf 2` Make Commands `tput sgr0`────────────────────────────────\n"
	@sed -ne "/@sed/!s/\(^[^#?=]*:\).*##\(.*\)/`tput setaf 2``tput bold`\1`tput sgr0`\2/p" $(MAKEFILE_LIST)
	@printf "───────────────────────────────────────────────────────────────────────\n"
