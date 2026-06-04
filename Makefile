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

.PHONY: install uninstall restow clean brew vscode vscode-pull hooks

# VSCode User settings live on the Windows host under WSL. They are deployed by
# copy (not stow): VSCode on Windows can't reliably follow a symlink into the
# WSL filesystem. Override the destination with VSCODE_USER=/path if autodetect
# fails (e.g. native Linux: ~/.config/Code/User).
define VSCODE_DIR
$${VSCODE_USER:-$$(wslpath "$$(cmd.exe /c 'echo %USERPROFILE%' 2>/dev/null | tr -d '\r')" 2>/dev/null)/AppData/Roaming/Code/User}
endef

install: hooks
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

# Point git at the repo's tracked hooks (core.hooksPath is per-clone config).
hooks:
	git config core.hooksPath .githooks
	@echo "git hooks -> .githooks"

# Deploy repo VSCode settings to the editor's User dir.
vscode:
	@dir="$(VSCODE_DIR)"; \
	test -d "$$dir" || { echo "VSCode User dir not found: $$dir (set VSCODE_USER=...)"; exit 1; }; \
	cp vscode/settings.json "$$dir/settings.json"; \
	cp vscode/keybindings.json "$$dir/keybindings.json"; \
	echo "Deployed VSCode settings -> $$dir"

# Capture the editor's current VSCode settings back into the repo.
vscode-pull:
	@dir="$(VSCODE_DIR)"; \
	test -d "$$dir" || { echo "VSCode User dir not found: $$dir (set VSCODE_USER=...)"; exit 1; }; \
	cp "$$dir/settings.json" vscode/settings.json; \
	cp "$$dir/keybindings.json" vscode/keybindings.json; \
	echo "Pulled VSCode settings <- $$dir"
