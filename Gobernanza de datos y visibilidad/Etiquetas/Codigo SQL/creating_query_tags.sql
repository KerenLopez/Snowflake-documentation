----------------------------------------------------------------------------
--SESSION-LEVEL QUERY TAG
----------------------------------------------------------------------------
USE ROLE ACCOUNTADMIN;
SET SESSION_ID_VAR = CURRENT_SESSION();

ALTER SESSION SET QUERY_TAG = 'DEMO_DEV QUERIES';

--Execute a query
USE DATABASE DEMO_DEV;
SELECT * FROM SALES_DM.CUSTOMER;
SELECT * FROM SALES_DM.CUSTOMER WHERE C_SALUTATION LIKE 'Dr.';

--Verify that the query tag was applied to the query
SELECT * FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY());

--Unset query tag
ALTER SESSION UNSET QUERY_TAG;
SELECT * FROM SALES_DM.CUSTOMER WHERE C_FIRST_NAME LIKE 'Jane';

--Verify that the query tag was removed
SELECT * FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY());

----------------------------------------------------------------------------
--USER-LEVEL QUERY TAG
----------------------------------------------------------------------------
ALTER USER SARA SET QUERY_TAG = 'TeamA';
ALTER USER JOHN SET QUERY_TAG = 'TeamB';
ALTER USER HAPPY SET QUERY_TAG = 'TeamC';
ALTER USER ALICE SET QUERY_TAG = 'TeamD';

--Verify the queries by an specific tag
SELECT USER_NAME, ROLE_NAME, QUERY_TAG
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE QUERY_TAG = 'TeamA'
GROUP BY USER_NAME, ROLE_NAME, QUERY_TAG;

--Unset query tag
ALTER USER SARA UNSET QUERY_TAG;

----------------------------------------------------------------------------
--ACCOUNT-LEVEL QUERY TAG
----------------------------------------------------------------------------
ALTER ACCOUNT DYZKCFJ.YAB45029 SET QUERY_TAG = 'HighPriority';

--Execute a query
SELECT * FROM SALES_DM.CUSTOMER;
SELECT * FROM SALES_DM.CUSTOMER_ADRESS WHERE CA_STATE LIKE 'GA';

--Verify that the query tag was applied to the query
SELECT * FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY());

--Unset query tag
ALTER ACCOUNT DYZKCFJ.YAB45029 UNSET QUERY_TAG;
SELECT * FROM SALES_DM.CUSTOMER_ADRESS WHERE CA_STATE LIKE 'CA';

--Verify that the query tag was removed
SELECT * FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY());

------------------------------------------------------------------------------------
--Visualizing executed queries
------------------------------------------------------------------------------------

SELECT * FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY_BY_USER()) WHERE USER_NAME LIKE 'SARA' ORDER BY START_TIME;

SELECT * 
FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY_BY_SESSION()) 
WHERE SESSION_ID LIKE $SESSION_ID_VAR;

--Number of queries made by tag
SELECT 
    QUERY_TAG, 
    COUNT(*) AS NUM_QUERIES
FROM 
    SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE 
    QUERY_TAG IS NOT NULL
GROUP BY 
    QUERY_TAG;
