#!/bin/bash

# ═══════════════════════════════════════════════════════════════
# DANTO AI Trading System - Single Command Installation Script
# Usage: curl -sSL https://raw.githubusercontent.com/somdipto/DANTO/main/install.sh | bash
# Or: wget -qO- https://raw.githubusercontent.com/somdipto/DANTO/main/install.sh | bash
# ═══════════════════════════════════════════════════════════════

set -e  # Exit on any error

# ------------------------------------------------------------------------
# Color Definitions
# ------------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ------------------------------------------------------------------------
# Utility Functions: Colored Output
# ------------------------------------------------------------------------
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# ------------------------------------------------------------------------
# OS Detection
# ------------------------------------------------------------------------
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    else
        print_error "Unsupported operating system: $OSTYPE"
        exit 1
    fi
    print_info "Detected OS: $OS"
}

# ------------------------------------------------------------------------
# Check if running inside the Danto project directory
# ------------------------------------------------------------------------
check_project_dir() {
    if [[ -f "go.mod" && -f "main.go" && -f "docker-compose.yml" ]]; then
        INSIDE_PROJECT=true
        PROJECT_ROOT=$(pwd)
        print_info "Running inside Danto project directory: $PROJECT_ROOT"
    else
        INSIDE_PROJECT=false
        print_info "Not inside Danto project directory, will clone repository"
    fi
}

# ------------------------------------------------------------------------
# Dependency Checks
# ------------------------------------------------------------------------
check_dependencies() {
    print_info "Checking system dependencies..."
    
    # Check for Git
    if command -v git &> /dev/null; then
        print_info "Git: ✓"
        GIT_AVAILABLE=true
    else
        print_warning "Git: Not found"
        GIT_AVAILABLE=false
    fi
    
    # Check for Docker
    if command -v docker &> /dev/null; then
        print_info "Docker: ✓"
        DOCKER_AVAILABLE=true
    else
        print_warning "Docker: Not found"
        DOCKER_AVAILABLE=false
    fi
    
    # Check for Docker Compose
    if command -v docker compose &> /dev/null || command -v docker-compose &> /dev/null; then
        print_info "Docker Compose: ✓"
        DOCKER_COMPOSE_AVAILABLE=true
    else
        print_warning "Docker Compose: Not found"
        DOCKER_COMPOSE_AVAILABLE=false
    fi
    
    # Check for Go
    if command -v go &> /dev/null; then
        GO_VERSION=$(go version | cut -d ' ' -f 3 | sed 's/go//')
        GO_MAJOR=$(echo $GO_VERSION | cut -d. -f1)
        GO_MINOR=$(echo $GO_VERSION | cut -d. -f2)
        
        if ((GO_MAJOR >= 1 && GO_MINOR >= 21)); then
            print_info "Go $GO_VERSION: ✓"
            GO_AVAILABLE=true
        else
            print_warning "Go $GO_VERSION: Unsupported version (need 1.21+)"
            GO_AVAILABLE=false
        fi
    else
        print_warning "Go: Not found"
        GO_AVAILABLE=false
    fi
    
    # Check for Node.js
    if command -v node &> /dev/null; then
        NODE_VERSION=$(node --version | sed 's/v//')
        NODE_MAJOR=$(echo $NODE_VERSION | cut -d. -f1)
        
        if [[ $NODE_MAJOR -ge 18 ]]; then
            print_info "Node.js $NODE_VERSION: ✓"
            NODE_AVAILABLE=true
        else
            print_warning "Node.js $NODE_VERSION: Unsupported version (need 18+)"
            NODE_AVAILABLE=false
        fi
    else
        print_warning "Node.js: Not found"
        NODE_AVAILABLE=false
    fi
    
    # Check for required tools for installation
    if [[ $OS == "linux" ]]; then
        if ! command -v curl &> /dev/null && ! command -v wget &> /dev/null; then
            print_error "curl or wget required to download packages"
            exit 1
        fi
    fi
}

# ------------------------------------------------------------------------
# Install Git
# ------------------------------------------------------------------------
install_git() {
    if [[ $GIT_AVAILABLE == false ]]; then
        print_info "Installing Git..."
        
        if [[ $OS == "linux" ]]; then
            if command -v apt-get &> /dev/null; then
                sudo apt-get update && sudo apt-get install -y git
            elif command -v yum &> /dev/null; then
                sudo yum install -y git
            elif command -v dnf &> /dev/null; then
                sudo dnf install -y git
            elif command -v pacman &> /dev/null; then
                sudo pacman -Sy git
            else
                print_error "Unsupported package manager"
                exit 1
            fi
        elif [[ $OS == "macos" ]]; then
            if command -v brew &> /dev/null; then
                brew install git
            else
                print_error "Homebrew required to install Git on macOS. Please install Homebrew first."
                exit 1
            fi
        fi
        
        # Verify installation
        if command -v git &> /dev/null; then
            print_success "Git installed successfully"
            GIT_AVAILABLE=true
        else
            print_error "Failed to install Git"
            exit 1
        fi
    fi
}

# ------------------------------------------------------------------------
# Install Docker
# ------------------------------------------------------------------------
install_docker() {
    if [[ $DOCKER_AVAILABLE == false ]]; then
        print_info "Installing Docker..."
        
        if [[ $OS == "linux" ]]; then
            # Install Docker using the convenience script
            curl -fsSL https://get.docker.com -o get-docker.sh
            sh get-docker.sh
            rm get-docker.sh
            
            # Add current user to docker group
            sudo usermod -aG docker $USER
            
            # Start Docker service
            sudo systemctl start docker
            sudo systemctl enable docker
        elif [[ $OS == "macos" ]]; then
            print_error "Please install Docker Desktop for macOS manually from https://www.docker.com/products/docker-desktop"
            exit 1
        fi
        
        # Verify installation
        if command -v docker &> /dev/null; then
            print_success "Docker installed successfully"
            DOCKER_AVAILABLE=true
        else
            print_error "Failed to install Docker"
            exit 1
        fi
    fi
}

# ------------------------------------------------------------------------
# Install Docker Compose
# ------------------------------------------------------------------------
install_docker_compose() {
    if [[ $DOCKER_COMPOSE_AVAILABLE == false ]]; then
        print_info "Installing Docker Compose..."
        
        if [[ $OS == "linux" ]]; then
            DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
            mkdir -p $DOCKER_CONFIG/plugins
            LATEST_COMPOSE_VERSION=$(curl -sL https://api.github.com/repos/docker/compose/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
            DOCKER_PLUGIN_PATH=$DOCKER_CONFIG/plugins/docker-compose
            curl -SL "https://github.com/docker/compose/releases/download/${LATEST_COMPOSE_VERSION}/docker-compose-linux-$(uname -m)" -o $DOCKER_PLUGIN_PATH
            chmod +x $DOCKER_PLUGIN_PATH
        elif [[ $OS == "macos" ]]; then
            # On macOS, Docker Desktop includes Docker Compose
            print_info "Please install Docker Desktop for macOS which includes Docker Compose: https://www.docker.com/products/docker-desktop"
            exit 1
        fi
        
        # Verify installation
        if command -v docker compose &> /dev/null || command -v docker-compose &> /dev/null; then
            print_success "Docker Compose installed successfully"
            DOCKER_COMPOSE_AVAILABLE=true
        else
            print_error "Failed to install Docker Compose"
            exit 1
        fi
    fi
}

# ------------------------------------------------------------------------
# Install Go
# ------------------------------------------------------------------------
install_go() {
    if [[ $GO_AVAILABLE == false ]]; then
        print_info "Installing Go..."
        
        if [[ $OS == "linux" ]]; then
            # Download and install Go
            GO_VERSION_DOWNLOAD="1.25.0"
            curl -LO "https://golang.org/dl/go${GO_VERSION_DOWNLOAD}.linux-amd64.tar.gz"
            sudo rm -rf /usr/local/go
            sudo tar -C /usr/local -xzf go${GO_VERSION_DOWNLOAD}.linux-amd64.tar.gz
            rm go${GO_VERSION_DOWNLOAD}.linux-amd64.tar.gz
            
            # Add to PATH for current session
            export PATH=$PATH:/usr/local/go/bin
            
            # Add to PATH permanently if not already there
            if [[ -f ~/.bashrc ]]; then
                if ! grep -q "/usr/local/go/bin" ~/.bashrc; then
                    echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
                fi
            elif [[ -f ~/.zshrc ]]; then
                if ! grep -q "/usr/local/go/bin" ~/.zshrc; then
                    echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.zshrc
                fi
            fi
        elif [[ $OS == "macos" ]]; then
            if command -v brew &> /dev/null; then
                brew install go
            else
                print_error "Homebrew required to install Go on macOS. Please install Homebrew first."
                exit 1
            fi
        fi
        
        # Verify installation
        if command -v go &> /dev/null; then
            print_success "Go installed successfully"
            GO_AVAILABLE=true
        else
            print_error "Failed to install Go"
            exit 1
        fi
    fi
}

# ------------------------------------------------------------------------
# Install Node.js
# ------------------------------------------------------------------------
install_nodejs() {
    if [[ $NODE_AVAILABLE == false ]]; then
        print_info "Installing Node.js..."
        
        if [[ $OS == "linux" ]]; then
            # Install Node.js using the official installation script
            curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
            sudo apt-get install -y nodejs
        elif [[ $OS == "macos" ]]; then
            if command -v brew &> /dev/null; then
                brew install node
            else
                print_error "Homebrew required to install Node.js on macOS. Please install Homebrew first."
                exit 1
            fi
        fi
        
        # Verify installation
        if command -v node &> /dev/null; then
            print_success "Node.js installed successfully"
            NODE_AVAILABLE=true
        else
            print_error "Failed to install Node.js"
            exit 1
        fi
    fi
}

# ------------------------------------------------------------------------
# Clone Danto repository if not already in project directory
# ------------------------------------------------------------------------
clone_danto() {
    if [[ $INSIDE_PROJECT == false ]]; then
        print_info "Cloning Danto repository..."
        
        if [[ $GIT_AVAILABLE == false ]]; then
            print_error "Git is required to clone the repository. Please install Git first."
            exit 1
        fi
        
        # Clone the repository to a new directory
        git clone https://github.com/somdipto/DANTO.git danto-install
        cd danto-install
        PROJECT_ROOT=$(pwd)
        print_success "Repository cloned successfully"
    else
        PROJECT_ROOT=$(pwd)
    fi
}

# ------------------------------------------------------------------------
# Create environment files from templates if they don't exist
# ------------------------------------------------------------------------
setup_env_files() {
    print_info "Setting up environment files..."
    
    # Create .env from .env.example if it doesn't exist
    if [[ ! -f ".env" ]]; then
        if [[ -f ".env.example" ]]; then
            cp .env.example .env
            print_success ".env file created from example"
        else
            print_warning ".env.example not found, skipping"
        fi
    fi
    
    # Create config.json from config.json.example if it doesn't exist
    if [[ ! -f "config.json" ]]; then
        if [[ -f "config.json.example" ]]; then
            cp config.json.example config.json
            print_success "config.json created from example"
        else
            print_warning "config.json.example not found, skipping"
        fi
    fi
}

# ------------------------------------------------------------------------
# Build and start Docker services
# ------------------------------------------------------------------------
start_docker_services() {
    print_info "Starting Danto services with Docker Compose..."
    
    # Check if docker compose command is available
    if command -v docker compose &> /dev/null; then
        COMPOSE_CMD="docker compose"
    elif command -v docker-compose &> /dev/null; then
        COMPOSE_CMD="docker-compose"
    else
        print_error "Docker Compose not found after installation attempt"
        exit 1
    fi
    
    # Start services with build
    $COMPOSE_CMD up -d --build
    
    # Wait a bit for services to start
    sleep 10
    
    # Check if services are running
    $COMPOSE_CMD ps
    
    print_success "Danto services are now running!"
    print_info "Web Interface: http://localhost:3000"
    print_info "API Endpoint: http://localhost:8080"
    print_info ""
    print_info "To view logs: $COMPOSE_CMD logs -f"
    print_info "To stop services: $COMPOSE_CMD down"
    print_info ""
    print_info "Configuration files:"
    print_info "- Edit .env to configure environment variables"
    print_info "- Edit config.json to configure API keys and traders"
}

# ------------------------------------------------------------------------
# Main Installation Process
# ------------------------------------------------------------------------
main() {
    print_info "🚀 Starting DANTO AI Trading System installation..."
    echo ""
    
    detect_os
    check_project_dir
    check_dependencies
    
    print_info "Installing required dependencies..."
    
    install_git
    install_docker
    install_docker_compose
    install_go
    install_nodejs
    
    clone_danto
    setup_env_files
    start_docker_services
    
    print_info ""
    print_success "🎉 DANTO AI Trading System installation completed successfully!"
    print_info ""
    print_info "Next steps:"
    print_info "1. Edit config.json to add your API keys and configure traders"
    print_info "2. Visit http://localhost:3000 to access the dashboard"
    echo ""
}

# Execute Main
main "$@"