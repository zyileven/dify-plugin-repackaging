# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Dify plugin repackaging tool that downloads and repackages plugins for offline installation. The tool supports downloading plugins from three sources: Dify Marketplace, GitHub releases, and local files. It repackages them with their Python dependencies for offline installation.

## Core Architecture

- `plugin_repackaging.sh` - Main bash script that handles downloading, unpacking, dependency installation, and repackaging
- `dify-plugin-*-5g` - Platform-specific Dify plugin CLI binaries (Linux/macOS, AMD64/ARM64)
- `Dockerfile` - Containerized execution environment with Python 3.12

## Key Operations

### Running the Tool

**Docker execution (recommended):**
```bash
# Build container
docker build -t dify-plugin-repackaging .

# Run (Linux/macOS)
docker run -v $(pwd):/app dify-plugin-repackaging

# Run (Windows)
docker run -v %cd%:/app dify-plugin-repackaging

# Override default command
docker run -v $(pwd):/app dify-plugin-repackaging ./plugin_repackaging.sh -p manylinux_2_17_x86_64 market antv visualization 0.1.7
```

**Direct execution:**
```bash
# From Dify Marketplace
./plugin_repackaging.sh market [author] [name] [version]

# From GitHub
./plugin_repackaging.sh github [repo] [release] [asset.difypkg]

# From local file
./plugin_repackaging.sh local [path/to/plugin.difypkg]

# Cross-platform repackaging
./plugin_repackaging.sh -p manylinux_2_17_x86_64 market [author] [name] [version]
```

### GitHub Actions

Manual workflow trigger for repackaging plugins with inputs for author, name, and version. Outputs repackaged artifacts.

## Platform Support

- **Operating Systems**: Linux (amd64/aarch64), macOS (x86_64/arm64)
- **Python Version**: 3.12.x (matches dify-plugin-daemon)
- **Cross-platform**: Uses pip platform tags for building packages for different target platforms

## Important Notes

- The script uses `yum` for installing `unzip` (RPM-based Linux systems only)
- For other Linux distributions, install `unzip` manually before running
- Uses `.difyignore` if available, falls back to `.gitignore` for package exclusions
- Automatically detects architecture and selects appropriate Dify CLI binary
- Dependencies are downloaded to `./wheels/` directory and requirements.txt is modified for offline installation

## Environment Variables

- `GITHUB_API_URL` - GitHub API base URL (default: https://github.com)
- `MARKETPLACE_API_URL` - Dify Marketplace API URL (default: https://marketplace.dify.ai)  
- `PIP_MIRROR_URL` - PyPI mirror URL (default: https://mirrors.aliyun.com/pypi/simple)