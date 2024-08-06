--Change role
use role analytics_admin;

create database sales_db;

create schema sales_schema;

create table orders_table(id number, items varchar(50));

use database sales_db;

insert into sales_schema.orders_table (id, items)
values (12345, 'initial_value');

INSERT INTO SALES_DB.SALES_SCHEMA.ORDERS_TABLE (ID, ITEMS) VALUES (1, 'Laptop');
INSERT INTO SALES_DB.SALES_SCHEMA.ORDERS_TABLE (ID, ITEMS) VALUES (2, 'Smartphone');
INSERT INTO SALES_DB.SALES_SCHEMA.ORDERS_TABLE (ID, ITEMS) VALUES (3, 'Tablet');


INSERT INTO SALES_DB.SALES_SCHEMA.ORDERS_TABLE (ID, ITEMS) VALUES (4, 'Headphones');
INSERT INTO SALES_DB.SALES_SCHEMA.ORDERS_TABLE (ID, ITEMS) VALUES (5, 'Smartwatch');
INSERT INTO SALES_DB.SALES_SCHEMA.ORDERS_TABLE (ID, ITEMS) VALUES (6, 'Keyboard');


INSERT INTO SALES_DB.SALES_SCHEMA.ORDERS_TABLE (ID, ITEMS) VALUES (7, 'Mouse');
INSERT INTO SALES_DB.SALES_SCHEMA.ORDERS_TABLE (ID, ITEMS) VALUES (8, 'Monitor');

INSERT INTO SALES_DB.SALES_SCHEMA.ORDERS_TABLE (ID, ITEMS) VALUES (9, 'Printer');
INSERT INTO SALES_DB.SALES_SCHEMA.ORDERS_TABLE (ID, ITEMS) VALUES (10, 'Camera');





