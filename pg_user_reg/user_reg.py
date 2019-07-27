#####################################################
# This module will create new user with Postgres SQL data base 
# To connect with PG DB, Psycopg2 is used

# Author: Prateek M

#####################################################

import psycopg2 as pg

class NewUser:
    name        = ""
    username    = ""
    pwd         = ""


    def __init__(self, name, username, pwd):
        self.username = username
        self.pwd = pwd
    
    def newUserReg(self, name, username, pwd):
        ## create new SMS user#
        try:
            ## execute the PsotgreSQL query
            postgres_insert_query = """ INSERT INTO user (name, username, pwd) VALUES (%s,%s,%s)""" 
            record_to_insert = (self.name, self.username, self.pwd)
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
    