--Change role
use role accountadmin;

--CREATING THE ADMINISTRATIVE USERS

CREATE USER KEREN_LOPEZ
    PASSWORD = 'password'
    LOGIN_NAME = 'quantil.keren'
    EMAIL = 'kerenlopezcordoba@gmail.com'
    COMMENT = 'this is the security admin user'
    MUST_CHANGE_PASSWORD = FALSE;
--Assigning role    
GRANT ROLE "SECURITYADMIN" TO USER KEREN_LOPEZ;
GRANT ROLE "USERADMIN" TO USER KEREN_LOPEZ;

--Changing email
ALTER USER your_user_name SET EMAIL = 'your_email@example.com';

--Granting OWNERSHIP privilege to a user so he/she can change the e-mail address
GRANT OWNERSHIP ON USER your_user_name TO ROLE your_role_name;


--Change role
use role securityadmin;

CREATE USER userSysAdmin
    PASSWORD = 'password'
    COMMENT = 'this is the system admin user'
    MUST_CHANGE_PASSWORD = FALSE;
--Assigning role
GRANT ROLE "SYSADMIN" TO USER userSysAdmin;



--CREATING THE USERS RELATED TO THE CUSTOM ROLES

CREATE USER userLecture
    PASSWORD = 'password'
    COMMENT = 'this is a lecture user'
    MUST_CHANGE_PASSWORD = FALSE;

CREATE USER userDevAdmin
    PASSWORD = 'password'
    COMMENT = 'this is the development area admin user'
    MUST_CHANGE_PASSWORD = FALSE;

CREATE USER userAnalyticsAdmin
    PASSWORD = 'password'
    COMMENT = 'this is the analytics area admin user'
    MUST_CHANGE_PASSWORD = FALSE;

CREATE USER userDev
    PASSWORD = 'password'
    COMMENT = 'this is a dev user'
    MUST_CHANGE_PASSWORD = FALSE;

CREATE USER userAnalytics
    PASSWORD = 'password'
    COMMENT = 'this is an analytics user'
    MUST_CHANGE_PASSWORD = FALSE;




