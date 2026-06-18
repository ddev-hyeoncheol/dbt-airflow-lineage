#!/bin/bash
# Helper script to run Airflow 3 with docker-compose-airflow.yml

COMPOSE_FILE="docker-compose-airflow.yml"

show_usage() {
    echo "Usage: $0 {up|down|restart|logs|ps|cli|build}"
    echo "  up      : Start Airflow containers in background (-d)"
    echo "  down    : Stop and remove Airflow containers"
    echo "  restart : Restart Airflow containers"
    echo "  logs    : Follow container logs (optionally pass service name, e.g., $0 logs airflow-scheduler)"
    echo "  ps      : Check status of running containers"
    echo "  cli     : Access the Airflow CLI container"
    echo "  build   : Build the custom Airflow image"
}

if [ -z "$1" ]; then
    show_usage
    exit 1
fi

case "$1" in
    up)
        echo "Starting Airflow 3.x containers..."
        docker compose -f "$COMPOSE_FILE" up -d
        ;;
    down)
        echo "Stopping Airflow 3.x containers..."
        docker compose -f "$COMPOSE_FILE" down
        ;;
    restart)
        echo "Restarting Airflow 3.x containers..."
        docker compose -f "$COMPOSE_FILE" down
        docker compose -f "$COMPOSE_FILE" up -d
        ;;
    logs)
        docker compose -f "$COMPOSE_FILE" logs -f "$2"
        ;;
    ps)
        docker compose -f "$COMPOSE_FILE" ps
        ;;
    cli)
        echo "Entering Airflow CLI session..."
        docker compose -f "$COMPOSE_FILE" run --entrypoint bash airflow-cli
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
