#!/bin/bash

help_createdumpinstance() {
    echo "Usage: createdumpinstance [dump_file_path]"
    echo "  -n Name of docker container"
    echo "  -d Name of data base"
}

help_dropdumpinstance() {
    echo "Usage: dropdumpinstance"
    echo "  -n Name of docker container"
}

createdumpinstance() {
    local dump_path=""
    local container_name="postgres"
    local database_name="postgres"

    while [ -n "$1" ]; do
        case "$1" in
            -h) help_createdumpinstance
                exit 0 ;;
            -d) database_name="$2"
                shift ;;
            -n) container_name="$2"
                shift ;;
            -f) dump_path="$2"
                shift;;
            --) shift
                break ;;
            *) echo "$1 is not an option";;
        esac
        shift
    done

    echo "$($dump_path) 1"
    echo "$($container_name) 2"
    echo "$($database_name) 3"

    if [[ -z "$dump_path" ]]; then
        help_createdumpinstance
        exit 1
    fi

    if ! [[ "$dump_path" == *.sql ]]; then
        echo "Dump $dump_path is not the appropriate type (.sql). Is it okay?"
        read -p "[Y/n] " answer
        if [[ "$answer" != "Y" && "$answer" != "y" && "$answer" != "yes" && "$answer" != "Yes" ]]; then
            echo "Exiting..."
            exit 1
        fi
    fi

    runContainer "$dump_path" "$container_name" "$database_name"
}

runContainer() {
    local dump_path="$1"
    local container_name="$2"
    local database_name="$3"

    docker run -d --rm --name "$container_name" -e POSTGRES_PASSWORD="postgres" postgres

    while ! docker exec -it "$container_name" pg_isready -q -h localhost -U postgres; do
        sleep 1
    done

    docker exec -it "$container_name" createdb -U postgres "$database_name"

    docker exec -i "$container_name" psql -U postgres -d "$database_name" < "$dump_path"

    docker exec -it "$container_name" psql -U postgres
}

dropdumpinstance() {
    local container_name="postgres"

    while [[ $# -gt 0 ]]; do 
        case "$1" in
            -h)
                help_dropdumpinstance
                exit 1
                ;;
            -n)
                container_name="$2"
                shift 2 ;;
            *)
                echo "Parameter \"$1\" does not exist!"
                exit 1
                ;;
        esac
    done

    if ! docker container ls --format '{{.Names}}' | grep -q "$container_name"; then
        echo "Docker container \"$container_name\" does not exist!"
        exit 1
    fi

    docker rm "$container_name" -f
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
