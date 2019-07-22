#!venv/bin/python
import os
from flask import Flask, url_for, redirect, render_template, request, abort, session, abort, Response, send_from_directory, make_response
from functools import wraps
import gc
from flask import Flask, abort, request, jsonify, g, url_for
from pg_access_module.sql_api import PgSqlAcess as pgaccess
from pg_user_reg.user_reg import NewUser as nu
from login_validation.login_val import LoginValidation as lv
import json
import psycopg2 as pg

connection = pg.connect(user = "doadmin",
                        password = "xiy137wyu7kydkt0",
                        host = "db-postgresql-lon1-28344-do-user-1661509-0.db.ondigitalocean.com",
                        port = "25060",
                        database = "defaultdb")
                        
## PG DB connection enabled
pg_access_obj = pgaccess(connection)
pg_access_obj.sqlConnection(connection)

app = Flask(__name__)

######################Template Rendering#################################################

## home page
@app.route('/', methods=['GET', 'POST'])
def index():
    return render_template('login.html')

## user registration page
@app.route('/userReg', methods=['GET', 'POST'])
def userReg():
    print('Enter')
    return render_template('user_reg.html')



######################Module#############################################################

## Call SQL module to insert new username and password in DB    
@app.route('/newUserDb', methods=['GET', 'POST'])
def newUserDb():
    
    ## Get name, username, pwd from client
    name        = request.form['name']
    username    = request.form['email']
    pwd         = request.form['password']
    ## call newUserReg module
    nu_obj = nu(name, username,pwd)
    nu_obj.newUserReg(name, username,pwd)
    
    ## close PG DB connection
    # pg_conn_close = pgaccess(connection)
    # pg_conn_close.sqlConnectionClose((connection)
    
    
## Login validation
@app.route('/fetchLoginStatus', methods=['GET', 'POST'])
def fetchLoginStatus():
    # status = 'OK'
    # dictTest = {}
    # dictTest['result'] = status
    # return json.dumps(dictTest)
    ## Get username, pwd from client
    username    = request.form['email']
    pwd         = request.form['password']
    ## call login validation module
    lv_obj = pg(username,pwd)
    lv_obj.loginValidation()
    
    ## close PG DB connection
    # pg_conn_close = pgaccess(connection)
    # pg_conn_close.sqlConnectionClose((connection)


if __name__ == '__main__':
    try:
        app.run(host= '0.0.0.0',port=5003,debug=True, threaded=False)
        
    except Exception as e:
        print('Error in starting::{}'.format(e))

