Migrations fixed for TIDB 5.0
-----------------------------

1. Configure your TIDB with these 2 options:

     * experimental / allow-expression-index:true  
     * alter-primary-key:true

    See https://docs.pingcap.com/tidb/stable/tidb-configuration-file#allow-expression-index-new-in-v400

    You can reference the tidb.pods.yaml file for a Kubernetes version of config

2. init your tidb with a new database, e.g.
    '''
    CREATE DATABASE metabase_dev;
    '''

3. create users metabase_root with all privileges and grant option on metabase_dev

4. start metabase in docker container by setting this ENV variable inside docker container to FALSE
    '''
    MB_DB_AUTOMIGRATE=false
    '''

5. metabase will start and then stop after giving you a list of SQL to run to do the manual migrations, ignore these SQL statements, which I have already fixed / modified in fixed_migrate0.39.1.sql to work with TIDB

6. connect to your TIDB instance using a mysql client from the same host running the DB, i.e. your mysql client appears as a client connected using 127.0.0.1 to TIDB:
    
    '''
    FPATH=/your/path/to/fixed_migrate0.39.1.sql
    mysql -h 127.0.0.1 -P 4000 -u root < $FPATH > output.txt 2>&1
    '''


7. restart your metabase container with the following setting:
    '''
    MB_DB_AUTOMIGRATE=true
    '''

   it should proceed normally.


Note: I have not modified the Liquibase resources/migrations/000_migrations.yaml file as that requires a lot of testing on mysql and tidb to ensure nothing is broken
