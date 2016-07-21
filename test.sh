#!/bin/bash

#################################################
# Tests the failure cases of Sql__open
#################################################
Sql__test_open_failure() {
    # Trying to run 'Sql__open' with an invalid driver
    open_hello=$(Sql__open "hello")
    if [[ $? -eq 0 ]]; then
        echo "'Sql__open' should return an error when trying to open driver 'hello'"
        return 1;
    fi

    # Test connection
    local ping_output
    ping_output=$(Sql__ping)
    if [[ $? -eq 0 ]]; then
        Sql__close
        echo "Should not be connected to a database on an open failure"
        return 1
    fi

    # Trying to run 'Sql__open' with no driver
    open_no_driver=$(Sql__open)
    if [[ $? -eq 0 ]]; then
        echo "'Sql__open' should return an error when trying to call 'Sql__open' without a driver name"
        return 1;
    fi
}

#################################################
# Tests the success case of Sql__open for PostgreSQL
#################################################
Sql__test_postgres_open() {
    Sql_test_generic_open "$Sql__DRIVER_POSTGRES"
}

#################################################
# Tests the success case of Sql__open for MySQL
#################################################
Sql__test_mysql_open() {
    Sql_test_generic_open "$Sql__DRIVER_MYSQL"
}

#################################################
# Tests a successful PostgreSQL query
#################################################
Sql__test_postgres_query() {
    Sql_test_generic_query "$Sql__DRIVER_POSTGRES"
}

#################################################
# Tests a successful MySQL query
#################################################
Sql__test_mysql_query() {
    Sql_test_generic_query "$Sql__DRIVER_MYSQL"
}

#################################################
# Tests the a failed PostgreSQL query
#################################################
Sql__test_postgres_query_failure() {
    Sql_test_generic_query_failure "$Sql__DRIVER_POSTGRES"
}

#################################################
# Tests the a failed MySQL query
#################################################
Sql__test_mysql_query_failure() {
    Sql_test_generic_query_failure "$Sql__DRIVER_MYSQL"
}

#################################################
# Test the successful and unsuccessful case for
# the Sql__table_exists function for PostgreSQL
#################################################
Sql__test_postgres_table_exists() {
    Sql_test_generic_table_exists "$Sql__DRIVER_POSTGRES"
}

#################################################
# Test the successful and unsuccessful case for
# the Sql__table_exists function for MySQL
#################################################
Sql__test_mysql_table_exists() {
    Sql_test_generic_table_exists "$Sql__DRIVER_MYSQL"
}

#################################################
# Tests the success case of Sql__open for a driver
#
# @param $1: The driver to test
#################################################
Sql_test_generic_open() {
    # Open DB
    Sql__open "$1"
    if [[ $? -ne 0 ]]; then
        echo "'Sql__open' returned an error"
        return 1
    fi

    # Test connection
    local ping_output
    ping_output=$(Sql__ping)
    if [[ $? -ne 0 ]]; then
        Sql__close
        echo -e "Error connecting to database:"
        echo "$ping_output"
        return 1
    fi

    # Close DB
    Sql__close
    if [[ $? -ne 0 ]]; then
        echo "'Sql__close' returned an error"
        return 1
    fi

    # Test connection
    local ping_output
    ping_output=$(Sql__ping)
    if [[ $? -eq 0 ]]; then
        echo "Database not closed properly, can still ping the database after closing"
        return 1
    fi
}

#################################################
# Tests the successful case for the Sql__execute
# method for a driver
#
# @param $1: The driver to test
#################################################
Sql_test_generic_query() {
    # Open DB
    Sql__open "$1"

    # Query
    local formatted_result=""
    local result=""
    result="$(Sql__execute "SELECT * FROM people;")"

    # Handle result
    if [[ $? -eq 0 ]]; then
        # Echo Result
        while read -r record; do
            while IFS=$'\t' read id name; do
                if [[ "$formatted_result" = "" ]]; then
                    formatted_result="$id,$name"
                else
                    formatted_result="$formatted_result | $id,$name"
                fi
            done <<< "$record"
        done <<< "$result"
    else
        echo "Something wrong with query!"
        echo "$result"
        return 1
    fi

    # Verify result
    local expected_result="1,Brandon | 2,Ryan | 3,Rigby | 4,Norbert"
    if [[ "$formatted_result" != "$expected_result" ]]; then
        echo "Something wrong with query result!"
        echo "Expected: '$expected_result'"
        echo "Actual:   '$formatted_result'"
        return 1
    fi

    # Close DB
    Sql__close
}

#################################################
# Tests the failure case for the Sql__execute
# method for a driver
#
# @param $1: The driver to test
#################################################
Sql_test_generic_query_failure() {
    # Open DB
    Sql__open "$1"
    if [[ $? -ne 0 ]]; then
        echo "Failed to open database connection."
        return 1
    fi

    # Query
    result="$(Sql__execute "SELECT * FROM;")"

    # Handle result
    if [[ $? -eq 0 ]]; then
        echo "Query should have failed, but was successful!"
        echo "Output:"
        echo "$result"
        return 1
    fi

    # Close DB
    Sql__close
}

#################################################
# Test the successful and unsuccessful case for
# the Sql__table_exists function for a driver
#
# @param $1: The driver to test
#################################################
Sql_test_generic_table_exists() {
    # Open DB
    Sql__open "$1"
    if [[ $? -ne 0 ]]; then
        echo "Failed to open database connection."
        return 1
    fi

    # Test that "people" table exists
    Sql__table_exists "people"
    if [[ "$?" -ne 0 ]]; then
        echo "Table 'people' should exist, but it does not!"
        return 1
    fi

    # Test that "animals" table does not exist
    Sql__table_exists "animals"
    if [[ "$?" -eq 0 ]]; then
        echo "Table 'animals' should not exist, but it does!"
        return 1
    fi

    # Close DB
    Sql__close
}
