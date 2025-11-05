# Development Container

This repository includes a development container configuration for use with:
- **GitHub Codespaces** - Cloud-based development environment
- **VS Code Remote - Containers** - Local containerized development

## What's Included

- Ubuntu base image
- Node.js LTS
- Python 3.11
- Git & GitHub CLI
- Docker-in-Docker
- Zsh with Oh My Zsh
- Essential VS Code extensions

## Usage

### GitHub Codespaces

1. Click "Code" → "Create codespace on main"
2. Wait for the container to build
3. Start developing in your browser or VS Code

### Local Development with VS Code

1. Install [Docker Desktop](https://www.docker.com/products/docker-desktop)
2. Install [VS Code](https://code.visualstudio.com/)
3. Install the [Remote - Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extension
4. Open this repository in VS Code
5. Click "Reopen in Container" when prompted

## Customization

Edit `.devcontainer/devcontainer.json` to:
- Add more features or tools
- Install additional VS Code extensions
- Configure port forwarding
- Customize post-creation commands
