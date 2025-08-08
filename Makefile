STOW_PACKAGES := shell .config .local
STOW_TARGET := $(HOME)
STOW_DIR := linux

.PHONY: install uninstall restow clean

install:
   stow --no-folding -t $(STOW_TARGET) -d $(STOW_DIR) $(STOW_PACKAGES)

uninstall:
   stow --no-folding -t $(STOW_TARGET) -d $(STOW_DIR) -D $(STOW_PACKAGES)

restow:
   stow --no-folding -t $(STOW_TARGET) -d $(STOW_DIR) -R $(STOW_PACKAGES)

clean:
   stow --no-folding -t $(STOW_TARGET) -d $(STOW_DIR) -D $(STOW_PACKAGES) || true
