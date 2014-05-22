ora2pg_tools
============

Set of tools we use to migrate an Oracle database to Postgresql using ora2pg but in parallel

The ora2pg_wrapper is just a basic script that will copy only one table, it will create the table and copy the data.

This is just a WIP.

To manage parallelism, we use ppss (https://code.google.com/p/ppss/) to minimize the migration time.
