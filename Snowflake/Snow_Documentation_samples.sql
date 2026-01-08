Even we can use IP address range for safety reasons

select CURRENT_IP_ADDRESS();

+----------------------+
| CURRENT_IP_ADDRESS() |
|----------------------|
| 223.185.22.219       |
+----------------------+

https://whatismyipaddress.com/ -- Visit and see current IP of the machine - IPv4: 223.185.22.219 -- Wow

select current_Date current_Date();  -- Both works in SQL but in scripting lang need to used with ()

select CURRENT_REGION();  -- Current region for the account where the current user is logged in. 
+------------------+
| CURRENT_REGION() |
|------------------|
| AWS_US_WEST_2    |
+------------------+

Show the current region when the current user is logged into an account in an organization that spans multiple region groups:

+----------------------+
| CURRENT_REGION()     |
|----------------------|
| PUBLIC.AWS_US_WEST_2 |
+----------------------+

CURRENT_TIME( [ <fract_sec_precision> ] ) -- fract_sec_precision 0-9 digits for seconds

select CURRENT_TIME(3), CURRENT_TIME(9);  -- not working 
+-----------------+-----------------+
| CURRENT_TIME(3) | CURRENT_TIME(9) |
|-----------------+-----------------|
| 22:07:54        | 22:07:54        |
+-----------------+-----------------+

Fractional seconds are only displayed if they have been explicitly set in the TIME_OUTPUT_FORMAT parameter for the session (e.g. 'HH24:MI:SS.FF').

alter session set TIME_OUTPUT_FORMAT='HH24:MI:SS.FF';

select CURRENT_TIME(3), CURRENT_TIME(9);  -- works now
+-----------------+--------------------+
| CURRENT_TIME(3) | CURRENT_TIME(9)    |
|-----------------+--------------------|
| 22:17:25.258    | 22:17:25.258000000 |
+-----------------+--------------------+

SELECT CURRENT_TIME;
SELECT LOCALTIME(); --- ANSI compliant alias for CURRENT_TIME

+--------------------+
| CURRENT_TIME       |
|--------------------|
| 22:18:54.373000000 |
+--------------------+

select CURRENT_TIMESTAMP(3), CURRENT_TIMESTAMP(9);  
select CURRENT_TIMESTAMP(3), LOCALTIMESTAMP(9), ;     -- ANSI compliant alias for CURRENT_TIMESTAMP
SELECT CURRENT_TIMESTAMP(3), GETDATE();     -- alias for CURRENT_TIMESTAMP
select CURRENT_TIMESTAMP(3), SYSDATE();     -- alias for CURRENT_TIMESTAMP
select CURRENT_TIMESTAMP(3), SYSTIMESTAMP();     -- alias for CURRENT_TIMESTAMP

Fractional seconds are only displayed if they have been explicitly set in the TIMESTAMP_OUTPUT_FORMAT parameter for the session (e.g. 'YYYY-MM-DD HH24:MI:SS.FF').

Users with any active role can retrieve the list of all usernames in the current account.

select all_user_names();
+--------------------------------+
| ALL_USER_NAMES()               |
|--------------------------------|
| [ "NESANAWSNEW", "SNOWFLAKE" ] |
+--------------------------------+

Usernames (i.e. the NAME property value) are the unique identifier of the user object in Snowflake, while login names (i.e. the LOGIN_NAME property value) are used to authenticate to Snowflake. Usernames are not sensitive data and are returned by other commands and functions (e.g. SHOW GRANTS). Login names are sensitive data.

show grants;
+-------------------------------+--------------+------------+--------------+------------+
| created_on                    | role         | granted_to | grantee_name | granted_by |
|-------------------------------+--------------+------------+--------------+------------|
| 2024-11-18 08:39:12.483 -0800 | ACCOUNTADMIN | USER       | NESANAWSNEW  |            |
| 2024-11-18 08:39:16.477 -0800 | ORGADMIN     | USER       | NESANAWSNEW  |            |
+-------------------------------+--------------+------------+--------------+------------+
2 Row(s) produced. Time Elapsed: 0.325s

As a best practice, username and login name values should be different. To update existing username or login name values, execute the ALTER USER command. When creating new users with the CREATE USER command, ensure that the NAME and LOGIN_NAME values are different.

SELECT CURRENT_ACCOUNT();
+-------------------+
| CURRENT_ACCOUNT() |
|-------------------|
| CPB95846          |
+-------------------+

SELECT CURRENT_ACCOUNT_NAME();
+------------------------+
| CURRENT_ACCOUNT_NAME() |
|------------------------|
| JXB47930               |
+------------------------+

SELECT CURRENT_ORGANIZATION_NAME();
+-----------------------------+
| CURRENT_ORGANIZATION_NAME() |
|-----------------------------|
| CRCNDFT                     |
+-----------------------------+

SELECT CURRENT_ROLE();

Granting access on a secure UDF or secure view that contains this function to a share is allowed. When the secure UDF or secure view is accessed from the data sharing consumer account, this function always returns a NULL value.

Snowflake returns a NULL value if this function is used in a masking policy or row access policy that is assigned to a shared table or view.

CURRENT_AVAILABLE_ROLES, CURRENT_ROLE , CURRENT_SECONDARY_ROLES , IS_ROLE_IN_SESSION

This CURRENT_AVAILABLE_ROLES function returns a list of account-level roles only when queried by a user. Querying the function using a service that has no active user could result in a failed query. For example, the function does not return a list of roles when queried within a task, because the task runs are executed by a system service that is not associated with a user. In this case, the query could time out because the query plan cannot be completed.
This function does not return the names of database roles, application roles, or class instance roles.
This function does not account for role activation in a session.
For example, if specifying this function in the conditions of a masking policy or a row access policy, the policy might inadvertently restrict access.
If role activation and role hierarchy is necessary in the policy conditions, use IS_ROLE_IN_SESSION.

select CURRENT_AVAILABLE_ROLES();
+------------------------------------------------------------------------------------+
| CURRENT_AVAILABLE_ROLES()                                                          |
|------------------------------------------------------------------------------------|
| [ "ACCOUNTADMIN", "ORGADMIN", "PUBLIC", "SECURITYADMIN", "SYSADMIN", "USERADMIN" ] |
+------------------------------------------------------------------------------------+

select CURRENT_SECONDARY_ROLES();
+---------------------------+
| CURRENT_SECONDARY_ROLES() |
|---------------------------|
| {"roles":"","value":""}   |
+---------------------------+

SELECT INDEX,VALUE,THIS FROM TABLE(FLATTEN(input => PARSE_JSON(CURRENT_AVAILABLE_ROLES())));

+-------+-----------------+--------------------+
| INDEX | VALUE           | THIS               |
|-------+-----------------+--------------------|
|     0 | "ACCOUNTADMIN"  | [                  |
|       |                 |   "ACCOUNTADMIN",  |
|       |                 |   "ORGADMIN",      |
|       |                 |   "PUBLIC",        |
|       |                 |   "SECURITYADMIN", |
|       |                 |   "SYSADMIN",      |
|       |                 |   "USERADMIN"      |
|       |                 | ]                  |
|     1 | "ORGADMIN"      | [                  |
|       |                 |   "ACCOUNTADMIN",  |
|       |                 |   "ORGADMIN",      |
|       |                 |   "PUBLIC",        |
|       |                 |   "SECURITYADMIN", |
|       |                 |   "SYSADMIN",      |
|       |                 |   "USERADMIN"      |
|       |                 | ]                  |
|     2 | "PUBLIC"        | [                  |
|       |                 |   "ACCOUNTADMIN",  |
|       |                 |   "ORGADMIN",      |
|       |                 |   "PUBLIC",        |
|       |                 |   "SECURITYADMIN", |
|       |                 |   "SYSADMIN",      |
|       |                 |   "USERADMIN"      |
|       |                 | ]                  |
|     3 | "SECURITYADMIN" | [                  |
|       |                 |   "ACCOUNTADMIN",  |
|       |                 |   "ORGADMIN",      |
|       |                 |   "PUBLIC",        |
|       |                 |   "SECURITYADMIN", |
|       |                 |   "SYSADMIN",      |
|       |                 |   "USERADMIN"      |
|       |                 | ]                  |
|     4 | "SYSADMIN"      | [                  |
|       |                 |   "ACCOUNTADMIN",  |
|       |                 |   "ORGADMIN",      |
|       |                 |   "PUBLIC",        |
|       |                 |   "SECURITYADMIN", |
|       |                 |   "SYSADMIN",      |
|       |                 |   "USERADMIN"      |
|       |                 | ]                  |
|     5 | "USERADMIN"     | [                  |
|       |                 |   "ACCOUNTADMIN",  |
|       |                 |   "ORGADMIN",      |
|       |                 |   "PUBLIC",        |
|       |                 |   "SECURITYADMIN", |
|       |                 |   "SYSADMIN",      |
|       |                 |   "USERADMIN"      |
|       |                 | ]                  |
+-------+-----------------+--------------------+
6 Row(s) produced. Time Elapsed: 1157.569s

Returns a unique system identifier for the Snowflake session corresponding to the present connection. will generally be a system-generated alphanumeric string. It is NOT derived from the user name or user account.

SELECT CURRENT_SESSION();
+-------------------+
| CURRENT_SESSION() |
|-------------------|
| 748007209440346   |
+-------------------+

SELECT 2.71, CURRENT_STATEMENT();

CURRENT_TRANSACTION, LAST_TRANSACTION , DESCRIBE TRANSACTION

begin TRANSACTION;

SELECT CURRENT_TRANSACTION();
+-----------------------+
| CURRENT_TRANSACTION() |
|-----------------------|
| 1732436987323000000   |
+-----------------------+
1 Row(s) produced. Time Elapsed: 0.448s

rollback; -- must commit or rollback to end the transaction

SELECT CURRENT_TRANSACTION();
+-----------------------+
| CURRENT_TRANSACTION() |
|-----------------------|
| NULL                  |
+-----------------------+
1 Row(s) produced. Time Elapsed: 0.590s

SELECT LAST_TRANSACTION();    -- Same as above as the transaction ended.

+---------------------+
| LAST_TRANSACTION()  |
|---------------------|
| 1732436987323000000 |
+---------------------+

CURRENT_USER

SELECT CURRENT_USER();

+----------------+
| CURRENT_USER() |
|----------------|
| NESANAWSNEW    |
+----------------+

To comply with the ANSI standard, this function can be called without parentheses in SQL statements.

However, if you are setting a Snowflake Scripting variable to an expression that calls the function (for example, my_var := CURRENT_USER();), you must include the parentheses. For more information, see the usage notes for context functions.

Granting access on a secure UDF or secure view that contains this function to a share is allowed. When the secure UDF or secure view is accessed from the data sharing consumer account, this function always returns a NULL value.

Snowflake returns a NULL value if this function is used in a masking policy or row access policy that is assigned to a shared table or view.

GETVARIABLE

SET MY_LOCAL_VARIABLE= 'my_local_variable_value';

SELECT 
    GETVARIABLE('MY_LOCAL_VARIABLE'),      -- must be upper case
    SESSION_CONTEXT('MY_LOCAL_VARIABLE'),   -- must be upper case
    $my_local_variable;       -- Can be lower case
+----------------------------------+--------------------------------------+-------------------------+
| GETVARIABLE('MY_LOCAL_VARIABLE') | SESSION_CONTEXT('MY_LOCAL_VARIABLE') | $MY_LOCAL_VARIABLE      |
|----------------------------------+--------------------------------------+-------------------------|
| my_local_variable_value          | my_local_variable_value              | my_local_variable_value |
+----------------------------------+--------------------------------------+-------------------------+

When variables are created with the SET command, the variable names are forced to all upper case. The functions GETVARIABLE and SESSION_CONTEXT must pass the uppercase version of the function name. The “$” notation works with either uppercase or lowercase variable names.

SET var_2 = 'value_2';

SELECT 
    GETVARIABLE('var_2'),  -- Returns NULL 
    GETVARIABLE('VAR_2'),
    SESSION_CONTEXT('var_2'),  -- Returns NULL 
    SESSION_CONTEXT('VAR_2'),
    $var_2,
    $VAR_2;

+----------------------+----------------------+--------------------------+--------------------------+---------+---------+
| GETVARIABLE('VAR_2') | GETVARIABLE('VAR_2') | SESSION_CONTEXT('VAR_2') | SESSION_CONTEXT('VAR_2') | $VAR_2  | $VAR_2  |
|----------------------+----------------------+--------------------------+--------------------------+---------+---------|
| NULL                 | value_2              | NULL                     | value_2                  | value_2 | value_2 |
+----------------------+----------------------+--------------------------+--------------------------+---------+---------+

LAST_QUERY_ID

LAST_QUERY_ID( [ <num> ] )  -- [ <num> ] is Default: -1 Specifies the query to return, based on the position of the query (within the session).

LAST_QUERY_ID(1) returns the first query.

LAST_QUERY_ID(2) returns the second query.

LAST_QUERY_ID(6) returns the sixth query.

LAST_QUERY_ID(-1) returns the most recently-executed query (equivalent to LAST_QUERY_ID()).

LAST_QUERY_ID(-2) returns the second most recently-executed query.

SELECT LAST_QUERY_ID();
+--------------------------------------+
| LAST_QUERY_ID()                      |
|--------------------------------------|
| 01b894fc-0004-386c-0002-a84f00016536 |
+--------------------------------------+

SELECT LAST_QUERY_ID(1);
+--------------------------------------+
| LAST_QUERY_ID(1)                     |
|--------------------------------------|
| 01b89410-0004-3869-0002-a84f000195c2 |
+--------------------------------------+


RESULT_SCAN

RESULT_SCAN ( { '<query_id>' | <query_index>  | LAST_QUERY_ID() } )

SELECT $1 AS value FROM VALUES (1), (2), (3);
+-------+
| VALUE |
|-------|
|     1 |
|     2 |
|     3 |
+-------+
3 Row(s) produced. Time Elapsed: 0.340s

SELECT * FROM TABLE(RESULT_SCAN(LAST_QUERY_ID())) WHERE value > 1;

+-------+
| VALUE |
|-------|
|     2 |
|     3 |
+-------+
2 Row(s) produced. Time Elapsed: 1.048s

SELECT * FROM table(RESULT_SCAN(LAST_QUERY_ID(-2)));
+-------+
| VALUE |
|-------|
|     1 |
|     2 |
|     3 |
+-------+

SELECT * FROM table(RESULT_SCAN(LAST_QUERY_ID(1)));
+----------------+----------------+
| CURRENT_USER() | CURRENT_ROLE() |
|----------------+----------------|
| NESANAWSNEW    | ACCOUNTADMIN   |
+----------------+----------------+

Examples using DESCRIBE and SHOW commands

DESC USER NESANAWSNEW;  -- display all the user property 

SELECT "property", "value" FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
  WHERE "property" = 'DEFAULT_ROLE'
  ;

+--------------+--------------+
| property     | value        |
|--------------+--------------|
| DEFAULT_ROLE | ACCOUNTADMIN |
+--------------+--------------+

show tables limit 2; --- limit can be used with show commands Also

SHOW TABLES;
-- Show the tables that are more than 2 days old and that are empty
-- (i.e. tables that I might have forgotten about).
SELECT "database_name", "schema_name", "name" as "table_name", "rows", "created_on"
    FROM table(RESULT_SCAN(LAST_QUERY_ID()))
    WHERE "rows" = 0 AND "created_on" < DATEADD(day, -2, CURRENT_TIMESTAMP())
    ORDER BY "created_on";

Process the result of a SHOW TABLES command to extract the tables in descending order of size. This example also illustrates using a UDF to show table size in a slightly more human-readable format.

-- Show byte counts with suffixes such as "KB", "MB", and "GB".
CREATE OR REPLACE FUNCTION NiceBytes(NUMBER_OF_BYTES INTEGER)
RETURNS VARCHAR
AS
$$
CASE
    WHEN NUMBER_OF_BYTES < 1024
        THEN NUMBER_OF_BYTES::VARCHAR
    WHEN NUMBER_OF_BYTES >= 1024 AND NUMBER_OF_BYTES < 1048576
        THEN (NUMBER_OF_BYTES / 1024)::VARCHAR || 'KB'
   WHEN NUMBER_OF_BYTES >= 1048576 AND NUMBER_OF_BYTES < (POW(2, 30))
       THEN (NUMBER_OF_BYTES / 1048576)::VARCHAR || 'MB'
    ELSE
        (NUMBER_OF_BYTES / POW(2, 30))::VARCHAR || 'GB'
END
$$
;
SHOW TABLES;
-- Show all of my tables in descending order of size.
SELECT "database_name", "schema_name", "name" as "table_name", NiceBytes("bytes") AS "size"
    FROM table(RESULT_SCAN(LAST_QUERY_ID()))
    ORDER BY "bytes" DESC;

+---------------+-------------+------------+--------------+
| database_name | schema_name | table_name | size         |
|---------------+-------------+------------+--------------|
| LEARNING_SQL  | PUBLIC      | CUSTOMER   | 4.539551MB   |
| LEARNING_SQL  | PUBLIC      | LINEITEM   | 3.652344MB   |
| LEARNING_SQL  | PUBLIC      | ORDERS     | 3.611816MB   |
| LEARNING_SQL  | PUBLIC      | PARTSUPP   | 727.000000KB |
| LEARNING_SQL  | PUBLIC      | SUPPLIER   | 489.000000KB |
| LEARNING_SQL  | PUBLIC      | PART       | 144.500000KB |
| LEARNING_SQL  | PUBLIC      | PERSON     | 4.000000KB   |
| LEARNING_SQL  | PUBLIC      | NATION     | 3.000000KB   |
| LEARNING_SQL  | PUBLIC      | EMPLOYEE   | 2.000000KB   |
| LEARNING_SQL  | PUBLIC      | REGION     | 2.000000KB   |
| LEARNING_SQL  | PUBLIC      | DEPARTMENT | 1.500000KB   |
| LEARNING_SQL  | PUBLIC      | EMPL_DEPT  | 1.000000KB   |
+---------------+-------------+------------+--------------+

Examples using a stored procedure

Stored procedure calls return a value. However, this value cannot be processed directly because you cannot embed a stored procedure call in another statement. To work around this limitation, you can use RESULT_SCAN to process the value returned by a stored procedure. A simplified example is below:

First, create a procedure that returns a “complicated” value (in this case, a string that contains JSON-compatible data) that can be processed after it has been returned from the CALL.

CREATE OR REPLACE PROCEDURE return_JSON()
    RETURNS VARCHAR
    LANGUAGE JavaScript
    AS
    $$
        return '{"keyA": "ValueA", "keyB": "ValueB"}';
    $$
    ;
	
CALL return_JSON();
+--------------------------------------+
| RETURN_JSON                          |
|--------------------------------------|
| {"keyA": "ValueA", "keyB": "ValueB"} |
+--------------------------------------+

SELECT $1 AS output_col FROM table(RESULT_SCAN(LAST_QUERY_ID()));  -- Get the first (and only) column:
+--------------------------------------+
| OUTPUT_COL                           |
|--------------------------------------|
| {"keyA": "ValueA", "keyB": "ValueB"} |
+--------------------------------------+

SELECT PARSE_JSON(output_col) AS JSON_COL FROM table(RESULT_SCAN(LAST_QUERY_ID())); -- Convert from a VARCHAR to a VARIANT:
+---------------------+
| JSON_COL            |
|---------------------|
| {                   |
|   "keyA": "ValueA", |
|   "keyB": "ValueB"  |
| }                   |
+---------------------+

SELECT JSON_COL:keyB FROM table(RESULT_SCAN(LAST_QUERY_ID()));  -- Extract the value that corresponds to the key “keyB”:
+---------------+
| JSON_COL:KEYB |
|---------------|
| "ValueB"      |
+---------------+

Achive all the above in single query

CALL return_JSON();
+--------------------------------------+
| RETURN_JSON                          |
|--------------------------------------|
| {"keyA": "ValueA", "keyB": "ValueB"} |
+--------------------------------------+
SELECT JSON_COL:keyB 
   FROM (
        SELECT PARSE_JSON($1::VARIANT) AS JSON_COL 
            FROM table(RESULT_SCAN(LAST_QUERY_ID()))
        );
+---------------+
| JSON_COL:KEYB |
|---------------|
| "ValueB"      |
+---------------+

Same using the column name of the returned value of proc

CALL return_JSON();
+--------------------------------------+
| RETURN_JSON                          |
|--------------------------------------|
| {"keyA": "ValueA", "keyB": "ValueB"} |
+--------------------------------------+
SELECT JSON_COL:keyB
        FROM (
             SELECT PARSE_JSON(RETURN_JSON::VARIANT) AS JSON_COL 
                 FROM table(RESULT_SCAN(LAST_QUERY_ID()))
             );
+---------------+
| JSON_COL:KEYB |
|---------------|
| "ValueB"      |
+---------------+


