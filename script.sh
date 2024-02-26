#!/bin/bash

check_variable() {
    variable_name="$1"
    parameter_name="$2"

    if [[ "$variable_name" == -* ]]; then
        echo "Error: Variable \"$variable_name\" for flag $2 cannot start with a hyphen."
        exit 1
    fi
}

help_createdumpinstance() {
    echo "Usage: createdumpinstance"
    echo "  -n Name of Docker container (optional). Default: postgres"
    echo "  -d Name of database (optional). Default: postgres"
    echo "  -f Dump file path (required)."
    echo "  -s Show import log (optional). Default: false"
    echo "  -e Exit from container after \"\\q\" command in PostgreSQL (optional). Default: true"
}

help_dropdumpinstance() {
    echo "Usage: dropdumpinstance"
    echo "  -n Name of Docker container (optional). Default: postgres"
}

cleanup() {
    local container_name="$1"

    if docker container ls --format '{{.Names}}' | grep -q "$container_name"; then
        echo "Removing Docker container \"$container_name\"."
        docker rm "$container_name" -f
    fi
}

createdumpinstance() {
    local dump_path=""
    local container_name="postgres"
    local database_name="postgres"
    local show_import_log=false
    local exit_from_container=true

    while [ -n "$1" ]; do
        case "$1" in
            -h) 
                help_createdumpinstance
                exit 0 ;;
            -d) 
                database_name="$2"
                check_variable "$database_name" "-d"
                shift ;;
            -n) 
                container_name="$2"
                check_variable "$container_name" "-n"
                shift ;;
            -f) 
                dump_path="$2"
                check_variable "$dump_path" "-f"
                shift ;;
            -s) 
                show_import_log=true
                ;;
            -e) 
                exit_from_container=false
                ;;
            --) 
                shift
                break ;;
            *) 
                echo "$1 is not an option" 
                exit 1
                ;;
        esac
        shift
    done

    if [[ -z "$dump_path" ]]; then
        echo "Error: Dump path is not provided."
        help_createdumpinstance
        exit 1
    fi

    if ! [[ "$dump_path" == *.sql ]]; then
        echo "Error: Dump $dump_path is not the appropriate type (.sql)."
        help_createdumpinstance
        exit 1
    fi

    runContainer "$dump_path" "$container_name" "$database_name" "$show_import_log" "$exit_from_container"
}

runContainer() {
    local dump_path="$1"
    local container_name="$2"
    local database_name="$3"
    local show_import_log="$4"
    local exit_from_container="$5"

    echo "Creating Docker container \"$container_name\"."
    docker run -d --rm --name "$container_name" -e POSTGRES_PASSWORD="postgres" postgres

    until docker exec -it "$container_name" pg_isready -q -h localhost -U postgres; do
        sleep 1
    done

    echo "Creating database \"$database_name\"."
    docker exec -it "$container_name" createdb -U postgres "$database_name"

    if [ "$show_import_log" = true ]; then
        echo "Importing data with log from \"$dump_path\"."
        docker exec -i "$container_name" psql -U postgres -d "$database_name" < "$dump_path"
    else
        echo "Importing data without log from \"$dump_path\"."
        docker exec -i "$container_name" psql -U postgres -d "$database_name" < "$dump_path" > /dev/null 2>&1
    fi

    echo "Accessing PostgreSQL shell in container \"$container_name\"."
    docker exec -it "$container_name" psql -U postgres -d "$database_name"

    if [ "$exit_from_container" = true ]; then
        cleanup "$container_name"
    fi
}

dropdumpinstance() {
    local container_name="postgres"

    while [ -n "$1" ]; do
        case "$1" in
            -h)
                help_dropdumpinstance
                exit 1
                ;;
            -n) 
                container_name="$2"
                check_variable "$container_name" "-n"
                shift ;;
            --) 
                shift
                break ;;
            *) 
                echo "$1 is not an option" 
                exit 1
                ;;
        esac
        shift
    done

    if ! docker container ls --format '{{.Names}}' | grep -q "$container_name"; then
        echo "Error: Docker container \"$container_name\" does not exist!"
        exit 1
    fi

    cleanup "$container_name"
    exit 0
}

case "$1" in
    createdumpinstance)
        shift
        createdumpinstance "$@"
        ;;
    dropdumpinstance)
        shift
        dropdumpinstance "$@"
        ;;
    *)
        echo "Invalid command: $1" >&2
        exit 1
        ;;
esac
