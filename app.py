#!venv/bin/python
import os
from flask import Flask, url_for, redirect, render_template, request, abort, session, abort, Response, send_from_directory, make_response
from functools import wraps
import gc
from flask import Flask, abort, request, jsonify, g, url_for
from pg_access_module.sql_api import PgSqlAcess
import json
# from bson.json_util import dumps

app = Flask(__name__)


## home page
@app.route('/', methods=['GET', 'POST'])
def index():
    return render_template('login.html')

## user registration page
@app.route('/userReg', methods=['GET', 'POST'])
def userReg():
    print('Enter')
    return render_template('user_reg.html')

    
## Login validation
@app.route('/fetchLoginStatus', methods=['GET', 'POST'])
def fetchLoginStatus():
    status = 'OK'
    dictTest = {}
    dictTest['result'] = status
    return json.dumps(dictTest)
    username = {}
    pwd = {}
    pg_access_obj = pg(username,pwd)
    pg_access_obj.loginValidation()
    

## Call SQL module to insert new username and password in DB    
@app.route('/newUserDb', methods=['GET', 'POST'])
def newUserDb():
    username = {}
    pwd = {}
    pg_access_obj = pg(username,pwd)
    pg_access_obj.newUserReg()
    

if __name__ == '__main__':
    try:
        app.run(host= '0.0.0.0',port=5003,debug=True, threaded=False)
    except Exception as e:
        print('Error in starting::{}'.format(e))

