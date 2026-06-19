#!/bin/bash
# Manage Airflow 3 and Marquez local environment with Docker Compose

COMPOSE_FILE="docker-compose-airflow.yml"
MARQUEZ_COMPOSE_FILE="docker-compose-marquez.yml"
NETWORK_NAME="lineage-network"

# Ensure external Docker network exists before startup
ensure_network() {
    if ! docker network inspect "$NETWORK_NAME" >/dev/null 2>&1; then
        echo "Creating external docker network: $NETWORK_NAME"
        docker network create "$NETWORK_NAME"
    fi
}

show_usage() {
    echo "Usage: $0 {up|down|restart|logs|ps|cli|build} [target]"
    echo "  up [target]      : Start containers (default target: all)"
    echo "  down [target]    : Stop and remove containers (default target: all)"
    echo "  restart [target] : Restart containers (default target: all)"
    echo "  logs [target]    : Follow container logs (default target: airflow)"
    echo "  ps [target]      : Check status of running containers (default target: all)"
    echo "  cli              : Access the Airflow CLI container"
    echo "  build            : Build the custom Airflow image"
    echo ""
    echo "Targets (for up/down/restart/ps/logs):"
    echo "  all     : Both Airflow and Marquez"
    echo "  airflow : Airflow only"
    echo "  marquez : Marquez only"
}

if [ -z "$1" ]; then
    show_usage
    exit 1
fi

ACTION="$1"
TARGET="${2:-all}"

# Helper function to check if a target is selected
is_target() {
    [ "$TARGET" = "all" ] || [ "$TARGET" = "$1" ]
}

case "$ACTION" in
    up)
        ensure_network
        if is_target marquez; then
            echo "Starting Marquez containers..."
            docker compose -f "$MARQUEZ_COMPOSE_FILE" up -d
        fi
        if is_target airflow; then
            echo "Starting Airflow 3.x containers..."
            docker compose -f "$COMPOSE_FILE" up -d
        fi
        ;;
    down)
        if is_target airflow; then
            echo "Stopping Airflow 3.x containers..."
            docker compose -f "$COMPOSE_FILE" down
        fi
        if is_target marquez; then
            echo "Stopping Marquez containers..."
            docker compose -f "$MARQUEZ_COMPOSE_FILE" down -v
        fi
        ;;
    restart)
        echo "Restarting stack ($TARGET)..."
        "$0" down "$TARGET"
        "$0" up "$TARGET"
        ;;
    logs)
        if [ "$TARGET" = "marquez" ]; then
            docker compose -f "$MARQUEZ_COMPOSE_FILE" logs -f
        elif [ -n "$2" ]; then
            docker compose -f "$COMPOSE_FILE" logs -f "$2"
        else
            docker compose -f "$COMPOSE_FILE" logs -f
        fi
        ;;
    ps)
        if is_target marquez; then
            echo "=== Marquez Status ==="
            docker compose -f "$MARQUEZ_COMPOSE_FILE" ps
        fi
        if is_target airflow; then
            echo "=== Airflow Status ==="
            docker compose -f "$COMPOSE_FILE" ps
        fi
        ;;
    cli)
        echo "Entering Airflow CLI session..."
        docker compose -f "$COMPOSE_FILE" run --rm --entrypoint bash airflow-cli
        ;;
    build)
        echo "Building custom Airflow image..."
        docker compose -f "$COMPOSE_FILE" build
        ;;
    *)
        show_usage
        exit 1
        ;;
esac
