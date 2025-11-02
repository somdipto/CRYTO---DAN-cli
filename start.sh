#!/bin/bash

# ═══════════════════════════════════════════════════════════════
# DANTO AI Trading System - Docker Quick Start Script
# Usage: ./start.sh [command]
# ═══════════════════════════════════════════════════════════════

set -e

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
# Detection: Docker Compose Command (Backward Compatible)
# ------------------------------------------------------------------------
detect_compose_cmd() {
    if command -v docker compose &> /dev/null; then
        COMPOSE_CMD="docker compose"
    elif command -v docker-compose &> /dev/null; then
        COMPOSE_CMD="docker-compose"
    else
        print_error "Docker Compose not installed! Please install Docker Compose first"
        exit 1
    fi
    print_info "Using Docker Compose command: $COMPOSE_CMD"
}

# ------------------------------------------------------------------------
# Validation: Docker Installation
# ------------------------------------------------------------------------
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker not installed! Please install Docker: https://docs.docker.com/get-docker/"
        exit 1
    fi

    detect_compose_cmd
    print_success "Docker and Docker Compose are installed"
}

# ------------------------------------------------------------------------
# Validation: Environment File (.env)
# ------------------------------------------------------------------------
check_env() {
    if [ ! -f ".env" ]; then
        print_warning ".env file not found, copying from template..."
        cp .env.example .env
        print_info "Please edit .env file to configure your environment variables"
        print_info "Run: nano .env or use another editor"
        exit 1
    fi
    print_success "Environment file exists"
}

# ------------------------------------------------------------------------
# Validation: Configuration File (config.json)
# ------------------------------------------------------------------------
check_config() {
    if [ ! -f "config.json" ]; then
        print_warning "config.json not found, copying from template..."
        cp config.json.example config.json
        print_info "Please edit config.json to configure your API keys"
        print_info "Run: nano config.json or use another editor"
        exit 1
    fi
    print_success "Configuration file exists"
}

# ------------------------------------------------------------------------
# Build: Frontend (Node.js Based)
# ------------------------------------------------------------------------
# build_frontend() {
#     print_info "检查前端构建环境..."

#     if ! command -v node &> /dev/null; then
#         print_error "Node.js 未安装！请先安装 Node.js"
#         exit 1
#     fi

#     if ! command -v npm &> /dev/null; then
#         print_error "npm 未安装！请先安装 npm"
#         exit 1
#     fi

#     print_info "正在构建前端..."
#     cd web

#     print_info "安装 Node.js 依赖..."
#     npm install

#     print_info "构建前端应用..."
#     npm run build

#     cd ..
#     print_success "前端构建完成"
# }

# ------------------------------------------------------------------------
# Service Management: Start
# ------------------------------------------------------------------------
start() {
    print_info "Starting DANTO AI Trading System..."

    # Auto-build frontend if missing or forced
    # if [ ! -d "web/dist" ] || [ "$1" == "--build" ]; then
    #     build_frontend
    # fi

    # Rebuild images if flag set
    if [ "$1" == "--build" ]; then
        print_info "Rebuilding images..."
        $COMPOSE_CMD up -d --build
    else
        print_info "Starting containers..."
        $COMPOSE_CMD up -d
    fi

    print_success "Services started!"
    print_info "Web Interface: http://localhost:3000"
    print_info "API Endpoint: http://localhost:8080"
    print_info ""
    print_info "View logs: ./start.sh logs"
    print_info "Stop services: ./start.sh stop"
}

# ------------------------------------------------------------------------
# Service Management: Stop
# ------------------------------------------------------------------------
stop() {
    print_info "Stopping services..."
    $COMPOSE_CMD stop
    print_success "Services stopped"
}

# ------------------------------------------------------------------------
# Service Management: Restart
# ------------------------------------------------------------------------
restart() {
    print_info "Restarting services..."
    $COMPOSE_CMD restart
    print_success "Services restarted"
}

# ------------------------------------------------------------------------
# Monitoring: Logs
# ------------------------------------------------------------------------
logs() {
    if [ -z "$2" ]; then
        $COMPOSE_CMD logs -f
    else
        $COMPOSE_CMD logs -f "$2"
    fi
}

# ------------------------------------------------------------------------
# Monitoring: Status
# ------------------------------------------------------------------------
status() {
    print_info "Service status:"
    $COMPOSE_CMD ps
    echo ""
    print_info "Health check:"
    curl -s http://localhost:8080/health | jq '.' || echo "Backend not responding"
}

# ------------------------------------------------------------------------
# Maintenance: Clean (Destructive)
# ------------------------------------------------------------------------
clean() {
    print_warning "This will delete all containers and data!"
    read -p "Confirm deletion? (yes/no): " confirm
    if [ "$confirm" == "yes" ]; then
        print_info "Cleaning up..."
        $COMPOSE_CMD down -v
        print_success "Cleanup completed"
    else
        print_info "Cancelled"
    fi
}

# ------------------------------------------------------------------------
# Maintenance: Update
# ------------------------------------------------------------------------
update() {
    print_info "Updating..."
    git pull
    $COMPOSE_CMD up -d --build
    print_success "Update completed"
}

# ------------------------------------------------------------------------
# Help: Usage Information
# ------------------------------------------------------------------------
show_help() {
    echo "DANTO AI Trading System - Docker Management Script"
    echo ""
    echo "Usage: ./start.sh [command] [options]"
    echo ""
    echo "Commands:"
    echo "  start [--build]    Start services (optional: rebuild)"
    echo "  stop               Stop services"
    echo "  restart            Restart services"
    echo "  logs [service]     View logs (optional: specify service name backend/frontend)"
    echo "  status             View service status"
    echo "  clean              Clean all containers and data"
    echo "  update             Update code and restart"
    echo "  help               Show this help information"
    echo ""
    echo "Examples:"
    echo "  ./start.sh start --build    # Build and start"
    echo "  ./start.sh logs backend     # View backend logs"
    echo "  ./start.sh status           # View status"
}
}

# ------------------------------------------------------------------------
# Main: Command Dispatcher
# ------------------------------------------------------------------------
main() {
    check_docker

    case "${1:-start}" in
        start)
            check_env
            check_config
            start "$2"
            ;;
        stop)
            stop
            ;;
        restart)
            restart
            ;;
        logs)
            logs "$@"
            ;;
        status)
            status
            ;;
        clean)
            clean
            ;;
        update)
            update
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            print_error "Unknown command: $1"
            show_help
            exit 1
            ;;
    esac
}

# Execute Main
main "$@"