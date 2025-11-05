# New Computer; Who Dis

![Lint Code Base](https://github.com/ryanspoone/new-computer-who-dis/workflows/Lint%20Code%20Base/badge.svg)

Collection of personally helpful setup scripts and other information for setting up a new development machine.

## Usage

### MacOS Setup

**⚠️ Security Warning:** Always review scripts before running them, especially when piping curl to bash. Consider downloading and inspecting the script first.

#### Option 1: Review First (Recommended)

```bash
# Download and review the script
curl -fsSL https://raw.githubusercontent.com/ryanspoone/new-computer-who-dis/main/macos-setup.sh -o macos-setup.sh

# Review the contents
cat macos-setup.sh

# Make executable and run
chmod +x macos-setup.sh
./macos-setup.sh
```

#### Option 2: Direct Execution

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/ryanspoone/new-computer-who-dis/main/macos-setup.sh)"
```

### What Gets Installed

The setup script will prompt you for each section and includes:

- **Finder Configuration**: Show hidden files, path bar, status bar
- **Xcode Command Line Tools**: Required for development
- **Homebrew**: Package manager for macOS
- **Node.js & Yarn**: JavaScript runtime and package manager
- **Development Apps**: VS Code, Chrome, Firefox, iTerm2, Slack, and more
- **Fira Code Font**: Popular programming font with ligatures
- **SSH Keys**: Generates ED25519 keys for GitHub/GitLab
- **Git Configuration**: Sets up user name, email, and defaults

The script includes interactive prompts, so you can choose which components to install.
