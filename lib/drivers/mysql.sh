#!/bin/bash

# Temporary config file location
SQL_MYSQL_CONFIG_FILE="/tmp/ash_sql_mysql_config.cnf"

#################################################
# Executes a database statement and
# gives the output
#
# @param $1: the statement to be executed
#################################################
Sql__execute() {
    "$SQL_MYSQL_PATH" \
        --defaults-extra-file="$SQL_MYSQL_CONFIG_FILE" \
        --database="$SQL_MYSQL_DATABASE_NAME" \
        --silent \
        --skip-column-names \
        --batch \
        --execute="$1" \
        2>&1
}

#################################################
# Pings the database to verify if we have a
# valid connection.

# @returns: 0 if we have a valid connection,
#   1 otherwise
#################################################
Sql__ping() {
    local out
    out=$(Sql__execute "SELECT 1;")
    if [[ $? -eq 0 ]]; then
        return 0
    else
        echo "$out"
        return 1
    fi
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
    local sql="SHOW TABLES LIKE '$1';"
    local output=$(Sql__execute "$sql")
    if [ "$output" != "" ]; then
        return 0 # Table exists
    else
        return 1 # Table does not exist
    fi
}

#################################################
# Generates the MySQL config file to be used
#################################################
Sql_driver_open() {
    # Setting defaults, if not set
    if [[ "$SQL_MYSQL_PATH" = "" ]]; then
        SQL_MYSQL_PATH="mysql"
    fi
    if [[ "$SQL_MYSQL_USER" = "" ]]; then
        SQL_MYSQL_USER="root"
    fi
    if [[ "$SQL_MYSQL_HOST" = "" ]]; then
        SQL_MYSQL_HOST="localhost"
    fi
    if [[ "$SQL_MYSQL_PORT" = "" ]]; then
        SQL_MYSQL_PORT="3306"
    fi

    # Deleting old mysql config file if it existed
    if [[ -e "$SQL_MYSQL_CONFIG_FILE" ]]; then
        rm "$SQL_MYSQL_CONFIG_FILE"
    fi

    # Creating new MySQL config file
    touch "$SQL_MYSQL_CONFIG_FILE"
    chmod 600 "$SQL_MYSQL_CONFIG_FILE"

    echo "[client]" >> "$SQL_MYSQL_CONFIG_FILE"
    echo "user = $SQL_MYSQL_USER" >> "$SQL_MYSQL_CONFIG_FILE"
    echo "password = $SQL_MYSQL_PASSWORD" >> "$SQL_MYSQL_CONFIG_FILE"
    echo "host = $SQL_MYSQL_HOST" >> "$SQL_MYSQL_CONFIG_FILE"
    echo "port = $SQL_MYSQL_PORT" >> "$SQL_MYSQL_CONFIG_FILE"
}

#################################################
# Deletes the temporary database config file
#################################################
Sql_driver_close() {
    # Deleting old mysql config file if it existed
    if [[ -e "$SQL_MYSQL_CONFIG_FILE" ]]; then
        rm "$SQL_MYSQL_CONFIG_FILE"
    fi
}
