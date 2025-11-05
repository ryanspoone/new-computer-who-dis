#!/bin/bash
# VS Code Configuration
# Installs extensions and configures VS Code settings

set -euo pipefail

source "$(dirname "$0")/utils.sh"

section "VS Code Setup"

# Check if VS Code is installed
if ! command_exists code; then
    warn "VS Code is not installed or 'code' command is not in PATH"
    if confirm "Would you like to install VS Code?"; then
        brew install --cask visual-studio-code
        success "VS Code installed"
        log "You may need to restart your terminal for 'code' command to work"
    else
        warn "Skipping VS Code configuration"
        exit 0
    fi
fi

### Install Extensions ###
if confirm "Install recommended VS Code extensions?"; then
    log "Installing VS Code extensions..."

    # Language Support
    code --install-extension dbaeumer.vscode-eslint
    code --install-extension esbenp.prettier-vscode
    code --install-extension ms-python.python
    code --install-extension ms-python.vscode-pylance
    code --install-extension golang.go
    code --install-extension rust-lang.rust-analyzer

    # Frameworks
    code --install-extension bradlc.vscode-tailwindcss
    code --install-extension Vue.volar
    code --install-extension svelte.svelte-vscode

    # Git & Version Control
    code --install-extension eamodio.gitlens
    code --install-extension mhutchie.git-graph
    code --install-extension GitHub.vscode-pull-request-github

    # Docker & Containers
    code --install-extension ms-azuretools.vscode-docker
    code --install-extension ms-vscode-remote.remote-containers
    code --install-extension ms-kubernetes-tools.vscode-kubernetes-tools

    # Database
    code --install-extension mtxr.sqltools
    code --install-extension mongodb.mongodb-vscode

    # Productivity
    code --install-extension usernamehw.errorlens
    code --install-extension christian-kohler.path-intellisense
    code --install-extension formulahendry.auto-rename-tag
    code --install-extension formulahendry.auto-close-tag
    code --install-extension streetsidesoftware.code-spell-checker

    # Themes & Icons
    code --install-extension PKief.material-icon-theme
    code --install-extension GitHub.github-vscode-theme
    code --install-extension zhuangtongfa.material-theme

    # Markdown & Documentation
    code --install-extension yzhang.markdown-all-in-one
    code --install-extension bierner.markdown-mermaid

    # Other Useful Extensions
    code --install-extension EditorConfig.EditorConfig
    code --install-extension dotenv.dotenv-vscode
    code --install-extension humao.rest-client
    code --install-extension wayou.vscode-todo-highlight

    success "VS Code extensions installed"
fi

### Configure Settings ###
if confirm "Apply recommended VS Code settings?"; then
    log "Configuring VS Code settings..."

    VSCODE_SETTINGS_DIR="$HOME/Library/Application Support/Code/User"
    mkdir -p "$VSCODE_SETTINGS_DIR"

    SETTINGS_FILE="$VSCODE_SETTINGS_DIR/settings.json"

    # Backup existing settings
    if [[ -f "$SETTINGS_FILE" ]]; then
        backup_file "$SETTINGS_FILE"
    fi

    # Create settings.json
    cat > "$SETTINGS_FILE" << 'EOF'
{
  // Editor
  "editor.fontSize": 14,
  "editor.fontFamily": "'Fira Code', 'JetBrains Mono', Menlo, Monaco, 'Courier New', monospace",
  "editor.fontLigatures": true,
  "editor.lineHeight": 22,
  "editor.tabSize": 2,
  "editor.insertSpaces": true,
  "editor.detectIndentation": true,
  "editor.formatOnSave": true,
  "editor.formatOnPaste": true,
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": "explicit",
    "source.organizeImports": "explicit"
  },
  "editor.minimap.enabled": true,
  "editor.rulers": [80, 120],
  "editor.renderWhitespace": "boundary",
  "editor.bracketPairColorization.enabled": true,
  "editor.guides.bracketPairs": true,
  "editor.suggestSelection": "first",
  "editor.quickSuggestions": {
    "strings": true
  },

  // Files
  "files.autoSave": "onFocusChange",
  "files.exclude": {
    "**/.git": true,
    "**/.DS_Store": true,
    "**/node_modules": true,
    "**/__pycache__": true,
    "**/.pytest_cache": true
  },
  "files.watcherExclude": {
    "**/.git/objects/**": true,
    "**/node_modules/**": true
  },
  "files.trimTrailingWhitespace": true,
  "files.insertFinalNewline": true,

  // Workbench
  "workbench.colorTheme": "GitHub Dark Default",
  "workbench.iconTheme": "material-icon-theme",
  "workbench.startupEditor": "newUntitledFile",
  "workbench.editor.enablePreview": false,

  // Terminal
  "terminal.integrated.fontSize": 13,
  "terminal.integrated.fontFamily": "'Hack Nerd Font', 'Fira Code', Menlo",
  "terminal.integrated.defaultProfile.osx": "zsh",
  "terminal.integrated.cursorBlinking": true,

  // Git
  "git.autofetch": true,
  "git.confirmSync": false,
  "git.enableSmartCommit": true,
  "gitlens.codeLens.enabled": false,

  // Language-specific settings
  "[javascript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[typescript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[json]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[html]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[css]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[python]": {
    "editor.defaultFormatter": "ms-python.python",
    "editor.formatOnSave": true
  },
  "[markdown]": {
    "editor.wordWrap": "on",
    "editor.quickSuggestions": {
      "comments": "off",
      "strings": "off",
      "other": "off"
    }
  },

  // Prettier
  "prettier.semi": true,
  "prettier.singleQuote": true,
  "prettier.trailingComma": "es5",
  "prettier.printWidth": 80,

  // ESLint
  "eslint.validate": [
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact"
  ],

  // Python
  "python.linting.enabled": true,
  "python.linting.pylintEnabled": true,
  "python.formatting.provider": "black",

  // Other
  "explorer.confirmDelete": false,
  "explorer.confirmDragAndDrop": false,
  "security.workspace.trust.enabled": false,
  "telemetry.telemetryLevel": "off"
}
EOF

    success "VS Code settings configured"
fi

### Configure Keybindings ###
if confirm "Apply custom keybindings?"; then
    KEYBINDINGS_FILE="$VSCODE_SETTINGS_DIR/keybindings.json"

    if [[ -f "$KEYBINDINGS_FILE" ]]; then
        backup_file "$KEYBINDINGS_FILE"
    fi

    cat > "$KEYBINDINGS_FILE" << 'EOF'
[
  // Toggle terminal
  {
    "key": "ctrl+`",
    "command": "workbench.action.terminal.toggleTerminal"
  },
  // Quick open file
  {
    "key": "cmd+p",
    "command": "workbench.action.quickOpen"
  },
  // Format document
  {
    "key": "shift+alt+f",
    "command": "editor.action.formatDocument"
  },
  // Duplicate line
  {
    "key": "shift+alt+down",
    "command": "editor.action.copyLinesDownAction"
  },
  {
    "key": "shift+alt+up",
    "command": "editor.action.copyLinesUpAction"
  }
]
EOF

    success "Keybindings configured"
fi

### Install Code Snippets ###
if confirm "Install useful code snippets?"; then
    SNIPPETS_DIR="$VSCODE_SETTINGS_DIR/snippets"
    mkdir -p "$SNIPPETS_DIR"

    # JavaScript/TypeScript snippets
    cat > "$SNIPPETS_DIR/javascript.json" << 'EOF'
{
  "Console log": {
    "prefix": "clg",
    "body": ["console.log('$1', $1);"],
    "description": "Console log with label"
  },
  "Arrow Function": {
    "prefix": "af",
    "body": ["const $1 = ($2) => {", "  $3", "}"],
    "description": "Arrow function"
  },
  "Async Arrow Function": {
    "prefix": "aaf",
    "body": ["const $1 = async ($2) => {", "  $3", "}"],
    "description": "Async arrow function"
  },
  "Try Catch": {
    "prefix": "tryc",
    "body": ["try {", "  $1", "} catch (error) {", "  console.error(error);", "  $2", "}"],
    "description": "Try catch block"
  }
}
EOF

    success "Code snippets installed"
fi

success "VS Code setup complete!"
log "Restart VS Code to apply all changes"
