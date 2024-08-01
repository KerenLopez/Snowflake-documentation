--Change role
USE ROLE SECURITYADMIN;

--Create user
CREATE USER SARA
    PASSWORD = 'password'
    LOGIN_NAME = 'quantil.sara'
    EMAIL = 'kerenlopezcordoba@gmail.com'
    COMMENT = 'this is a system admin user'
    MUST_CHANGE_PASSWORD = FALSE;
GRANT ROLE "SYSADMIN" TO USER SARA;