from user_reg import NewUser as nu
import os


if __name__ == "__main__":
    
    """ This constructor should be initialised with 
        arg1 : username
        arg2 : PWD
    """
    nu_obj = nu(username,pwd)
    nu_obj.newUserReg(username,pwd)
    
    