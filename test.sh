#!/bin/bash

#################################################
# Tests the failure cases of Sql__open
#################################################
Sql__test_open_failure(){
    # Trying to run 'Sql__open' with an invalid driver
    open_hello=$(Sql__open "hello")
    if [[ $? -eq 0 ]]; then
        echo "'Sql__open' should return an error when trying to open driver 'hello'"
        return 1;
    fi

    # Trying to run 'Sql__open' with no driver
    open_no_driver=$(Sql__open)
    if [[ $? -eq 0 ]]; then
        echo "'Sql__open' should return an error when trying to call 'Sql__open' without a driver name"
        return 1;
    fi
}

#################################################
# Tests the success case of Sql__open for MySQL
#################################################
Sql__test_mysql_open(){
    # Open DB
    Sql__open "$Sql__DRIVER_MYSQL"
    if [[ $? -ne 0 ]]; then
        echo "'Sql__open' returned an error"
        return 1
    fi

    # Verify MySQL config file was created
    if [[ ! -f "$SQL_MYSQL_CONFIG_FILE" ]]; then
        echo "MySQL config file was not created"
        echo "Make sure you have permissions to write to $SQL_MYSQL_CONFIG_FILE"
        return 1
    fi

    # Close DB
    Sql__close
    if [[ $? -ne 0 ]]; then
        echo "'Sql__close' returned an error"
        return 1
    fi

    # Verify MySQL config file was deleted
    if [[ -f "$SQL_MYSQL_CONFIG_FILE" ]]; then
        echo "MySQL config file was not deleted"
        echo "Make sure you have permissions to delete $SQL_MYSQL_CONFIG_FILE"
        return 1
    fi
}

#################################################
# Tests a successful MySQL query
#################################################
Sql__test_mysql_query(){
    # Open DB
    Sql__open "$Sql__DRIVER_MYSQL"

    # Query
    local formatted_result=""
    local result=""
    result="$(Sql__execute "SELECT * FROM people;")"

    # Handle result
    if [[ $? -eq 0 ]]; then
        # Echo Result
        while read -r record; do
            while IFS=$'\t' read id name; do
                if [[ $formatted_result = "" ]]; then
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
# Tests the a failed MySQL query
#################################################
Sql__test_mysql_query_failure(){
    # Open DB
    Sql__open "$Sql__DRIVER_MYSQL"

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
# Tests the success case of Sql__open for PostgreSQL
#################################################
Sql__test_postgres_open(){
    # Open DB
    Sql__open "$Sql__DRIVER_POSTGRES"
    if [[ $? -ne 0 ]]; then
        echo "'Sql__open' returned an error"
        return 1
    fi

    # Close DB
    Sql__close
    if [[ $? -ne 0 ]]; then
        echo "'Sql__close' returned an error"
        return 1
    fi
}

#################################################
# Tests a successful PostgreSQL query
#################################################
Sql__test_postgres_query(){
    # Open DB
    Sql__open "$Sql__DRIVER_POSTGRES"

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
# Tests the a failed PostgreSQL query
#################################################
Sql__test_postgres_query_failure(){
    # Open DB
    Sql__open "$Sql__DRIVER_POSTGRES"

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
