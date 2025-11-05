# New Computer; Who Dis

![Lint Code Base](https://github.com/ryanspoone/new-computer-who-dis/workflows/Lint%20Code%20Base/badge.svg)

A comprehensive, modular setup script for configuring new macOS development machines. Get from unboxing to coding in under an hour with automated installation of tools, applications, and security configurations.

## Features

- **Modular Design** - Run only what you need
- **Security Hardened** - FileVault, firewall, and privacy settings
- **Complete Dev Environment** - Languages, tools, and databases
- **Customizable** - Configuration file support
- **Brewfile Support** - Declarative package management
- **Shell Enhancement** - Oh My Zsh or Starship prompt
- **VS Code Ready** - Extensions and settings pre-configured
- **Dotfiles Included** - Git, editor, and shell configs
- **Idempotent** - Safe to run multiple times
- **Logging** - Full execution logs for troubleshooting

## Quick Start

### Option 1: Review First (Recommended)

```bash
# Download the repository
git clone https://github.com/ryanspoone/new-computer-who-dis.git
cd new-computer-who-dis

# Review the scripts
cat macos-setup.sh
ls -la scripts/

# Run the setup
chmod +x macos-setup.sh
./macos-setup.sh
```

### Option 2: Direct Download and Run

**Security Warning:** Always review scripts before executing them!

```bash
# Download and run
curl -fsSL https://raw.githubusercontent.com/ryanspoone/new-computer-who-dis/main/macos-setup.sh -o macos-setup.sh
chmod +x macos-setup.sh
./macos-setup.sh
```

### Option 3: Automated with Configuration

```bash
# Clone repository
git clone https://github.com/ryanspoone/new-computer-who-dis.git
cd new-computer-who-dis

# Create configuration file
cp .setup-config.example .setup-config
# Edit .setup-config with your preferences

# Run with configuration
./macos-setup.sh --config .setup-config
```

## What Gets Installed

### System Configuration

- **Finder**: Show hidden files, path bar, status bar, file extensions
- **Dock**: Auto-hide, faster animations, optimized size
- **Keyboard**: Fast key repeat, disabled auto-correct/smart quotes
- **Trackpad**: Tap to click, three-finger drag
- **Screenshots**: Save to Downloads in PNG format

### Security

- macOS Firewall with stealth mode
- FileVault disk encryption
- Gatekeeper app verification
- Immediate password requirement after sleep
- Disabled guest account
- Automatic security updates
- Secure Safari settings

### Package Managers

- **Homebrew** - macOS package manager
- **Homebrew Bundle** - Declarative package management
- **mas** - Mac App Store CLI

### Development Languages

- Node.js (LTS) + npm + Yarn
- Python 3.11 + pip + pyenv
- Go
- Rust

### Databases

- PostgreSQL 15
- MySQL
- Redis
- SQLite

### Essential CLI Tools

- **Modern replacements**: bat, exa, ripgrep, fd, delta
- **Utilities**: jq, yq, tree, htop, fzf, tldr
- **Git**: git, gh (GitHub CLI)
- **Development**: docker, kubernetes-cli, terraform
- **Security**: gnupg, openssl

### Applications

**Browsers:**
- Google Chrome
- Firefox
- Brave Browser

**Development:**
- Visual Studio Code (with extensions)
- iTerm2
- Docker Desktop
- Postman
- TablePlus

**Productivity:**
- Slack
- Zoom
- Notion
- Rectangle (window management)
- Alfred

**Security:**
- 1Password / Authy

**Fonts:**
- Fira Code
- JetBrains Mono
- Hack Nerd Font

### Shell Configuration

- Zsh as default shell
- **Oh My Zsh** or **Starship** prompt
- Plugins: zsh-autosuggestions, zsh-syntax-highlighting
- Useful aliases for git, docker, npm, and more
- FZF fuzzy finder integration
- Environment variables pre-configured

### VS Code

**Extensions:**
- Language support: ESLint, Prettier, Python, Go, Rust
- Git: GitLens, Git Graph, GitHub PR
- Docker & Kubernetes
- Database tools
- Productivity: Error Lens, Path Intellisense, spell checker

**Settings:**
- Optimized font settings (Fira Code with ligatures)
- Format on save
- Recommended rulers and indentation
- Terminal integration

## Project Structure

```
.
├── macos-setup.sh              # Main orchestration script
├── macos-cleanup.sh            # Uninstall/cleanup script
├── Brewfile                    # Homebrew package definitions
├── .setup-config.example       # Configuration template
├── scripts/
│   ├── utils.sh               # Shared utility functions
│   ├── 01-system-preferences.sh
│   ├── 02-package-managers.sh
│   ├── 03-development-tools.sh
│   ├── 04-shell-setup.sh
│   ├── 05-security.sh
│   └── 06-vscode.sh
├── dotfiles/
│   ├── .gitconfig             # Git configuration template
│   ├── .gitignore_global      # Global gitignore
│   └── .editorconfig          # Editor configuration
├── .devcontainer/
│   ├── devcontainer.json      # VS Code dev container config
│   └── README.md
└── README.md
```

## Usage

### Interactive Mode

Run the main script and respond to prompts:

```bash
./macos-setup.sh
```

### Configuration File Mode

Create a configuration file to automate responses:

```bash
cp .setup-config.example .setup-config
# Edit .setup-config with your preferences
./macos-setup.sh --config .setup-config
```

### Run Individual Scripts

Execute specific setup modules:

```bash
# Just install packages
./scripts/02-package-managers.sh

# Just configure shell
./scripts/04-shell-setup.sh

# Just security hardening
./scripts/05-security.sh
```

### Help

```bash
./macos-setup.sh --help
```

## Customization

### Modifying Packages

Edit `Brewfile` to add/remove packages:

```ruby
# Add a new CLI tool
brew "neofetch"

# Add a new application
cask "figma"

# Add a font
cask "font-cascadia-code"
```

Then install:

```bash
brew bundle install
```

### Adding Custom Scripts

Create a new script in `scripts/`:

```bash
#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/utils.sh"

section "My Custom Setup"
log "Installing custom tools..."
# Your code here
```

Add it to the `SETUP_SCRIPTS` array in `macos-setup.sh`.

### Customizing Dotfiles

Templates are in `dotfiles/`. Copy and customize:

```bash
cp dotfiles/.gitconfig ~/.gitconfig
# Edit with your information
```

## Troubleshooting

### Logs

All output is logged to `~/.macos-setup.log`:

```bash
tail -f ~/.macos-setup.log
```

### Common Issues

**Homebrew not in PATH**
```bash
# For Apple Silicon
eval "$(/opt/homebrew/bin/brew shellenv)"

# For Intel
eval "$(/usr/local/bin/brew shellenv)"
```

**VS Code 'code' command not found**
- Open VS Code
- Press Cmd+Shift+P
- Type "shell command"
- Select "Install 'code' command in PATH"

**Permission denied**
```bash
chmod +x macos-setup.sh
chmod +x scripts/*.sh
```

**Script fails partway through**
- Check `~/.macos-setup.log` for errors
- Scripts are idempotent - safe to run again
- Run individual scripts from `scripts/` directory

## Uninstalling

To remove everything installed by this script:

```bash
chmod +x macos-cleanup.sh
./macos-cleanup.sh
```

**Warning:** This will remove applications and configurations!

## GitHub Codespaces / Dev Containers

This repository includes a dev container configuration:

### Using GitHub Codespaces

1. Click "Code" → "Create codespace on main"
2. Wait for container to build
3. Start developing in your browser

### Using VS Code Dev Containers

1. Install Docker Desktop
2. Install VS Code "Remote - Containers" extension
3. Open repository in VS Code
4. Click "Reopen in Container"

See `.devcontainer/README.md` for details.

## Requirements

- macOS 10.15 (Catalina) or later
- Administrator access
- Internet connection
- ~5-10 GB free disk space (for applications)

## Estimated Time

- Full setup: 30-60 minutes (depending on internet speed)
- Individual modules: 2-10 minutes each

## FAQ

**Q: Is this safe to run?**
A: Yes, but always review scripts before running. Everything is logged and changes can be reverted.

**Q: Can I run this on an existing system?**
A: Yes! Scripts are idempotent and won't break existing configurations.

**Q: What if I don't want everything?**
A: Use interactive mode and skip unwanted sections, or run individual scripts.

**Q: How do I update installed packages?**
A: Run `brew update && brew upgrade && brew cleanup`

**Q: Can I customize the packages?**
A: Yes! Edit `Brewfile` and run `brew bundle install`

**Q: Does this work on Intel and Apple Silicon Macs?**
A: Yes! The script detects architecture and configures appropriately.

## Contributing

Contributions welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Test your changes
4. Submit a pull request

## License

MIT License - see [LICENSE](LICENSE) for details.

## Credits

Created by [Ryan Spoone](https://github.com/ryanspoone)

Inspired by various dotfiles repositories and macOS setup scripts from the community.

## Related Projects

- [Homebrew](https://brew.sh/) - Package manager for macOS
- [Oh My Zsh](https://ohmyz.sh/) - Zsh configuration framework
- [Starship](https://starship.rs/) - Cross-shell prompt
- [mathiasbynens/dotfiles](https://github.com/mathiasbynens/dotfiles) - Sensible macOS defaults

## Support

- [Report issues](https://github.com/ryanspoone/new-computer-who-dis/issues)
- [Discussions](https://github.com/ryanspoone/new-computer-who-dis/discussions)
- Star this repo if you find it useful!

---

**Happy coding!**
