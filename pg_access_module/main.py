from sql_api import PgSqlAcess as pgaccess
import os
import psycopg2 as pg
connection = pg.connect(user = "doadmin",
                        password = "xiy137wyu7kydkt0",
                        host = "db-postgresql-lon1-28344-do-user-1661509-0.db.ondigitalocean.com",
                        port = "25060",
                        database = "defaultdb")
                                             

if __name__ == "__main__":
    
    """ This constructor should be initialised with 
        arg1 : username
        arg2 : PWD
    """
    pg_access_obj = pgaccess(connection)
    pg_access_obj.sqlConnection(connection)
    
    