# DANTO AI Trading System - Installation Guide

## 🚀 Single-Command Installation (Recommended)

### Quick Setup
The easiest way to install DANTO is using our single-command installer:

```bash
curl -sSL https://raw.githubusercontent.com/somdipto/DANTO/main/install.sh | bash
```

This command will:
- Check your system for required dependencies
- Install missing dependencies (Docker, Go, Node.js, Git)
- Clone the DANTO repository
- Set up configuration files
- Build and start all services using Docker

### Alternative Installation Method
If you prefer to download the script first:

```bash
# Download the installation script
curl -sSL https://raw.githubusercontent.com/somdipto/DANTO/main/install.sh -o install.sh

# Make it executable
chmod +x install.sh

# Run the installation
./install.sh
```

## 🔧 What the Installation Script Does

### 1. System Detection
- Detects your operating system (Linux/macOS)
- Checks for required dependencies (Docker, Go, Node.js, Git)

### 2. Dependency Installation
- **Docker**: If not installed, installs Docker
- **Docker Compose**: If not available, installs Docker Compose
- **Go**: Installs Go 1.25 (required for backend compilation)
- **Node.js**: Installs Node.js 20 (required for frontend build)
- **Git**: Installs Git if needed for cloning

### 3. Project Setup
- Clones the DANTO repository if not already in the project directory
- Creates configuration files from templates (`.env`, `config.json`)
- Builds Docker images for both backend and frontend
- Starts all services using Docker Compose

### 4. Post-Installation
- Provides access URLs for the web interface and API
- Shows commands for managing services
- Provides next steps for configuration

## 🖥️ Supported Operating Systems

- **Linux**: Ubuntu, Debian, CentOS, Fedora, Arch Linux
- **macOS**: With Homebrew installed

## ⚙️ Manual Installation Requirements

If you prefer manual installation, ensure you have:

- **Go**: Version 1.21 or higher
- **Node.js**: Version 18 or higher
- **Docker**: Version 20.10 or higher
- **Docker Compose**: Version 2.0 or higher
- **Git**: Any recent version
- **TA-Lib**: C library for technical analysis (usually installed in Docker)

## 🌐 Access After Installation

Once the installation is complete, you can access:

- **Web Interface**: http://localhost:3000
- **Backend API**: http://localhost:8080
- **Health Check**: http://localhost:8080/health

## 🔐 Configuration

After installation, you should:

1. Edit `config.json` to add your exchange API keys
2. Configure your AI provider credentials
3. Set up your trading parameters and initial balances

## 🛠️ Managing Your Installation

### View Logs
```bash
# View all logs
docker compose logs -f

# View specific service logs
docker compose logs -f danto
docker compose logs -f danto-frontend
```

### Stop Services
```bash
docker compose down
```

### Restart Services
```bash
docker compose up -d
```

### Rebuild and Restart
```bash
docker compose up -d --build
```

## 🐛 Troubleshooting

### Docker Permission Issues
If you encounter Docker permission errors, add your user to the docker group:
```bash
sudo usermod -aG docker $USER
```
Then log out and log back in, or run:
```bash
newgrp docker
```

### Port Conflicts
If ports 8080 or 3000 are already in use, update the `.env` file to use different ports.

### Installation Script Errors
- Make sure you have an active internet connection
- Ensure your system has enough disk space (at least 2GB free)
- Check that no other Docker containers are using the required ports

## 📋 Post-Installation Checklist

- [ ] Verify all services are running: `docker compose ps`
- [ ] Access the web interface at http://localhost:3000
- [ ] Check the API at http://localhost:8080/health
- [ ] Edit `config.json` to add your API keys
- [ ] Configure your trading strategies
- [ ] Review the documentation in the repository

## 🆘 Support

If you encounter issues during installation:

1. Check the [FAQ](README.md#faq) section in the main README
2. Review the [Troubleshooting](README.md#-troubleshooting) section
3. Join our [Telegram community](https://t.me/nofx_dev_community) for support
4. Open an [issue](https://github.com/somdipto/DANTO/issues) on GitHub