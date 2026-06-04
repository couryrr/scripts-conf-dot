UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
  OS_DIR := macos
  OS_PACKAGES := env shell
else
  OS_DIR := linux
  OS_PACKAGES := env
endif

COMMON_DIR := common
COMMON_PACKAGES := config local shell claude
STOW_TARGET := $(HOME)

.PHONY: install uninstall restow clean brew

install:
	stow --no-folding -t $(STOW_TARGET) -d $(COMMON_DIR) $(COMMON_PACKAGES)
	stow --no-folding -t $(STOW_TARGET) -d $(OS_DIR) $(OS_PACKAGES)
uninstall:
	stow --no-folding -t $(STOW_TARGET) -d $(COMMON_DIR) -D $(COMMON_PACKAGES)
	stow --no-folding -t $(STOW_TARGET) -d $(OS_DIR) -D $(OS_PACKAGES)
restow:
	stow --no-folding -t $(STOW_TARGET) -d $(COMMON_DIR) -R $(COMMON_PACKAGES)
	stow --no-folding -t $(STOW_TARGET) -d $(OS_DIR) -R $(OS_PACKAGES)
clean:
	stow --no-folding -t $(STOW_TARGET) -d $(COMMON_DIR) -D $(COMMON_PACKAGES) || true
	stow --no-folding -t $(STOW_TARGET) -d $(OS_DIR) -D $(OS_PACKAGES) || true
brew:
	brew bundle --file=$(OS_DIR)/Brewfile
