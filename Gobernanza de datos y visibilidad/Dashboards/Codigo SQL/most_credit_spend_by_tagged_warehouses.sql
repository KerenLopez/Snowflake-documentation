-- Step 1: Retrieve tagged warehouses
WITH Tagged_Warehouses AS (
    SELECT DISTINCT OBJECT_NAME AS WAREHOUSE_NAME
    FROM SNOWFLAKE.ACCOUNT_USAGE.TAG_REFERENCES
    WHERE DOMAIN = 'WAREHOUSE'
),

-- Step 2: Aggregate credit usage for tagged warehouses
Credit_Spend AS (
    SELECT 
        mh.WAREHOUSE_NAME,
        SUM(mh.CREDITS_USED) AS TOTAL_CREDITS
    FROM 
        SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY mh
    JOIN 
        Tagged_Warehouses tw
    ON 
        mh.WAREHOUSE_NAME = tw.WAREHOUSE_NAME
    WHERE 
        mh.START_TIME >= DATEADD('DAYS', -30, CURRENT_DATE())  -- Adjust time range if needed
    GROUP BY 
        mh.WAREHOUSE_NAME
)

-- Step 3: Select and sort the results
SELECT 
    WAREHOUSE_NAME,
    TOTAL_CREDITS
FROM 
    Credit_Spend
ORDER BY 
    TOTAL_CREDITS DESC;
