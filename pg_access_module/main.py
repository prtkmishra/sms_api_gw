from sql_api import PgSqlAcess as pg
import os


if __name__ == "__main__":
    
    """ This constructor should be initialised with 
        arg1 : username
        arg2 : PWD
    """
    pg_access_obj = pg(username,pwd)
    pg_access_obj.newUserReg()