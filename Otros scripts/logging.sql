--Creating a DB for save the table that contains logging registers
CREATE OR REPLACE DATABASE tutorial_log_trace_db;

--Creating an event table
CREATE OR REPLACE EVENT TABLE tutorial_event_table;

--Asocciating the table to this account
USE ROLE ACCOUNTADMIN;

ALTER ACCOUNT SET EVENT_TABLE = tutorial_log_trace_db.public.tutorial_event_table;


--************************************************************************
--Emitting log messages with a user-defined function (UDF) made in Python
--************************************************************************

--Specifying the severity of log messages that Snowflake should capture as the UDF runs. In this case, the level permits all messages ranging from informational (INFO) to the most severe (FATAL).
ALTER SESSION SET LOG_LEVEL = WARN;

--UDF function
CREATE OR REPLACE FUNCTION log_trace_data()
RETURNS VARCHAR
LANGUAGE PYTHON
RUNTIME_VERSION = 3.8
HANDLER = 'run'
AS $$

import logging

logger = logging.getLogger("tutorial_logger")


def run():

  logger.info("Logging from Python function.")

  return "SUCCESS"
$$;

--Executing the function
SELECT log_trace_data();

--Query the event table for log message data emitted by the UDF
--It can take some time to see results
SELECT
  TIMESTAMP AS time,
  RESOURCE_ATTRIBUTES['snow.executable.name'] as executable,
  RECORD['severity_text'] AS severity,
  VALUE AS message
FROM
  tutorial_log_trace_db.public.tutorial_event_table
WHERE
  RECORD_TYPE = 'LOG'
  AND SCOPE['name'] = 'tutorial_logger'
ORDER BY
  TIMESTAMP DESC;

--Just curious about the structure 'cause some columns contain structured data expressed as key-value pairs 
SELECT * 
FROM tutorial_log_trace_db.public.tutorial_event_table
ORDER BY TIMESTAMP DESC;


--***************************************************************************************************
--Getting csv files from a stage
--***************************************************************************************************

LIST @EXCEL_FILES;

--Snowpark Python stored procedure (or SPROC) that will load the excel data files into snowflake tables for further analysis
CREATE OR REPLACE PROCEDURE LOAD_EXCEL_WORKSHEET_TO_TABLE_SP(file_path string, worksheet_name string, target_table string)
RETURNS VARIANT
LANGUAGE PYTHON
RUNTIME_VERSION = '3.10'
PACKAGES = ('snowflake-snowpark-python', 'pandas', 'openpyxl')
HANDLER = 'main'
AS
$$
from snowflake.snowpark.files import SnowflakeFile
from openpyxl import load_workbook
import pandas as pd
import logging

# Configurar el logger
logger = logging.getLogger("excel_loader")
logger.setLevel(logging.INFO)

def main(session, file_path, worksheet_name, target_table):
    try:
        logger.info(f"Starting to load worksheet '{worksheet_name}' from file '{file_path}' into table '{target_table}'")
        
        with SnowflakeFile.open(file_path, 'rb') as f:
            logger.info(f"Opened file '{file_path}' successfully.")
            workbook = load_workbook(f)
            logger.info(f"Loaded workbook from file '{file_path}' successfully.")
            
            if worksheet_name not in workbook.sheetnames:
                raise ValueError(f"Worksheet '{worksheet_name}' does not exist in the workbook.")
                
            sheet = workbook[worksheet_name]
            data = sheet.values
            
            # Obtener la primera línea como encabezados
            columns = next(data)[0:]
            logger.info(f"Columns detected: {columns}")
            
            # Crear un DataFrame con los datos
            df = pd.DataFrame(data, columns=columns)
            logger.info("DataFrame created successfully.")
            
            # Crear un DataFrame de Snowpark y guardar los datos en la tabla objetivo
            df2 = session.create_dataframe(df)
            df2.write.mode("overwrite").save_as_table(target_table)
            logger.info(f"Data written to table '{target_table}' successfully.")
        
        return True
    
    except Exception as e:
        logger.error(f"Error occurred while loading data: {str(e)}")
        return {"status": "failure", "error": str(e)}
$$;

--Calling the procedure
CALL LOAD_EXCEL_WORKSHEET_TO_TABLE_SP(BUILD_SCOPED_FILE_URL(@EXCEL_FILES, 'order_detail.xlsx'), 'order_detail', 'ORDER_DETAIL');

--CALL LOAD_EXCEL_WORKSHEET_TO_TABLE_SP(BUILD_SCOPED_FILE_URL(@EXCEL_FILES, 'intro/location.xlsx'), 'location', 'LOCATION');

--Query the event table for log message data emitted by the procedure
--It can take some time to see results
SELECT
  TIMESTAMP AS time,
  RESOURCE_ATTRIBUTES['snow.executable.name'] as executable,
  RECORD['severity_text'] AS severity,
  VALUE AS message
FROM
  tutorial_log_trace_db.public.tutorial_event_table
WHERE
  RECORD_TYPE = 'LOG'
  AND SCOPE['name'] = 'excel_loader'
ORDER BY
  TIMESTAMP DESC;

--Verifing table creation
DESCRIBE TABLE ORDER_DETAIL;
SELECT * FROM ORDER_DETAIL;

--DESCRIBE TABLE LOCATION;
--SELECT * FROM LOCATION;

--Executing SQL transformations based on the ORDER_DETAIL table
CREATE OR REPLACE PROCEDURE TRANSFORM_ORDER_DATA()
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.10'
PACKAGES = ('snowflake-snowpark-python')
HANDLER = 'main'
AS
$$
import logging

# Configurar el logger
logger = logging.getLogger("order_data_transformer")
logger.setLevel(logging.INFO)

def main(session):
    try:
        logger.info("Starting transformation process.")
        
        # Transformación SQL
        session.sql("""
            CREATE OR REPLACE TABLE transformed_orders AS
            SELECT
                ORDER_ID,
                TRUCK_ID,
                LOCATION_ID,
                COALESCE(CAST(CUSTOMER_ID AS STRING), 'UNKNOWN') AS CUSTOMER_ID,
                SHIFT_ID,
                SHIFT_START_TIME,
                SHIFT_END_TIME,
                COALESCE(CAST(ORDER_CHANNEL AS STRING), 'UNKNOWN') AS ORDER_CHANNEL,
                TO_TIMESTAMP(ORDER_TS) AS ORDER_TS,
                TO_TIMESTAMP(SERVED_TS) AS SERVED_TS,
                ORDER_CURRENCY,
                ORDER_AMOUNT,
                COALESCE(ORDER_TAX_AMOUNT, 0) AS ORDER_TAX_AMOUNT,
                COALESCE(ORDER_DISCOUNT_AMOUNT, 0) AS ORDER_DISCOUNT_AMOUNT,
                COALESCE(ORDER_TOTAL, ORDER_AMOUNT + COALESCE(ORDER_TAX_AMOUNT, 0) - COALESCE(ORDER_DISCOUNT_AMOUNT, 0)) AS ORDER_TOTAL,
                ORDER_DETAIL_ID,
                LINE_NUMBER,
                MENU_ITEM_ID,
                DISCOUNT_ID,
                QUANTITY,
                UNIT_PRICE,
                PRICE,
                COALESCE(ORDER_ITEM_DISCOUNT_AMOUNT, 0) AS ORDER_ITEM_DISCOUNT_AMOUNT
            FROM
                ORDER_DETAIL;
        """).collect()
        
        logger.info("Transformation process completed successfully.")
        return "Transformation completed successfully"
    
    except Exception as e:
        logger.error(f"Error during transformation process: {str(e)}")
        return f"Transformation failed: {str(e)}"
$$;

--Calling the procedure
CALL TRANSFORM_ORDER_DATA();

/*
List of the transformations performed

1. Null Value Handling:
    CUSTOMER_ID: If the value is null, it is replaced with 'UNKNOWN'.
    ORDER_CHANNEL: If the value is null, it is replaced with 'UNKNOWN'.
    ORDER_TAX_AMOUNT: If the value is null, it is replaced with 0.
    ORDER_DISCOUNT_AMOUNT: If the value is null, it is replaced with 0.
    ORDER_ITEM_DISCOUNT_AMOUNT: If the value is null, it is replaced with 0.
    
2. Date and Time Format Conversion:
    ORDER_TS: Converted from its original format to a TIMESTAMP.
    SERVED_TS: Converted from its original format to a TIMESTAMP.

3. Derived Value Calculation:
    ORDER_TOTAL: If the value is null, it is calculated by summing ORDER_AMOUNT and ORDER_TAX_AMOUNT and subtracting ORDER_DISCOUNT_AMOUNT.
*/

--Query the event table for log message data emitted by the procedure
--It can take some time to see results
SELECT
  TIMESTAMP AS time,
  RESOURCE_ATTRIBUTES['snow.executable.name'] as executable,
  RECORD['severity_text'] AS severity,
  VALUE AS message
FROM
  tutorial_log_trace_db.public.tutorial_event_table
WHERE
  RECORD_TYPE = 'LOG'
  AND SCOPE['name'] = 'order_data_transformer'
ORDER BY
  TIMESTAMP DESC;

--Verifing table creation
DESCRIBE TABLE TRANSFORMED_ORDERS;
SELECT * FROM TRANSFORMED_ORDERS;

--*************************************************************************************************
--Creating an alert for error registers on the log table
--*************************************************************************************************

--First create a notification integration
CREATE OR REPLACE NOTIFICATION INTEGRATION my_email_int
  TYPE=EMAIL
  ENABLED=TRUE;

--Create the alert to be notified on errors in the event table

CREATE OR REPLACE ALERT alert_new_warn_errors
    WAREHOUSE = 'COMPUTE_WH'
    SCHEDULE = '1 MINUTE'    
    IF (
        EXISTS(
            SELECT *
            FROM tutorial_log_trace_db.public.tutorial_event_table
                WHERE timestamp BETWEEN SNOWFLAKE.ALERT.LAST_SUCCESSFUL_SCHEDULED_TIME()
                AND SNOWFLAKE.ALERT.SCHEDULED_TIME()
                AND (
                    RECORD_TYPE = 'LOG'
                    AND RECORD['severity_text'] = 'ERROR'
                )    
        )
    )THEN CALL SYSTEM$SEND_EMAIL(
        'my_email_int',
        'keren.lopez@quantil.com.co',
        'Alert: Error(s) wit any procedure or function',
        'There were one or more errors. Please check the logs'
    );

--Set state on active mode
ALTER ALERT alert_new_warn_errors RESUME;

--See last logger events
SELECT VALUE
FROM tutorial_log_trace_db.public.tutorial_event_table
WHERE 
    RECORD_TYPE = 'LOG'
    AND RECORD['severity_text'] = 'ERROR'
ORDER BY
  TIMESTAMP DESC;

--Verifying integration and alert status
SHOW INTEGRATIONS LIKE 'MY_EMAIL_INT';
SHOW ALERTS LIKE 'ALERT_NEW_WARN_ERRORS';


--*************************************************************************************************
--Automatizing the load of files and table transformations
--*************************************************************************************************

--Task is a basic, smallest unit of execution.
--A Directed Acyclic Graph (DAG) is a series of tasks composed of a single root task and additional tasks, organized by their dependencies.

/*We have 3 tasks: 1 --> 2 ---> 3 
The dag is scheduled on the 15th of each month.

1. load_order_detail_task: loads the order_detail data by calling the stored procedure LOAD_EXCEL_WORKSHEET_TO_TABLE_SP.
2. load_location_task: loads the location data by calling the stored procedure LOAD_EXCEL_WORKSHEET_TO_TABLE_SP.
3. transform_order_data_task: makes some transformations on the ORDER_DETAIL table in snowflake by calling the stored procedure TRANSFORM_ORDER_DATA.*/

CREATE OR REPLACE TASK load_order_detail_task
WAREHOUSE = COMPUTE_WH
SCHEDULE = 'USING CRON 0 0 15 * * UTC'
AS
CALL LOAD_EXCEL_WORKSHEET_TO_TABLE_SP(BUILD_SCOPED_FILE_URL(@EXCEL_FILES, 'order_detail.xlsx'), 'order_detail', 'ORDER_DETAIL');

CREATE OR REPLACE TASK load_location_task
WAREHOUSE = COMPUTE_WH
AFTER load_order_detail_task
AS
CALL LOAD_EXCEL_WORKSHEET_TO_TABLE_SP(BUILD_SCOPED_FILE_URL(@EXCEL_FILES, 'location.xlsx'), 'location', 'LOCATION');

CREATE OR REPLACE TASK transform_order_data_task
WAREHOUSE = COMPUTE_WH
AFTER load_location_task
AS
CALL TRANSFORM_ORDER_DATA();

SHOW TASKS;