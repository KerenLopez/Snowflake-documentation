--Change role
use role securityadmin;

--Creating role lecture_user
create role "LECTURE_USER" comment = "this is a role for a user that can perform only select queries";
grant role "LECTURE_USER" to role "SYSADMIN";
--Assigning role
GRANT ROLE "LECTURE_USER" TO USER userLecture;

--Creating role dev_admin
create role "DEV_ADMIN" comment = "this is the admin role of the development area";
grant role "DEV_ADMIN" to role "SYSADMIN";
--Assigning role
GRANT ROLE "DEV_ADMIN" TO USER userdevAdmin;

--Creating role dev_user
create role "DEV_USER" comment = "this is a role for a user of the development area";
grant role "DEV_USER" to role "DEV_ADMIN";
--Assigning role
GRANT ROLE "DEV_USER" TO USER userDev;

--Creating role analytics_admin
create role "ANALYTICS_ADMIN" comment = "this is the admin role of the analytics area";
grant role "ANALYTICS_ADMIN" to role "SYSADMIN";
--Assigning role
GRANT ROLE "ANALYTICS_ADMIN" TO USER userAnalyticsAdmin;

--Creating role analytics_user
create role "ANALYTICS_USER" comment = "this is a role for a user of the analytics area";
grant role "ANALYTICS_USER" to role "ANALYTICS_ADMIN";
--Assigning role
GRANT ROLE "ANALYTICS_USER" TO USER userAnalytics;


--Giving other privilegies

--Suppose that the development area is the only one in charge of creating datawarehouses
use role sysadmin;
GRANT CREATE warehouse ON account TO role "DEV_ADMIN";
--Test: login into account

--Suppose that only the admin user of the analytics area can create databases (also schemas and tables)
GRANT CREATE database ON account TO role "ANALYTICS_ADMIN";
--Test: login into account

--Suppose that dev users can access to the created datawarehouses
use role accountadmin;
GRANT USAGE on warehouse compute_wh to role "DEV_USER";

--Test
use role dev_user;
show warehouses;


--GO TO SCRIPT TEST PRIVILEGES OF AN ANALYTICS_ADMIN TO CREATE SALES_DB!!


--Suppose that lecture user can only perform the select operation in all tables of an specific schema
use role sysadmin;
GRANT USAGE on database SALES_DB to role "LECTURE_USER"; 
GRANT USAGE on schema SALES_SCHEMA to role "LECTURE_USER"; 
GRANT SELECT on ALL tables IN schema SALES_SCHEMA to role "LECTURE_USER";
use role accountadmin;
GRANT USAGE on warehouse compute_wh to role "LECTURE_USER";

--Test
use role lecture_user;
use database SALES_DB;

select * from sales_schema.orders_table;

drop table sales_schema.orders_table;

update sales_schema.orders_table
set items = 'new_value'
where id = 12345;

--Suppose that analytics users can access to the created databases (also schemas and tables)
use role sysadmin;
GRANT USAGE on database sales_db to role "ANALYTICS_USER";
GRANT ALL PRIVILEGES on schema sales_schema to role "ANALYTICS_USER";
GRANT ALL PRIVILEGES on ALL tables IN schema sales_schema to role "ANALYTICS_USER";
use role accountadmin;
GRANT USAGE on warehouse compute_wh to role "ANALYTICS_USER";

--Test
use role analytics_user;
show warehouses;
show databases;
show schemas;
show tables;


