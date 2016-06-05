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
        --database="$SQL_MYSQL_DATABASE_NAME" \
        --silent \
        --skip-column-names \
        --batch \
        --execute="$1" \
        2>&1
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
    if [[ -e "$Sql_MYSQL_CONFIG_FILE" ]]; then
        rm "$Sql_MYSQL_CONFIG_FILE"
    fi

    # Creating new MySQL config file
    touch "$Sql_MYSQL_CONFIG_FILE"
    chmod 600 "$Sql_MYSQL_CONFIG_FILE"

    echo "[client]" >> "$Sql_MYSQL_CONFIG_FILE"
    echo "user = $SQL_MYSQL_USER" >> "$Sql_MYSQL_CONFIG_FILE"
    echo "password = $SQL_MYSQL_PASSWORD" >> "$Sql_MYSQL_CONFIG_FILE"
    echo "host = $SQL_MYSQL_HOST" >> "$Sql_MYSQL_CONFIG_FILE"
    echo "port = $SQL_MYSQL_PORT" >> "$Sql_MYSQL_CONFIG_FILE"
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
