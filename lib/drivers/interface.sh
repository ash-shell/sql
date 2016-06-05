#!/bin/bash
#
# This file is a blank interface that all sql drivers must adhere to.
#
# Some of these methods in this actual interface have error messages,
# as this interface is actually imported before any specific driver is
# loaded.
#
# When creating a driver, you must override all methods here.

#################################################
# Executes a database statement and outputs the
# result as a space delimited string of columns.
#
# @param $1: The statement to be executed
#################################################
Sql__execute() {
    Logger__error "No sql driver selected, must call 'Sql__open' before calling 'Sql__execute'"
}

#################################################
# Here is an opportunity to provide any driver
# specific logic for when the database is opened.
#################################################
Sql_driver_open() {
    :
}

#################################################
# Here is an opportunity to provide any driver
# specific logic for when the database is closed.
#################################################
Sql_driver_close() {
    :
}
