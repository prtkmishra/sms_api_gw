"""
This module will interact with Postgres SQL data base 
To connect with PG DB, Psycopg2 is used

Author: Prateek M

""" 

import psycopg2 as pg

## PG DB Connection
try:
    connection = pg.connect(user = "doadmin",
                                  password = "xiy137wyu7kydkt0",
                                  host = "db-postgresql-lon1-28344-do-user-1661509-0.db.ondigitalocean.com",
                                  port = "25060",
                                  database = "defaultdb")
    cursor = connection.cursor()
    ## Print PostgreSQL Connection properties
    print ( connection.get_dsn_parameters(),"\n")
    ## Print PostgreSQL version
    cursor.execute("SELECT version();")
    record = cursor.fetchone()
    print("You are connected to - ", record,"\n")
except (Exception, pg.Error) as error :
    print ("Error while connecting to PostgreSQL", error)
finally:
    ## closing database connection.
        if(connection):
            cursor.close()
            connection.close()
            print("PostgreSQL connection is closed")