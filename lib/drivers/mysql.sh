#!/bin/bash

# Temporary config file location
Sql_MYSQL_CONFIG_FILE="/tmp/ash_sql_mysql_config.cnf"

#################################################
# Executes a database statement and
# gives the output
#
# @param $1: the statement to be executed
#################################################
Sql__execute() {
    "$SQL_MYSQL_PATH" \
        --defaults-extra-file="$Sql_MYSQL_CONFIG_FILE" \
        --database="$SQL_DATABASE_NAME" \
        --silent \
        --skip-column-names \
        --batch \
        --execute="$1"
}

#################################################
# Generates the MySQL config file to be used
#################################################
Sql_driver_open() {
    # Deleting old mysql config file if it existed
    if [[ -e "$Sql_MYSQL_CONFIG_FILE" ]]; then
        rm "$Sql_MYSQL_CONFIG_FILE"
    fi

    # Creating new MySQL config file
    touch "$Sql_MYSQL_CONFIG_FILE"
    chmod 600 "$Sql_MYSQL_CONFIG_FILE"

    echo "[client]" >> "$Sql_MYSQL_CONFIG_FILE"
    echo "user = $SQL_USER" >> "$Sql_MYSQL_CONFIG_FILE"
    echo "password = $SQL_PASSWORD" >> "$Sql_MYSQL_CONFIG_FILE"
    echo "host = $SQL_HOST" >> "$Sql_MYSQL_CONFIG_FILE"
    echo "port = $SQL_PORT" >> "$Sql_MYSQL_CONFIG_FILE"
}

#################################################
# Deletes the temporary database config file
#################################################
Sql_driver_close() {
    # Deleting old mysql config file if it existed
    if [[ -e "$Sql_MYSQL_CONFIG_FILE" ]]; then
        rm "$Sql_MYSQL_CONFIG_FILE"
    fi
}
