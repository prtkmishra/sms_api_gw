#####################################################
# This module will interact with Postgres SQL data base 
# To connect with PG DB, Psycopg2 is used

# Author: Prateek M

#####################################################

import psycopg2 as pg

connection = ""

class PgSqlAcess:

    def __init__(self,connection):       
        self.connection = connection
    
    def sqlConnection(self, connection):
        ## PG DB Connection
        try:
            cursor = self.connection.cursor()
            ## Print PostgreSQL Connection properties
            print ( self.connection.get_dsn_parameters(),"\n")
            ## Print PostgreSQL version
            cursor.execute("SELECT version();")
            record = cursor.fetchone()
            print("You are connected to - ", record,"\n")
        except (Exception, pg.Error) as error :
            print ("Error while connecting to PostgreSQL", error)
        

def sqlConnectionClose(self, connection):
    ## closing database connection.
    cursor = self.connection.cursor()
    if(self.connection):
        cursor.close()
        self.connection.close()
        print("PostgreSQL connection is closed")
            




            
    
   