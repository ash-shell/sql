#!/bin/bash

Sql__PACKAGE_LOCATION="$(Ash__find_module_directory "github.com/ash-shell/sql")"
Sql__DRIVER_MYSQL='mysql'
Sql__DRIVER_POSTGRES='postgres'

# Load the interface for appropriate non loaded messages
. "$Sql__PACKAGE_LOCATION/lib/drivers/interface.sh"

#################################################
# Loads the appropriate database driver handles
# all other setup operations
#
# @param $1: The driver to setup
# @returns: 1 if the driver is invalid,
#   0 otherwise
#################################################
Sql__open() {
    local driver="$1"
    if [[ "$driver" = "" ]]; then
        return 1
    fi

    # Loading the appropriate database driver
    if [[ "$driver" = "$Sql__DRIVER_MYSQL" ]]; then
        . "$Sql__PACKAGE_LOCATION/lib/drivers/mysql.sh"
    elif [[ "$driver" = "$Sql__DRIVER_POSTGRES" ]]; then
        . "$Sql__PACKAGE_LOCATION/lib/drivers/postgres.sh"
    else
        return 1
    fi

    # Run any driver specific logic
    Sql_driver_open
}

#################################################
# Shuts down the database
#################################################
Sql__close() {
    . "$Sql__PACKAGE_LOCATION/lib/drivers/interface.sh"
    Sql_driver_close
}
