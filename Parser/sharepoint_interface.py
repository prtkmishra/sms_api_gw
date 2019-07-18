import requests
import json
from requests.auth import HTTPBasicAuth
import sys
from collections import Counter
#from Parser.global_vars import globalData
from global_vars import globalData
import requests
import pprint
from requests_ntlm import HttpNtlmAuth

class SharepointParser:

    url = ''
    username = ''
    password = ''
    sharepoint_url = 'http://ats-sharepoint.aeroflex.com/_api/web/'
    sharepoint_user = 'saurabh.bansal@viavisolutions.com'
    sharepoint_password = 'Qwerty"12345'


    def __init__(self):
        self.url = globalData.__SHAREPOINT_URL__
        self.username = globalData.__USER_NAME__
        self.password = globalData.__PASSWORD__
        

    def accessAndProcessSharepoint(self):
        
        #Sharepoint URL should be the address of the site followed by /_api/web/
       
        sharepoint_contextinfo_url = 'http://ats-sharepoint.aeroflex.com/_api/contextinfo'
        sharepoint_listname = 'products'
         
        headers = {
        "Accept":"application/json; odata=verbose",
        "Content-Type":"application/json; odata=verbose",
        "odata":"verbose",
        "X-RequestForceAuthentication": "true"
        }
        
        auth = HttpNtlmAuth(self.sharepoint_user, self.sharepoint_password)
        print(auth)
        r = requests.get(sharepoint_contextinfo_url+"lists/getbytitle('%s')" % sharepoint_listname, auth=auth, headers=headers, verify=False)
        print(r)
        
        #list_id = r.json()['d']['Id']
        #print(list_id)
        #list_itemcount = r.json()['d']['Id']
        #print(process_exists('TmaApplication.exe'))
        #objSharepointParser = SharepointParser()
        #objJIRAParser.getBugDistributionOnNFG()
        #objSharepointParser.getResultFile()
    
if __name__ == '__main__':

    objSharepointParser = SharepointParser()
    objSharepointParser.accessAndProcessSharepoint()
