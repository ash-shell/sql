#!/bin/bash

#################################################
# Executes a database statement and
# gives the output
#
# @param $1: The statement to be executed
#################################################
Sql__execute() {
    output=$("$SQL_POSTGRES_PATH" \
        --username "$SQL_POSTGRES_USER" \
        --dbname "$SQL_POSTGRES_DATABASE_NAME" \
        --host "$SQL_POSTGRES_HOST" \
        --port "$SQL_POSTGRES_PORT" \
        --command "$1" \
        --no-align \
        --field-separator="	" \
        --record-separator="\n" \
        --tuples-only 2>&1)
    result="$?"
    printf "$output"
    return $result
}

#################################################
# Checks if a specific table exists in the
# database.
#
# @param $1: The name of the table to check if
#   if it exists.
# @returns: 0 if a table exists, 1 if no table
#   exists
#################################################
Sql__table_exists() {
    local sql=''
    read -d '' sql <<____EOF
    SELECT count(*)
    FROM information_schema.tables
    WHERE table_schema = 'public'
        AND table_name = '$1';
____EOF

    local count=$(Sql__execute "${sql}")
    if [ "$count" -eq 1 ]; then
        return 0 # Table exists
    else
        return 1 # Table does not exist
    fi
}

#################################################
# Do nothing, no driver specific setup
#################################################
Sql_driver_open() {
    # Setting defaults, if not set
    if [[ "$SQL_POSTGRES_PATH" = "" ]]; then
        SQL_POSTGRES_PATH="psql"
    fi
    if [[ "$SQL_POSTGRES_USER" = "" ]]; then
        SQL_POSTGRES_USER="postgres"
    fi
    if [[ "$SQL_POSTGRES_HOST" = "" ]]; then
        SQL_POSTGRES_HOST="localhost"
    fi
    if [[ "$SQL_POSTGRES_PORT" = "" ]]; then
        SQL_POSTGRES_PORT="5432"
    fi
}

#################################################
# Do nothing, no driver specific shutdown
#################################################
Sql_driver_close() {
    :
}
