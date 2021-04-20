PRODUCT_NAME=figmagen
PRODUCT_VERSION=1.0.0

TEMPLATES_NAME=Templates
README_NAME=README.md
LICENSE_NAME=LICENSE

RELEASE_PATH=.build/release/$(PRODUCT_NAME)-$(PRODUCT_VERSION)
RELEASE_ZIP_PATH = ./$(PRODUCT_NAME)-$(PRODUCT_VERSION).zip
PRODUCT_PATH=.build/release/$(PRODUCT_NAME)
TEMPLATES_PATH=$(TEMPLATES_NAME)
README_PATH=$(README_NAME)
LICENSE_PATH=$(LICENSE_NAME)

PREFIX = /usr/local

BIN_PATH=$(PREFIX)/bin
BIN_PRODUCT_PATH=$(BIN_PATH)/$(PRODUCT_NAME)
SHARE_PRODUCT_PATH=$(PREFIX)/share/$(PRODUCT_NAME)

.PHONY: all version build install uninstall release lint

version:
	@echo $(PRODUCT_VERSION)

build:
	swift build --disable-sandbox -c release

unversal_build:
	swift build --disable-sandbox -c release --arch arm64 --arch x86_64

install: build
	mkdir -p $(BIN_PATH)
	cp -f $(PRODUCT_PATH) $(BIN_PRODUCT_PATH)

	mkdir -p $(SHARE_PRODUCT_PATH)
	cp -R $(TEMPLATES_PATH)/. $(SHARE_PRODUCT_PATH)

uninstall:
	rm -rf $(BIN_PRODUCT_PATH)
	rm -rf $(SHARE_PRODUCT_PATH)

release: build
	mkdir -p $(RELEASE_PATH)
	cp -f $(PRODUCT_PATH) $(RELEASE_PATH)
	cp -r $(TEMPLATES_PATH) $(RELEASE_PATH)
	cp -f $(README_PATH) $(RELEASE_PATH)
	cp -f $(LICENSE_PATH) $(RELEASE_PATH)
	(cd $(RELEASE_PATH); zip -yr - $(PRODUCT_NAME) $(TEMPLATES_NAME) $(README_NAME) $(LICENSE_NAME)) > $(RELEASE_ZIP_PATH)

lint:
	swiftlint lint --quiet
