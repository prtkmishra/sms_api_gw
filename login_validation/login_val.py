#####################################################
# This module will create new user with Postgres SQL data base 
# To connect with PG DB, Psycopg2 is used

# Author: Prateek M

#####################################################

import psycopg2 as pg

class LoginValidation:
    username    = ""
    pwd         = ""


    def __init__(self, username, pwd):
        self.username = username
        self.pwd = pwd

    def loginValidation(self, username, pwd):
        ## validate login credentials
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
    