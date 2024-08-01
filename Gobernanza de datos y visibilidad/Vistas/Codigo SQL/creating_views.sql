USE ROLE ACCOUNTADMIN;
USE DATABASE DEMO_DEV;
USE SCHEMA SALES_DM;

--Adding a new table to the DB
CREATE OR REPLACE TABLE DEMO_DEV.SALES_DM.ORDERS
AS
SELECT * FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF100.ORDERS;
 
-- Provides a normal view of the preferred customers in the state of Georgia that had orders with a total price over 48.000 and urgent priority. 

CREATE OR REPLACE VIEW DEMO_DEV.SALES_DM.CUSTOMER_DETAILS_VW AS
SELECT 
    c.C_CUSTOMER_ID,
    c.C_FIRST_NAME,
    c.C_LAST_NAME,
    c.C_EMAIL_ADDRESS,
    ca.CA_STREET_NAME,
    ca.CA_CITY,
    ca.CA_STATE,
    ca.CA_ZIP,
    o.O_ORDERKEY,
    o.O_TOTALPRICE,
    o.O_ORDERDATE
FROM 
    DEMO_DEV.SALES_DM.CUSTOMER c
JOIN 
    DEMO_DEV.SALES_DM.CUSTOMER_ADRESS ca
ON 
    c.C_CURRENT_ADDR_SK = ca.CA_ADDRESS_SK
JOIN
    DEMO_DEV.SALES_DM.ORDERS o
ON
    c.C_CUSTOMER_SK = o.O_CUSTKEY
WHERE 
    ca.CA_STATE = 'GA'
    AND c.C_PREFERRED_CUST_FLAG = 'Y'
    AND o.O_TOTALPRICE > 48000.0
    AND o.O_ORDERPRIORITY LIKE '1%';
    
--Click on query_id to see the details
SELECT * FROM DEMO_DEV.SALES_DM.CUSTOMER_DETAILS_VW;

-- Secure version of the same data, offering additional security features such as data encryption and stricter access controls, while presenting the same information. 

CREATE OR REPLACE SECURE VIEW DEMO_DEV.SALES_DM.CUSTOMER_DETAILS_SECURE_VW AS
SELECT 
    c.C_CUSTOMER_ID,
    c.C_FIRST_NAME,
    c.C_LAST_NAME,
    c.C_EMAIL_ADDRESS,
    ca.CA_STREET_NAME,
    ca.CA_CITY,
    ca.CA_STATE,
    ca.CA_ZIP,
    o.O_ORDERKEY,
    o.O_TOTALPRICE,
    o.O_ORDERDATE
FROM 
    DEMO_DEV.SALES_DM.CUSTOMER c
JOIN 
    DEMO_DEV.SALES_DM.CUSTOMER_ADRESS ca
ON 
    c.C_CURRENT_ADDR_SK = ca.CA_ADDRESS_SK
JOIN
    DEMO_DEV.SALES_DM.ORDERS o
ON
    c.C_CUSTOMER_SK = o.O_CUSTKEY
WHERE 
    ca.CA_STATE = 'GA'
    AND c.C_PREFERRED_CUST_FLAG = 'Y'
    AND o.O_TOTALPRICE > 48000.0
    AND o.O_ORDERPRIORITY LIKE '1%';
    
--Click on query_id again. Now the joins and filters made to get the result doesn't appears
SELECT * FROM DEMO_DEV.SALES_DM.CUSTOMER_DETAILS_SECURE_VW;

--Creating a materialized view of orders with a total price over 48000 and an urgent priority
CREATE OR REPLACE MATERIALIZED VIEW DEMO_DEV.SALES_DM.ORDERS_MV AS
SELECT 
    O_CUSTKEY,
    O_ORDERKEY,
    O_TOTALPRICE,
    O_ORDERDATE
FROM 
    DEMO_DEV.SALES_DM.ORDERS
WHERE 
    O_TOTALPRICE > 48000.0
    AND O_ORDERPRIORITY LIKE '1%';

--Checking the materialized view    
SELECT * FROM DEMO_DEV.SALES_DM.ORDERS_MV;

--Deleting the materialized view
DROP MATERIALIZED VIEW IF EXISTS DEMO_DEV.SALES_DM.ORDERS_MV;



