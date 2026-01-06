#!/usr/bin/env bash
# PlusCraft Deployment Helper Script
# Simplifies pulling and running pre-built Docker images from GHCR

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

COMPOSE_FILES="-f docker-compose.yml -f docker-compose.deploy.yml"
COMPOSE_CMD="docker compose $COMPOSE_FILES"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

usage() {
    echo -e "${BLUE}PlusCraft Deployment Script${NC}"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  pull      Pull latest images from GHCR"
    echo "  up        Start services (pulls if needed)"
    echo "  down      Stop and remove services"
    echo "  restart   Restart all services"
    echo "  logs      Show logs (follow mode)"
    echo "  status    Show service status"
    echo "  update    Pull latest images and restart"
    echo ""
    echo "Examples:"
    echo "  $0 pull              # Pull latest Playerbot images"
    echo "  $0 up                # Start all services"
    echo "  $0 logs              # Follow all logs"
    echo "  $0 update            # Update to latest and restart"
    echo ""
}

pull_images() {
    echo -e "${BLUE}Pulling latest images from GHCR...${NC}"
    $COMPOSE_CMD pull
    echo -e "${GREEN}✓ Images pulled successfully${NC}"
}

start_services() {
    echo -e "${BLUE}Starting PlusCraft services...${NC}"
    $COMPOSE_CMD up -d
    echo -e "${GREEN}✓ Services started${NC}"
    echo ""
    show_status
}

stop_services() {
    echo -e "${BLUE}Stopping PlusCraft services...${NC}"
    $COMPOSE_CMD down
    echo -e "${GREEN}✓ Services stopped${NC}"
}

restart_services() {
    echo -e "${BLUE}Restarting PlusCraft services...${NC}"
    $COMPOSE_CMD restart
    echo -e "${GREEN}✓ Services restarted${NC}"
}

show_logs() {
    echo -e "${BLUE}Showing logs (Ctrl+C to exit)...${NC}"
    $COMPOSE_CMD logs -f
}

show_status() {
    echo -e "${BLUE}Service Status:${NC}"
    $COMPOSE_CMD ps
}

update_and_restart() {
    echo -e "${BLUE}Updating PlusCraft to latest version...${NC}"
    pull_images
    echo ""
    echo -e "${BLUE}Restarting services...${NC}"
    $COMPOSE_CMD up -d --remove-orphans
    echo -e "${GREEN}✓ Update complete${NC}"
    echo ""
    show_status
}

# Main command handler
case "${1:-}" in
    pull)
        pull_images
        ;;
    up|start)
        start_services
        ;;
    down|stop)
        stop_services
        ;;
    restart)
        restart_services
        ;;
    logs)
        show_logs
        ;;
    status|ps)
        show_status
        ;;
    update)
        update_and_restart
        ;;
    "")
        usage
        exit 0
        ;;
    *)
        echo -e "${RED}Error: Unknown command '$1'${NC}"
        echo ""
        usage
        exit 1
        ;;
esac
