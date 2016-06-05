#!/bin/bash

#################################################
# Executes a database statement and
# gives the output
#
# @param $1: The statement to be executed
#################################################
Sql__execute() {
    output=$("$SQL_POSTGRES_PATH" \
        --username "$SQL_USER" \
        --dbname "$SQL_DATABASE_NAME" \
        --host "$SQL_HOST" \
        --command "$1" \
        --no-align \
        --field-separator="	" \
        --record-separator="\r\n" \
        --tuples-only 2>&1)
    result="$?"
    printf "$output"
    return $result
}

#################################################
# Do nothing, no driver specific setup
#################################################
Sql_driver_open() {
    :
}

#################################################
# Do nothing, no driver specific shutdown
#################################################
Sql_driver_close() {
    :
}
