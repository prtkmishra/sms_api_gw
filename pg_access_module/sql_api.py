#####################################################
# This module will interact with Postgres SQL data base 
# To connect with PG DB, Psycopg2 is used

# Author: Prateek M

#####################################################

import psycopg2 as pg

class PgSqlAcess:
    username    = 0
    pwd         = 0


def __init__(self, username, pwd):
    self.username = username
    self.pwd = pwd
    
def sqlConnection(self):
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
    # finally:
    ## closing database connection.
        # if(connection):
        # cursor.close()
        # connection.close()
        # print("PostgreSQL connection is closed")
        

def newUserReg(self, username, pwd):
    self.sqlConnection()
    ## create new SMS user#
    try:
        ## execute the PsotgreSQL query
        postgres_insert_query = """ New user name and password (%s,%s)"""
        record_to_insert = (self.username, self.pwd)
        cursor.execute(postgres_insert_query, record_to_insert)
        connection.commit()
        count = cursor.rowcount
        print (count, "Record inserted successfully into login table")
    except (Exception, psycopg2.Error) as error :
        if(connection):
            print("Failed to insert record into login table", error)
    finally:
    ## closing database connection.
        if(connection):
        cursor.close()
        connection.close()
        print("PostgreSQL connection is closed")
            

def loginValidation(self, username, pwd):
    self.sqlConnection()
    ##validate login credentials
    try:
        ## create new cursor 
        postgres_insert_query = """ SELECT (%s,%s)"""
        record_to_select = (self.username, self.pwd)
        cursor.execute(postgres_insert_query, record_to_select)
        row = cursor.fetchone()
        while row is not None:
            return row
            row = cursor.fetchone()
        cursor.close()
    except (Exception, psycopg2.Error) as error :
        if(connection):
            print("Failed to read record from login table", error)
    finally:
    ## closing database connection.
        if(connection):
        cursor.close()
        connection.close()
        print("PostgreSQL connection is closed")


        
    
   