default: install

install:
	./scripts/install.sh

update:
	./scripts/update.sh

check: lint
lint:
	git ls-files | grep '\.sh$$' | xargs shellcheck -e SC1071
