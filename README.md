# SQL

[![Build Status](https://travis-ci.org/ash-shell/sql.svg?branch=br.travis)](https://travis-ci.org/ash-shell/sql) [![GitHub release](https://img.shields.io/github/release/ash-shell/sql.svg?maxAge=2592000)](https://github.com/ash-shell/sql/releases)

SQL is a SQL driver for [Ash](https://github.com/ash-shell/ash).  This library provides a clean and unified interface to interact with multiple types of databases.

Currently there is full support for `MySQL` and `PostgreSQL`.

## Getting Started

You're going to have to install [Ash](https://github.com/ash-shell/ash) to use this module.

After you have Ash installed, run either one of these two commands depending on your git clone preference:

- `ash apm:install git@github.com:ash-shell/sql.git`
- `ash apm:install https://github.com/ash-shell/sql.git`

You can optionally install this globally by adding `--global` to the end of the command.

## Dependencies

The external dependencies for this module you likely already have:

#### MySQL Driver

For the MySQL driver, the [MySQL Command Line Tool](http://dev.mysql.com/doc/refman/5.7/en/mysql.html) is required.

#### PostgreSQL Driver

For the PostgreSQL driver, [psql](https://www.postgresql.org/docs/9.1/static/app-psql.html) is required.

## Environment Variables

Before jumping into using this library, you're going to have to set some environment variables so SQL knows how to connect to your database.

I would recommend creating a `.env` file and sourcing it into your project.

### PostgreSQL

Here is a list of all of the configurable values, if you plan on using the PostgreSQL driver.  The values that I have set below are the defaults (so if your needs match the defaults, feel free to exclude them).

```sh
# The location of your psql command.  If psql is already in
# your $PATH (which it probably is), no need to edit this value.
# In the event this isn't already in your path, I recommend putting
# this value into your ~/.ashrc file.
SQL_POSTGRES_PATH='psql'

# The PostgreSQL user you will connect with.
# Note there is no password environment variable:
# you must use the ~/.pgpass file.
SQL_POSTGRES_USER='postgres'

# The host of your database.
SQL_POSTGRES_HOST='localhost'

# The port of your database.
SQL_POSTGRES_PORT='5432'

# The name of your database.
SQL_POSTGRES_DATABASE_NAME=''
```

> You must use a [pgpass file](https://www.postgresql.org/docs/9.3/static/libpq-pgpass.html) for the PostgreSQL driver.

### MySQL

Here is a list of all of the configurable values, if you plan on using the MySQL driver.  The values that I have set below are the defaults (so if your needs match the defaults, feel free to exclude them).

```sh
# The location of your mysql command.  If mysql is already in
# your $PATH (which it probably is), no need to edit this value.
# In the event this isn't already in your path, I recommend putting
# this value into your ~/.ashrc file.
SQL_MYSQL_PATH='mysql'

# The MySQL user you will connect with.
SQL_MYSQL_USER='root'

# The MySQL users password you will connect with.
SQL_MYSQL_PASSWORD=''

# The host of your database.
SQL_MYSQL_HOST='localhost'

# The port of your database.
SQL_MYSQL_PORT='3306'

# The name of your database.
SQL_MYSQL_DATABASE_NAME=''

# The location where this library will temporarily create a
# MySQL config file.
# http://dev.mysql.com/doc/refman/5.7/en/option-files.html
# It is pretty unlikely you will want to change this, but in the
# event you need to change this, I recommend putting this value
# into your ~/.ashrc file.
SQL_MYSQL_CONFIG_FILE='/tmp/ash_sql_mysql_config.cnf'
```

> You must have write access to `SQL_MYSQL_CONFIG_FILE`s directory.  You most likely won't ever have to change that (so just exclude it), but I've added it as configurable in the event you are on an operating system without a `/tmp` directory.

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

> Note: You can't run this function in a subshell, as it is responsible for sourcing in specific driver files.

### Testing Connections

After you open a connection, you'll likely want to verify we can actually start executing queries against it.

You can test a connection by calling `Sql__ping`.

```sh
# Test connection
local ping_output
ping_output=$(Sql__ping)
if [[ $? -ne 0 ]]; then
    Sql__close
    echo "Error connecting to database:"
    echo "$ping_output"
    return 1
fi
```

> The reason why this doesn't just automatically happen in `Sql__open` is because you can't run `Sql__open` in a subshell (as it sources other files), and this function has output that we want to capture.

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

## Running Tests

This project is fully tested, and is [using Travis](https://travis-ci.org/ash-shell/sql) to make sure all new code doesn't break anything.  Feel free to check out the [test file](./test.sh) to see our tests.

If that's not enough for you, and you'd like to run the tests yourself to verify that everything works on your environment here are the following steps to run the tests:

First, you're going to have to create a `MySQL`, and `PostgreSQL` database.  The name doesn't matter for either, but remember the names of the databases you've created.

Inside of both databases, create the following table:

```sql
CREATE TABLE people(
    id integer,
    name varchar(20)
);
```

And seed it with the following data:

```sql
INSERT INTO people VALUES
    (1, 'Brandon'),
    (2, 'Ryan'),
    (3, 'Rigby'),
    (4, 'Norbert');
```

Next, we're going to have to set environment variables so we can point the tests to the databases.  Look at the [Environment Variables(#environment-variables) section to see what variables you'll need set.

After the environment variables are set run the following:

```sh
ash test github.com/ash-shell/sql
```

Hopefully all of the tests passed.  If not and you suspect it's due to a bug, please file an issue!

## License

[MIT](./LICENSE.md)
