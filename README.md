# SQL

[![Build Status](https://travis-ci.org/ash-shell/sql.svg?branch=br.travis)](https://travis-ci.org/ash-shell/sql)

SQL is a SQL driver for [Ash](https://github.com/ash-shell/ash).  This library provides a clean and unified interface to interact with multiple types of databases.

Currently there is full support for `MySQL` and `PostgreSQL`.

## Getting Started

You're going to have to install [Ash](https://github.com/ash-shell/ash) to use this module.

After you have Ash installed, run either one of these two commands depending on your git clone preference:

- `ash apm:install git@github.com:ash-shell/sql.git`
- `ash apm:install https://github.com/ash-shell/sql.git`

You can optionally install this globally by adding `--global` to the end of the command.

## Environment Variables

Before jumping into using this library, you're going to have to set some environment variables so SQL knows how to connect to your database.

I would recommend creating a `.env` file and sourcing it into your project.

### PostgreSQL

Here is a list of all of the configurable values, if you plan on using the PostgreSQL driver.  The values that I have set below are the defaults (so if your needs match the defaults, feel free to exclude them).

```sh
SQL_POSTGRES_PATH='psql'
SQL_POSTGRES_USER='postgres'
SQL_POSTGRES_HOST='localhost'
SQL_POSTGRES_PORT='5432'
SQL_POSTGRES_DATABASE_NAME=''
```

You must use a [pgpass file](https://www.postgresql.org/docs/9.3/static/libpq-pgpass.html) for the PostgreSQL driver.

### MySQL

Here is a list of all of the configurable values, if you plan on using the MySQL driver.  The values that I have set below are the defaults (so if your needs match the defaults, feel free to exclude them).

```sh
SQL_MYSQL_PATH='mysql'
SQL_MYSQL_USER='root'
SQL_MYSQL_HOST='localhost'
SQL_MYSQL_PORT='3306'
SQL_MYSQL_DATABASE_NAME=''
SQL_MYSQL_PASSWORD=''
SQL_MYSQL_CONFIG_FILE='/tmp/ash_sql_mysql_config.cnf'
```

You must have write access to `SQL_MYSQL_CONFIG_FILE`s directory.  You most likely won't ever have to change that (so just exclude it), but I've added it as configurable in the event you are on an operating system without a `/tmp` directory.

## Usage

To use SQL in your project you're first going to have to import it.  Place this line at the top of your file:

```sh
Ash__import "github.com/ash-shell/sql"
```

### Opening Connections

After it's imported, you can now open a connection to the database.

You can simply open a connection by calling `Sql__open`.

```sh
# For MySQL
Sql__open "$Sql__DRIVER_MYSQL"

# For PostgreSQL
Sql__open "$Sql__DRIVER_POSTGRES"
```

`Sql__open` returns a non 0 value in the event something went wrong, so feel free to check for that for a more robust setup:

```sh
Sql__open "$Sql__DRIVER_POSTGRES"
if [[ $? -ne 0 ]]; then
    echo "'Sql__open' returned an error"
    return 1
fi
```

### Closing Connections

After you are done running all of your queries against the database, you will now have to close your database.

```sh
Sql__close
```

`Sql__close` returns a non 0 value in the event something went wrong, so feel free to check for that for a more robust setup:

```sh
Sql__close
if [[ $? -ne 0 ]]; then
    echo "'Sql__close' returned an error"
    return 1
fi
```

### Executing Queries

Executing queries is the same for both MySQL and PostgreSQL.  The function is `Sql__execute`.

Assuming that we have already connected to a database with a table named `people`, we should be able to run a query like this.

```sh
# Execute query
result="$(Sql__execute "SELECT * FROM people;")"

# Handle result
while read -r record; do                # Iterate over records
    while IFS=$'\t' read id name; do    # Iterate over columns
        echo "$id, $name"               # Print records columns, or do anything here!
    done <<< "$record"
done <<< "$result"
```

Now, the code above is assuming that everything will go OK with the query, but we likely want to add some error checking.  With error checking, the above will look like this:

```sh
# Execute query
result="$(Sql__execute "SELECT * FROM people;")"

# Handle result
if [[ $? -eq 0 ]]; then                     # Check to see if $? (the query result) is non zero
    while read -r record; do                # Iterate over records
        while IFS=$'\t' read id name; do    # Iterate over columns
            echo "$id, $name"               # Print records columns, or do anything here!
        done <<< "$record"
    done <<< "$result"
else
    echo "Something wrong with query!"
    echo "$result"                          # Prints the error message!
    return 1
fi
```

### Checking If Tables Exist

You may run into a situation where you would like to see if a table exists in a database.  This library provides the function `Sql__table_exists`.

Ignoring the code for opening/closing your database, checking if a table exists should look something like this:

```sh
# Test that "people" table exists
Sql__table_exists "people"
if [[ "$?" -eq 0 ]]; then
    echo "Table exists!"
else
    echo "Table does not exist!"
fi
```

### A Quick Gotcha!

If you've been working with Bash for a little while, you'll know that most of your variables should probably be `local`.

Let's look at this example here (note the local before the result variable).

```sh
# Execute query
local result="$(Sql__execute "SELECT * FROM people;")"

# Handle result
if [[ $? -eq 0 ]]; then
    echo "OK"
else
    echo "NOT OK"
fi
```

Let's assume that the `Sql__execute` query fails, because we actually didn't have a `people` table in our database.  What will happen in the above code is that actually `OK` will be printed out.  This is because `local` is itself a builtin function that returns a result, after `Sql__execute` finishes.  Now inside of `$?` is a 0, because the local builtin function succeeded.

If you want to use local variables inside of functions, they must be declared before our `Sql__execute` line.

```sh
# Execute query
local result=""
result="$(Sql__execute "SELECT * FROM people;")"
```

## License

[MIT](./LICENSE.md)
