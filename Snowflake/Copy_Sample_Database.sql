use role SYSADMIN;

create DATABASE Learning_Sql;

use schema Learning_Sql.public;

create table region 
as select * from snowflake_sample_data.tpch_sf1.region;

create table nation 
as select * from snowflake_sample_data.tpch_sf1.nation;

create table part as
select * from snowflake_sample_data.tpch_sf1.part 
where mod(p_partkey,50) = 8;

create table partsupp as
select * from snowflake_sample_data.tpch_sf1.partsupp
where mod(ps_partkey,50) = 8;

create table supplier as
with sp as (select distinct ps_suppkey from partsupp)
select s.* from snowflake_sample_data.tpch_sf1.supplier s
inner join sp
on s.s_suppkey = sp.ps_suppkey;

create table lineitem as
select l.* from snowflake_sample_data.tpch_sf1.lineitem l
inner join part p
on p.p_partkey = l.l_partkey;

create table orders as
with li as (select distinct l_orderkey from lineitem)
select o.* from snowflake_sample_data.tpch_sf1.orders o
inner join li on o.o_orderkey = li.l_orderkey;

create table customer as
with o as (select distinct o_custkey from orders)
select c.* from snowflake_sample_data.tpch_sf1.customer c
inner join o on c.c_custkey = o.o_custkey;

show tables in public;


describe table region;
show terse tables in PUBLIC;

show terse databases;

!set prompt_format=[schema]>;

select 'Welcome to Snowflake SQL!';

select 'Welcome to Snowflake SQL!' as
welcome_message,
5 * 3.1415927 as circle_circumference,
dayname(current_date) as day_of_week;

describe table nation;
select n_nationkey, n_name, n_regionkey from nation;

select n_regionkey from nation;
select distinct n_regionkey from nation;

-- distinct to your select clause will instruct the server to sort the values and remove any duplicates.

select n_nationkey, n_name as nation_name,
r_name as region_name
from nation join region
on nation.n_regionkey = region.r_regionkey;

-- Generate Dataset on the fly using query

select *
from (values
('JAN',1),
('FEB',2),
('MAR',3),
('APR',4),
('MAY',5),
('JUN',6),
('JUL',7),
('AUG',8),
('SEP',9),
('OCT',10),
('NOV',11),
('DEC',12))
as months (month_name, month_num);


with my_mon as (
select *
from (values
('JAN',1),
('FEB',2),
('MAR',3),
('APR',4),
('MAY',5),
('JUN',6),
('JUL',7),
('AUG',8),
('SEP',9),
('OCT',10),
('NOV',11),
('DEC',12))
as months (month_name, month_num))
select * from my_mon where month_Num <=6;

select n_name
from nation
where n_name like 'U%';

select n_name
from nation
where n_name like 'U%'
or n_name like 'A%';

select r_name as region_name,
count(*) as number_of_countries
from nation join region
on nation.n_regionkey = region.r_regionkey
group by r_name;

describe table supplier;

select n_name, count(*) as no_supp from supplier join nation on supplier.S_NATIONKEY=nation.N_NATIONKEY 
group by n_name having no_supp>300; 
 
select n_name, count(*) as no_supp from supplier join nation on supplier.S_NATIONKEY=nation.N_NATIONKEY 
where n_name like '%A%' group by n_name having no_supp>300; 

select n_name, count(*) as no_supp from supplier join nation on supplier.S_NATIONKEY=nation.N_NATIONKEY 
where n_name like '%A' group by n_name having no_supp>300; 

select n_name,
rank() over (order by length(n_name) desc)
as length_rank
from nation;

select n_name,
DENSE_RANK() over (order by length(n_name) desc)
as length_dense_rank
from nation;

select n_name,
rank() over (order by length(n_name) desc)
as length_rank
from nation
qualify length_rank <= 5;

select s_name, s_acctbal
from supplier
order by s_acctbal desc limit 10;

select s_name, s_acctbal
from supplier
order by 2 desc limit 10;

select s_name, s_acctbal
from supplier
order by s_acctbal desc
limit 10 offset 7390;      --- skip 7390 rows show only last 10 rows

select top 10 s_name, s_acctbal
from supplier
order by s_acctbal desc;   -- Same as limit 10

Excercise - Chap1
select n_nationkey, n_name from nation order by n_name;

select n_nationkey, n_name from nation join region on nation.n_regionkey = region.r_regionkey where n_regionkey=3;  

select n_nationkey, n_name from nation join region on nation.n_regionkey = region.r_regionkey where r_name='AFRICA';

select s_name, s_acctbal from supplier order by s_acctbal limit 10;

where last_name = 'SMITH' and state = 'CA'
where last_name = 'SMITH' or state = 'CA'

where (last_name = 'SMITH' or last_name = 'JACKSON')
and (state = 'CA' or state = 'WA')

where not ((last_name = 'SMITH' or last_name ='JACKSON') 
and (state = 'CA' or state = 'WA'))

where last_name <> 'SMITH' and last_name <> 'JACKSON' 
and state <> 'CA' and state <> 'WA'

c_custkey = 12345
s_name = 'Acme Wholesale'
o_orderdate = to_date('02/14/2022','MM/DD/YYYY')

-- equality conditions in both the from and where clauses
select n_name, r_name
from nation join region
on nation.n_regionkey = region.r_regionkey
where r_name = 'ASIA';

-- inequality condition either the != or <> operator.
select n_name, r_name
from nation join region
on nation.n_regionkey = region.r_regionkey
where r_name <> 'ASIA';

-- Range Conditions Ranges are inclusive
select s_suppkey, s_name
from supplier
where s_suppkey between 1 and 10;

select o_orderkey, o_custkey, o_orderdate
from orders
where o_orderdate between
to_date('29-JAN-1998','DD-MON-YYYY')
and to_date('30-JAN-1998','DD-MON-YYYY');

select n_name from nation
where n_name between 'GA' and 'IP';

-- Membership Conditions 

where c_mktsegment = 'AUTOMOBILE' or c_mktsegment =
'MACHINERY' or c_mktsegment = 'BUILDING'

where c_mktsegment in ('AUTOMOBILE','MACHINERY','BUILDING')

-- Matching Conditions
select n_name
from nation
where n_name like 'M%';

 -- 'I___' Exactly 4 characters long starting with I
 -- '__A%' 3 or more characters in length, A in third position

select n_name
from nation
where n_name like 'M%'
or n_name like 'U%'
or n_name like 'I____'
or n_name like '%MANY%';

-- Regular Expression

select n_name
from nation
where regexp_like(n_name, '^[MU].*');

-- Null Values
-- An expression can be null, but it can never equal null.
-- Two nulls are never equal to each other.

select 'YES' as is_valid where null = null;  -- 0 rows
select 'YES' as is_valid where null is null; -- 1 row YES

create table null_example
(num_col number, char_col varchar(10))
as select *
from (values (1, 'ABC'),
(2, 'JKL'),
(null, 'QRS'),
(3, null));

select * from null_example;

-- function is nvl(),which can be used to substitute a value for any nulls encountered.

select num_col, char_col
from null_example
where nvl(num_col,0) < 3;  --- substitute Null value with 0

select nvl(num_col,0) as num_col, char_col
from null_example
where nvl(num_col,0) < 3;

select o_orderkey, o_custkey, o_orderdate from orders 
where o_orderdate = :daterange
and o_orderpriority = :ord_pri;

select o_orderkey, o_custkey, o_orderdate from orders 
where (o_orderdate >= ('2024-11-16 10:38:44')::timestamp AND o_orderdate < ('2024-11-17 10:38:44')::timestamp) ;

Excercise - Chap2
select c_name , c_acctbal from  Customer where 
c_mktsegment = 'MACHINERY' and c_acctbal > 9998;

select c_name , c_acctbal, c_mktsegment from  Customer where 
c_mktsegment in ( 'MACHINERY', 'FURNITURE') and c_acctbal between -1 and 1;

select c_name , c_acctbal, c_mktsegment from  Customer where 
(c_mktsegment = 'MACHINERY' and c_acctbal =20) or (c_mktsegment = 'FURNITURE' and c_acctbal =334);

with Balances as (
select *
from (values
(1234,342.22),
(3498,9.00),
(3887, null),
(6277, 28.33))
as months (Acct_Num, Acct_Bal))
select * from Balances where (Acct_Bal!=9) or (Acct_Bal is null);

describe table customer;
describe table orders;

select o_orderkey, o_orderstatus,
o_orderdate, c_name
from orders join customer
on orders.o_custkey = customer.c_custkey
limit 10;

-- not required to specify the inner keyword in the from clause.

select o.o_orderkey, o.o_orderstatus,
o.o_orderdate,
c.c_name
from orders as o
join customer as c
on o.o_custkey = c.c_custkey
limit 10;

select o.o_orderkey, o.o_orderstatus,
o.o_orderdate,
c.c_name
from orders as o
inner join customer as c
on o.o_custkey = c.c_custkey
limit 10;

create table customer_simple (custkey,
custname)
as select *
from (values (101, 'BOB'), (102, 'KIM'),
(103, 'JIM'));

select * from customer_simple;

create table orders_simple (ordernum,
custkey)
as select *
from (values (990, 101), (991, 102),
(992, 101), (993, 104));

select * from orders_simple;

-- 993 is not selected in below query
select o.ordernum, o.custkey, c.custname
from orders_simple as o
inner join
customer_simple as c
on o.custkey = c.custkey;

-- Outer join selects 993 with Null for Custname
-- left outer, meaning that all rows from the table on the left side of the join
select o.ordernum, o.custkey, c.custname
from orders_simple as o
left outer join
customer_simple as c
on o.custkey = c.custkey;

-- Right join selects JIM from customer_simple table with NULL for ordernum and custkey
select o.ordernum, o.custkey, c.custname
from orders_simple as o
right outer join
customer_simple as c
on o.custkey = c.custkey;

-- Full is both left and Right join selects JIM from customer_simple table with NULL for ordernum and custkey
-- also all rows from the table on the left side of the join
select o.ordernum, o.custkey, c.custname
from orders_simple as o
full outer join
customer_simple as c
on o.custkey = c.custkey;

-- Cross join cross join does not include the on subclause, since there is no join being specified.
select years.yearnum, qtrs.qtrname,
qtrs.startmonth,
qtrs.endmonth
from
(values (2020), (2021), (2022))
as years (yearnum)
cross join
(values ('Q1',1,3), ('Q2',4,6), ('Q3',7,9),
('Q4',10,12))
as qtrs (qtrname, startmonth, endmonth)
order by 1,2;

+---------+---------+------------+----------+
| YEARNUM | QTRNAME | STARTMONTH | ENDMONTH |
|---------+---------+------------+----------|
|    2020 | Q1      |          1 |        3 |
|    2020 | Q2      |          4 |        6 |
|    2020 | Q3      |          7 |        9 |
|    2020 | Q4      |         10 |       12 |
|    2021 | Q1      |          1 |        3 |
|    2021 | Q2      |          4 |        6 |
|    2021 | Q3      |          7 |        9 |
|    2021 | Q4      |         10 |       12 |
|    2022 | Q1      |          1 |        3 |
|    2022 | Q2      |          4 |        6 |
|    2022 | Q3      |          7 |        9 |
|    2022 | Q4      |         10 |       12 |
+---------+---------+------------+----------+

describe table lineitem;
describe table part;

-- Joining three tables
select o.o_orderkey, o.o_orderdate, c.c_name,
p.p_name
from orders as o
inner join customer as c
on o.o_custkey = c.c_custkey
inner join lineitem as l
on o.o_orderkey = l.l_orderkey
inner join part p
on l.l_partkey = p.p_partkey
limit 10;

create table employee
(empid number, emp_name varchar(30),
mgr_empid number)
as select *
from (values
(1001, 'Bob Smith', null),
(1002, 'Susan Jackson', 1001),
(1003, 'Greg Carpenter', 1001),
(1004, 'Robert Butler', 1002),
(1005, 'Kim Josephs', 1003),
(1006, 'John Tyler', 1004));

select * from employee;

+-------+----------------+-----------+
| EMPID | EMP_NAME       | MGR_EMPID |
|-------+----------------+-----------|
|  1001 | Bob Smith      |      NULL |
|  1002 | Susan Jackson  |      1001 |
|  1003 | Greg Carpenter |      1001 |
|  1004 | Robert Butler  |      1002 |
|  1005 | Kim Josephs    |      1003 |
|  1006 | John Tyler     |      1004 |
+-------+----------------+-----------+

-- Self join
select e.empid, e.emp_name, mgr.emp_name as
mgr_name
from employee as e
inner join employee as mgr
on e.mgr_empid = mgr.empid;

+-------+----------------+----------------+
| EMPID | EMP_NAME       | MGR_NAME       |
|-------+----------------+----------------|
|  1002 | Susan Jackson  | Bob Smith      |
|  1003 | Greg Carpenter | Bob Smith      |
|  1004 | Robert Butler  | Susan Jackson  |
|  1005 | Kim Josephs    | Greg Carpenter |
|  1006 | John Tyler     | Robert Butler  |
+-------+----------------+----------------+

-- Table aliases are required in this query because you need to refer to each table in the from clause using a unique name.
-- To include Bob in the results, the previous query needs to be modified to use an outer join

select e.empid, e.emp_name, mgr.emp_name as
mgr_name
from employee e
left outer join employee mgr
on e.mgr_empid = mgr.empid;

+-------+----------------+----------------+
| EMPID | EMP_NAME       | MGR_NAME       |
|-------+----------------+----------------|
|  1002 | Susan Jackson  | Bob Smith      |
|  1003 | Greg Carpenter | Bob Smith      |
|  1004 | Robert Butler  | Susan Jackson  |
|  1005 | Kim Josephs    | Greg Carpenter |
|  1006 | John Tyler     | Robert Butler  |
|  1001 | Bob Smith      | NULL           |
+-------+----------------+----------------+

alter table employee add column
birth_nationkey integer;

alter table employee add column
current_nationkey integer;

describe employee;

update employee
set birth_nationkey = empid - 1000,
current_nationkey = empid - 999;

-- Since every row in Employee potentially references two different rows in the Nation table, the query needs to join Nation twice using two different table aliases.

select e.empid, e.emp_name,
n1.n_name as birth_nation, n2.n_name as
current_nation
from employee e
inner join nation as n1
on e.birth_nationkey = n1.n_nationkey
inner join nation as n2
on e.current_nationkey = n2.n_nationkey;

+-------+----------------+--------------+----------------+
| EMPID | EMP_NAME       | BIRTH_NATION | CURRENT_NATION |
|-------+----------------+--------------+----------------|
|  1001 | Bob Smith      | ARGENTINA    | BRAZIL         |
|  1002 | Susan Jackson  | BRAZIL       | CANADA         |
|  1003 | Greg Carpenter | CANADA       | EGYPT          |
|  1004 | Robert Butler  | EGYPT        | ETHIOPIA       |
|  1005 | Kim Josephs    | ETHIOPIA     | FRANCE         |
|  1006 | John Tyler     | FRANCE       | GERMANY        |
+-------+----------------+--------------+----------------+

select e.empid, e.emp_name,
n1.n_name as birth_nation, n2.n_name as
current_nation
from employee e
inner join nation as n1
on e.birth_nationkey = n1.n_nationkey
inner join nation as n2
on e.current_nationkey = n2.n_nationkey;

Chap 4

A = {1, 2, 4, 7, 9}
B = {3, 5, 7, 9}
A union B = {1, 2, 3, 4, 5, 7, 9}   -- Duplicates are eliminated 7,9

select 1 as numeric_col, 'ABC' as string_col
union
select 2 as numeric_col, 'XYZ' as string_col;

-- Both sets must contain the same number of columns.
-- The data types of the columns must match.

select 1 as numeric_col, 'ABC' as string_col
union
select 2 as numeric_col, 'XYZ' as string_col,
99 as extra_col;
001789 (42601): SQL compilation error:
invalid number of result columns for set operator

select 1 as numeric_col, 'ABC' as string_col
union
select 'XYZ' as numeric_col, 2 as string_col;
100038 (22018): Numeric value 'ABC' is not recognized

select integer_val
from (values (1), (2), (4), (7), (9))
as set_a (integer_val)
union
select integer_val
from (values (3), (5), (7), (9))
as set_b (integer_val);

-- As you can see, both sets include 7 and 9, but these values only appear once in the result set because the union operator sorts the values and removes duplicates.

-- While this is the default behavior, there are cases when you don’t want the duplicates to be removed, in which case you can use union all

select integer_val
from (values (1), (2), (4), (7), (9))
as set_a (integer_val)
union all
select integer_val
from (values (3), (5), (7), (9))
as set_b (integer_val);

-- find all customers who placed orders greater than $350,000 in 1992 or 1993:
select distinct o_custkey
from orders
where o_totalprice > 350000
and date_part(year, o_orderdate) = 1992
union
select distinct o_custkey
from orders
where o_totalprice > 350000
and date_part(year, o_orderdate) = 1993;


A = {1, 2, 4, 7, 9}
B = {3, 5, 7, 9}
A intersect B = {7, 9} -- Only common values are results

select integer_val
from (values (1), (2), (4), (7), (9))
as set_a (integer_val)
intersect
select integer_val
from (values (3), (5), (7), (9))
as set_b (integer_val);

+-------------+
| INTEGER_VAL |
|-------------|
|           7 |
|           9 |
+-------------+

-- find all customers who placed orders greater than $350,000 in 1992 and 1993:
select distinct o_custkey
from orders
where o_totalprice > 350000
and date_part(year, o_orderdate) = 1992
intersect
select distinct o_custkey
from orders
where o_totalprice > 350000
and date_part(year, o_orderdate) = 1993;

+-----------+
| O_CUSTKEY |
|-----------|
|    100510 |
+-----------+

-- only one of the customer placed such orders in both years.

A = {1, 2, 4, 7, 9}
B = {3, 5, 7, 9}
A except B = {1, 2, 4}  -- 

select integer_val
from (values (1), (2), (4), (7), (9))
as set_a (integer_val)
except
select integer_val
from (values (3), (5), (7), (9))
as set_b (integer_val);

+-------------+
| INTEGER_VAL |
|-------------|
|           1 |
|           2 |
|           4 |
+-------------+

A = {1, 2, 4, 7, 9}
B = {3, 5, 7, 9}
B except A = {3, 5}   

select integer_val
from (values (3), (5), (7), (9))
as set_b (integer_val)
except
select integer_val
from (values (1), (2), (4), (7), (9))
as set_a (integer_val);

+-------------+
| INTEGER_VAL |
|-------------|
|           3 |
|           5 |
+-------------+

-- There may only be one order by clause, and it must be at the end of the statement.
-- When specifying column names in the order by clause, you must use the column names/aliases from the first query.

select distinct o_orderdate from orders
intersect
select distinct l_shipdate from lineitem
order by o_orderdate;

select distinct o_orderdate from orders
intersect
select distinct l_shipdate from lineitem
order by l_shipdate;
000904 (42000): SQL compilation error: error line 4
at position 9
invalid identifier 'L_SHIPDATE'


(A union B) except (A intersect B) 
-- or --
(A except B) union (B except A)

-- If your compound query contains more than two queries using different set operators, you need to consider the order in which to place the queries in order to achieve the desired results.

select integer_val
from (values (1), (2), (4), (7), (9))
as set_a (integer_val);

select integer_val
from (values (3), (5), (7), (9))
as set_b (integer_val);

-- there are multiple ways to generate the shaded area in Figure 4-5, which in this case is the set {1, 2, 3, 4, 5}, but let’s choose the second one:

(A except B) union (B except A)

-- Without precendance fix result is wrong
-- The issue here is that the server is applying these operations from the top down, whereas these operations need to be grouped together.

select integer_val
from (values (1), (2), (4), (7), (9))
as set_a (integer_val)
except
select integer_val
from (values (3), (5), (7), (9))
as set_b (integer_val)
union
select integer_val
from (values (3), (5), (7), (9))
as set_b (integer_val)
except
select integer_val
from (values (1), (2), (4), (7), (9))
as set_a (integer_val);

+-------------+
| INTEGER_VAL |
|-------------|
|           5 |
|           3 |
+-------------+

(select integer_val
from (values (1), (2), (4), (7), (9))
as set_a (integer_val)
except
select integer_val
from (values (3), (5), (7), (9))
as set_b (integer_val)
)
union
(select integer_val
from (values (3), (5), (7), (9))
as set_b (integer_val)
except
select integer_val
from (values (1), (2), (4), (7), (9))
as set_a (integer_val)
);

+-------------+
| INTEGER_VAL |
|-------------|
|           1 |
|           2 |
|           4 |
|           5 |
|           3 |
+-------------+

-- When building compound queries with three or more set operators, make sure you consider how the different operations may need to be grouped in order to achieve the desired results.

Excercise - Chap4

-- Write a compound query that returns the names of all regions  (Region.r_name) and nations (Nation.n_name) that start with the letter A. 

select r_name from region where r_name like 'A%'
union
select n_name from nation where n_name like 'A%';

-- Modify the query from Exercise 4-2 to sort by name (the default sort is fine).

select r_name as all_name from region where r_name like 'A%'
union
select n_name as nation_name from nation where n_name like 'A%'
order by all_name;

Chap 5
Data Types

Character Data

varchar that can store up to 16 MB of character data. Data is stored sing the Unicode UTF-8 character set, so the upper limit on the number of characters that may be stored in a single varchar column depends on whether you are storing single-byte or multibyte characters.

favorite_movie varchar(100)

Snowflake would store up to 100 bytes of data depending on the length of the string. If you do not specify a maximum length, the column will hold up to 16 MB.

Char datatypes 
~~~~~~~~~~~~~~~~~
char, character, char varying
nchar, nchar varying
nvarchar, nvarchar2
string, text

While you are free to use any of these synonyms, they are generally used for porting table definitions from other database servers. If you’re building new tables in Snowflake, you should just use varchar.

All character columns stored in Snowflake are variablelength, even if defined using char, and Snowflake will never add spaces to the end of a string. The only thing to keep in mind when defining a column as char in Snowflake is that the default length is 1 if you do not specify a length.

select 'here is a string' as output_string;

select 'you haven''t reached the end yet' as output_string;

-- For complex strings, you have the option of using two dollar signs ($$) as delimiters, in which case Snowflake will accept the string exactly as written

select $$string with 4 single quotes ' ' ' 
'

two lines gap$$
as output_string;

+------------------------------------+
| OUTPUT_STRING                      |
|------------------------------------|
| string with 4 single quotes ' ' '  |
| '                                  |
|                                    |
| two lines gap                      |
+------------------------------------+

Numeric Data

Snowflake has a single data type called number that will handle just about any type of numeric data. The values stored in a number column can include up to 38 digits, either with a decimal point (floating-point numbers) or without (integers).

The total number of digits is known as the precision, and the maximum number of digits to the right of the decimal 	point (if there are any) is called the scale.

default will be number(38,0). such as numbers between –999.99 and 999.99, you could define the column in this case to be number(5,2). The storage needed for numeric data is variable depending on the number of digits, so there is nothing wasteful about defining all of your numeric columns as number(38,0).

Numeric datatypes 
~~~~~~~~~~~~~~~~~
decimal, numeric, real
tinyint, smallint, int, integer, bigint
double, float, float4, float8

integer for integers and number for floating point numbers.

Temporal Data

dates and/or times.
Three types are supported 

Data type 	Allowable range
date 		1582-01-01 to 9999-12-31
time 		00:00:00 to 23:59:59.999999999
timestamp 	1582-01-01 00:00:00 to 9999-12-31 23:59:59.999999999

Snowflake dates can range from the year 1582 to the year 9999, and times are comprised of hours, minutes, seconds, and partial seconds to 9 significant digits (nanoseconds). Timestamps are a combination of date and time and come in three flavors:

timestamp_ntz
No specific time zone
timestamp_ltz
Uses current session’s time zone
timestamp_tz
Allows time zone to be specified

show parameters; -- To know the timezone in snowflake system
show parameters like 'timez%'; -- To know the timezone in snowflake system

-- To set the timezone
alter session set
timezone='America/New_York';

-- To set the timezone
alter account set
timezone='America/New_York';

alter session command to change the time zone in your session, or the alter account command if you’d like to make the change permanent.

select current_date, current_time,
current_timestamp;

+--------------+--------------+-------------------------------+
| CURRENT_DATE | CURRENT_TIME | CURRENT_TIMESTAMP             |
|--------------+--------------+-------------------------------|
| 2024-11-19   | 05:49:55     | 2024-11-19 05:49:55.315 -0800 |
+--------------+--------------+-------------------------------+

-800 designation at the end of the timestamp value tells me that my time zone is 8 hours behind Greenwich 
Snowflake is very flexible regarding date literals and can handle many common formats. Mean Time (GMT).

'24-OCT-2022'
'10/24/2022'
'2022-10-24'

However, there is a single default format for date values to be returned, which is found in the date_output_format parameter:

show parameters like 'date_output%';

alter session set date_output_format='DD-MM-YYYY';

timestamp_output_format parameter is used for timestamp

Other Data Types
Boolean
logical data type and can hold the values true and false.

Strings 'true', '1', 'yes', 't', 'y', 'on' for true
Strings 'false', '0', 'no', 'f', 'n', 'off' for false
Number 0 for false
Any nonzero number for true

You can use true and false by themselves, or as part of an expression,

select true, false, true = true, true = false;

Like any other data type, boolean columns may also be null.

Variant
Variant is the Swiss Army knife of data types; it can hold any type of data. As you can imagine, this provides a great deal of flexibility when storing semistructured data. If you are inserting values into a variant column, you can use the :: operator to cast a string, number, date, etc., to a variant type.
You can also use the variant data type to store JSON documents

select 1::variant, 'abc'::variant, current_date::variant;

Snowflake provides the built-in function typeof() to tell you what type of data is being stored:

select typeof('this is a character string'::variant);
select typeof(false::variant);
select typeof(current_timestamp::variant);

Array

The array data type is a variable-length array of variant values. Arrays can be created with an initial length of 0 or   greater and can be extended later; there is no upper limit on the number of elements in an array, but there is an overall size limit of 16 MB. The square brackets ([ and ]) are used as delimiters for array literals; here’s an example of an array containing a number, a string, and a time value:

select [123, 'ABC', current_time] as my_array;

+--------------+
| MY_ARRAY     |
|--------------|
| [            |
|   123,       |
|   "ABC",     |
|   "06:06:53" |
| ]            |
+--------------+

The result set is a single row containing a single column of type array. Arrays can be flattened into X rows (X = 3 in this case) by using a combination of the table() and flatten() functions:

Object

Snowflake’s object type stores an array of key-value pairs, with the keys being of type varchar and the values of type variant. Object literals are created using curly braces ({ and }), and keys are separated from values using colons.

select {'new_years' : '01/01',
'independence_day' : '07/04',
'christmas' : '12/25'}
as my_object;    -- one row with one object

+--------------------------------+
| MY_OBJECT                      |
|--------------------------------|
| {                              |
|   "christmas": "12/25",        |
|   "independence_day": "07/04", |
|   "new_years": "01/01"         |
| }                              |
+--------------------------------+
1 Row(s) produced. Time Elapsed: 0.395s

select typeof({'new_years' : '01/01',
'independence_day' : '07/04',
'christmas' : '12/25'})
as my_object;    -- one row with one object

+-----------+
| MY_OBJECT |
|-----------|
| OBJECT    |
+-----------+

you can use the flatten() and table() functions to transform this result set into three rows, each having a key and value column:

select key, value
from table(flatten(
{'new_years' : '01/01',
'independence_day' : '07/04',
'christmas' : '12/25'}));    -- 3 rows of key and value

+------------------+---------+
| KEY              | VALUE   |
|------------------+---------|
| christmas        | "12/25" |
| independence_day | "07/04" |
| new_years        | "01/01" |
+------------------+---------+
3 Row(s) produced. Time Elapsed: 0.394s

select value
from table(flatten(
{'new_years' : '01/01',
'independence_day' : '07/04',
'christmas' : '12/25'}))
where key = 'new_years';

create table person
(first_name varchar(50),
last_name varchar(50),
birth_date date,
eye_color varchar(10),
occupation varchar(50),
children array,
years_of_education number(2,0)
);

insert into person (first_name, last_name,
birth_date,
eye_color, occupation, children,
years_of_education)
values ('Bob','Smith','22-JAN-2000','blue','teacher',
null, 18);

Therefore, the previous example could have omitted the children column, as shown in the next example, which adds a row for Gina Peters

insert into person (first_name, last_name,
birth_date,
eye_color, occupation, years_of_education)
values ('Gina','Peters','03-MAR-2001','brown',
'student', 12);

insert into person (first_name, last_name, birth_date, eye_color, occupation, years_of_education)
values
('Tim','Carpenter','09-JUL-2002','green','salesman', 16),
('Kathy','Little','29-AUG-2001','blue','professor', 20),
('Sam','Jacobs','13-FEB-2003','brown','lawyer', 18);

Snowflake provides the overwrite option, which will first remove all rows from the table before inserting new rows.

insert overwrite into person
(first_name, last_name, birth_date,
eye_color, occupation, years_of_education)
values
('Bob','Smith','22-JAN-2000','brown','teacher', 18),
('Gina','Peters','03-MAR-2001','green','student', 12),
('Tim','Carpenter','09-JUL-2002','blue','salesman', 16),
('Kathy','Little','29-AUG-2001','brown','professor', 20),
('Sam','Jacobs','13-FEB-2003','blue','lawyer', 18);

Along with using values, you can use a select statement to generate one or more rows to be inserted into a table.

insert into person (first_name, last_name,
birth_date,
eye_color, occupation, children,
years_of_education)
select 'Sharon' as first_name,
last_name, birth_date, eye_color,
'doctor' as occupation,
['Sue'::variant, 'Shawn'::variant] as
children,
20 as years_of_education
from person
where first_name = 'Tim' and last_name = 
'Carpenter';

select query can retrieve data from any table

select first_name, last_name from person;

delete from person
where first_name = 'Sam' and last_name =
'Jacobs';

above was simple delete but in some cases you might want to remove rows in one table based on rows in another table.
For example, Bob Smith appears in both the Person and Employee tables:

select first_name, last_name
from person
where last_name = 'Smith';

+------------+-----------+
| FIRST_NAME | LAST_NAME |
|------------+-----------|
| Bob        | Smith     |
+------------+-----------+

select emp_name
from employee
where emp_name like '%Smith';

+-----------+
| EMP_NAME  |
|-----------|
| Bob Smith |
+-----------+

Let’s say you want to remove any rows from Person TABLE where a row exists in Employee TABLE having the same name (Bob Smith happens to be the only case).

delete from person
using employee
where employee.emp_name =
concat(person.first_name, ' ',
person.last_name);

select first_name, last_name from person;
select emp_name from employee;

Snowflake has a feature called Time Travel, which allows you to see the state of your data at a particular point in time. If you are using Snowflake Standard edition, you can see your data as it was up to 24 hours ago. With Snowflake Enterprise, you can configure the retention period to be up to 90 days in the past.

delete from employee where emp_name =
'Greg Carpenter';

You can query the Employee table as it was 10 minutes ago (travel –600 seconds into the past) by using the at subclause:

select * from employee at(offset => -600)
where emp_name = 'Greg Carpenter';  -- -600 is 600 seconds 10 mins BACKUP

-- Using above data insert the data back in to the table with select 
insert into employee
select * from employee at(offset => -600)
where emp_name = 'Greg Carpenter';

Modifying Data

Your statement will need to identify which row(s) you want to modify by specifying a where clause, and then describe the desired changes in a set clause.

update person
set occupation = 'musician', eye_color =
'grey'
where first_name = 'Kathy' and last_name =
'Little';

+------------------------+-------------------------------------+
| number of rows updated | number of multi-joined rows updated |
|------------------------+-------------------------------------|
|                      1 |                                   0 |
+------------------------+-------------------------------------+

Snowflake’s response tells us that one row was updated, but it also specifies that no multijoined rows were modified. This second piece of information isn’t relevant if your statement uses a where clause, but you can optionally use a from clause if you want to apply changes from values in another table.

insert into person (first_name, last_name,
birth_date,
eye_color, occupation, years_of_education)
values ('Bob','Smith','22-JAN-2000','blue','teacher', 18);

below statement updates Bob’s row in Person table using data from his Employee table row:

update person as p
set occupation = 'boss'
from employee as e
where e.emp_name =
concat(p.first_name, ' ', p.last_name)
and e.mgr_empid is null;

select first_name, last_name, occupation
from person;

+------------+-----------+------------+
| FIRST_NAME | LAST_NAME | OCCUPATION |
|------------+-----------+------------|
| Gina       | Peters    | student    |
| Tim        | Carpenter | salesman   |
| Kathy      | Little    | musician   |
| Sharon     | Carpenter | doctor     |
| Bob        | Smith     | boss       |
+------------+-----------+------------+

Similar to the prior update statement, there was one row updated and no multijoined rows updated. What this second part means is that each updated row in Person joined to exactly one row in Employee, which is generally what you want to see.

next statement shows what happens if rows in Person join to multiple Employee rows:

update person as p
set p.years_of_education = e.empid - 1000
from employee as e
where e.empid < 1003;

+------------------------+-------------------------------------+
| number of rows updated | number of multi-joined rows updated |
|------------------------+-------------------------------------|
|                      5 |                                   5 |
+------------------------+-------------------------------------+
10 Row(s) produced. Time Elapsed: 3.309s

Snowflake tells us there were five multijoined rows updated, which means that all five rows in Person joined to multiple rows in Employee. Looking at the where clause, you can see why; there are two rows in Employee with empid < 1003, so every row in Person joined to two rows in Employee.

select * from employee where empid < 1003;
+-------+---------------+-----------+-----------------+-------------------+
| EMPID | EMP_NAME      | MGR_EMPID | BIRTH_NATIONKEY | CURRENT_NATIONKEY |
|-------+---------------+-----------+-----------------+-------------------|
|  1001 | Bob Smith     |      NULL |               1 |                 2 |
|  1002 | Susan Jackson |      1001 |               2 |                 3 |
+-------+---------------+-----------+-----------------+-------------------+

select first_name, last_name,
years_of_education
from person;

+------------+-----------+--------------------+
| FIRST_NAME | LAST_NAME | YEARS_OF_EDUCATION |
|------------+-----------+--------------------|
| Gina       | Peters    |                  1 |
| Tim        | Carpenter |                  1 |
| Kathy      | Little    |                  1 |
| Sharon     | Carpenter |                  1 |
| Bob        | Smith     |                  1 |
+------------+-----------+--------------------+

For each of the five rows in Person, the years_of_education column was set to 1001 – 1000 = 1. There are two rows in Employee with a value of empid less than 1003 (Bob Smith with empid = 1001, and Susan Jackson with empid = 1002), but Bob Smith’s row was the last one to be used for the update in this case. If you don’t want to allow multijoined updates to succeed (and I can’t think of why you would), you can set the error_on_nondeterministic_update parameter to true, after which Snowflake will throw an error:

alter session set
error_on_nondeterministic_update=true;

update person as p
set p.years_of_education = e.empid - 1000
from employee as e
where e.empid < 1003;
100090 (42P18): Duplicate row detected during DML action
Row Values: ["Gina", "Peters", 11384, "green", "student", NULL, 1]

The error happened after the first multijoined row was encountered, which in this case happened to be Gina Peters.

insert, delete, and update statements, let’s look at how you can do all three operations in a single statement. To see how this works, imagine that someone in human resources loaded data into a table called Person_Refresh and asks you to modify the Person table to match the new table. Here’s how the data was loaded:

create table person_refresh as
select *
from (values
('Bob','Smith','no','22-JAN-2000','blue','manager'),
('Gina','Peters','no','03-MAR-2001','brown','student'),
('Tim','Carpenter','no','09-JUL-2002','green','salesman'),
('Carl','Langford','no','16-JUN-2001','blue','tailor'),
('Sharon','Carpenter','yes',null,null,null),
('Kathy','Little','yes',null,null,null))
as hr_list (fname, lname, remove, dob, eyes,
profession);

select * from person_refresh;

+--------+-----------+--------+-------------+-------+------------+
| FNAME  | LNAME     | REMOVE | DOB         | EYES  | PROFESSION |
|--------+-----------+--------+-------------+-------+------------|
| Bob    | Smith     | no     | 22-JAN-2000 | blue  | manager    |
| Gina   | Peters    | no     | 03-MAR-2001 | brown | student    |
| Tim    | Carpenter | no     | 09-JUL-2002 | green | salesman   |
| Carl   | Langford  | no     | 16-JUN-2001 | blue  | tailor     |
| Sharon | Carpenter | yes    | NULL        | NULL  | NULL       |
| Kathy  | Little    | yes    | NULL        | NULL  | NULL       |
+--------+-----------+--------+-------------+-------+------------+

select first_name, last_name, birth_date, eye_color, occupation from person;

+------------+-----------+------------+-----------+------------+
| FIRST_NAME | LAST_NAME | BIRTH_DATE | EYE_COLOR | OCCUPATION |
|------------+-----------+------------+-----------+------------|
| Gina       | Peters    | 03-03-2001 | green     | student    |
| Tim        | Carpenter | 09-07-2002 | blue      | salesman   |
| Kathy      | Little    | 29-08-2001 | grey      | musician   |
| Sharon     | Carpenter | 09-07-2002 | blue      | doctor     |
| Bob        | Smith     | 22-01-2000 | blue      | boss       |
+------------+-----------+------------+-----------+------------+

Comparing these two sets, it looks like Kathy Little and Sharon Carpenter have a value of yes for the remove column (meaning that they should be removed from the Person table), and Carl Langford is a new row that needs to be added. Additionally, there are some changes to some of the values in the eye_color and occupation columns.

The easiest approach would be to delete all rows in the Person table and reload from the Person_Refresh table, but let’s say that isn’t an option because removing rows would cause unwanted changes in downstream systems. Instead, you can execute a single merge statement to add any new rows, remove rows no longer needed, and modify any existing rows.

Person before merge

nesanawsenter#COMPUTE_WH@LEARNING_SQL.PUBLIC>select * from person;
+------------+-----------+------------+-----------+------------+-----------+--------------------+
| FIRST_NAME | LAST_NAME | BIRTH_DATE | EYE_COLOR | OCCUPATION | CHILDREN  | YEARS_OF_EDUCATION |
|------------+-----------+------------+-----------+------------+-----------+--------------------|
| Gina       | Peters    | 03-03-2001 | green     | student    | NULL      |                  1 |
| Tim        | Carpenter | 09-07-2002 | blue      | salesman   | NULL      |                  1 |
| Kathy      | Little    | 29-08-2001 | grey      | musician   | NULL      |                  1 |
| Sharon     | Carpenter | 09-07-2002 | blue      | doctor     | [         |                  1 |
|            |           |            |           |            |   "Sue",  |                    |
|            |           |            |           |            |   "Shawn" |                    |
|            |           |            |           |            | ]         |                    |
| Bob        | Smith     | 22-01-2000 | blue      | boss       | NULL      |                  1 |
+------------+-----------+------------+-----------+------------+-----------+--------------------+

merge into person as p
using person_refresh as pr
on p.first_name = pr.fname
and p.last_name = pr.lname
when matched and pr.remove = 'yes' then
delete
when matched then update set p.birth_date =
pr.dob,
p.eye_color = pr.eyes,
p.occupation = pr.profession
when not matched then insert
(first_name, last_name, birth_date,
eye_color, occupation)
values (pr.fname, pr.lname, pr.dob,
pr.eyes, pr.profession);

+-------------------------+------------------------+------------------------+
| number of rows inserted | number of rows updated | number of rows deleted |
|-------------------------+------------------------+------------------------|
|                       1 |                      3 |                      2 |
+-------------------------+------------------------+------------------------+

-- The using clause names the source table, and the on subclause describes how the source table should be joined to the target table.
-- For any rows common to both the target and source tables, the when matched clause describes how the rows in the target table should be modified.
-- For any rows in the source table but not in the target table, the when not matched clause describes how rows should be inserted.
-- The when clauses are evaluated from top to bottom, so matching rows will be deleted if the remove column = yes and updated otherwise.

Person after merge

nesanawsenter#COMPUTE_WH@LEARNING_SQL.PUBLIC>select * from person;
+------------+-----------+------------+-----------+------------+----------+--------------------+
| FIRST_NAME | LAST_NAME | BIRTH_DATE | EYE_COLOR | OCCUPATION | CHILDREN | YEARS_OF_EDUCATION |
|------------+-----------+------------+-----------+------------+----------+--------------------|
| Gina       | Peters    | 03-03-2001 | brown     | student    | NULL     |                  1 |
| Tim        | Carpenter | 09-07-2002 | green     | salesman   | NULL     |                  1 |
| Bob        | Smith     | 22-01-2000 | blue      | manager    | NULL     |                  1 |
| Carl       | Langford  | 16-06-2001 | blue      | tailor     | NULL     |               NULL |
+------------+-----------+------------+-----------+------------+----------+--------------------+
4 Row(s) produced. Time Elapsed: 0.682s

Excercise - Chap5

Write a query that returns the string 'you can't always get what you want'.

SELECT $$'you can't always get what you want'$$;
SELECT 'you can\'t always get what you want';
SELECT 'you can''t always get what you want';

Write a query that returns an array containing the number 985, the string 'hello there', and the boolean value true.

SELECT [985, 'hello there', TRUE] AS ARRAY;

Write a query that uses the array generated in Exercise 5-2 as an input, and then flattens the array into three rows.

SELECT * from TABLE(FLATTEN([985, 'hello there', TRUE]));

+-----+------+------+-------+---------------+------------------+
| SEQ | KEY  | PATH | INDEX | VALUE         | THIS             |
|-----+------+------+-------+---------------+------------------|
|   1 | NULL | [0]  |     0 | 985           | [                |
|     |      |      |       |               |   985,           |
|     |      |      |       |               |   "hello there", |
|     |      |      |       |               |   true           |
|     |      |      |       |               | ]                |
|   1 | NULL | [1]  |     1 | "hello there" | [                |
|     |      |      |       |               |   985,           |
|     |      |      |       |               |   "hello there", |
|     |      |      |       |               |   true           |
|     |      |      |       |               | ]                |
|   1 | NULL | [2]  |     2 | true          | [                |
|     |      |      |       |               |   985,           |
|     |      |      |       |               |   "hello there", |
|     |      |      |       |               |   true           |
|     |      |      |       |               | ]                |
+-----+------+------+-------+---------------+------------------+

SELECT value from TABLE(FLATTEN([985, 'hello there', TRUE]));

+---------------+
| VALUE         |
|---------------|
| 985           |
| "hello there" |
| true          |
+---------------+
3 Row(s) produced. Time Elapsed: 0.561s

Chap 6
Working with Character Data

String Generation and Manipulation

select 'here is my string';

|| operator, or using the builtin concat() function

select 'string 1' || ' and ' || 'string2';
select concat('string1',' and ','string2');

char() function if you know the character’s ASCII value, if you want to disclose how many euros you spent on a trip to Paris

select concat('I spent ',char(8364),'357 in


Paris');

select upper(str.val), lower(str.val),
initcap(str.val)
from (values ('which case is best?'))
as str(val);

select reverse('?siht daer uoy nac');

select ltrim(str.val), rtrim(str.val),
trim(str.val)
from (values (' abc ')) as str(val);

-- What is the use of str() in below -- not able to understand
select * 
from (values (' abc ')) as str(val);
+-------+
| VAL   |
|-------|
|  abc  |
+-------+

select *
from (values (' abc ')) as val;
+---------+
| COLUMN1 |
|---------|
|  abc    |
+---------+

select *
from (values (' abc ')) val;
+---------+
| COLUMN1 |
|---------|
|  abc    |
+---------+

select typeof(str.val) 
from (values (' abc ')) as str(val);
001044 (42P13): SQL compilation error: error line 1 at position 7
Invalid argument types for function 'TYPEOF': (VARCHAR(5))

select typeof(str(val)) 
from (values (' abc ')) as str(val);
002140 (42601): SQL compilation error:
Unknown function STR

select typeof(str('siva'));
002140 (42601): SQL compilation error:
Unknown function STR

select length(ltrim(str.val)) as str1_len,
length(rtrim(str.val)) as str2_len,
length(trim(str.val)) as str3_len
from (values ('   abc   ')) as str(val);
+----------+----------+----------+
| STR1_LEN | STR2_LEN | STR3_LEN |
|----------+----------+----------|
|        6 |        6 |        3 |
+----------+----------+----------+

translate() function - used to replace char in String

select translate('(857)-234-5678','()-','');  -- replace all unwanted chars with ''
+--------------------------------------+
| TRANSLATE('(857)-234-5678','()-','') |
|--------------------------------------|
| 8572345678                           |
+--------------------------------------+

select translate('(857)-(234)-(5678)','()-','ab');
+--------------------------------------------+
| TRANSLATE('(857)-(234)-(5678)','()-','AB') |
|--------------------------------------------|
| a857ba234ba5678b                           |
+--------------------------------------------+

select 'AaBBbCCCc'
union 
select translate('AaBBbCCCc','ABC','XYZ');

+-------------+
| 'AABBBCCCC' |
|-------------|
| AaBBbCCCc   |
| XaYYbZZZc   |
+-------------+

To find the position of a substring within a string, you can use the position() function

select position('here',str.val) as pos1,  -- Search from begining
position('here',str.val,10) as pos2,    -- Search after 10th position
position('nowhere',str.val) as pos3    -- Not found return 0
from (values ('here, there, and everywhere'))
as str(val);

+------+------+------+
| POS1 | POS2 | POS3 |
|------+------+------|
|    1 |   24 |    0 |
+------+------+------+

substr()

select substr(str.val, 1, 10) as
start_of_string,
substr(str.val, 11) as rest_of_string
from (values ('beginning ending')) as
str(val);

position() function as a parameter to the substr()

select substr(str.val,
position('every',str.val))
from (values 
('here, there, and everywhere'),
('everywhere we have life')
)
as str(val);

+----------------------------+
| SUBSTR(STR.VAL,            |
| POSITION('EVERY',STR.VAL)) |
|----------------------------|
| everywhere                 |
| everywhere we have life    |
+----------------------------+

Snowflake also has several functions that return a boolean value rather than a numeric position, which can be useful for filter conditions:

select str.val
from (values 
('here, there, and everywhere'),
('siva, are, you there'),
('here, where, and nowhere'),
('HERE, where, and nowhere')
)
as str(val)
where startswith(str.val,'here');

+-----------------------------+
| VAL                         |
|-----------------------------|
| here, there, and everywhere |
| here, where, and nowhere    |
+-----------------------------+

select str.val
from (values 
('here, there, and everywhere'),
('siva, are, you there'),
('here, where, and nowhere'),
('HERE, where, and nowhere')
)
as str(val)
where endswith(str.val,'where');

+-----------------------------+
| VAL                         |
|-----------------------------|
| here, there, and everywhere |
| here, where, and nowhere    |
| HERE, where, and nowhere    |
+-----------------------------+

select str.val
from (values 
('here, there, and everywhere'),
('siva, are, you there'),
('here, where, and nowhere'),
('HERE, where, and nowhere')
)
as str(val)
where contains(str.val,'there');

+-----------------------------+
| VAL                         |
|-----------------------------|
| here, there, and everywhere |
| siva, are, you there        |
+-----------------------------+

Working with Numeric Data

select 10 as radius, 2 * 3.14159 * 10 as
circumference;

-- use parentheses in order to dictate calculation precedence
select (3 * 6) - (10 / 2);
+--------------------+
| (3 * 6) - (10 / 2) |
|--------------------|
|          13.000000 |
+--------------------+

Numeric Functions
select 10 as radius, 2 * 3.14159 * 10 as
circumference,
3.14159 * power(10,2) as area;

+--------+---------------+---------+
| RADIUS | CIRCUMFERENCE |    AREA |
|--------+---------------+---------|
|     10 |      62.83180 | 314.159 |
+--------+---------------+---------+

select 10 as radius, 2 * 3.14159 * 10 as
pi() * power(10,2) as area;
circumference,
+--------+---------------+---------------+
| RADIUS | CIRCUMFERENCE |          AREA |
|--------+---------------+---------------|
|     10 |      62.83180 | 314.159265359 |
+--------+---------------+---------------+

select mod(70, 9);    -- find remaindar
+------------+
| MOD(70, 9) |
|------------|
|          7 |
+------------+

select sign(-7.5233), abs(-7.5233);
+---------------+--------------+
| SIGN(-7.5233) | ABS(-7.5233) |
|---------------+--------------|
|            -1 |       7.5233 |
+---------------+--------------+

remove the decimal portion (trunc()), round up to the nearest value (round()), ower or higher integer (floor() and ceil())

select trunc(6.49), round(6.49, 1),
floor(6.49), ceil(6.49);

+-------------+----------------+-------------+------------+
| TRUNC(6.49) | ROUND(6.49, 1) | FLOOR(6.49) | CEIL(6.49) |
|-------------+----------------+-------------+------------|
|           6 |            6.5 |           6 |          7 |
+-------------+----------------+-------------+------------+

If you need to convert a string to a number, there are several strategies: explicit conversion, where you specify that the string be converted to a number, and implicit conversion (also known as coercion), where Snowflake sees the need for the conversion and attempts to do so.

select 123.45 as real_num     -- Implicit conversion Coercion
union
select '678.90' as real_num;

+----------+
| REAL_NUM |
|----------|
|   123.45 |
|   678.90 |
+----------+

select 123.45 as real_num     -- Implicit conversion Coercion
union
select '678.90    ' as real_num;

+-----------+
|  REAL_NUM |
|-----------|
| 123.45000 |
| 678.90000 |
+-----------+

select 123.45 as real_num     -- Error as conversion fails
union
select 'a678.90a    ' as real_num;

100038 (22018): Numeric value 'a678.90a' is not recognized

you can explicitly request a data conversion using one of the following:

The cast() function
The cast operator ::
A specific conversion function such as to_decimal()

select cast(str.val as number(7,2)) as
cast_val,
str.val::number(7,2) as cast_opr_val,
to_decimal(str.val,7,2) as to_dec_val
from (values ('15873.26')) as str(val);

+----------+--------------+------------+
| CAST_VAL | CAST_OPR_VAL | TO_DEC_VAL |
|----------+--------------+------------|
| 15873.26 |     15873.26 |   15873.26 |
+----------+--------------+------------+

select cast(str.val as number(7,2)) as  -- Error due to $
cast_val,
str.val::number(7,2) as cast_opr_val,
to_decimal(str.val,7,2) as to_dec_val
from (values ('$15873.26')) as str(val);
100038 (22018): Numeric value '$15873.26' is not recognized


select 'Bill amt : ';
select OCTET_LENGTH('Bill amt : ');   -- 11

select 'Bill amt : '||char(8377);
select OCTET_LENGTH('Bill amt : '||char(8377));  -- 11 ₹ is multibyte Character

The to_decimal() function luckily includes an optional formatting string:

select to_decimal(str.val,'$99999.99',7,2) as
to_dec_val
from (values ('$15873.26')) as
str(val);
+------------+
| TO_DEC_VAL |
|------------|
|   15873.26 |
+------------+

If you want to test the conversion of a string before actually doing so, you can use the try_to_decimal() function, which returns null if the conversion fails but does not throw an error

select try_to_decimal(str.val,'$99999.99',7,2)
as good,
try_to_decimal(str.val,'999.9',4,2) as bad
from (values ('$15873.26')) as str(val);
+----------+-----+
|     GOOD | BAD |
|----------+-----|
| 15873.26 | NULL |
+----------+-----+

Number Generation

For situations when you need to generate a set of numbers, such as for fabricating test data, Snowflake provides a number of handy built-in functions. The first step involves a call to the generator() function, which is a table function used to generate rows of data. Table functions are called in the from clause of a query

generator() is a function that returns a configurable number of rows. Here’s an example that asks generator() to return five rows, and then calls the random() function to generate a random number for each row:

select random()
from table(generator(rowcount => 5));

+----------------------+
|             RANDOM() |
|----------------------|
|  2400328882360400570 |
| -9144753376321323987 |
| -7399148148096879269 |
|  4389202032077053159 |
| -3634580655539651248 |
+----------------------+
5 Row(s) produced. Time Elapsed: 2.273s

If you want a sequence of numbers rather than a random set, you can use the seq1() function

select seq1()
from table(generator(rowcount => 5));
+--------+
| SEQ1() |
|--------|
|      0 |
|      1 |
|      2 |
|      3 |
|      4 |
+--------+

example that generates date values corresponding to the first day of the month for every month in 2023

select to_date('01/' ||
to_char(seq1() + 1) ||
'/2023','DD/MM/YYYY') as first_of_month
from table(generator(rowcount => 12));

+----------------+
| FIRST_OF_MONTH |
|----------------|
| 2023-01-01     |
| 2023-02-01     |
| 2023-03-01     |
| 2023-04-01     |
| 2023-05-01     |
| 2023-06-01     |
| 2023-07-01     |
| 2023-08-01     |
| 2023-09-01     |
| 2023-10-01     |
| 2023-11-01     |
| 2023-12-01     |
+----------------+
12 Row(s) produced. Time Elapsed: 0.672s

select to_date('01/' ||
to_char(seq1() + 1) ||
'/2023','DD/MM/YYYY') as first_of_month,
DAYNAME(to_date('01/' ||
to_char(seq1() + 1) ||
'/2023','DD/MM/YYYY')) as day_of_first_of_month,
from table(generator(rowcount => 12));

+----------------+-----------------------+
| FIRST_OF_MONTH | DAY_OF_FIRST_OF_MONTH |
|----------------+-----------------------|
| 2023-01-01     | Sun                   |
| 2023-02-01     | Wed                   |
| 2023-03-01     | Wed                   |
| 2023-04-01     | Sat                   |
| 2023-05-01     | Mon                   |
| 2023-06-01     | Thu                   |
| 2023-07-01     | Sat                   |
| 2023-08-01     | Tue                   |
| 2023-09-01     | Fri                   |
| 2023-10-01     | Sun                   |
| 2023-11-01     | Wed                   |
| 2023-12-01     | Fri                   |
+----------------+-----------------------+

Snowflake is quite forgiving regarding dates and will apply several common formatting strings to try to decipher your date literals. However, you can always specify a formatting string to tell Snowflake how to interpret your date or timestamp literal:

select to_timestamp('04-NOV-2022 18:48:56',
'DD-MON-YYYY HH24:MI:SS') as now;
+-------------------------+
| NOW                     |
|-------------------------|
| 2022-11-04 18:48:56.000 |
+-------------------------+

Snowflake uses your formatting string to interpret your timestamp literal, but it uses the format defined in parameter timestamp_output_format to return the timestamp, which in this case is the default setting of YYYY-MM-DD HH24:MI:SS.SSS. If you want to see the output format defined for your database, you can execute the following command:

select current_timestamp;
+-------------------------------+
| CURRENT_TIMESTAMP             |
|-------------------------------|
| 2024-11-20 01:00:19.999 -0800 |
+-------------------------------+

alter session set timestamp_output_format =
'MM/DD/YYYY HH12:MI:SS AM TZH';

select current_timestamp;
+------------------------------+
| CURRENT_TIMESTAMP            |
|------------------------------|
| 11/20/2024 01:00:43 AM -0800 |
+------------------------------+

select date_from_parts(2023, 3, 15) as
my_date,
time_from_parts(10, 22, 47) as my_time;
+------------+----------+
| MY_DATE    | MY_TIME  |
|------------+----------|
| 2023-03-15 | 10:22:47 |
+------------+----------+

you specify the date/time components in a specified order (year/month/day for a date, hour/minute/second for a time).

select timestamp_from_parts(
date_from_parts(2023, 3, 15),
time_from_parts(10, 22, 47)) as
my_timestamp;

+-------------------------+
| MY_TIMESTAMP            |
|-------------------------|
| 2023-03-15 10:22:47.000 |
+-------------------------+

The date_from_parts() function also allows zero or negative numbers for month or day, which allows you to move backward in time. Specifying 0 for the day value will move backward one day, specifying –1 day will move backward two days, etc. This is handy for finding month end dates without having to remember which months have 30 days and which have 31:

select date_from_parts(2024, seq1() + 2, 0) as
month_end
from table(generator(rowcount => 12));

+------------+
| MONTH_END  |
|------------|
| 2024-01-31 |
| 2024-02-29 |
| 2024-03-31 |
| 2024-04-30 |
| 2024-05-31 |
| 2024-06-30 |
| 2024-07-31 |
| 2024-08-31 |
| 2024-09-30 |
| 2024-10-31 |
| 2024-11-30 |
| 2024-12-31 |
+------------+

select date_from_parts(2024, seq1() + 1, 0) as
month_end
from table(generator(rowcount => 12));
+------------+
| MONTH_END  |
|------------|
| 2023-12-31 |
| 2024-01-31 |
| 2024-02-29 |
| 2024-03-31 |
| 2024-04-30 |
| 2024-05-31 |
| 2024-06-30 |
| 2024-07-31 |
| 2024-08-31 |
| 2024-09-30 |
| 2024-10-31 |
| 2024-11-30 |
+------------+

Snowflake has several built-in functions that accept one date value as a parameter and return a different date value.
you might retrieve a date from a column and then determine the beginning of the month, quarter, or year associated with that date. can use the date_trunc() function

select date_trunc('YEAR',dt.val) as
start_of_year,
date_trunc('MONTH',dt.val) as
start_of_month,
date_trunc('QUARTER',dt.val) as
start_of_quarter
from (values (to_date('26-MAY-2023','DD-MON-YYYY')))
as dt(val);

+---------------+----------------+------------------+
| START_OF_YEAR | START_OF_MONTH | START_OF_QUARTER |
|---------------+----------------+------------------|
| 2023-01-01    | 2023-05-01     | 2023-04-01       |
+---------------+----------------+------------------+

While date_trunc() will move a date value backward, there are other occasions where you want to move forward.

select
dateadd(month, 1,
to_date('01-JAN-2024','DD-MON-YYYY')) as
date1,
dateadd(month, 1,
to_date('15-JAN-2024','DD-MON-YYYY')) as
date2,
dateadd(month, 1,
to_date('31-JAN-2024','DD-MON-YYYY')) as  -- 2024-02-29
date3;
+------------+------------+------------+
| DATE1      | DATE2      | DATE3      |
|------------+------------+------------|
| 2024-02-01 | 2024-02-15 | 2024-02-29 |
+------------+------------+------------+

moving the date January 31, 2024, ahead by one month results in February 29, 2024, which is exactly one month in the future but is only 29 days. Therefore, the unit of time (a month in this case) can be somewhat fluid depending on the
situation.

select dateadd(year, -1,
to_date('29-FEB-2024','DD-MON-YYYY'))
new_date;

+------------+
| NEW_DATE   |
|------------|
| 2023-02-28 |
+------------+

In this case, moving backward from February 29, 2024, yields the value February 28, 2023,

select dayname(current_date),
monthname(current_date);

+-----------------------+-------------------------+
| DAYNAME(CURRENT_DATE) | MONTHNAME(CURRENT_DATE) |
|-----------------------+-------------------------|
| Wed                   | Nov                     |
+-----------------------+-------------------------+

The date_part() function can be used to extract various units of time.

select date_part(year, dt.val) as year_num,
date_part(quarter, dt.val) as qtr_num,
date_part(month, dt.val) as month_num,
date_part(week, dt.val) as week_num
from (values(to_date('24-APR-2023','DD-MON-YYYY')))
as dt(val);

+----------+---------+-----------+----------+
| YEAR_NUM | QTR_NUM | MONTH_NUM | WEEK_NUM |
|----------+---------+-----------+----------|
|     2023 |       2 |         4 |       17 |
+----------+---------+-----------+----------+

select date_part(hour, dt.val) as hour_num,
date_part(minute, dt.val) as min_num,
date_part(second, dt.val) as sec_num,
date_part(nanosecond, dt.val) as nsec_num
from (values(current_timestamp)) as dt(val);

+----------+---------+---------+-----------+
| HOUR_NUM | MIN_NUM | SEC_NUM |  NSEC_NUM |
|----------+---------+---------+-----------|
|       10 |      25 |      20 | 567000000 |
+----------+---------+---------+-----------+

Another function that returns a number is datediff(), which will return the number of time units (years, months, days, hours, etc.) between two different date values.

select datediff(year, dt.val1, dt.val2)
num_years,
datediff(month, dt.val1, dt.val2)
num_months,
datediff(day, dt.val1, dt.val2) num_days,
datediff(hour, dt.val1, dt.val2) num_hours
from (values (to_date('12-FEB-2022','DD-MON-YYYY'),
to_date('06-MAR-2023','DD-MON-YYYY'))) as
dt(val1, val2);
+-----------+------------+----------+-----------+
| NUM_YEARS | NUM_MONTHS | NUM_DAYS | NUM_HOURS |
|-----------+------------+----------+-----------|
|         1 |         13 |      387 |      9288 |
+-----------+------------+----------+-----------+

The datediff() function returns an integer, so the value returned is approximate when asking for the number of years or months. The return value can be negative, however, as shown by the next example, which simply reverses the order of the dates from the previous example:

select datediff(year, dt.val1, dt.val2)
num_years,
datediff(month, dt.val1, dt.val2)
num_months,
datediff(day, dt.val1, dt.val2) num_days,
datediff(hour, dt.val1, dt.val2) num_hours
from (values (to_date('06-MAR-2023','DD-MON-YYYY'),
to_date('12-FEB-2022','DD-MON-YYYY'))) as
dt(val1, val2);
+-----------+------------+----------+-----------+
| NUM_YEARS | NUM_MONTHS | NUM_DAYS | NUM_HOURS |
|-----------+------------+----------+-----------|
|        -1 |        -13 |     -387 |     -9288 |
+-----------+------------+----------+-----------+

Snowflake provides several different functions used to convert from one data type to another.

select cast('23-SEP-2023' as date) as format1,
cast('09/23/2023' as date) as format2,
cast('2023-09-23' as date) as format3;
+------------+------------+------------+
| FORMAT1    | FORMAT2    | FORMAT3    |
|------------+------------+------------|
| 2023-09-23 | 2023-09-23 | 2023-09-23 |
+------------+------------+------------+

select cast('09-23-2023' as date);
100040 (22007): Date '09-23-2023' is not recognized

If you want Snowflake to attempt the conversion without raising an error, you can use the try_cast() function, which will return null if the conversion fails:

select try_cast('09-23-2023' as date);
+--------------------------------+
| TRY_CAST('09-23-2023' AS DATE) |
|--------------------------------|
| NULL                           |
+--------------------------------+

The cast() function can also be used to convert a string to a number, or to convert from a real number to an integer:

select cast('123.456' as number(6,3)), cast('123.456' as number(10,5)),
cast(123.456 as integer);
+--------------------------------+---------------------------------+--------------------------+
| CAST('123.456' AS NUMBER(6,3)) | CAST('123.456' AS NUMBER(10,5)) | CAST(123.456 AS INTEGER) |
|--------------------------------+---------------------------------+--------------------------|
|                        123.456 |                       123.45600 |                      123 |
+--------------------------------+---------------------------------+--------------------------+

You can also choose to use the :: operator instead of calling the cast() function:

select '09/23/2023'::date date_val,
'23-SEP-2023'::timestamp tmstmp_val,
'123.456'::number(6,3) num_val;
+------------+-------------------------+---------+
| DATE_VAL   | TMSTMP_VAL              | NUM_VAL |
|------------+-------------------------+---------|
| 2023-09-23 | 2023-09-23 00:00:00.000 | 123.456 |
+------------+-------------------------+---------+

The only downside to using :: is that there is no “try” version similar to try_cast(), so if the conversion fails you will receive an error.

Excercise - Chap6

Write a query that uses a function to alter the string 'cow it maked dende' by changing all occurrences of c to n, and all
occurrences of d to s.

select translate('cow it maked dende','c','n');

Write a query that returns the numbers 1 through 10, one per row.

select (seq1() + 1) as
seqeg
from table(generator(rowcount => 10));

Write a query that returns the number of days between the dates 01-JAN-2024 and 15-AUG-2025.

select datediff(day, '01-JAN-2024', '15-AUG-2025');

Write a query that sums the numeric year, month, and day for the date 27-SEP-2025.

select date_part(day, to_date('27-SEP-2025','DD-MON-YYYY'));

Chap 7

Databases must store data at the lowest level of granularity needed for any particular operation.

25% off for customers who have spent $1,800,000 or more or who have placed eight or more orders. 

select count(*) from orders;

select O_CUSTKEY, sum(O_TOTALPRICE) as tot_pur, count(O_CUSTKEY) no_of_ord from orders group by O_CUSTKEY having tot_pur>=1800000 or no_of_ord>=8;

select O_CUSTKEY from orders group by O_CUSTKEY having sum(O_TOTALPRICE)>=1800000 or count(O_CUSTKEY)>=8; --- Just select only cust key keep aggregations in having clause only

select count(*) as num_orders,   -- Can use aggregate functions without group by it will work on all records
min(o_totalprice) as min_price,
max(o_totalprice) as max_price,
avg(o_totalprice) as avg_price
from orders;

select date_part(year, o_orderdate) as     
order_year,
count(*) as num_orders,
min(o_totalprice) as min_price,
max(o_totalprice) as max_price,
avg(o_totalprice) as avg_price
from orders
group by date_part(year, o_orderdate) order by order_year;  --- Use both alias or agg function in group by

Counting the number of rows belonging to each group is a very common operation, and you’ve already seen several examples in this chapter. However, there are a couple of variations that are worth discussing, the first being the combination of the count() function with the distinct operator:

select count(*) as total_orders,             -- Counts Distinct customers and distinct years
count(distinct o_custkey) as num_customers, -- count only the number of distinct values of custkey and the year
count(distinct date_part(year,
o_orderdate)) as num_years
from orders;   

+--------------+---------------+-----------+
| TOTAL_ORDERS | NUM_CUSTOMERS | NUM_YEARS |
|--------------+---------------+-----------|
|       115269 |         66076 |         7 |
+--------------+---------------+-----------+

Another useful variation of the count() function is count_if(), which will count the number of rows for which a given condition evaluates as true.

select
count_if(1992 = date_part(year,
o_orderdate)) num_1992,
count_if(1995 = date_part(year,
o_orderdate)) num_1995
from orders;

+----------+----------+
| NUM_1992 | NUM_1995 |
|----------+----------|
|    17506 |    17637 |
+----------+----------+

Unfortunately, there aren’t similar variations of the sum(), min(), and max() functions that allow for rows to be included or excluded, but can handle it with subqueries. When you are grouping data that includes numeric columns, you will often want to find the largest or smallest value within the group, compute the average value for the group, or sum the values across all rows in the group.

The max(), min(), avg(), and sum() aggregate functions are used for these purposes, and max() and min() are also often used with date columns.

select date_part(year, o_orderdate) as year,
min(o_orderdate) as first_order,
max(o_orderdate) as last_order,
avg(o_totalprice) as avg_price,
sum(o_totalprice) as tot_sales
from orders
group by date_part(year, o_orderdate);

+------+-------------+------------+-----------------+---------------+
| YEAR | FIRST_ORDER | LAST_ORDER |       AVG_PRICE |     TOT_SALES |
|------+-------------+------------+-----------------+---------------|
| 1997 | 1997-01-01  | 1997-12-31 | 186987.97800322 | 3255086721.08 |
| 1998 | 1998-01-01  | 1998-08-02 | 188929.97532090 | 1925196448.52 |
| 1995 | 1995-01-01  | 1995-12-31 | 188100.11965924 | 3317521810.43 |
| 1994 | 1994-01-01  | 1994-12-31 | 187566.44502946 | 3278473892.67 |
| 1992 | 1992-01-01  | 1992-12-31 | 189062.87926368 | 3309734764.39 |
| 1993 | 1993-01-01  | 1993-12-31 | 188041.41387649 | 3270416270.14 |
| 1996 | 1996-01-01  | 1996-12-31 | 186689.32167356 | 3296373352.79 |
+------+-------------+------------+-----------------+---------------+

If you ever need to flatten data, which is common when generating XML or JSON documents, you will find the listagg() function to be extremely valuable. Listagg() generates a delimited list of values as a single column.

select r.r_name,
listagg(n.n_name,',')
within group (order by n.n_name) as
nation_list
from region r inner join nation n
on r.r_regionkey = n.n_regionkey
group by r.r_name;

+-------------+----------------------------------------------+
| R_NAME      | NATION_LIST                                  |
|-------------+----------------------------------------------|
| AFRICA      | ALGERIA,ETHIOPIA,KENYA,MOROCCO,MOZAMBIQUE    |
| EUROPE      | FRANCE,GERMANY,ROMANIA,RUSSIA,UNITED KINGDOM |
| AMERICA     | ARGENTINA,BRAZIL,CANADA,PERU,UNITED STATES   |
| MIDDLE EAST | EGYPT,IRAN,IRAQ,JORDAN,SAUDI ARABIA          |
| ASIA        | CHINA,INDIA,INDONESIA,JAPAN,VIETNAM          |
+-------------+----------------------------------------------+

select r.r_name,
listagg(n.n_name,',')
within group (order by n.n_name)
nation_list
from region r inner join nation n
on r.r_regionkey = n.n_regionkey
group by r.r_name
order by r.r_name;

+-------------+----------------------------------------------+
| R_NAME      | NATION_LIST                                  |
|-------------+----------------------------------------------|
| AFRICA      | ALGERIA,ETHIOPIA,KENYA,MOROCCO,MOZAMBIQUE    |
| AMERICA     | ARGENTINA,BRAZIL,CANADA,PERU,UNITED STATES   |
| ASIA        | CHINA,INDIA,INDONESIA,JAPAN,VIETNAM          |
| EUROPE      | FRANCE,GERMANY,ROMANIA,RUSSIA,UNITED KINGDOM |
| MIDDLE EAST | EGYPT,IRAN,IRAQ,JORDAN,SAUDI ARABIA          |
+-------------+----------------------------------------------+

If there are duplicate values in the list generated by listagg(), you can specify distinct, in which case the list will contain only the unique values.

As you have seen in previous examples, the group by clause is the mechanism for grouping rows of data. In this section, you will see how to group data by multiple columns, how to group data using expressions, and how to generate rollups within groups.

Multicolumn Grouping

you can group on as many columns as you wish. The next example counts the number of customers in each country and market segment for customers in the America region

select n.n_name, c.c_mktsegment, count(*)
from customer c inner join nation n
on c.c_nationkey = n.n_nationkey
where n.n_regionkey = 1
group by n.n_name, c.c_mktsegment
order by 1,2;

+---------------+--------------+----------+
| N_NAME        | C_MKTSEGMENT | COUNT(*) |
|---------------+--------------+----------|
| ARGENTINA     | AUTOMOBILE   |      521 |
| ARGENTINA     | BUILDING     |      580 |
| ARGENTINA     | FURNITURE    |      488 |
| ARGENTINA     | HOUSEHOLD    |      516 |
| ARGENTINA     | MACHINERY    |      533 |
| BRAZIL        | AUTOMOBILE   |      503 |
| BRAZIL        | BUILDING     |      551 |
| BRAZIL        | FURNITURE    |      492 |
| BRAZIL        | HOUSEHOLD    |      521 |
| BRAZIL        | MACHINERY    |      547 |
| CANADA        | AUTOMOBILE   |      499 |
| CANADA        | BUILDING     |      555 |
| CANADA        | FURNITURE    |      511 |
| CANADA        | HOUSEHOLD    |      544 |
| CANADA        | MACHINERY    |      522 |
| PERU          | AUTOMOBILE   |      560 |
| PERU          | BUILDING     |      541 |
| PERU          | FURNITURE    |      516 |
| PERU          | HOUSEHOLD    |      538 |
| PERU          | MACHINERY    |      470 |
| UNITED STATES | AUTOMOBILE   |      514 |
| UNITED STATES | BUILDING     |      516 |
| UNITED STATES | FURNITURE    |      522 |
| UNITED STATES | HOUSEHOLD    |      532 |
| UNITED STATES | MACHINERY    |      519 |
+---------------+--------------+----------+
25 Row(s) produced. Time Elapsed: 2.247s

Grouping Using Expressions

for the last two years of operations (1997 and 1998) showing the number of months between when orders are placed and when the parts are shipped

select date_part(year, o.o_orderdate) as
year,
datediff(month, o.o_orderdate,
l.l_shipdate) as months_to_ship,
count(*)
from orders o inner join lineitem l
on o.o_orderkey = l.l_orderkey
where o.o_orderdate >= '01-JAN-1997'::date
group by date_part(year, o.o_orderdate),
datediff(month, o.o_orderdate,
l.l_shipdate)
order by 1,2;

+------+----------------+----------+
| YEAR | MONTHS_TO_SHIP | COUNT(*) |
|------+----------------+----------|
| 1997 |              0 |     2195 |
| 1997 |              1 |     4601 |
| 1997 |              2 |     4644 |
| 1997 |              3 |     4429 |
| 1997 |              4 |     2245 |
| 1997 |              5 |        2 |
| 1998 |              0 |     1295 |
| 1998 |              1 |     2602 |
| 1998 |              2 |     2628 |
| 1998 |              3 |     2724 |
| 1998 |              4 |     1356 |
| 1998 |              5 |        1 |
+------+----------------+----------+
12 Row(s) produced. Time Elapsed: 2.239s

Snowflake added the group by all option, which is a nice shortcut when grouping data using expressions. Here’s the previous example using group by all:

select date_part(year, o.o_orderdate) as
year,
datediff(month, o.o_orderdate,
l.l_shipdate) as months_to_ship,
count(*)
from orders o inner join lineitem l
on o.o_orderkey = l.l_orderkey
where o.o_orderdate >= '01-JAN-1997'::date
group by all
order by 1,2;

With this feature, the all keyword represents everything in the select statement that is not an aggregate function.

Rollup 

select n.n_name, c.c_mktsegment, count(*)
from customer c inner join nation n
on c.c_nationkey = n.n_nationkey
where n.n_regionkey = 1
group by rollup(n.n_name, c.c_mktsegment)
order by 1,2;

+---------------+--------------+----------+
| N_NAME        | C_MKTSEGMENT | COUNT(*) |
|---------------+--------------+----------|
| ARGENTINA     | AUTOMOBILE   |      521 |
| ARGENTINA     | BUILDING     |      580 |
| ARGENTINA     | FURNITURE    |      488 |
| ARGENTINA     | HOUSEHOLD    |      516 |
| ARGENTINA     | MACHINERY    |      533 |
| ARGENTINA     | NULL         |     2638 |
| BRAZIL        | AUTOMOBILE   |      503 |
| BRAZIL        | BUILDING     |      551 |
| BRAZIL        | FURNITURE    |      492 |
| BRAZIL        | HOUSEHOLD    |      521 |
| BRAZIL        | MACHINERY    |      547 |
| BRAZIL        | NULL         |     2614 |
| CANADA        | AUTOMOBILE   |      499 |
| CANADA        | BUILDING     |      555 |
| CANADA        | FURNITURE    |      511 |
| CANADA        | HOUSEHOLD    |      544 |
| CANADA        | MACHINERY    |      522 |
| CANADA        | NULL         |     2631 |
| PERU          | AUTOMOBILE   |      560 |
| PERU          | BUILDING     |      541 |
| PERU          | FURNITURE    |      516 |
| PERU          | HOUSEHOLD    |      538 |
| PERU          | MACHINERY    |      470 |
| PERU          | NULL         |     2625 |
| UNITED STATES | AUTOMOBILE   |      514 |
| UNITED STATES | BUILDING     |      516 |
| UNITED STATES | FURNITURE    |      522 |
| UNITED STATES | HOUSEHOLD    |      532 |
| UNITED STATES | MACHINERY    |      519 |
| UNITED STATES | NULL         |     2603 |
| NULL          | NULL         |    13111 |
+---------------+--------------+----------+

The rollup option generated six additional rows: one for each country, and a final row showing the total number of rows across the entire result set. The additional rows show null for the column that is being rolled up.

This feature is designed to save you some work if you need subtotals, but what would you do if you also want subtotals for each market segment? One answer would be to use rollup but switch the order of the columns:

select n.n_name, c.c_mktsegment, count(*)
from customer c inner join nation n
on c.c_nationkey = n.n_nationkey
where n.n_regionkey = 1
group by rollup(c.c_mktsegment, n.n_name)
order by 1,2;

+---------------+--------------+----------+
| N_NAME        | C_MKTSEGMENT | COUNT(*) |
|---------------+--------------+----------|
| ARGENTINA     | AUTOMOBILE   |      521 |
| ARGENTINA     | BUILDING     |      580 |
| ARGENTINA     | FURNITURE    |      488 |
| ARGENTINA     | HOUSEHOLD    |      516 |
| ARGENTINA     | MACHINERY    |      533 |
| BRAZIL        | AUTOMOBILE   |      503 |
| BRAZIL        | BUILDING     |      551 |
| BRAZIL        | FURNITURE    |      492 |
| BRAZIL        | HOUSEHOLD    |      521 |
| BRAZIL        | MACHINERY    |      547 |
| CANADA        | AUTOMOBILE   |      499 |
| CANADA        | BUILDING     |      555 |
| CANADA        | FURNITURE    |      511 |
| CANADA        | HOUSEHOLD    |      544 |
| CANADA        | MACHINERY    |      522 |
| PERU          | AUTOMOBILE   |      560 |
| PERU          | BUILDING     |      541 |
| PERU          | FURNITURE    |      516 |
| PERU          | HOUSEHOLD    |      538 |
| PERU          | MACHINERY    |      470 |
| UNITED STATES | AUTOMOBILE   |      514 |
| UNITED STATES | BUILDING     |      516 |
| UNITED STATES | FURNITURE    |      522 |
| UNITED STATES | HOUSEHOLD    |      532 |
| UNITED STATES | MACHINERY    |      519 |
| NULL          | AUTOMOBILE   |     2597 |
| NULL          | BUILDING     |     2743 |
| NULL          | FURNITURE    |     2529 |
| NULL          | HOUSEHOLD    |     2651 |
| NULL          | MACHINERY    |     2591 |
| NULL          | NULL         |    13111 |
+---------------+--------------+----------+
31 Row(s) produced. Time Elapsed: 40.679s

If you need subtotals created for both columns, you can use the cube option instead of rollup:

select n.n_name, c.c_mktsegment, count(*)
from customer c inner join nation n
on c.c_nationkey = n.n_nationkey
where n.n_regionkey = 1
group by cube(c.c_mktsegment, n.n_name)
order by 1,2;

+---------------+--------------+----------+
| N_NAME        | C_MKTSEGMENT | COUNT(*) |
|---------------+--------------+----------|
| ARGENTINA     | AUTOMOBILE   |      521 |
| ARGENTINA     | BUILDING     |      580 |
| ARGENTINA     | FURNITURE    |      488 |
| ARGENTINA     | HOUSEHOLD    |      516 |
| ARGENTINA     | MACHINERY    |      533 |
| ARGENTINA     | NULL         |     2638 |
| BRAZIL        | AUTOMOBILE   |      503 |
| BRAZIL        | BUILDING     |      551 |
| BRAZIL        | FURNITURE    |      492 |
| BRAZIL        | HOUSEHOLD    |      521 |
| BRAZIL        | MACHINERY    |      547 |
| BRAZIL        | NULL         |     2614 |
| CANADA        | AUTOMOBILE   |      499 |
| CANADA        | BUILDING     |      555 |
| CANADA        | FURNITURE    |      511 |
| CANADA        | HOUSEHOLD    |      544 |
| CANADA        | MACHINERY    |      522 |
| CANADA        | NULL         |     2631 |
| PERU          | AUTOMOBILE   |      560 |
| PERU          | BUILDING     |      541 |
| PERU          | FURNITURE    |      516 |
| PERU          | HOUSEHOLD    |      538 |
| PERU          | MACHINERY    |      470 |
| PERU          | NULL         |     2625 |
| UNITED STATES | AUTOMOBILE   |      514 |
| UNITED STATES | BUILDING     |      516 |
| UNITED STATES | FURNITURE    |      522 |
| UNITED STATES | HOUSEHOLD    |      532 |
| UNITED STATES | MACHINERY    |      519 |
| UNITED STATES | NULL         |     2603 |
| NULL          | AUTOMOBILE   |     2597 |
| NULL          | BUILDING     |     2743 |
| NULL          | FURNITURE    |     2529 |
| NULL          | HOUSEHOLD    |     2651 |
| NULL          | MACHINERY    |     2591 |
| NULL          | NULL         |    13111 |
+---------------+--------------+----------+
36 Row(s) produced. Time Elapsed: 0.582s

You can look for the null values to determine which type of subtotal is shown (a null  value for country name indicates the subtotal is for a market segment, while a null value for market segment indicates a subtotal for a country), but a better option is to use the grouping() function, which returns a 0 if the associated column is included in the subtotal, and 1 if the value is not included

select n.n_name, c.c_mktsegment, count(*),
grouping(n.n_name) name_sub,
grouping(c.c_mktsegment) mktseg_sub
from customer c inner join nation n
on c.c_nationkey = n.n_nationkey
where n.n_regionkey = 1
group by cube(c.c_mktsegment, n.n_name)
order by 1,2;

+---------------+--------------+----------+----------+------------+
| N_NAME        | C_MKTSEGMENT | COUNT(*) | NAME_SUB | MKTSEG_SUB |
|---------------+--------------+----------+----------+------------|
| ARGENTINA     | AUTOMOBILE   |      521 |        0 |          0 |
| ARGENTINA     | BUILDING     |      580 |        0 |          0 |
| ARGENTINA     | FURNITURE    |      488 |        0 |          0 |
| ARGENTINA     | HOUSEHOLD    |      516 |        0 |          0 |
| ARGENTINA     | MACHINERY    |      533 |        0 |          0 |
| ARGENTINA     | NULL         |     2638 |        0 |          1 |
| BRAZIL        | AUTOMOBILE   |      503 |        0 |          0 |
| BRAZIL        | BUILDING     |      551 |        0 |          0 |
| BRAZIL        | FURNITURE    |      492 |        0 |          0 |
| BRAZIL        | HOUSEHOLD    |      521 |        0 |          0 |
| BRAZIL        | MACHINERY    |      547 |        0 |          0 |
| BRAZIL        | NULL         |     2614 |        0 |          1 |
| CANADA        | AUTOMOBILE   |      499 |        0 |          0 |
| CANADA        | BUILDING     |      555 |        0 |          0 |
| CANADA        | FURNITURE    |      511 |        0 |          0 |
| CANADA        | HOUSEHOLD    |      544 |        0 |          0 |
| CANADA        | MACHINERY    |      522 |        0 |          0 |
| CANADA        | NULL         |     2631 |        0 |          1 |
| PERU          | AUTOMOBILE   |      560 |        0 |          0 |
| PERU          | BUILDING     |      541 |        0 |          0 |
| PERU          | FURNITURE    |      516 |        0 |          0 |
| PERU          | HOUSEHOLD    |      538 |        0 |          0 |
| PERU          | MACHINERY    |      470 |        0 |          0 |
| PERU          | NULL         |     2625 |        0 |          1 |
| UNITED STATES | AUTOMOBILE   |      514 |        0 |          0 |
| UNITED STATES | BUILDING     |      516 |        0 |          0 |
| UNITED STATES | FURNITURE    |      522 |        0 |          0 |
| UNITED STATES | HOUSEHOLD    |      532 |        0 |          0 |
| UNITED STATES | MACHINERY    |      519 |        0 |          0 |
| UNITED STATES | NULL         |     2603 |        0 |          1 |
| NULL          | AUTOMOBILE   |     2597 |        1 |          0 |
| NULL          | BUILDING     |     2743 |        1 |          0 |
| NULL          | FURNITURE    |     2529 |        1 |          0 |
| NULL          | HOUSEHOLD    |     2651 |        1 |          0 |
| NULL          | MACHINERY    |     2591 |        1 |          0 |
| NULL          | NULL         |    13111 |        1 |          1 |
+---------------+--------------+----------+----------+------------+

Filtering on Grouped Data

For example, let’s say you want to find customers who generated more than $700,000 worth of orders in 1998.

select o_custkey, sum(o_totalprice)
from orders
where 1998 = date_part(year, o_orderdate)
group by o_custkey
having sum(o_totalprice) >= 700000
order by 1;

Filtering with Snowsight
By using :daterange, you can choose a different set of dates using the filter menu in the top left corner, Snowsight also provides the :datebucket filter to use in your group by clause when grouping data.

select o_orderkey, o_custkey, o_orderdate 
from orders
where o_orderdate = :daterange;

select :datebucket(o_orderdate) as date_bucket,
  count(*) as num_orders, 
  sum(o_totalprice) as tot_sales
from orders o
group by :datebucket(o_orderdate)
order by 1;

select :datebucket(o_orderdate) as date_bucket,
  count(*) as num_orders, 
  sum(o_totalprice) as tot_sales
from orders o
where o_orderdate = :daterange 
group by :datebucket(o_orderdate)
order by 1;

Excercise - Chap7

Write a query to count the number of rows in the Supplier table, along with determining the minimum and maximum values of the s_acctbal column.

select count(*), min(s_acctbal), max(s_acctbal) from Supplier;

Modify the query from Exercise 7-1 to perform the same calculations, but for each value of s_nationkey rather than for the entire table.

Modify the above query to return only those rows with more than 300 suppliers per s_nationkey value.

select s_nationkey, min(s_acctbal), max(s_acctbal) from Supplier group by s_nationkey having count(*)>300;

join it using nation table to get nation name

select n.n_name, s_nationkey, min(s_acctbal), max(s_acctbal) 
from Supplier s
inner join Nation n
where s.s_nationkey = n.n_nationkey
group by 1,2 having count(*)>300;

modify the above to create rollup 

select n.n_name, min(s_acctbal), max(s_acctbal) 
from Supplier s
inner join Nation n
where s.s_nationkey = n.n_nationkey
group by rollup(n.n_name) having count(*)>300;

Chap 8
Subqueries
Subqueries are a powerful tool that can be used in select, update, insert, delete, and merge statements. A subquery is a query that is contained within another SQL statement (referred to as the containing statement or containing query for the rest of this chapter). Subqueries are always surrounded by parentheses and generally run prior to the containing statement. Like any query, subqueries return a result set that can consist of a single row or multiple rows, and a single column or multiple columns. The type of result set returned by the subquery determines which operators the containing statement may use to interact with the data returned by the subquery.

select n_nationkey, n_name from nation
where n_regionkey =
(select r_regionkey from region where r_name
= 'ASIA');

+-------------+-----------+
| N_NATIONKEY | N_NAME    |
|-------------+-----------|
|           8 | INDIA     |
|           9 | INDONESIA |
|          12 | JAPAN     |
|          18 | CHINA     |
|          21 | VIETNAM   |
+-------------+-----------+

sub query
select r_regionkey from region where r_name = 'ASIA';

+-------------+
| R_REGIONKEY |
|-------------|
|           2 |
+-------------+

The subquery runs first and returns the value 2, and thecontaining query then returns information about all nations with a regionkey value of 2. If you are thinking that the same result set could also be returned using a join rather than a subquery, you are correct:

select n.n_nationkey, n.n_name
from nation n inner join region r
on n.n_regionkey = r.r_regionkey
where r.r_name = 'ASIA';

+-------------+-----------+
| N_NATIONKEY | N_NAME    |
|-------------+-----------|
|           8 | INDIA     |
|           9 | INDONESIA |
|          12 | JAPAN     |
|          18 | CHINA     |
|          21 | VIETNAM   |
+-------------+-----------+

There are two types of subqueries, and the difference lies in whether the subquery can be executed separately from the containing query.

Uncorrelated Subqueries

The Asia table we have used so far is an uncorrelated subquery; it may be executed separately and does not reference anything from the containing query.Most subqueries that you encounter will be of this type unless you are writing update or delete statements which include subqueries. Along with being uncorrelated, the example table is known as a scalar subquery, meaning that it returns a single row having a single column. Scalar subqueries can appear on either side of a condition using the operators =, <>, <, >, <=, and >=.

select n_nationkey, n_name from nation
where n_regionkey <>
(select r_regionkey from region where r_name
= 'ASIA');

If you use a subquery in an equality condition, but the subquery returns more than one row, you will receive an error.

select n_nationkey, n_name from nation
where n_regionkey =
(select r_regionkey from region where r_name
<> 'ASIA');
090150 (22000): Single-row subquery returns more than one row.

Since the subquery is uncorrelated, you can run it by itself: 

select r_regionkey from region where r_name <> 'ASIA'; -- But the result is no scalar 

Multiple-row, single-column subqueries

While you can’t equate a single value to a set of values, you can determine if a single value can be found within a set of values. Using the in clause. You can also use not in to return rows where a value is not found within the set returned by the subquery

select n_nationkey, n_name from nation
where n_regionkey in
(select r_regionkey from region where r_name
<> 'ASIA');

select n_nationkey, n_name from nation
where n_regionkey not in
(select r_regionkey from region
where r_name = 'AMERICA' or r_name =
'EUROPE');

The subquery in this example returns the two regionkey values for America and Europe, and the containing query returns all countries that are not in that set, which includes all countries from Africa, Asia, and Middle East.

Along with checking if a value can be found, or not found, in a set of values, it is also possible to perform comparisons on each value in a set. 
find all customers whose total number of orders in 1996 exceeded any customer’s total numbers in 1997. Here’s one
way to do it, using the all operator:

select o_custkey, count(*) as num_orders
from orders
where 1996 = date_part(year, o_orderdate)
group by o_custkey
having count(*) > all
(select count(*)
from orders
where 1997 = date_part(year, o_orderdate)
group by o_custkey);

+-----------+------------+
| O_CUSTKEY | NUM_ORDERS |
|-----------+------------|
|     43645 |          5 |
+-----------+------------+

The subquery in this example returns the total number of orders for each customer in 1997, and the containing query returns all customers whose total orders in 1996 exceeds all of the values returned by the subquery.

select count(*)
from orders
where 1997 = date_part(year, o_orderdate)
group by o_custkey order by count(*) desc limit 3;

+----------+
| COUNT(*) |
|----------|
|        4 |
|        4 |
|        4 |
+----------+

select count(*)
from orders
where 1996 = date_part(year, o_orderdate)
group by o_custkey order by count(*) desc limit 3;

+----------+
| COUNT(*) |
|----------|
|        5 |
|        4 |
|        4 |
+----------+

select o_custkey, count(*)
from orders
where 1996 = date_part(year, o_orderdate)
group by o_custkey having count(*) >= 5 order by count(*) desc limit 3; 

+-----------+----------+
| O_CUSTKEY | COUNT(*) |
|-----------+----------|
|     43645 |        5 |
+-----------+----------+

Along with all, you can also use the any operator, which also compares a value to a set of values, but only needs to find a single instance where the comparison holds true.

let’s say you want to find all orders in 1997 whose total price exceeded the maximum price for orders for any other year. The first step is to generate the list of maximum prices for each year other than 1997

select date_part(year, o_orderdate),
max(o_totalprice)
from orders
where 1997 <> date_part(year, o_orderdate)
group by date_part(year, o_orderdate)
order by 1;

+------------------------------+-------------------+
| DATE_PART(YEAR, O_ORDERDATE) | MAX(O_TOTALPRICE) |
|------------------------------+-------------------|
|                         1992 |         555285.16 |
|                         1993 |         460118.47 |   -- Lowest value in the lot
|                         1994 |         489099.53 |
|                         1995 |         499753.01 |
|                         1996 |         498599.91 |
|                         1998 |         502742.76 |
+------------------------------+-------------------+

The next step is to construct a containing query that finds any order from 1997 whose total price exceeds any of these values:

select o_custkey, o_orderdate, o_totalprice
from orders
where 1997 = date_part(year, o_orderdate)
and o_totalprice > any
(select max(o_totalprice)
from orders
where 1997 <> date_part(year,
o_orderdate)
group by date_part(year, o_orderdate));

+-----------+-------------+--------------+
| O_CUSTKEY | O_ORDERDATE | O_TOTALPRICE |
|-----------+-------------+--------------|
|    148348 | 1997-01-31  |    465610.95 |  -- all of these orders have a total price greater than at least one of the
|     54602 | 1997-02-09  |    471220.08 |  -- values returned by the subquery (the smallest being 460,118.47 in 1993).
|    140506 | 1997-12-21  |    461118.75 |
+-----------+-------------+--------------+

Multicolumn subqueries

In certain situations, however, you can use subqueries that return two or more columns. Let’s start with a query that finds the largest order for each year:

select date_part(year, o_orderdate),
max(o_totalprice)
from orders
group by date_part(year, o_orderdate)
order by 1;

+------------------------------+-------------------+
| DATE_PART(YEAR, O_ORDERDATE) | MAX(O_TOTALPRICE) |
|------------------------------+-------------------|
|                         1992 |         555285.16 |
|                         1993 |         460118.47 |
|                         1994 |         489099.53 |
|                         1995 |         499753.01 |
|                         1996 |         498599.91 |
|                         1997 |         471220.08 |
|                         1998 |         502742.76 |
+------------------------------+-------------------+

select o_custkey, o_orderdate, o_totalprice
from orders
where (date_part(year, o_orderdate),
o_totalprice) in
(select date_part(year, o_orderdate),
max(o_totalprice)
from orders
group by date_part(year, o_orderdate))
order by 2;

+-----------+-------------+--------------+
| O_CUSTKEY | O_ORDERDATE | O_TOTALPRICE |
|-----------+-------------+--------------|
|     21433 | 1992-11-30  |    555285.16 |
|     95069 | 1993-02-28  |    460118.47 |
|    121546 | 1994-10-20  |    489099.53 |
|     52516 | 1995-08-15  |    499753.01 |
|     56620 | 1996-05-22  |    498599.91 |
|     54602 | 1997-02-09  |    471220.08 |
|    100159 | 1998-07-28  |    502742.76 |
+-----------+-------------+--------------+

While there are two columns being compared in this example, there is no limit to the number of columns returned by the subquery, as long as the data types match between the containing query and the subquery.

Correlated Subqueries

So far in this chapter, all of the subqueries have been independent of the containing statement, meaning that the subqueries are run once, prior to the execution of the containing statement. A correlated subquery, on the other hand, references one or more columns from the containing statement, which means that both the subquery and containing query must run together.

For example, the next query returns the set of customers who have placed at least $17,50,000 in all of the orders they placed:

select c.c_name
from customer c
where 1750000 <=
(select sum(o.o_totalprice)
from orders o
where o.o_custkey = c.c_custkey);

+--------------------+
| C_NAME             |
|--------------------|
| Customer#000036316 |
| Customer#000066103 |
| Customer#000120202 |
| Customer#000022924 |
+--------------------+

Looking at the subquery, you can see that the condition in the where clause references a column from the Customer table in the containing query, which is what makes it a correlated subquery. For every row in the Customer table, the subquery is executed to determine the total price of all orders for that customer. Since there are 66,076 rows in the Customer table, the subquery is executed 66,076 times.

Since the correlated subquery will be executed once for each row of the containing query, the use of correlated subqueries can cause performance issues if the containing query returns a large number of rows.

Exists operator

Correlated subqueries are often used with the exists operator, which is useful when you want to test for the existence of a particular relationship without regard for the quantity.
For example, let’s say you want to find all customers who have ever placed an (atleast one of the order they placed) order over $500,000, without regard for the number of orders or the exact amount of the order.

select c.c_name
from customer c
where exists
(select 1 from orders o
where o.o_custkey = c.c_custkey
and o.o_totalprice > 500000);

+--------------------+
| C_NAME             |
|--------------------|
| Customer#000008936 |
| Customer#000021433 |
| Customer#000100159 |
+--------------------+

Again, the subquery is executed once for each row in the Customer table, but this time the subquery either returns no rows (if the customer never placed an order above $500,000) or a single row if at least one order above $500,000 is found. When using exists, Snowflake is smart enough to stop execution of the subquery once the first matching row is found.

Correlated subqueries in update and delete statements

For example, your IT department may have a policy to remove rows from the Customer table for any customers who haven’t placed an order in the past 5 years.

delete from customer c
where not exists
(select 1 from orders o
where o.o_custkey = c.c_custkey
and o.o_orderdate > dateadd(year, -5,
current_date));

This statement uses not exists, so it is finding rows in Customer where no rows exist in Orders with a date greater than current day minus 5 years.

If the policy is instead to mark the customer’s record as inactive rather than deleting the record, you could modify the previous statement to use update instead:

update customer c
set inactive = 'Y'
where not exists
(select 1 from orders o
where o.o_custkey = c.c_custkey
and o.o_orderdate > dateadd(year, -5,
current_date));

Another example
alter table employee add inactive varchar(1);

update employee e set e.inactive = 'Y'
where not exists
(select 1 from person p
where p.first_name || ' ' || p.last_name =
e.emp_name);

Subqueries are commonly used in update and delete statements, since you will frequently need information from other tables when modifying or deleting rows.

The previous update statement was executed while in autocommit mode, which is the default when using Snowflake. This means that the changes made were automatically committed as soon as the statement completed.

Subqueries as Data Sources

Since subqueries return result sets, they can be used in place of tables in select statements, as shown in the next two sections.

Subqueries in the from Clause

Tables consist of multiple rows and multiple columns, and the result set returned by a subquery also consists of multiple rows and columns. Therefore, tables and subqueries can both be used in the from clause of a query, and can even be joined to each other.

select c.c_name, o.total_dollars
from
(select o_custkey, sum(o_totalprice) as
total_dollars
from orders
where 1998 = date_part(year, o_orderdate)
group by o_custkey
having sum(o_totalprice) >= 650000
) o
inner join customer c
on c.c_custkey = o.o_custkey
order by 1;

+--------------------+---------------+
| C_NAME             | TOTAL_DOLLARS |
|--------------------+---------------|
| Customer#000002948 |     663115.18 |
| Customer#000004309 |     719354.94 |
| Customer#000005059 |     734893.37 |
| Customer#000022924 |     686947.21 |
| Customer#000026729 |     654376.71 |
| Customer#000033487 |     727194.76 |
| Customer#000044116 |     699699.98 |
| Customer#000061120 |     656770.28 |
| Customer#000065434 |    1030712.34 |
| Customer#000074695 |     665357.12 |
| Customer#000074807 |     673802.06 |
| Customer#000090608 |     727770.25 |
| Customer#000097519 |     680678.45 |
| Customer#000098410 |     673907.68 |
| Customer#000102904 |     667912.44 |
| Customer#000138724 |     717744.86 |
+--------------------+---------------+

In this example, the subquery is given the alias o and is then joined to the Customer table using the custkey column.
The subquery returns all customers having orders in 1998 of $650,000 or above, and the result set is then joined to the Customer table to allow the customer name to be returned instead of the custkey value.

Subqueries used as data sources must be uncorrelated; they are executed first, and the result set is held in memory until  the containing query has completed.

However, the next section shows how you can access the results of one subquery in another subquery by utilizing a with clause.

Along with putting subqueries in the from clause, you also have the option to move your subqueries into a with clause, which must always appear at the top of your query above the select clause.

Same above query using with Clause

with big_orders as
(select o_custkey, sum(o_totalprice) as
total_dollars
from orders
where 1998 = date_part(year, o_orderdate)
group by o_custkey
having sum(o_totalprice) >= 650000
)
select c.c_name, big_orders.total_dollars
from big_orders
inner join customer c
on c.c_custkey = big_orders.o_custkey
order by 1;

+--------------------+---------------+
| C_NAME             | TOTAL_DOLLARS |
|--------------------+---------------|
| Customer#000002948 |     663115.18 |
| Customer#000004309 |     719354.94 |
| Customer#000005059 |     734893.37 |
| Customer#000022924 |     686947.21 |
| Customer#000026729 |     654376.71 |
| Customer#000033487 |     727194.76 |
| Customer#000044116 |     699699.98 |
| Customer#000061120 |     656770.28 |
| Customer#000065434 |    1030712.34 |
| Customer#000074695 |     665357.12 |
| Customer#000074807 |     673802.06 |
| Customer#000090608 |     727770.25 |
| Customer#000097519 |     680678.45 |
| Customer#000098410 |     673907.68 |
| Customer#000102904 |     667912.44 |
| Customer#000138724 |     717744.86 |
+--------------------+---------------+

Subqueries in a with clause are known as common table expressions, or CTEs. Having a single CTE can make a query more readable, but if you have multiple CTEs in a with clause you can reference any subqueries defined above in the same with clause.

previous query again, this time with both queries defined as CTEs:

with 
big_orders as
(select o_custkey, sum(o_totalprice) as
total_dollars
from orders
where 1998 = date_part(year, o_orderdate)
group by o_custkey
having sum(o_totalprice) >= 650000
),

big_orders_with_names as
(select c.c_name, big_orders.total_dollars
from big_orders
inner join customer c
on c.c_custkey = big_orders.o_custkey
)
select *
from big_orders_with_names
order by 1;

+--------------------+---------------+
| C_NAME             | TOTAL_DOLLARS |
|--------------------+---------------|
| Customer#000002948 |     663115.18 |
| Customer#000004309 |     719354.94 |
| Customer#000005059 |     734893.37 |
| Customer#000022924 |     686947.21 |
| Customer#000026729 |     654376.71 |
| Customer#000033487 |     727194.76 |
| Customer#000044116 |     699699.98 |
| Customer#000061120 |     656770.28 |
| Customer#000065434 |    1030712.34 |
| Customer#000074695 |     665357.12 |
| Customer#000074807 |     673802.06 |
| Customer#000090608 |     727770.25 |
| Customer#000097519 |     680678.45 |
| Customer#000098410 |     673907.68 |
| Customer#000102904 |     667912.44 |
| Customer#000138724 |     717744.86 |
+--------------------+---------------+

The with clause now has two subqueries; big_orders and big_orders_with_names. Additionally, the big_orders_with_names subquery retrieves data from the big_orders subquery, with is allowable because big_orders is defined first.

Using CTEs is a bit like creating a function in Java or Python: you can use the subqueries as many times as you want within a piece of code, the difference being that with SQL the results from the CTEs are discarded after the statement execution completes. You can also use CTEs to fabricate data sets that don’t exist in your database, as shown in the next example:

with dollar_ranges as
(
select * from 
(values (3, 'Bottom Tier', 650000, 700000),
(2, 'Middle Tier', 700001, 730000),
(1, 'Top Tier', 730001, 9999999)
)
as dr (range_num, range_name, low_val, high_val)),

big_orders as
(select o_custkey, sum(o_totalprice) as
total_dollars
from orders
where 1998 = date_part(year, o_orderdate)
group by o_custkey
having sum(o_totalprice) >= 650000
),

big_orders_with_names as
(select c.c_name, big_orders.total_dollars
from big_orders
inner join customer c
on c.c_custkey = big_orders.o_custkey
)

select dr.range_name,
sum(round(bon.total_dollars,0)) rng_sum,
listagg(bon.c_name,',')
within group (order by bon.c_name)
name_list
from big_orders_with_names as bon
inner join dollar_ranges as dr
on bon.total_dollars between dr.low_val and
dr.high_val
group by dr.range_name;

+-------------+---------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| RANGE_NAME  | RNG_SUM | NAME_LIST                                                                                                                                                                                     |
|-------------+---------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Top Tier    | 1765605 | Customer#000005059,Customer#000065434                                                                                                                                                         |
| Middle Tier | 2892065 | Customer#000004309,Customer#000033487,Customer#000090608,Customer#000138724                                                                                                                   |
| Bottom Tier | 6722566 | Customer#000002948,Customer#000022924,Customer#000026729,Customer#000044116,Customer#000061120,Customer#000074695,Customer#000074807,Customer#000097519,Customer#000098410,Customer#000102904 |
+-------------+---------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

Excercise - Chap8

Write a query against the Nation table that uses an uncorrelated subquery on the Region table to return the names of all nations except those in the America and Asia regions.

select R_REGIONKEY from region where R_NAME not in ('AMERICA' , 'ASIA');

select N_NAME from nation where N_REGIONKEY in 
(select R_REGIONKEY from region where R_NAME not in ('AMERICA' , 'ASIA'))
;

Generate the same results as previous query, but using a correlated subquery against the Region table.

select N_NAME from nation as n where exists  
(select 1 from region r where n.N_REGIONKEY = r.R_REGIONKEY and R_NAME not in ('AMERICA' , 'ASIA'));

Write a query against the Customer table that returns the c_custkey and c_name columns for all customers who placed exactly four orders in 1997. Use an uncorrelated subquery against the Orders table.

select c_custkey, C_NAME from customer where c_custkey in (
select O_CUSTKEY from orders where date_part (year, O_ORDERDATE) = 1997 group by 1 having count(*) =4) ;

Modify the query from previous query to return the same results, but with a correlated subquery.

with 
fourord as 
(select O_CUSTKEY from orders where date_part (year, O_ORDERDATE) = 1997 group by 1 having count(*) =4),
final as
(select c_custkey, C_NAME from customer as c inner join fourord where c.c_custkey = fourord.O_CUSTKEY)
select * from final;


Chap 9

create table employee
(empid number, emp_name varchar(30), mgr_empid number)
as select *
from (values
(1001, 'Bob Smith', null),
(1002, 'Susan Jackson', 1001),
(1003, 'Greg Carpenter', 1001),
(1004, 'Robert Butler', 1002),
(1005, 'Kim Josephs', 1003),
(1006, 'John Tyler', 1004));

Hierarchical Queries

Some data is hierarchical in nature, such as a family tree, where each data point has a relationship with other data points above and/or below.

each employee’s row contains a value to identify the employee’s manager. If you wanted to write a query to show these relationships, you could try to join the Employee table to itself multiple times:

select e_1.emp_name, e_2.emp_name,
e_3.emp_name, e_4.emp_name
from employee e_1
inner join employee e_2
on e_1.mgr_empid = e_2.empid
inner join employee e_3
on e_2.mgr_empid = e_3.empid
inner join employee e_4
on e_3.mgr_empid = e_4.empid
where e_1.emp_name = 'John Tyler';

+------------+---------------+---------------+-----------+
| EMP_NAME   | EMP_NAME      | EMP_NAME      | EMP_NAME  |
|------------+---------------+---------------+-----------|
| John Tyler | Robert Butler | Susan Jackson | Bob Smith |
+------------+---------------+---------------+-----------+ 

This query includes the Employee table four times, one for each level in the management hierarchy. But what if there are more levels of managers?

Snowflake provides the connect by clause to traverse hierarchical relationships.

select emp_name
from employee
start with emp_name = 'John Tyler'
connect by prior mgr_empid = empid;

+---------------+
| EMP_NAME      |
|---------------|
| John Tyler    |
| Robert Butler |
| Susan Jackson |
| Bob Smith     |
+---------------+

The start by clause describes which row to start from, and the connect by clause describes how to traverse from one row to the next. The prior keyword is used to denote the current level, so when the query starts with John Tyler’s row, the prior mgr_empid value is 1004, which is used to move to the row with empid of 1004 (Robert Butler’s row).

Let’s see what happens if the query is run in the opposite direction, starting with Bob Smith and moving down the hierarchy

select emp_name
from employee
start with emp_name = 'Bob Smith'
connect by prior empid = mgr_empid;

+----------------+
| EMP_NAME       |
|----------------|
| Bob Smith      |
| Susan Jackson  |
| Greg Carpenter |
| Robert Butler  |
| Kim Josephs    |
| John Tyler     |
+----------------+

This time, Bob Smith’s row is the starting point, and the connect by clause is reversed because we are traveling down the tree instead of up. the results don’t show any of the intermediate relationships, such as the fact that Robert Butler reports to Susan Jackson. If you want to see these relationships, you can use the built in function sys_connect_by_path() to see a description of the entire hierarchy up to that point:

select emp_name,
sys_connect_by_path(emp_name, ' : ')
management_path
from employee
start with emp_name = 'Bob Smith'
connect by prior empid = mgr_empid;

+----------------+-----------------------------------------------------------+
| EMP_NAME       | MANAGEMENT_PATH                                           |
|----------------+-----------------------------------------------------------|
| Bob Smith      |  : Bob Smith                                              |
| Susan Jackson  |  : Bob Smith : Susan Jackson                              |
| Greg Carpenter |  : Bob Smith : Greg Carpenter                             |
| Robert Butler  |  : Bob Smith : Susan Jackson : Robert Butler              |
| Kim Josephs    |  : Bob Smith : Greg Carpenter : Kim Josephs               |
| John Tyler     |  : Bob Smith : Susan Jackson : Robert Butler : John Tyler |
+----------------+-----------------------------------------------------------+

Time Travel

Snowflake’s Time Travel feature allows you to execute queries that will see your data as it was at a certain time in the past. To do so, you can use the at keyword to specify either a specific time or an offset from the current time, and Snowflake will retrieve the data as it was at that point in time.

insert into employee (empid, emp_name,
mgr_empid)
values (9999, 'Tim Traveler',1006);

select empid, emp_name, mgr_empid
from employee;
+-------+----------------+-----------+
| EMPID | EMP_NAME       | MGR_EMPID |
|-------+----------------+-----------|
|  1001 | Bob Smith      |      NULL |
|  1002 | Susan Jackson  |      1001 |
|  1003 | Greg Carpenter |      1001 |
|  1004 | Robert Butler  |      1002 |
|  1005 | Kim Josephs    |      1003 |
|  1006 | John Tyler     |      1004 |
|  9999 | Tim Traveler   |      1006 |
+-------+----------------+-----------+
7 Row(s) produced. Time Elapsed: 0.824s

select empid, emp_name, mgr_empid
from employee
at(offset => -3600);     -- 1 hour back 3600 seconds
000707 (02000): Time travel data is not available for table EMPLOYEE. The requested time is either beyond the allowed time travel period or before the object creation time.

select empid, emp_name, mgr_empid
from employee
at(offset => -1800);     -- 30 mins back 1800 seconds

+-------+----------------+-----------+
| EMPID | EMP_NAME       | MGR_EMPID |
|-------+----------------+-----------|
|  1001 | Bob Smith      |      NULL |   -- new insert record is not present 30 mins back
|  1002 | Susan Jackson  |      1001 |
|  1003 | Greg Carpenter |      1001 |
|  1004 | Robert Butler  |      1002 |
|  1005 | Kim Josephs    |      1003 |
|  1006 | John Tyler     |      1004 |
+-------+----------------+-----------+
6 Row(s) produced. Time Elapsed: 0.693s

One of the uses of this feature would be to identify which rows were inserted over a particular time span. This next query uses the minus operator to compare the current state of the table with the state one hour ago:

select empid, emp_name, mgr_empid
from employee
minus
select empid, emp_name, mgr_empid
from employee
at(offset => -1800);

+-------+--------------+-----------+
| EMPID | EMP_NAME     | MGR_EMPID |
|-------+--------------+-----------|
|  9999 | Tim Traveler |      1006 |
+-------+--------------+-----------+
1 Row(s) produced. Time Elapsed: 1.284s

The default for Time Travel is one day in the past, but if you are using Snowflake’s Enterprise edition you can run queries that see the state of the data up to 90 days in the past.

Pivot Queries

Pivoting is a common operation in data analysis, where rows of data need to be pivoted into columns. query that sums
the total sales for each year after 1995:

select date_part(year, o_orderdate) as year,
round(sum(o_totalprice)) as total_sales
from orders
where 1995 <= date_part(year, o_orderdate)
group by date_part(year, o_orderdate)
order by 1;

+------+-------------+
| YEAR | TOTAL_SALES |
|------+-------------|
| 1995 |  3317521810 |
| 1996 |  3296373353 |
| 1997 |  3255086721 |
| 1998 |  1925196449 |
+------+-------------+

you are asked to format these results for a report that shows this data on a single row, with four columns showing the total sales for 1995, 1996, 1997, and 1998: For these types of operations, Snowflake supplies a pivot clause to allow you to specify how you want the data to be presented.

select round(yr_1995) as "1995_sales",
round(yr_1996) as "1996_sales",
round(yr_1997) as "1997_sales",
round(yr_1998) as "1998_sales"
from (select date_part(year, o_orderdate) as
year,
o_totalprice
from orders
where 1995 <= date_part(year,
o_orderdate)
)
pivot (sum(o_totalprice)
for year in (1995,1996,1997,1998))
as pvt(yr_1995, yr_1996, yr_1997, yr_1998);

+------------+------------+------------+------------+
| 1995_sales | 1996_sales | 1997_sales | 1998_sales |
|------------+------------+------------+------------|
| 3317521810 | 3296373353 | 3255086721 | 1925196449 |
+------------+------------+------------+------------+

The subquery in the from clause retrieves the year and totalprice values for all orders in 1995 and later, and the pivot clause specifies that the totalprice values be summed into 4 columns, one each for the years 1995, 1996, 1997, and 1998. The third line in the pivot clause assigns column names to each of the columns (yr_1995, ..., yr_1998), which are then used in the select clause to round each value.

Snowflake also provides an unpivot clause that performs the opposite transformation (pivot data from columns into rows). To demonstrate, I’ll take the previous pivot query, put it into a with clause, and then use a query with unpivot to return the result set to its original state:

with year_pvt as
(select round(yr_1995) as "1995",
round(yr_1996) as "1996",
round(yr_1997) as "1997",
round(yr_1998) as "1998"
from (select date_part(year, o_orderdate)
as year,
o_totalprice
from orders
where 1995 <= date_part(year,
o_orderdate)
)
pivot (sum(o_totalprice)
for year in (1995,1996,1997,1998))
as pvt(yr_1995, yr_1996, yr_1997,
yr_1998)
)
select *
from year_pvt
unpivot (total_sales for year in
("1995", "1996", "1997", "1998"));

+------+-------------+
| YEAR | TOTAL_SALES |
|------+-------------|
| 1995 |  3317521810 |
| 1996 |  3296373353 |
| 1997 |  3255086721 |
| 1998 |  1925196449 |
+------+-------------+

Random Sampling

Sometimes it is useful to retrieve a subset of a table for tasks such as testing, and you want the subset to be different every time. For this purpose, Snowflake includes the sample clause to allow you to specify what percent of the rows you would like returned.

the Supplier table has 7,400 rows, but perhaps you’d like to return just 1/1,000 of the rows to run some tests.

select s_suppkey, s_name, s_nationkey from supplier
sample (0.1);

In this example, 0.1 is specified as the probability, meaning that there should be a 0.1% chance that any particular row is included in the result set. If you run this query multiple times, you will get a different set of rows (and potentially a different number of rows) each time.

select count(*) from (
select s_suppkey, s_name, s_nationkey from supplier
sample (0.1));    -- 9 records 0.1% probability for each row

select count(*) from (
select s_suppkey, s_name, s_nationkey from supplier
sample (1));    -- 80 records 1% probability for each row

select count(*) from (
select s_suppkey, s_name, s_nationkey from supplier
sample (10));    -- 684 records 10% probability for each row

select count(*) from (
select s_suppkey, s_name, s_nationkey from supplier
sample (10));    -- 760 records 10% probability for each row

select count(*) from (
select s_suppkey, s_name, s_nationkey from supplier
sample (10));    -- 769 records 10% probability for each row

select count(*) from (
select s_suppkey, s_name, s_nationkey from supplier
sample (100));    -- 7400 records 100% probability for each row - ALL ROWS RETURNED

If you need an exact number of rows, you can specify a row count:

select s_suppkey, s_name, s_nationkey
from supplier
sample (10 rows);

Full Outer Joins

select orders.ordernum, orders.custkey,
customer.custname
from
(values (990, 101), (991, 102), (992, 101), (993, 104))
as orders (ordernum, custkey)
full outer join
(values (101, 'BOB'), (102, 'KIM'), (103, 'JIM'))
as customer (custkey, custname)
on orders.custkey = customer.custkey;

+----------+---------+----------+
| ORDERNUM | CUSTKEY | CUSTNAME |
|----------+---------+----------|
|      990 |     101 | BOB      |
|      991 |     102 | KIM      |
|      992 |     101 | BOB      |
|      993 |     104 | NULL     |
|     NULL |    NULL | JIM      |
+----------+---------+----------+
5 Row(s) produced. Time Elapsed: 0.806s

However,
Jim’s custkey value in the result set is null because orders.custkey is specified in the select clause. This can be fixed by using the nvl() function to return the custkey value from either the orders or customer data sets:

select orders.ordernum,
nvl(orders.custkey, customer.custkey) as
custkey,
customer.custname
from
(values (990, 101), (991, 102),
(992, 101), (993, 104))
as orders (ordernum, custkey)
full outer join
(values (101, 'BOB'), (102, 'KIM'), (103,
'JIM'))
as customer (custkey, custname)
on orders.custkey = customer.custkey;

+----------+---------+----------+
| ORDERNUM | CUSTKEY | CUSTNAME |
|----------+---------+----------|
|      990 |     101 | BOB      |
|      991 |     102 | KIM      |
|      992 |     101 | BOB      |
|      993 |     104 | NULL     |
|     NULL |     103 | JIM      |
+----------+---------+----------+

When you specify full outer joins, you will generally want to use nvl() for any columns that can come from either of the tables.

Lateral Joins

Snowflake allows a subquery in the from clause to reference another table in the same from clause, which means that the subquery acts like a correlated subquery. This is done by specifying the lateral keyword,

select ord.o_orderdate, ord.o_totalprice,
cst.c_name, cst.c_address
from orders ord
inner join lateral
(select c.c_name, c.c_address
from customer c
where c.c_custkey = ord.o_custkey
) cst
where 1995 <= date_part(year,
ord.o_orderdate)
and ord.o_totalprice > 475000;

+-------------+--------------+--------------------+------------------------------------+
| O_ORDERDATE | O_TOTALPRICE | C_NAME             | C_ADDRESS                          |
|-------------+--------------+--------------------+------------------------------------|
| 1996-09-16  |    491096.90 | Customer#000111926 | yDC67043irodcywMl                  |
| 1998-07-28  |    502742.76 | Customer#000100159 | fcjfNCnKTf4wvvY0Nq9p,aYnTLmf1rpbu  |
| 1995-08-15  |    499753.01 | Customer#000052516 | BUePeY1OPR3 35zwkJF4NA7FKE8gKtI0cR |
| 1996-05-22  |    498599.91 | Customer#000056620 | QAnxRzFcVPARTjvvG3SvYnfCOMVqR5 yX  |
+-------------+--------------+--------------------+------------------------------------+

In this example, the cst subquery references the o_custkey column from the Orders table (alias ord), which is what makes it a correlated subquery. For the seven rows returned from the Orders table, the cst subquery is executed using the custkey value for that row. These same results can be generated using a standard inner join, so this is not a particularly compelling reason to use lateral,

select ord.O_ORDERKEY, ord.o_orderdate, li.last_shipdate, datediff(day,li.last_shipdate,ord.o_orderdate) as delay_day, li.num_line_items, ord.o_totalprice
from orders ord
inner join lateral
(select count(*) as num_line_items,
max(l_shipdate) as last_shipdate
from lineitem as l
where l.l_orderkey = ord.o_orderkey
) li
where 1995 <= date_part(year,
ord.o_orderdate)
and ord.o_totalprice > 475000 order by delay_day;

+------------+-------------+---------------+-----------+----------------+--------------+
| O_ORDERKEY | O_ORDERDATE | LAST_SHIPDATE | DELAY_DAY | NUM_LINE_ITEMS | O_TOTALPRICE |
|------------+-------------+---------------+-----------+----------------+--------------|
|    1395745 | 1998-07-28  | 1998-11-25    |      -120 |              1 |    502742.76 |
|    2152359 | 1996-05-22  | 1996-08-28    |       -98 |              1 |    498599.91 |
|    5709632 | 1995-08-15  | 1995-10-01    |       -47 |              1 |    499753.01 |
|    2844870 | 1996-09-16  | 1996-10-23    |       -37 |              1 |    491096.90 |
+------------+-------------+---------------+-----------+----------------+--------------+

In this case, the correlated subquery uses the aggregate functions count() and max() to retrieve the number of line items and maximum shipping date for each row returned from the Orders table.

Table Literals

Snowflake allows table names to be passed into a query as a string using the table() function. table() function then looks for a table of that name in the current schema. You can also pass in the database and schema names

select * from table('region');
select * from table('learning_sql.public.region');

-- Declare variable and use in query
set rtab='region';
select $rtab;

select * from table($rtab);

+-------------+-------------+---------------------------------------------------------------------------------------------------------------------+
| R_REGIONKEY | R_NAME      | R_COMMENT                                                                                                           |
|-------------+-------------+---------------------------------------------------------------------------------------------------------------------|
|           0 | AFRICA      | lar deposits. blithely final packages cajole. regular waters are final requests. regular accounts are according to  |
|           1 | AMERICA     | hs use ironic, even requests. s                                                                                     |
|           2 | ASIA        | ges. thinly even pinto beans ca                                                                                     |
|           3 | EUROPE      | ly final courts cajole furiously final excuse                                                                       |
|           4 | MIDDLE EAST | uickly special accounts cajole carefully blithely close requests. carefully final asymptotes haggle furiousl        |
+-------------+-------------+---------------------------------------------------------------------------------------------------------------------+

-- Declare variable set the query output into variable
SET rtab_cnt = (SELECT COUNT(*) FROM table($rtab));  -- Take the count of table in a variable
select $rtab_cnt;
+-----------+
| $RTAB_CNT |
|-----------|
|         5 |
+-----------+

-- Declare anonymous block returns count of table
execute immediate $$
DECLARE record_count INT;
begin
SELECT COUNT(*) INTO :record_count 
FROM region;
RETURN :record_count;
end;$$;

+-----------------+
| anonymous block |
|-----------------|
|               5 |
+-----------------+

-- 
SET sess_record_count = 0; 

execute immediate $$
DECLARE record_count INT;
begin
SELECT COUNT(*) INTO :record_count 
FROM region;
SET sess_record_count = :record_count;     -- already declared Session variable outside of block
SET nondec_record_count = :record_count;   -- undeclared Session variable outside of block, declared in block will be available outside
end;$$;

+-----------------+
| anonymous block |
|-----------------|
| NULL            |
+-----------------+

select $sess_record_count;
select $nondec_record_count;

+--------------------+
| $SESS_RECORD_COUNT |
|--------------------|
|                  5 |
+--------------------+
1 Row(s) produced. Time Elapsed: 0.741s
+----------------------+
| $NONDEC_RECORD_COUNT |
|----------------------|
|                    5 |
+----------------------+
1 Row(s) produced. Time Elapsed: 0.417s

When you are working with a script or stored procedure, the table literals passed into the table() function will be evaluated at runtime, allowing for some very flexible code.

script written using the Snowflake Scripting language that will return the number of rows for all tables in the Public schema with names less than 10 characters in length:

execute immediate $$
declare
v_tbl_nm varchar(50);
v_tbl_cnt number(7);
v_output varchar(99999) := '{';
v_cur cursor for
select table_name
from
learning_sql.information_schema.tables
where table_schema = 'PUBLIC' and
table_type <> 'VIEW'
and length(table_name) < 10;
begin
for rec in v_cur do
v_tbl_nm := rec.table_name;
select count(*)
into v_tbl_cnt
from table(:v_tbl_nm);
v_output := concat(v_output,' {',
v_tbl_nm,' : ',v_tbl_cnt,'}');
end for;
v_output := concat(v_output,'}');
set table_with_cnt = :v_output;    -- Assign the result to a session variable
return v_output;
end;$$;

+---------------------------------------------------------------------------------------------------------------------------------------------------------------+
| anonymous block                                                                                                                                               |
|---------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Tables: {ORDERS : 115269} {PART : 4000} {REGION : 5} {PARTSUPP : 16000} {LINEITEM : 119989} {SUPPLIER : 7400} {CUSTOMER : 66076} {EMPLOYEE : 7} {NATION : 25} |
+---------------------------------------------------------------------------------------------------------------------------------------------------------------+

select $table_with_cnt;
+---------------------------------------------------------------------------------------------------------------------------------------------------------------+
| $TABLE_WITH_CNT                                                                                                                                               |
|---------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Tables: {ORDERS : 115269} {PART : 4000} {REGION : 5} {PARTSUPP : 16000} {LINEITEM : 119989} {SUPPLIER : 7400} {CUSTOMER : 66076} {EMPLOYEE : 7} {NATION : 25} |
+---------------------------------------------------------------------------------------------------------------------------------------------------------------+


EXECUTE IMMEDIATE is used to execute dynamic SQL. its called as anonymous block without giving name to stored procedure.

In Snowflake, nested anonymous blocks (i.e., declaring one anonymous block inside another) are not allowed. Snowflake does not support defining a second anonymous block within the scope of the first one.

You cannot declare an anonymous block inside another anonymous block in Snowflake. However, you can use stored procedures, break your logic into multiple blocks, or utilize Snowflake Scripting to handle sequential execution of multiple SQL statements.

Change above anonymous block to return only tables with count of records more than 10000 --- Try later
Make the block to return the result as json variant object instead of string into session variable then flatten that variable --- try later

Excercise - Chap9

The following query returns the number of customers in each market segment:

select c_mktsegment as mktseg, count(*)
tot_custs
from customer
group by c_mktsegment;
+------------+-----------+
| MKTSEG     | TOT_CUSTS |
|------------+-----------|
| AUTOMOBILE |     13192 |
| MACHINERY  |     13185 |
| BUILDING   |     13360 |
| HOUSEHOLD  |     13214 |
| FURNITURE  |     13125 |
+------------+-----------+

Use this query as the basis for a pivot query so that there is a single row with five columns, with each column having the name of a market segment.

select aut_cust, mac_cust, bul_cust, hou_cust, fur_cust 
from
(select c_mktsegment as mktseg, 1 as one_cust
from customer)
pivot (sum(one_cust)
for mktseg in ('AUTOMOBILE','MACHINERY','BUILDING','HOUSEHOLD','FURNITURE'))
as pvt(aut_cust, mac_cust, bul_cust, hou_cust, fur_cust);

+----------+----------+----------+----------+----------+
| AUT_CUST | MAC_CUST | BUL_CUST | HOU_CUST | FUR_CUST |
|----------+----------+----------+----------+----------|
|    13192 |    13185 |    13360 |    13214 |    13125 |
+----------+----------+----------+----------+----------+

The following query counts the number of suppliers in each nation:

select s_nationkey, count(*) as
supplier_count
from supplier
group by s_nationkey;

Modify this query to add the Nation.n_name column using a lateral join to the Nation table.

Sol 1 - will work even without lateral keyword it can be just inner join itself

select n_name, sup.supplier_count 
from nation 
inner join lateral 
(select s_nationkey, count(*) as
supplier_count
from supplier group by s_nationkey) as sup
where sup.s_nationkey = n_nationkey;

Sol2 - With need for lateral keyword without lateral this will not work

select n_name, count(sup.one_supplier_count) 
from nation as naty
inner join lateral 
(select s_nationkey, 1 as 
one_supplier_count
from supplier where s_nationkey = naty.n_nationkey) as sup
group by n_name;

Thomas and Clara’s parents are unknown at this point, so they have a null value for the father_person_id column. Write a query to walk the Smith family tree starting with Thomas, using the sys_connect_by_path() function to show the full ancestry. You can use the following with clause as a starter:

with smith_history as
(select person_id, name, father_person_id
from (values
(1,'Thomas',null),
(2,'Clara',null),
(3,'Samuel',1),
(4,'Charles',1),
(5,'Beth',3),
(6,'Steven',4),
(7,'Sarah',6),
(8,'Robert',4),
(9,'Dorothy',8),
(10,'George',8))
as smith(person_id, name,
father_person_id)
)

select name,
sys_connect_by_path(name, ' : ') as family_tree
from (
select person_id, name, father_person_id
from (values
(1,'Thomas',null),
(2,'Clara',null),
(3,'Samuel',1),
(4,'Charles',1),
(5,'Beth',3),
(6,'Steven',4),
(7,'Sarah',6),
(8,'Robert',4),
(9,'Dorothy',8),
(10,'George',8))
as smith(person_id, name,
father_person_id)) 
start with name = 'Thomas'
connect by prior person_id = father_person_id;

+---------+----------------------------------------+
| NAME    | FAMILY_TREE                            |
|---------+----------------------------------------|
| Thomas  |  : Thomas                              |
| Samuel  |  : Thomas : Samuel                     |
| Charles |  : Thomas : Charles                    |
| Beth    |  : Thomas : Samuel : Beth              |
| Steven  |  : Thomas : Charles : Steven           |
| Robert  |  : Thomas : Charles : Robert           |
| Sarah   |  : Thomas : Charles : Steven : Sarah   |
| Dorothy |  : Thomas : Charles : Robert : Dorothy |
| George  |  : Thomas : Charles : Robert : George  |
+---------+----------------------------------------+
9 Row(s) produced. Time Elapsed: 0.444s

select name,
sys_connect_by_path(name, ' : ') as family_tree
from (
select person_id, name, father_person_id
from (values
(1,'Thomas',null),
(2,'Clara',null),
(3,'Samuel',1),
(4,'Charles',1),
(5,'Beth',3),
(6,'Steven',4),
(7,'Sarah',6),
(8,'Robert',4),
(9,'Dorothy',8),
(10,'George',8))
as smith(person_id, name,
father_person_id)) 
start with name = 'Clara'
connect by prior person_id = father_person_id;

+-------+-------------+
| NAME  | FAMILY_TREE |
|-------+-------------|
| Clara |  : Clara    |
+-------+-------------+
1 Row(s) produced. Time Elapsed: 0.558s

Chap 10 : Conditional Logic

In certain situations, you may want your SQL statement to behave differently depending on the values of certain columns or expressions, which is known as conditional logic. The mechanism used for conditional logic in SQL statements is the case expression, which can be utilized in insert, update, and delete statements, as well as in every clause of a select statement.

For example, a company’s order entry system may have logic specifying that a 10% discount be given if that customer’s orders exceeded a certain value for the previous year. If you have written programs using a language like Python or Java, you are accustomed to using if...then...else statements, but the SQL language uses case expressions for conditional logic. The case expression works like a cascading if-then-else statement, evaluating a series of conditions in sequence. Here’s a simple example:

select c_custkey, c_name, c_acctbal,
case
when c_acctbal < 0 then 'generate refund'
when c_acctbal = 0 then 'no action'
else 'send bill'
end as month_end_action
from customer
sample (0.1) limit 15;   -- Use both sample and limit to get random set of records just limit alone will return first 15 records only

+-----------+--------------------+-----------+------------------+
| C_CUSTKEY | C_NAME             | C_ACCTBAL | MONTH_END_ACTION |
|-----------+--------------------+-----------+------------------|
|        76 | Customer#000000076 |   5745.33 | send bill        |
|      4058 | Customer#000004058 |    324.15 | send bill        |
|     31018 | Customer#000031018 |   -685.25 | generate refund  |
|     61513 | Customer#000061513 |    128.44 | send bill        |
|     64723 | Customer#000064723 |   2749.13 | send bill        |
|     69769 | Customer#000069769 |   6789.03 | send bill        |
|     70657 | Customer#000070657 |   9320.42 | send bill        |
|     71731 | Customer#000071731 |   4367.83 | send bill        |
|    120568 | Customer#000120568 |   -417.02 | generate refund  |
|     11113 | Customer#000011113 |   2697.37 | send bill        |
|     11390 | Customer#000011390 |   9246.67 | send bill        |
|     13753 | Customer#000013753 |   4862.56 | send bill        |
|     14305 | Customer#000014305 |   7027.56 | send bill        |
|     45019 | Customer#000045019 |   2703.32 | send bill        |
|     45665 | Customer#000045665 |   1482.73 | send bill        |
+-----------+--------------------+-----------+------------------+

Case expressions can have multiple conditions (each starting with the when keyword), and the conditions are evaluated in order from top to bottom. Evaluation ends as soon as one condition evaluates as true.

select num.val,
case
when num.val > 90 then 'huge number'
when num.val > 50 then 'really big
number'
when num.val > 20 then 'big number'
when num.val > 10 then 'medium number'
when num.val <= 10 then 'small number'
end as num_size
from (values (11), (12), (25), (99), (3)) as
num (val);

+-----+---------------+
| VAL | NUM_SIZE      |
|-----+---------------|
|  11 | medium number |
|  12 | medium number |
|  25 | big number    |
|  99 | huge number   |
|   3 | small number  |
+-----+---------------+

Types of Case Expressions

two different types of case expressions. Searched Case Expressions and Simple Case Expressions

Searched Case Expressions

case
when condition1 then expression1
when condition2 then expression2
...
when conditionN then expressionN
[else expressionZ]
end

Searched case expressions can have multiple when clauses and an optional else clause to be returned if none of the when clauses evaluate as true. Case expressions can return any type of expression, including numbers, strings, dates, and even subqueries, as demonstrated in the following example:

This query looks at rows in the Part table and executes a subquery to count the number of times the part has been ordered only if the part’s retail price is above $2,000.

select p_partkey, p_retailprice,
case
when p_retailprice > 2000 then
(select count(*)
from lineitem li
where li.l_partkey = p.p_partkey)
else 0
end as num_bigticket_orders
from part p
where p_retailprice between 1990 and 2010;

+-----------+---------------+----------------------+
| P_PARTKEY | P_RETAILPRICE | NUM_BIGTICKET_ORDERS |
|-----------+---------------+----------------------|
|    135958 |       1993.95 |                    0 |
|    151958 |       2009.95 |                   36 |
|    147958 |       2005.95 |                   38 |
|    148958 |       2006.95 |                   26 |
|    183908 |       1991.90 |                    0 |

Simple Case Expressions

The simple case expression is quite similar to the searched case expression but is a bit less flexible (and thus used less
frequently). Here’s the syntax:

case expression
when value1 then expression1
when value2 then expression2
...
when valueN then expressionN
[else expressionZ]
end

For this type of statement, an expression is evaluated and compared to a set of values. If a match is found, the corresponding expression is returned, and if no match is found, the expression in the optional else clause is returned.

select o_orderkey,
case o_orderstatus
when 'P' then 'Partial'
when 'F' then 'Filled'
when 'O' then 'Open'
end as status
from orders
limit 20;

+------------+---------+
| O_ORDERKEY | STATUS  |
|------------+---------|
|    1200005 | Filled  |
|    1200128 | Partial |
|    1200199 | Filled  |
|    1200257 | Open    |
|    1200418 | Filled  |
|    1200453 | Partial |

Uses for Case Expressions

Pivot Operations

select
round(sum(case when 1995 = date_part(year,
o_orderdate)
then o_totalprice else 0 end))
as "1995",
round(sum(case when 1996 = date_part(year,
o_orderdate)
then o_totalprice else 0 end))
as "1996",
round(sum(case when 1997 = date_part(year,
o_orderdate)
then o_totalprice else 0 end))
as "1997",
round(sum(case when 1998 = date_part(year,
o_orderdate)
then o_totalprice else 0 end))
as "1998"
from orders
where date_part(year, o_orderdate) >= 1995;

+------------+------------+------------+------------+
|       1995 |       1996 |       1997 |       1998 |
|------------+------------+------------+------------|
| 3317521810 | 3296373353 | 3255086721 | 1925196449 |
+------------+------------+------------+------------+

Checking for Existence

"Big Spender" for any customer who placed an order over $400,000, "Regular" for everyone else 

update customer as c
set cust_type =
case
when exists
(select 1 from orders as o
where o.o_custkey = c.c_custkey
and o.o_totalprice > 400000)
then 'Big Spender'
else 'Regular'
end;


-- Same query as just select
select 
case
when exists
(select 1 from orders as o
where o.o_custkey = c.c_custkey
and o.o_totalprice > 400000)
then 'Big Spender'
else 'Regular' 
end as cust_type,
 count(c_custkey)
from customer as c group by 1;
;

+-------------+------------------+
| CUST_TYPE   | COUNT(C_CUSTKEY) |
|-------------+------------------|
| Regular     |            65633 |
| Big Spender |              443 |
+-------------+------------------+

Case expressions are also useful for delete statements, such as:

delete from customer c
where 1 =
case
when not exists
(select 1 from orders as o
where o.o_custkey = c.c_custkey
and o.o_totalprice > 1000)
then 1
when '31-DEC-1995' >
(select max(o_orderdate) from orders as o
where o.o_custkey = c.c_custkey)
then 1
else 0
end;

-- Same query as select count(*) 
select count(*) from customer c
where 1 =
case
when not exists
(select 1 from orders as o
where o.o_custkey = c.c_custkey
and o.o_totalprice > 1000)
then 1
when '31-DEC-1995' >
(select max(o_orderdate) from orders as o
where o.o_custkey = c.c_custkey)
then 1
else 0
end;

Functions for Conditional Logic

Along with case expressions, Snowflake also includes several built-in functions that are useful for conditional logic.

iff() Function

If you only need a simple if-then-else expression having a single condition, you can use the iff() function: Keep in mind that the iff() function cannot be used if multiple conditions need to be evaluated.

select c_name,
case
when exists
(select 1 from orders o
where o.o_custkey = c.c_custkey
and o.o_totalprice > 400000) then
'Big Spender'
else 'Regular'
end as cust_type_case,
iff(exists
(select 1 from orders o
where o.o_custkey = c.c_custkey
and o.o_totalprice > 400000),
'Big Spender','Regular') as
cust_type_iff
from customer c
where c_custkey between 74000 and 74020;

+--------------------+----------------+---------------+
| C_NAME             | CUST_TYPE_CASE | CUST_TYPE_IFF |
|--------------------+----------------+---------------|
| Customer#000074020 | Regular        | Regular       |
| Customer#000074012 | Regular        | Regular       |
| Customer#000074017 | Regular        | Regular       |
| Customer#000074011 | Big Spender    | Big Spender   |
| Customer#000074000 | Regular        | Regular       |
| Customer#000074015 | Regular        | Regular       |
| Customer#000074009 | Regular        | Regular       |
| Customer#000074014 | Regular        | Regular       |
| Customer#000074008 | Regular        | Regular       |
| Customer#000074005 | Regular        | Regular       |
| Customer#000074003 | Big Spender    | Big Spender   |
+--------------------+----------------+---------------+

ifnull() and nvl() Functions

you want to substitute a value such as 'unknown' or 'N/A' when a column is null. For these situations, you can use either the ifnull() or nvl() functions,

select name,
nvl(favorite_color,'Unknown') as
favorite_color_nvl,
ifnull(favorite_color,'Unknown') as
favorite_color_isnull
from (values ('Thomas','yellow'),
('Catherine','red'),
('Richard','blue'),
('Rebecca',null))
as person (name, favorite_color);

+-----------+--------------------+-----------------------+
| NAME      | FAVORITE_COLOR_NVL | FAVORITE_COLOR_ISNULL |
|-----------+--------------------+-----------------------|
| Thomas    | yellow             | yellow                |
| Catherine | red                | red                   |
| Richard   | blue               | blue                  |
| Rebecca   | Unknown            | Unknown               |
+-----------+--------------------+-----------------------+

-- Null substitution in full ourter joins using three methods Case, NVL or ifnull

select orders.ordernum,
case
when orders.custkey is not null then
orders.custkey
when customer.custkey is not null then
customer.custkey
end as custkey_case,
nvl(orders.custkey, customer.custkey) as
custkey_nvl,
ifnull(orders.custkey, customer.custkey)
as custkey_ifnull,
customer.custname as name
from
(values (990, 101), (991, 102),
(992, 101), (993, 104))
as orders (ordernum, custkey)
full outer join
(values (101, 'BOB'), (102, 'KIM'), (103,
'JIM'))
as customer (custkey, custname)
on orders.custkey = customer.custkey;

+----------+--------------+-------------+----------------+------+
| ORDERNUM | CUSTKEY_CASE | CUSTKEY_NVL | CUSTKEY_IFNULL | NAME |
|----------+--------------+-------------+----------------+------|
|      990 |          101 |         101 |            101 | BOB  |
|      991 |          102 |         102 |            102 | KIM  |
|      992 |          101 |         101 |            101 | BOB  |
|      993 |          104 |         104 |            104 | NULL |
|     NULL |          103 |         103 |            103 | JIM  |
+----------+--------------+-------------+----------------+------+

If you need to choose between more than two columns to find a nonnull value, you can use the coalesce() function, which allows for an unlimited number of expressions to be evaluated.

decode() Function

The decode() function works just like a simple case expression; a single expression is compared to a set of one or more values, and when a match is found the corresponding value is returned.

select o_orderkey,
case o_orderstatus
when 'P' then 'Partial'
when 'F' then 'Filled'
when 'O' then 'Open'
end as status_case,
decode(o_orderstatus, 'P', 'Partial',
'F', 'Filled',
'O', 'Open') as
status_decode
from orders
limit 7;

+------------+-------------+---------------+
| O_ORDERKEY | STATUS_CASE | STATUS_DECODE |
|------------+-------------+---------------|
|    1200005 | Filled      | Filled        |
|    1200128 | Partial     | Partial       |
|    1200199 | Filled      | Filled        |
|    1200257 | Open        | Open          |
|    1200418 | Filled      | Filled        |
|    1200453 | Partial     | Partial       |
|    1200582 | Open        | Open          |
+------------+-------------+---------------+

Excercise - Chap10

Add a column named order_status to the following query that will use a case expression to return the value 'order now' if the ps_availqty value is less than 100, 'order soon' if the ps_availqty value is between 101 and 1000, and 'plenty in stock' otherwise:

select ps_partkey, ps_suppkey, ps_availqty
from partsupp
where ps_partkey between 148300 and 148450;

select ps_partkey, ps_suppkey, ps_availqty, 
case 
 when (ps_availqty<100) then 'order now'
 when (ps_availqty>100 and ps_availqty<1000) then 'order soon'
 else 'plenty in stock'
end as
status_decode
from partsupp
where ps_partkey between 148300 and 148450;

+------------+------------+-------------+-----------------+
| PS_PARTKEY | PS_SUPPKEY | PS_AVAILQTY | STATUS_DECODE   |
|------------+------------+-------------+-----------------|
|     148308 |       8309 |        9570 | plenty in stock |
|     148308 |        823 |        7201 | plenty in stock |
|     148308 |       3337 |        7917 | plenty in stock |
|     148308 |       5851 |        8257 | plenty in stock |
|     148358 |       8359 |        9839 | plenty in stock |
|     148358 |        873 |        6917 | plenty in stock |
|     148358 |       3387 |        1203 | plenty in stock |
|     148358 |       5901 |           1 | order now       |
|     148408 |       8409 |          74 | order now       |
|     148408 |        923 |         341 | order soon      |
|     148408 |       3437 |        4847 | plenty in stock |
|     148408 |       5951 |        1985 | plenty in stock |
+------------+------------+-------------+-----------------+

Rewrite the following query to use a searched case expression instead of a simple case expression:

select o_orderdate, o_custkey,
case o_orderstatus
when 'P' then 'Partial'
when 'F' then 'Filled'
when 'O' then 'Open'
end status
from orders
where o_orderkey > 5999500;

select o_orderdate, o_custkey,
case 
when ( o_orderstatus = 'P') then 'Partial'
when ( o_orderstatus = 'F') then 'Filled'
when ( o_orderstatus = 'O') then 'Open'
else 'Unknown'
end status
from orders
where o_orderkey > 5999500;

+-------------+-----------+---------+
| O_ORDERDATE | O_CUSTKEY | STATUS  |
|-------------+-----------+---------|
| 1993-02-24  |     80807 | Filled  |
| 1995-05-06  |    124231 | Partial |
| 1995-06-03  |    141032 | Partial |
| 1994-07-20  |     30140 | Filled  |
| 1998-02-16  |     86125 | Open    |
| 1996-09-14  |    108310 | Open    |
| 1994-01-09  |     40673 | Filled  |
| 1995-11-19  |    124754 | Open    |
+-------------+-----------+---------+

The following query returns the number of suppliers in each region:

select r_name, count(*)
from nation n
inner join region r on r.r_regionkey =
n.n_regionkey
inner join supplier s on s.s_nationkey =
n.n_nationkey
group by r_name;

+-------------+----------+
| R_NAME      | COUNT(*) |
|-------------+----------|
| AMERICA     |     1532 |
| AFRICA      |     1444 |
| EUROPE      |     1474 |
| MIDDLE EAST |     1491 |
| ASIA        |     1459 |
+-------------+----------+

Modify this query to use case expressions to pivot this data so that it looks as follows:

select  
sum(case when r_name = 'AMERICA' then 1 else 0 end)
as AMERICA,
sum(case when r_name = 'AFRICA' then 1 else 0 end)
as AFRICA,
sum(case when r_name = 'EUROPE' then 1 else 0 end)
as EUROPE,
sum(case when r_name = 'MIDDLE EAST' then 1 else 0 end)
as MIDDLE_EAST,
sum(case when r_name = 'ASIA' then 1 else 0 end)
as ASIA,
from nation n
inner join region r on r.r_regionkey = n.n_regionkey
inner join supplier s on s.s_nationkey = n.n_nationkey;

+---------+--------+--------+-------------+------+
| AMERICA | AFRICA | EUROPE | MIDDLE_EAST | ASIA |
|---------+--------+--------+-------------+------|
|    1532 |   1444 |   1474 |        1491 | 1459 |
+---------+--------+--------+-------------+------+

Chap 11 - Transactions

transactions is mechanism used to group a set of SQL statements together such that either all or none of the statements succeed.

A transaction is a series of SQL statements within a single database session, with the goal of having all of the changes either applied or undone as a unit. In other words, when using a transaction, you will never face a situation where some of your changes succeed and others fail.

Syntax with logic 

Begin Transaction
Update Savings_Account (remove $100 as long as balance >= $100)
Update Checking_Account (add $100)
If errors then
Rollback Transaction
Else
Commit Transaction
End If

Explicit and Implicit Transactions

You can choose to start a transaction by issuing the begin transaction statement, after which all following SQL statements will be considered part of the transaction until you issue a commit or rollback statement. This is known as an explicit transaction because you are instructing Snowflake to start a transaction.

begin transaction;
+----------------------------------+
| status                           |
|----------------------------------|
| Statement executed successfully. |
+----------------------------------+

insert into person (first_name, last_name,
birth_date,
eye_color, occupation)
values ('John','Sanford','2002-03-22'::date,
'brown','analyst');

insert into employee (empid, emp_name,
mgr_empid)
values (1007, 'John Sanford',1002);

commit;
+----------------------------------+
| status                           |
|----------------------------------|
| Statement executed successfully. |
+----------------------------------+

select * from person where first_name = 'John';
+------------+-----------+------------+-----------+------------+----------+--------------------+
| FIRST_NAME | LAST_NAME | BIRTH_DATE | EYE_COLOR | OCCUPATION | CHILDREN | YEARS_OF_EDUCATION |
|------------+-----------+------------+-----------+------------+----------+--------------------|
| John       | Sanford   | 2002-03-22 | brown     | analyst    | NULL     |               NULL |
+------------+-----------+------------+-----------+------------+----------+--------------------+

select * from employee where empid=1007;
+-------+--------------+-----------+
| EMPID | EMP_NAME     | MGR_EMPID |
|-------+--------------+-----------|
|  1007 | John Sanford |      1002 |
+-------+--------------+-----------+

-- Try to fail the transation below 


If you execute an insert, update, delete, or merge statement without first starting a transaction, then a transaction is automatically started for you by Snowflake. This is known as an implicit transaction because you did not start the transaction yourself. What happens next depends on whether your session is in autocommit mode. When you are in autocommit mode, which is the default setting, every modification to the database will be committed individually if the statement succeeds, and rolled back otherwise.

show parameters like 'autocommit';

+------------+-------+---------+---------+----------------------------------------------------------------------------------+---------+
| key        | value | default | level   | description                                                                      | type    |
|------------+-------+---------+---------+----------------------------------------------------------------------------------+---------|
| AUTOCOMMIT | true  | true    | SESSION | The autocommit property determines whether is statement should to be implicitly  | BOOLEAN |
|            |       |         |         | wrapped within a transaction or not. If autocommit is set to true, then a        |         |
|            |       |         |         | statement that requires a transaction is executed within a transaction           |         |
|            |       |         |         | implicitly. If autocommit is off then an explicit commit or rollback is required |         |
|            |       |         |         | to close a transaction. The default autocommit value is true.                    |         |
+------------+-------+---------+---------+----------------------------------------------------------------------------------+---------+

alter session set autocommit=FALSE;
show parameters like 'autocommit';

alter session unset autocommit;     -- Make it back to default TRUE
+----------------------------------+
| status                           |
|----------------------------------|
| Statement executed successfully. |
+----------------------------------+

alter session unset autocommit=TRUE;     -- ERROR
001003 (42000): SQL compilation error:
syntax error line 1 at position 30 unexpected '='.

If your session is not in autocommit mode, and you modify the database without first issuing begin transaction, there are several ways in which your implicit transaction can end:

1) You execute a data definition language (DDL) command, such as create table.
2) You change the autocommit setting (using alter session set autocommit or alter session unset autocommit).
3) You start a transaction explicitly with begin transaction.
4) You end your database session.
5) You issue a commit or rollback.

For the first three cases, Snowflake will issue a commit if there are any pending changes and then start a new transaction. If you end your session, however, any pending changes will be rolled back.

Finding Open Transactions

Snowflake supplies the show transactions statement to list any open transactions.

begin transaction;
update employee set mgr_empid = 1004 where empid = 1007;

show transactions;
+---------------------+-------------+-----------------+--------------------------------------+-------------------------------+---------+-------+
|                  id | user        |         session | name                                 | started_on                    | state   | scope |
|---------------------+-------------+-----------------+--------------------------------------+-------------------------------+---------+-------|
| 1732382732408000000 | NESANAWSNEW | 748007209424118 | 62c546d7-0f57-4ccd-8a45-489a3217de1f | 2024-11-23 09:25:32.408 -0800 | running |     0 |
+---------------------+-------------+-----------------+--------------------------------------+-------------------------------+---------+-------+

If you should run into a problem that requires a transaction to be canceled, the output from show transactions should give you all the necessary information.

Isolation Levels

isolation deals with when changes are visible to other sessions. For example, let’s say session A starts a transaction, modifies 10,000 rows in table XYZ, and then issues a rollback. If session B issues a query against table XYZ after session A’s transaction has started but before the changes were rolled back, what should session B’s query return?

Some database servers provide multiple options, including a dirty read option, which allows one session to see uncommitted changes from other sessions. Snowflake, however, only allows a statement to see committed changes, so Snowflake is said to have an isolation level of read committed. 

This extends throughout the execution of the statement, so even if a query takes an hour to complete, the server must guarantee that no changes made after the statement began executing will be visible to the query.

There are a couple of caveats worth discussing regarding the isolation level. If you start a transaction and then execute two update statements (let’s call them Update A and Update B), you need to keep in mind the following: 

Update B will see the uncommitted changes from Update A.
Update B will see any changes committed by other sessions, even if the commit happened while Update A was executing.

Therefore, SQL statements will see uncommitted changes made within the same transaction, but only committed changes made by other transactions. Also, multiple statements in the same transaction may see different views of the data as other transactions commit their changes.

Locking

All database servers use locks to prevent multiple sessions from modifying the same data. If one user updates a row in a table, a lock is held until the transaction ends, which protects against another transaction modifying the same row. However, there are different levels, or granularities, of locking:

Table locks, where an entire table is locked when any row is modified.
Page locks, where a subset of a table’s rows are locked (rows in the same physical page or block).
Row locks, where only the modified rows are locked.

As you might imagine, table locks are easy to administer but are problematic when multiple users are modifying data in the same table. Row-level locks, on the other hand, provide the highest level of concurrent access, but also take the most overhead to administer.

Snowflake’s locking scheme is a bit harder to nail down but lies somewhere between table-level and page-level locking. Snowflake automatically breaks tables into pieces, called micropartitions, which hold between 50MB and 500MB of uncompressed data. If multiple transactions attempt to modify or delete data in the same micropartition, one session will be blocked and must wait until the other session’s transaction completes.

Lock wait time

When a session is blocked waiting for a lock to be released, it will wait for a configurable amount of time and then fail if the lock has not been released. The maximum number of seconds can be set using the lock_timeout parameter, which can be set at the session level

alter session set lock_timeout=600;   -- set maximum lock wait to 10 minutes

The default timeout is 12 hours, which is a very long time, so you may want to consider setting the value to something smaller.

Deadlocks

A deadlock is a scenario where session A is waiting for a lock held by session B, and session B is waiting for a lock held by session A. While this is generally a rare occurrence, it does happen, and database servers need to have a strategy to resolve deadlocks. When Snowflake identifies a deadlock, it chooses the session having the most recent statement to be the victim, allowing the other transaction to progress. It can take Snowflake a while to detect a deadlock, however, so setting the lock_timeout parameter to a lower value might help resolve these situations faster. If you encounter a deadlock situation and identify a transaction that you would like to abort, you can use the system function system abort_transaction() to do so.

Transactions and Stored Procedures

A stored procedure is a compiled program written using Snowflake’s Scripting language (see Chapter 15). Even if you don’t write your own stored procedures, you may need to call existing stored procedures within your transactions, so here are a few rules to consider:

1) A stored procedure cannot end a transaction started outside of the stored procedure.
2) If a stored procedure starts a transaction, it must also complete it by issuing either a commit or rollback. No transaction started within a stored procedure can be unresolved when the stored procedure completes.
3) A stored procedure can contain 0, 1, or several transactions, and not all statements within the stored procedure must be within a transaction.

Excercise - Chap11
Nothing in this 

Chap 12 - Views

With Snowflake, you can store data in tables but provide access to that data through a set of views (and/or table functions)

A view is a database object similar to a table, but views can only be queried. Views do not involve any data storage (with the exception of materialized views, which are discussed later). One way to think of a view is as a named query, stored in the database for easy use.

Creating Views

create view employee_vw as
select emp_id, emp_name, mgr_empid, inactive from employee;

describe employee_vw;

While the Employee table has six columns, only the four specified in the create view statement are accessible through this view. When defining a view, you have the option of providing your own names for the view columns, rather than having them derived from the underlying tables.

select * from employee_vw;

create view person_vw (fname, lname, dob, eyes)
as
select first_name, last_name, birth_date, eye_color from person;

describe person_vw;

The view definition shows the column names specified in the create view statement, rather than the associated column names from the Person table:

Complex view

create view big_spenders_1998_vw
(custkey, cust_name, total_order_dollars)
as
select o_custkey, c.c_name, sum(o_totalprice)
from orders as o
inner join customer as c
on o.o_custkey = c.c_custkey
where 1998 = date_part(year, o.o_orderdate)
group by o.o_custkey, c.c_name
having sum(o.o_totalprice) >= 500000;

A view such as this one might be useful for members of the marketing and sales departments to help identify customers for sales promotions.

select * from big_spenders_1998_vw;

Using Views

Views can be used in queries anywhere that tables can be used, meaning that you can join views, execute subqueries against views, use them in common table expressions, etc.

select p.fname, p.lname, e.empid
from person_vw as p
inner join employee_vw as e
on e.emp_name = concat(p.fname,' ',p.lname);

with p as
(select concat(fname,' ',lname) as
full_name, dob
from person_vw
)
select p.full_name, p.dob, e.empid
from p
inner join employee as e
on p.full_name = e.emp_name;

Data Security

Restricting column access

alter table employee add salary number(7,0);
update employee
set salary = uniform(50000, 200000,
random());

select empid, emp_name, salary
from employee;

+-------+----------------+--------+
| EMPID | EMP_NAME       | SALARY |
|-------+----------------+--------|
|  1001 | Bob Smith      |  75347 |
|  1002 | Susan Jackson  | 124448 |
|  1003 | Greg Carpenter | 191040 |
|  1004 | Robert Butler  | 195970 |
|  1005 | Kim Josephs    | 186901 |
|  1006 | John Tyler     |  62031 |
|  9999 | Tim Traveler   | 121968 |
|  1007 | John Sanford   | 184918 |
+-------+----------------+--------+

VP of human resources has decreed that managers can see what range each employee’s salary falls in (without seeing the actual salary), while nonmanagers won’t have any access to salary information.

To implement this strategy, managers will no longer have permissions on the Employee table but will instead access employee information using the new employee_manager_vw view, which is defined as follows

create view employee_manager_vw
(empid, emp_name, mgr_empid, salary_range)
as
select empid, emp_name, mgr_empid,
case
when salary <= 75000 then 'Low'
when salary <= 125000 then 'Medium'
else 'High'
end as salary_range
from employee;

select * from employee_manager_vw;

+-------+----------------+-----------+--------------+
| EMPID | EMP_NAME       | MGR_EMPID | SALARY_RANGE |
|-------+----------------+-----------+--------------|
|  1001 | Bob Smith      |      NULL | Medium       |
|  1002 | Susan Jackson  |      1001 | Medium       |
|  1003 | Greg Carpenter |      1001 | High         |
|  1004 | Robert Butler  |      1002 | High         |
|  1005 | Kim Josephs    |      1003 | High         |
|  1006 | John Tyler     |      1004 | Low          |
|  9999 | Tim Traveler   |      1006 | Medium       |
|  1007 | John Sanford   |      1004 | High         |
+-------+----------------+-----------+--------------+

Restricting row access

For example, let’s say that we only want a department manager to be able to access information about the employees in the same department. For this purpose, Snowflake provides secure views, which allow you to restrict access to rows based on either the database username (via the current_user() function) or the database roles assigned to a user (via the current_role() function).

select current_user(), current_role();

select current_schemas(), current_client(), CURRENT_DATABASE(), CURRENT_DATE(), CURRENT_ROLE(), CURRENT_SCHEMA(), CURRENT_SESSION(), CURRENT_STATEMENT(), CURRENT_TIME(), CURRENT_TIMESTAMP(), CURRENT_TRANSACTION(), CURRENT_USER(), CURRENT_VERSION(), CURRENT_WAREHOUSE();

+-------------------------+------------------+--------------------+----------------+----------------+------------------+-------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+----------------+-------------------------------+-----------------------+----------------+-------------------+---------------------+
| CURRENT_SCHEMAS()       | CURRENT_CLIENT() | CURRENT_DATABASE() | CURRENT_DATE() | CURRENT_ROLE() | CURRENT_SCHEMA() | CURRENT_SESSION() | CURRENT_STATEMENT()                                                                                                                                                                                                                                                           | CURRENT_TIME() | CURRENT_TIMESTAMP()           | CURRENT_TRANSACTION() | CURRENT_USER() | CURRENT_VERSION() | CURRENT_WAREHOUSE() |
|-------------------------+------------------+--------------------+----------------+----------------+------------------+-------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+----------------+-------------------------------+-----------------------+----------------+-------------------+---------------------|
| ["LEARNING_SQL.PUBLIC"] | SnowSQL 1.3.2    | LEARNING_SQL       | 2024-11-23     | ACCOUNTADMIN   | PUBLIC           | 748007209440346   | select current_schemas(), current_client(), CURRENT_DATABASE(), CURRENT_DATE(), CURRENT_ROLE(), CURRENT_SCHEMA(), CURRENT_SESSION(), CURRENT_STATEMENT(), CURRENT_TIME(), CURRENT_TIMESTAMP(), CURRENT_TRANSACTION(), CURRENT_USER(), CURRENT_VERSION(), CURRENT_WAREHOUSE(); | 21:09:00       | 2024-11-23 21:09:00.855 -0800 | NULL                  | NESANAWSNEW    | 8.44.2            | COMPUTE_WH          |
+-------------------------+------------------+--------------------+----------------+----------------+------------------+-------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+----------------+-------------------------------+-----------------------+----------------+-------------------+---------------------+

To demonstrate how secure views work, I will create two new tables, department and empl_dept, to create a set of departments and assign employees to the different departments

create or replace table department as
select dept_id, dept_name, auth_username
from (values (1, 'ACCOUNTING', CURRENT_USER()),
(2, 'FINANCE', 'ALANBEAU'),
(3, 'SHIPPING', 'JANEDOE'))
as dept(dept_id, dept_name, auth_username);

create table empl_dept as
select empid, dept_id
from (values (1001, 1), (1002, 2), (1003, 1),
(1004, 3), (1005, 2), (1006, 3))
as empdpt(empid, dept_id);

select d.dept_id, d.dept_name,
d.auth_username,
e.empid, e.emp_name
from department d
inner join empl_dept ed on d.dept_id =
ed.dept_id
inner join employee e on e.empid = ed.empid;

Looking at the data, I have made myself the manager of the finance department and assigned Susan Jackson and Kim Josephs to my department. Here’s a query that joins these two new tables to Employee to show all of the employees I am authorized to see:

make current user as AUTH_USERNAME for above scenario

update department set AUTH_USERNAME='NESANAWSNEW' where dept_name='ACCOUNTING';
update department set AUTH_USERNAME=CURRENT_USER() where dept_name='ACCOUNTING';  --- Working it can be used
100078 (22000): String 'NESANAWSNEW' is too long and would be truncated

Insead of editing the table datatype just recreate it with CURRENT_USER() as values

create or replace table department as
select dept_id, dept_name, auth_username
from (values (1, 'ACCOUNTING', CURRENT_USER()),    --- this is also working
(2, 'FINANCE', 'ALANBEAU'),
(3, 'SHIPPING', 'JANEDOE'))
as dept(dept_id, dept_name, auth_username);

Powerful Idea - We can even restrict access based on any of the below CONTEXT funcitions values using views we can use stored proc also inside store proc return the result only if certain client is used and return nothing when certain client is used.

Based on the current_time() if todays data is not yet loaded use yesterdays data for producing the result. 

select current_schemas(), current_client(), CURRENT_DATABASE(), CURRENT_DATE(), CURRENT_ROLE(), CURRENT_SCHEMA(), CURRENT_SESSION(), CURRENT_STATEMENT(), CURRENT_TIME(), CURRENT_TIMESTAMP(), CURRENT_TRANSACTION(), CURRENT_USER(), CURRENT_VERSION(), CURRENT_WAREHOUSE();

Even we can use IP address range for safety reasons

select CURRENT_IP_ADDRESS();

+----------------------+
| CURRENT_IP_ADDRESS() |
|----------------------|
| 223.185.22.219       |
+----------------------+

https://whatismyipaddress.com/ -- Visit and see current IP of the machine - IPv4: 223.185.22.219 -- Wow

select d.dept_id, d.dept_name,
d.auth_username,
e.empid, e.emp_name
from department d
inner join empl_dept ed on d.dept_id =
ed.dept_id
inner join employee e on e.empid = ed.empid;

+---------+------------+---------------+-------+----------------+
| DEPT_ID | DEPT_NAME  | AUTH_USERNAME | EMPID | EMP_NAME       |
|---------+------------+---------------+-------+----------------|
|       1 | ACCOUNTING | NESANAWSNEW   |  1001 | Bob Smith      |
|       2 | FINANCE    | ALANBEAU      |  1002 | Susan Jackson  |
|       1 | ACCOUNTING | NESANAWSNEW   |  1003 | Greg Carpenter |
|       3 | SHIPPING   | JANEDOE       |  1004 | Robert Butler  |
|       2 | FINANCE    | ALANBEAU      |  1005 | Kim Josephs    |
|       3 | SHIPPING   | JANEDOE       |  1006 | John Tyler     |
+---------+------------+---------------+-------+----------------+

select e.empid, e.emp_name, d.dept_name
from employee e
inner join empl_dept ed on e.empid = ed.empid
inner join department d on ed.dept_id =
d.dept_id
where d.auth_username = current_user();

+-------+----------------+------------+
| EMPID | EMP_NAME       | DEPT_NAME  |
|-------+----------------+------------|
|  1001 | Bob Smith      | ACCOUNTING |
|  1003 | Greg Carpenter | ACCOUNTING |
+-------+----------------+------------+
2 Row(s) produced. Time Elapsed: 1.836s

I can use this query to build a secure view called my_employees:

create secure view my_employees as       -- Based on the user who is selecting only employees reporting to him will be returned
select e.empid, e.emp_name, d.dept_name
from employee e
inner join empl_dept ed on e.empid = ed.empid
inner join department d on ed.dept_id =
d.dept_id
where d.auth_username = current_user();

select * from my_employees;   -- Returned as they both report to NESANAWSNEW who is AUTH_USERNAME in department table for two records

+-------+----------------+------------+
| EMPID | EMP_NAME       | DEPT_NAME  |
|-------+----------------+------------|
|  1001 | Bob Smith      | ACCOUNTING |
|  1003 | Greg Carpenter | ACCOUNTING |
+-------+----------------+------------+
2 Row(s) produced. Time Elapsed: 1.201s

Any other user executing this query would see only members of the accounting department (for username JOHNSMITH) or the shipping department (for username JANEDOE), and for any other users the my_employees view would return no rows.1

select get_ddl('view','my_employees');   -- to get the DDL for view

I can retrieve the view definition because I created the view, but another user without the same role would not be successful. Hiding the view definition makes sense in that if you are creating a mechanism to restrict access to data, you should probably also limit access to the mechanism used to do so.

+-----------------------------------------------+
| GET_DDL('VIEW','MY_EMPLOYEES')                |
|-----------------------------------------------|
| create or replace secure view MY_EMPLOYEES(   |
|       EMPID,                                                                                               |
|       EMP_NAME,                                                                                               |
|       DEPT_NAME                                                                                               |
| ) as                                          |
| select e.empid, e.emp_name, d.dept_name       |
| from employee e                               |
| inner join empl_dept ed on e.empid = ed.empid |
| inner join department d on ed.dept_id =       |
| d.dept_id                                     |
| where d.auth_username = current_user();       |
+-----------------------------------------------+

select get_ddl('table','employee');   -- to get the DDL for view

+------------------------------------+
| GET_DDL('TABLE','EMPLOYEE')        |
|------------------------------------|
| create or replace TABLE EMPLOYEE ( |
|       EMPID NUMBER(38,0),                                                                         |
|       EMP_NAME VARCHAR(30),                                                                         |
|       MGR_EMPID NUMBER(38,0),                                                                         |
|       SALARY NUMBER(7,0)                                                                         |
| );                                 |
+------------------------------------+

Data Aggregation in views

Data analysis and reporting are generally done with aggregated data, which, depending on the design of the database, can lead to some very complex queries. 

if the manager of the parts department needs to run reports showing the aggregate sales and available quantities for all parts sold by the company, you could create the following view

create view yearly_part_sales_vw
as
with part_supply as
(select p.p_partkey as partkey,
p.p_name as part_name,
sum(ps.ps_availqty) as avail_qty
from part p
inner join partsupp ps
on p.p_partkey = ps.ps_partkey
group by p.p_partkey, p.p_name
),
part_sales as
(select date_part(year, o.o_orderdate) as
order_year,
li.l_partkey as partkey,
count(*) as sales_qty,
max(li.l_shipdate - o.o_orderdate)
max_backlog_days
from orders o
inner join lineitem li
on o.o_orderkey = li.l_orderkey
group by date_part(year, o_orderdate),
li.l_partkey
)
select p_sply.partkey,
p_sply.part_name,
p_sply.avail_qty,
p_sale.order_year,
p_sale.sales_qty,
p_sale.max_backlog_days
from part_supply p_sply
inner join part_sales p_sale
on p_sply.partkey = p_sale.partkey;

Using this view, the manager could write a simple query to find the top 10 best-selling parts in 1998 along with the available quantities:

select partkey, sales_qty, avail_qty
from yearly_part_sales_vw
where order_year = 1998
order by sales_qty desc
limit 10;

+---------+-----------+-----------+
| PARTKEY | SALES_QTY | AVAIL_QTY |
|---------+-----------+-----------|
|  100458 |        11 |     17092 |
|    4558 |        10 |     19220 |
|  143508 |         9 |     10898 |
|    4308 |         9 |     17706 |
|   10658 |         9 |     27821 |
|    4008 |         8 |     16223 |
|   42208 |         8 |     21672 |
|     108 |         8 |     17723 |
|   36058 |         8 |     23578 |
|  163858 |         8 |     18021 |
+---------+-----------+-----------+
10 Row(s) produced. Time Elapsed: 2.778s

If the manager uses this view frequently enough, you might create a table to store the preaggregated data rather than incur the cost of grouping the rows each time.

MATERIALIZED VIEWS

Snowflake customers using the Enterprise edition have the ability to create materialized views, which are essentially tables built using a view definition and then automatically refreshed via background processes. Using materialized views will generally reduce computation time for queries but will incur additional storage space/fees and computation fees for the upkeep of the materialized view, so it is important to consider the number of times the materialized data will be queried versus the amount of data being stored and the frequency with which the data changes.

Creating a materialized view is a simple matter of using create materialized view instead of create view. Once created, Snowflake will update the stored data as changes are made to the underlying tables from the view definition. For example, if the yearly_part_sales_vw view was dropped and recreated as a materialized view, any future changes made to the Orders, Lineitem, Part, and Partsupp tables would need to be reflected in the materialized view data. Snowflake does these updates for you so that any queries against materialized views will return current data.

Hiding Complexity - with views

the process of calculating the cost of a customer’s order can include list prices, discounts, sale prices, state tax calculations, etc. Because it is critical to the company to charge the correct amount, it might be beneficial to create a view for the sales department that includes columns that contain various calculations,

create view order_calculation_vw
as
select o.o_orderkey,
sum((li.l_extendedprice * (1 -
li.l_discount))
* li.l_quantity) order_total,
sum((li.l_extendedprice * (1 -
li.l_discount))
* li.l_quantity * li.l_tax)
state_sales_tax
from orders o
inner join lineitem li
on o.o_orderkey = li.l_orderkey
group by o.o_orderkey;

SELECT * FROM order_calculation_vw sample(0.01);

+------------+----------------+-----------------+
| O_ORDERKEY |    ORDER_TOTAL | STATE_SALES_TAX |
|------------+----------------+-----------------|
|    2168708 |   66016.764000 |   1320.33528000 |
|    3606754 | 1079729.919000 |      0.00000000 |
|    5839811 |    1802.700000 |     54.08100000 |
|    5634561 | 1323184.572000 |  79391.07432000 |
|    3110818 | 2600775.936000 |  26007.75936000 |
|    4912544 | 1110991.950000 |  33329.75850000 |
|    4683141 | 1445519.520000 |  43365.58560000 |
|     919075 |  220144.072500 |   4402.88145000 |
|    1527143 | 1797907.700000 | 143832.61600000 |
|    5212962 |  762773.352000 |  45766.40112000 |
+------------+----------------+-----------------+

Once the sales department starts using this view, you could add additional calculations for seasonal sales, customer loyalty programs, and other discounts and promotions, and you could be sure that all of the sales associates will generate correct customer invoices.

potential drawbacks of view to consider.
When a view is created, Snowflake gathers information about the view (also known as metadata) using the state of the database at that point. If you later add, modify, or drop columns in one of the tables used by the view’s query, the view definition will not be automatically changed. Furthermore, if you drop a column that is used by a view, the view will be internally marked as invalid, and you will need to modify the view definition and re-create the view before it can be used again.

Even though views and tables are not the same thing, they share a namespace, so you can’t have a table and a view with the same name.

Joining two or three views with complex underlying queries can result in poor performance, which results in increased computation costs

-- Select all queries that ran more than 2000 milliseconds 
select query_id, total_elapsed_time as
runtime,
substr(query_text,1,40)
from
table(learning_sql.information_schema.query_history(
))
where total_elapsed_time > 2000
order by start_time;

+--------------------------------------+---------+--------------------------------------+
| QUERY_ID                             | RUNTIME | SUBSTR(QUERY_TEXT,1,40)              |
|--------------------------------------+---------+--------------------------------------|
| 01b896a1-0004-3868-0002-a84f0001359a |    2240 | select d.dept_id, d.dept_name,       |
|                                      |         | d.auth_us                            |
| 01b896bd-0004-3868-0002-a84f000135aa |    2466 | select partkey, sales_qty, avail_qty |
|                                      |         | fro                                  |
+--------------------------------------+---------+--------------------------------------+

In practice, secure views will generally be built using roles and not usernames, but for the sake of simplicity I have used usernames.

If you do have views that are aggregating a great deal of data, they are good candidates for being changed to materialized views, which can alleviate the performance issues.

Excercise - Chap12

Try later

Chap 13 - Metadata

Snowflake stores this Metadata in a database for internal use, but also makes metadata available for database users.

information_schema

Snowflake makes its metadata available via a set of views in the information_schema schema. information_schema views are created within each database.

use schema learning_sql.information_schema;

select table_name, table_type,
row_count
from tables
where table_schema = 'PUBLIC';

if you only want information about views you can query information_schema.views: This query returns the name of each view, along with the first 100 characters of the view definition.

select table_name,
substr(view_definition, 1, 100)
view_def
from views
where table_schema = 'PUBLIC';

query returns information about all columns in the learning_sql.public schema

select table_name, column_name,
concat(data_type,
case
when data_type = 'TEXT'
then
concat('(',character_maximum_length,
')')
when data_type = 'NUMBER'
then
concat('(',numeric_precision, ',',
numeric_scale,')')
else ''
end) column_def
from columns
where table_schema = 'PUBLIC'
order by table_name,
ordinal_position;

Working with Metadata

This section shows several ways in which you can make use of the metadata information in information_schema.

Schema Discovery

Let’s say, however, that you have been asked to ensure that all columns holding a person’s last name can handle up to 50 characters, and you want to find all tables that include either the lname or last_name column.

select table_name, data_type,
character_maximum_length
from columns
where table_schema = 'PUBLIC'
and column_name in
('LNAME','LAST_NAME');

+------------+-----------+--------------------------+
| TABLE_NAME | DATA_TYPE | CHARACTER_MAXIMUM_LENGTH |
|------------+-----------+--------------------------|
| PERSON_VW  | TEXT      |                       50 |
| PERSON     | TEXT      |                       50 |
+------------+-----------+--------------------------+

You can also write queries to find out when schema objects were last modified, which might be useful if you were to
perform internal auditing

select table_name, last_altered
from tables
where table_schema = 'PUBLIC'
order by 2 desc;

+----------------------+-------------------------------+
| TABLE_NAME           | LAST_ALTERED                  |
|----------------------+-------------------------------|
| ORDER_CALCULATION_VW | 2024-11-24 08:36:32.949 -0800 |
| YEARLY_PART_SALES_VW | 2024-11-24 08:28:52.770 -0800 |
| MY_EMPLOYEES         | 2024-11-24 08:03:52.564 -0800 |
| DEPARTMENT           | 2024-11-23 21:23:56.852 -0800 |
| EMPL_DEPT            | 2024-11-23 21:11:44.602 -0800 |
| EMPLOYEE_MANAGER_VW  | 2024-11-23 11:24:43.802 -0800 |
| EMPLOYEE             | 2024-11-23 11:19:27.594 -0800 |
| BIG_SPENDERS_1998_VW | 2024-11-23 11:10:18.135 -0800 |
| PERSON_VW            | 2024-11-23 11:03:59.895 -0800 |
| PERSON               | 2024-11-23 09:10:18.708 -0800 |
| CUSTOMER             | 2024-11-22 08:38:46.755 -0800 |
| ORDERS               | 2024-11-22 08:38:44.497 -0800 |
| LINEITEM             | 2024-11-22 08:38:42.533 -0800 |
| SUPPLIER             | 2024-11-22 08:38:40.409 -0800 |
| PARTSUPP             | 2024-11-22 08:38:38.490 -0800 |
| PART                 | 2024-11-22 08:38:36.578 -0800 |
| NATION               | 2024-11-22 08:38:34.936 -0800 |
| REGION               | 2024-11-22 08:38:33.494 -0800 |
+----------------------+-------------------------------+
18 Row(s) produced. Time Elapsed: 1.273s

Unfortunately, Snowflake’s Time Travel feature does not work with views, so you can’t write queries using the at clause to compare the current metadata with what it looked like an hour ago.

Deployment Verification

After deploying a set of database changes, it’s a good idea to verify that all changes have been successfully made before bringing system back on. For example, let’s say that part of a monthly deployment includes a change in the size of the emp_name column in the pub.lic .employee table

alter table public.employee
modify emp_name varchar(30);

select table_schema, table_name   -- Find all objects altered in last 1 hour
from tables
where last_altered >
dateadd(hour, -1,
current_date);
+--------------+----------------------+
| TABLE_SCHEMA | TABLE_NAME           |
|--------------+----------------------|
| PUBLIC       | YEARLY_PART_SALES_VW |
| PUBLIC       | ORDER_CALCULATION_VW |
| PUBLIC       | EMPLOYEE             |
| PUBLIC       | MY_EMPLOYEES         |
+--------------+----------------------+
4 Row(s) produced. Time Elapsed: 1.136s

If the deployment also included dropping or adding columns to tables or views, you could run a query to count the number of columns in each table:

select table_name, count(*)
num_columns
from columns
where table_schema = 'PUBLIC'
group by table_name
order by 1;

If you run this query before and after the deployment, you can verify that the appropriate number of column changes were made.

Generating Administration Scripts

You can also query information_schema tables to generate SQL statements that can then be executed. For example, let’s say your team has a database used by the QA team that needs to be refreshed periodically with a set of test data. You could run the following query to generate a set of delete statements for every table in a given schema:

select
concat('DELETE FROM ',table_name,';') cmnd_str
from tables
where table_schema = 'PUBLIC'
and table_type = 'BASE TABLE';

+-------------------------+
| CMND_STR                |
|-------------------------|
| DELETE FROM CUSTOMER;   |
| DELETE FROM DEPARTMENT; |
| DELETE FROM EMPLOYEE;   |
| DELETE FROM LINEITEM;   |
| DELETE FROM NATION;     |
| DELETE FROM ORDERS;     |
| DELETE FROM PART;       |
| DELETE FROM PARTSUPP;   |
| DELETE FROM PERSON;     |
| DELETE FROM REGION;     |
| DELETE FROM SUPPLIER;   |
| DELETE FROM EMPL_DEPT;  |
+-------------------------+
12 Row(s) produced. Time Elapsed: 1.089s

Setting the formatting to plain removes the '+', '-', and '|' characters surrounding the results, allowing the delete statements to be copied and pasted cleanly.

!set output_format=plain;    -- results not returned in tabular form

select
concat('DELETE FROM ',table_name,';') cmnd_str
from tables
where table_schema = 'PUBLIC'
and table_type = 'BASE TABLE';

CMND_STR
DELETE FROM CUSTOMER;
DELETE FROM DEPARTMENT;
DELETE FROM EMPLOYEE;
DELETE FROM LINEITEM;
DELETE FROM NATION;
DELETE FROM ORDERS;
DELETE FROM PART;
DELETE FROM PARTSUPP;
DELETE FROM PERSON;
DELETE FROM REGION;
DELETE FROM SUPPLIER;
DELETE FROM EMPL_DEPT;
12 Row(s) produced. Time Elapsed: 1.110s

When finished, you can opt to set the formatting back to the default, which is psql, or to any other available option, such as grid, html, json, or csv.

!set output_format=plain; 

!set output_format=grid; 

+-------------------------+
| CMND_STR                |
+=========================+
| DELETE FROM CUSTOMER;   |
+-------------------------+
| DELETE FROM DEPARTMENT; |
+-------------------------+
| DELETE FROM EMPLOYEE;   |
+-------------------------+
| DELETE FROM LINEITEM;   |
+-------------------------+
| DELETE FROM NATION;     |
+-------------------------+
| DELETE FROM ORDERS;     |
+-------------------------+
| DELETE FROM PART;       |
+-------------------------+
| DELETE FROM PARTSUPP;   |
+-------------------------+
| DELETE FROM PERSON;     |
+-------------------------+
| DELETE FROM REGION;     |
+-------------------------+
| DELETE FROM SUPPLIER;   |
+-------------------------+
| DELETE FROM EMPL_DEPT;  |
+-------------------------+

!set output_format=html; 

<table>
<tr><th>CMND_STR               </th></tr>
<tr><td>DELETE FROM CUSTOMER;  </td></tr>
<tr><td>DELETE FROM DEPARTMENT;</td></tr>
<tr><td>DELETE FROM EMPLOYEE;  </td></tr>
<tr><td>DELETE FROM LINEITEM;  </td></tr>
<tr><td>DELETE FROM NATION;    </td></tr>
<tr><td>DELETE FROM ORDERS;    </td></tr>
<tr><td>DELETE FROM PART;      </td></tr>
<tr><td>DELETE FROM PARTSUPP;  </td></tr>
<tr><td>DELETE FROM PERSON;    </td></tr>
<tr><td>DELETE FROM REGION;    </td></tr>
<tr><td>DELETE FROM SUPPLIER;  </td></tr>
<tr><td>DELETE FROM EMPL_DEPT; </td></tr>
</table>


!set output_format=json; 

[{"CMND_STR": "DELETE FROM CUSTOMER;"},{"CMND_STR": "DELETE FROM DEPARTMENT;"},{"CMND_STR": "DELETE FROM EMPLOYEE;"},{"CMND_STR": "DELETE FROM LINEITEM;"},{"CMND_STR": "DELETE FROM NATION;"},{"CMND_STR": "DELETE FROM ORDERS;"},{"CMND_STR": "DELETE FROM PART;"},{"CMND_STR": "DELETE FROM PARTSUPP;"},{"CMND_STR": "DELETE FROM PERSON;"},{"CMND_STR": "DELETE FROM REGION;"},{"CMND_STR": "DELETE FROM SUPPLIER;"},{"CMND_STR": "DELETE FROM EMPL_DEPT;"}]

!set output_format=csv; 

"CMND_STR"
"DELETE FROM CUSTOMER;"
"DELETE FROM DEPARTMENT;"
"DELETE FROM EMPLOYEE;"
"DELETE FROM LINEITEM;"
"DELETE FROM NATION;"
"DELETE FROM ORDERS;"
"DELETE FROM PART;"
"DELETE FROM PARTSUPP;"
"DELETE FROM PERSON;"
"DELETE FROM REGION;"
"DELETE FROM SUPPLIER;"
"DELETE FROM EMPL_DEPT;"

!set output_format=psql;    -- Default will display as table

+-------------------------+
| CMND_STR                |
|-------------------------|
| DELETE FROM CUSTOMER;   |
| DELETE FROM DEPARTMENT; |
| DELETE FROM EMPLOYEE;   |
| DELETE FROM LINEITEM;   |
| DELETE FROM NATION;     |
| DELETE FROM ORDERS;     |
| DELETE FROM PART;       |
| DELETE FROM PARTSUPP;   |
| DELETE FROM PERSON;     |
| DELETE FROM REGION;     |
| DELETE FROM SUPPLIER;   |
| DELETE FROM EMPL_DEPT;  |
+-------------------------+



select get_ddl('table','public.employee');

GET_DDL('TABLE','PUBLIC.EMPLOYEE')
create or replace TABLE EMPLOYEE (
        EMPID NUMBER(38,0),
        EMP_NAME VARCHAR(30),
        MGR_EMPID NUMBER(38,0),
        SALARY NUMBER(7,0)
);
1 Row(s) produced. Time Elapsed: 0.405s

The resulting statement could be used to create an mployee table in another schema or database, such as a separate database used for testing.

select get_ddl('view','public.PERSON_VW');

GET_DDL('VIEW','PUBLIC.PERSON_VW')
create or replace view PERSON_VW(
        FNAME,
        LNAME,
        DOB,
        EYES
) as
select first_name, last_name, birth_date, eye_color from person;
1 Row(s) produced. Time Elapsed: 0.523s

You can also generate a set of scripts for an entire schema:  -- Wow greate idea it gives DDL for all the tables and views in the public schema
This can be used to validate the DDL implementation - Take DDL snapshot before implementation and also after implementation and compare it. Since there is no timetravel available for DDL changes this is the only and best way to even revert back the changes and track the changes over the time. All the DDL can be kept as history.

Keep the DDL history table in which we can insert this DDL output.

select get_ddl('schema','public');

account_usage views

Snowflake also makes a set of views available at the account level, under the Snowflake database.

with infor_schema as
(select table_name
from learning_sql.information_schema.views
where table_schema = 'INFORMATION_SCHEMA')
,acct_usage as
(select table_name
from snowflake.information_schema.views
where table_schema = 'ACCOUNT_USAGE')
select all_views.table_name,
case when infor_schema.table_name is not
null then 'X'
else ' ' end as info_sch,
case when acct_usage.table_name is not null
then 'X'
else ' ' end as acct_usg
from
(select table_name from infor_schema
union
select table_name from acct_usage
) all_views
left outer join infor_schema
on infor_schema.table_name =
all_views.table_name
left outer join acct_usage
on acct_usage.table_name =
all_views.table_name
order by 1;

+-------------------------------------------+----------+----------+
| TABLE_NAME                                | INFO_SCH | ACCT_USG |
|-------------------------------------------+----------+----------|
| ACCESS_HISTORY                            |          | X        |
| AGGREGATE_ACCESS_HISTORY                  |          | X        |
| AGGREGATE_QUERY_HISTORY                   |          | X        |
| AGGREGATION_POLICIES                      |          | X        |
| ALERT_HISTORY                             |          | X        |
| APPLICABLE_ROLES                          | X        |          |
| AUTOMATIC_CLUSTERING_HISTORY              |          | X        |
| BLOCK_STORAGE_HISTORY                     |          | X        |
| CLASSES                                   | X        | X        |
| CLASS_INSTANCES                           | X        | X        |
| CLASS_INSTANCE_FUNCTIONS                  | X        |          |
| CLASS_INSTANCE_PROCEDURES                 | X        |          |
| COLUMNS                                   | X        | X        |
| COMPLETE_TASK_GRAPHS                      |          | X        |
| COMPUTE_POOLS                             |          | X        |
| CONTACTS                                  |          | X        |
| CONTACT_REFERENCES                        |          | X        |
| COPY_HISTORY                              |          | X        |
| CORTEX_FINE_TUNING_USAGE_HISTORY          |          | X        |
| CORTEX_FUNCTIONS_USAGE_HISTORY            |          | X        |
| CORTEX_SEARCH_SERVICES                    | X        |          |
| CORTEX_SEARCH_SERVING_USAGE_HISTORY       |          | X        |
| CURRENT_PACKAGES_POLICY                   | X        |          |
| DATABASES                                 | X        | X        |
| DATABASE_REPLICATION_USAGE_HISTORY        |          | X        |
| DATABASE_STORAGE_USAGE_HISTORY            |          | X        |
| DATA_CLASSIFICATION_LATEST                |          | X        |
| DATA_METRIC_FUNCTION_REFERENCES           |          | X        |
| DATA_QUALITY_MONITORING_USAGE_HISTORY     |          | X        |
| DATA_TRANSFER_HISTORY                     |          | X        |
| DOCUMENT_AI_USAGE_HISTORY                 |          | X        |
| DYNAMIC_TABLE_REFRESH_HISTORY             |          | X        |
| ELEMENT_TYPES                             | X        | X        |
| ENABLED_ROLES                             | X        |          |
| EVENT_TABLES                              | X        |          |
| EVENT_USAGE_HISTORY                       |          | X        |
| EXTERNAL_ACCESS_HISTORY                   |          | X        |
| EXTERNAL_TABLES                           | X        |          |
| FIELDS                                    | X        | X        |
| FILE_FORMATS                              | X        | X        |
| FUNCTIONS                                 | X        | X        |
| GIT_REPOSITORIES                          | X        |          |
| GRANTS_TO_ROLES                           |          | X        |
| GRANTS_TO_USERS                           |          | X        |
| HYBRID_TABLES                             | X        | X        |
| HYBRID_TABLE_USAGE_HISTORY                |          | X        |
| INDEXES                                   | X        | X        |
| INDEX_COLUMNS                             | X        | X        |
| INFORMATION_SCHEMA_CATALOG_NAME           | X        |          |
| INTERNAL_DATA_TRANSFER_HISTORY            |          | X        |
| LOAD_HISTORY                              | X        | X        |
| LOCK_WAIT_HISTORY                         |          | X        |
| LOGIN_HISTORY                             |          | X        |
| MASKING_POLICIES                          |          | X        |
| MATERIALIZED_VIEW_REFRESH_HISTORY         |          | X        |
| METERING_DAILY_HISTORY                    |          | X        |
| METERING_HISTORY                          |          | X        |
| MODEL_VERSIONS                            | X        |          |
| NETWORK_POLICIES                          |          | X        |
| NETWORK_RULES                             |          | X        |
| NETWORK_RULE_REFERENCES                   |          | X        |
| OBJECT_DEPENDENCIES                       |          | X        |
| OBJECT_PRIVILEGES                         | X        |          |
| OUTBOUND_PRIVATELINK_ENDPOINTS            |          | X        |
| PACKAGES                                  | X        |          |
| PASSWORD_POLICIES                         |          | X        |
| PIPES                                     | X        | X        |
| PIPE_USAGE_HISTORY                        |          | X        |
| POLICY_REFERENCES                         |          | X        |
| PRIVACY_BUDGETS                           |          | X        |
| PRIVACY_POLICIES                          |          | X        |
| PROCEDURES                                | X        | X        |
| PROJECTION_POLICIES                       |          | X        |
| QUERY_ACCELERATION_ELIGIBLE               |          | X        |
| QUERY_ACCELERATION_HISTORY                |          | X        |
| QUERY_ATTRIBUTION_HISTORY                 |          | X        |
| QUERY_HISTORY                             |          | X        |
| REFERENTIAL_CONSTRAINTS                   | X        | X        |
| REPLICATION_DATABASES                     | X        |          |
| REPLICATION_GROUPS                        | X        |          |
| REPLICATION_GROUP_REFRESH_HISTORY         |          | X        |
| REPLICATION_GROUP_USAGE_HISTORY           |          | X        |
| REPLICATION_USAGE_HISTORY                 |          | X        |
| ROLES                                     |          | X        |
| ROW_ACCESS_POLICIES                       |          | X        |
| SCHEMATA                                  | X        | X        |
| SEARCH_OPTIMIZATION_BENEFITS              |          | X        |
| SEARCH_OPTIMIZATION_HISTORY               |          | X        |
| SECRETS                                   |          | X        |
| SEQUENCES                                 | X        | X        |
| SERVERLESS_ALERT_HISTORY                  |          | X        |
| SERVERLESS_TASK_HISTORY                   |          | X        |
| SERVICES                                  | X        | X        |
| SESSIONS                                  |          | X        |
| SESSION_POLICIES                          |          | X        |
| SNOWPARK_CONTAINER_SERVICES_HISTORY       |          | X        |
| SNOWPIPE_STREAMING_CLIENT_HISTORY         |          | X        |
| SNOWPIPE_STREAMING_FILE_MIGRATION_HISTORY |          | X        |
| SPCS_EGRESS_ACCESS_HISTORY                |          | X        |
| STAGES                                    | X        | X        |
| STAGE_STORAGE_USAGE_HISTORY               |          | X        |
| STORAGE_USAGE                             |          | X        |
| STREAMLITS                                | X        |          |
| TABLES                                    | X        | X        |
| TABLE_CONSTRAINTS                         | X        | X        |
| TABLE_DML_HISTORY                         |          | X        |
| TABLE_PRIVILEGES                          | X        |          |
| TABLE_PRUNING_HISTORY                     |          | X        |
| TABLE_STORAGE_METRICS                     | X        | X        |
| TAGS                                      |          | X        |
| TAG_REFERENCES                            |          | X        |
| TASK_HISTORY                              |          | X        |
| TASK_VERSIONS                             |          | X        |
| USAGE_PRIVILEGES                          | X        |          |
| USERS                                     |          | X        |
| VIEWS                                     | X        | X        |
| WAREHOUSE_EVENTS_HISTORY                  |          | X        |
| WAREHOUSE_LOAD_HISTORY                    |          | X        |
| WAREHOUSE_METERING_HISTORY                |          | X        |
+-------------------------------------------+----------+----------+
119 Row(s) produced. Time Elapsed: 2.336s

If you want to find out information about tables, columns, databases, or views, you can use either information_schema or account_usage. If you want information about things at the account level, such as login history, storage usage, or grants, you will need to use account_usage.

One disadvantage to using account_usage, however, is a latency of between 45 minutes and 3 hours before schema changes are visible in account_ usage.

Advantages to using the views in account_usage over information_schema include: 

Data retention
Historic data is available for a year in account_usage, whereas history may only be kept for a few days in information_schema.

Dropped objects
If you drop a table or view, it will no longer be visible using informa⁠tion_ schema, whereas you can still find it in account_usage.

select table_name, table_owner, deleted
from snowflake.account_usage.views
order by 1, 3;

account_usage to see what were run in the past 24 hours

select substr(query_text, 1, 40)
partial_query,
total_elapsed_time as runtime,
rows_produced as num_rows
from snowflake.account_usage.query_history
where start_time > current_date - 1
and query_text not like 'SHOW%'
and rows_produced > 0;

+------------------------------------------+---------+----------+
| PARTIAL_QUERY                            | RUNTIME | NUM_ROWS |
|------------------------------------------+---------+----------|
| select table_name, table_owner, deleted  |    1275 |       20 |
|                                          |         |          |
| select table_name, table_owner, deleted  |    1065 |       20 |
|                                          |         |          |
| select table_name, table_owner, deleted  |    2845 |       20 |
|                                          |         |          |
| select query_id, total_elapsed_time as   |     499 |        3 |
| r                                        |         |          |
| select * from my_employees;              |     854 |        2 |
| select partkey, sales_qty, avail_qty     |    2466 |       10 |
| fro                                      |         |          |
| select query_id, total_elapsed_time as   |     423 |        2 |
| r                                        |         |          |
| select e.empid, e.emp_name, d.dept_name  |     885 |        2 |
|                                          |         |          |
| select * from                            |     365 |       17 |
| (                                        |         |          |
| select o.o_orderkey,                     |         |          |
| su                                       |         |          |
| select d.dept_id, d.dept_name,           |    2240 |        6 |
| d.auth_us                                |         |          |
| SELECT * FROM order_calculation_vw;      |    1261 |   115269 |

Querying the account_history.query_history view can be a great way to keep tabs on what your user community is doing, check for performance issues, and see which database objects are being utilized.

Excercise - Chap13

Write a query against account_usage.views that returns the name of any view that has been created more than once.

select TABLE_NAME  from account_usage.views group by table_name having count(*) > 1;

Chap 14 - Window functions

https://docs.snowflake.com/en/sql-reference/functions-window-syntax

for many years the result sets from queries had to be fed into spreadsheets or reporting engines where additional logic was performed to generate the desired final results. For example, subtotals, rankings, and row-to-row comparisons could not be generated within a query and required external processing.

modern SQL implementations offer a host of built-in functions used to generate additional column values after the from, where, group by, and having clauses of a query have been evaluated. These functions, known as window functions.

it will be helpful to understand what windows are, how they are defined, and how they are utilized.

Data Windows

Data windows are subsets of rows in a result set. You are already familiar with this concept if you have utilized the group by clause, which groups rows into subsets based on data values. When using group by, you can apply functions such as max(), min(), count(), and sum() across the rows in each group.

A data window is similar to a group, except that windows are created when the select clause is being evaluated. Once data windows have been defined, you can apply windowing functions, such as max() and rank(), to the data in each data window.

A data window can span a single row or all of the rows in the result set, or anything in between, and you can define multiple data windows within the same query.

let’s say you are writing a report that sums total orders by year and quarter for the years 1995 through 1997

select date_part(year, o_orderdate) year,
date_part(quarter, o_orderdate) quarter,
sum(o_totalprice) tot_sales
from orders
where date_part(year, o_orderdate) between
1995 and 1997
group by date_part(year, o_orderdate),
date_part(quarter, o_orderdate)
order by 1,2;

+------+---------+--------------+
| YEAR | QUARTER |    TOT_SALES |
|------+---------+--------------|
| 1995 |       1 | 828280426.28 |
| 1995 |       2 | 818992304.21 |
| 1995 |       3 | 845652776.68 |
| 1995 |       4 | 824596303.26 |
| 1996 |       1 | 805551195.59 |
| 1996 |       2 | 809903462.32 |
| 1996 |       3 | 841091513.43 |
| 1996 |       4 | 839827181.45 |
| 1997 |       1 | 793402839.95 |
| 1997 |       2 | 824211569.74 |
| 1997 |       3 | 824176170.61 |
| 1997 |       4 | 813296140.78 |
+------+---------+--------------+

Along with the quarterly sales totals, the report should also show the quarter’s percentage of yearly sales (all four quarters of the same year).

select date_part(year, o_orderdate) year,
date_part(quarter, o_orderdate) qrter,
sum(o_totalprice) tot_sales,
sum(sum(o_totalprice))       -- Gives the total sales for that particular year
over (partition by
date_part(year, o_orderdate))
tot_yrly_sales
from orders
where date_part(year, o_orderdate) between
1995 and 1997
group by date_part(year, o_orderdate),
date_part(quarter, o_orderdate)
order by 1,2;

+------+-------+--------------+----------------+
| YEAR | QRTER |    TOT_SALES | TOT_YRLY_SALES |
|------+-------+--------------+----------------|
| 1995 |     1 | 828280426.28 |  3317521810.43 |
| 1995 |     2 | 818992304.21 |  3317521810.43 |
| 1995 |     3 | 845652776.68 |  3317521810.43 |
| 1995 |     4 | 824596303.26 |  3317521810.43 |
| 1996 |     1 | 805551195.59 |  3296373352.79 |
| 1996 |     2 | 809903462.32 |  3296373352.79 |
| 1996 |     3 | 841091513.43 |  3296373352.79 |
| 1996 |     4 | 839827181.45 |  3296373352.79 |
| 1997 |     1 | 793402839.95 |  3255086721.08 |
| 1997 |     2 | 824211569.74 |  3255086721.08 |
| 1997 |     3 | 824176170.61 |  3255086721.08 |
| 1997 |     4 | 813296140.78 |  3255086721.08 |
+------+-------+--------------+----------------+

The tot_yrly_sales column uses a partition by clause to define a data window for all rows in the same year. Thus, there are 3 data windows defined, one each for the years 1995, 1996, and 1997. The total values for each year are generated by “summing the sums,” which is why you see the sum() function used twice:

select date_part(year, o_orderdate) year,
date_part(quarter, o_orderdate) qrter,
sum(o_totalprice) tot_sales,
sum(sum(o_totalprice))       -- Gives the total sales for that particular year
over (partition by
date_part(year, o_orderdate))
tot_yrly_sales,

round(tot_sales/tot_yrly_sales*100,2) as pct_of_yrly_sales   -- Find the percentage of sale for a quater within the same year

from orders
where date_part(year, o_orderdate) between
1995 and 1997
group by date_part(year, o_orderdate),
date_part(quarter, o_orderdate)
order by 1,2;

+------+-------+--------------+----------------+-------------------+
| YEAR | QRTER |    TOT_SALES | TOT_YRLY_SALES | PCT_OF_YRLY_SALES |
|------+-------+--------------+----------------+-------------------|
| 1995 |     1 | 828280426.28 |  3317521810.43 |             24.97 |
| 1995 |     2 | 818992304.21 |  3317521810.43 |             24.69 |
| 1995 |     3 | 845652776.68 |  3317521810.43 |             25.49 |
| 1995 |     4 | 824596303.26 |  3317521810.43 |             24.86 |
| 1996 |     1 | 805551195.59 |  3296373352.79 |             24.44 |
| 1996 |     2 | 809903462.32 |  3296373352.79 |             24.57 |
| 1996 |     3 | 841091513.43 |  3296373352.79 |             25.52 |
| 1996 |     4 | 839827181.45 |  3296373352.79 |             25.48 |
| 1997 |     1 | 793402839.95 |  3255086721.08 |             24.37 |
| 1997 |     2 | 824211569.74 |  3255086721.08 |             25.32 |
| 1997 |     3 | 824176170.61 |  3255086721.08 |             25.32 |
| 1997 |     4 | 813296140.78 |  3255086721.08 |             24.99 |
+------+-------+--------------+----------------+-------------------+

Partitioning and Sorting

For some windowing functions, such as sum() and avg(), defining the data window is all that is needed. For other types of window functions, however, it is necessary to sort the rows within each window, which necessitates the use of an order by clause.

let’s say you are asked to assign a ranking to each quarter in a year to show which quarter had the highest total sales (rank = 1), the next highest sales (rank = 2), and so on. In order to assign rankings within a data window, you will need to describe how to order the rows

select date_part(year, o_orderdate) year,
date_part(quarter, o_orderdate) qrter,
sum(o_totalprice) tot_sales,
rank()
over (partition by date_part(year,
o_orderdate)
order by sum(o_totalprice) desc)
qtr_rank_per_year
from orders
where date_part(year, o_orderdate) between
1995 and 1997
group by date_part(year, o_orderdate),
date_part(quarter, o_orderdate)
order by 1,2, ;

+------+-------+--------------+-------------------+
| YEAR | QRTER |    TOT_SALES | QTR_RANK_PER_YEAR |
|------+-------+--------------+-------------------|
| 1995 |     1 | 828280426.28 |                 2 |
| 1995 |     2 | 818992304.21 |                 4 |
| 1995 |     3 | 845652776.68 |                 1 |
| 1995 |     4 | 824596303.26 |                 3 |
| 1996 |     1 | 805551195.59 |                 4 |
| 1996 |     2 | 809903462.32 |                 3 |
| 1996 |     3 | 841091513.43 |                 1 |
| 1996 |     4 | 839827181.45 |                 2 |
| 1997 |     1 | 793402839.95 |                 4 |
| 1997 |     2 | 824211569.74 |                 1 |
| 1997 |     3 | 824176170.61 |                 2 |
| 1997 |     4 | 813296140.78 |                 3 |
+------+-------+--------------+-------------------+

However, if you want to generate a ranking across an entire result set, you can omit the partition by clause

select date_part(year, o_orderdate) year,
date_part(quarter, o_orderdate) qrter,
sum(o_totalprice) tot_sales,
rank()
over (order by sum(o_totalprice) desc)
qtr_ranking
from orders
where date_part(year, o_orderdate) between
1995 and 1997
group by date_part(year, o_orderdate),
date_part(quarter, o_orderdate)
order by 1,2;

+------+-------+--------------+-------------+
| YEAR | QRTER |    TOT_SALES | QTR_RANKING |
|------+-------+--------------+-------------|
| 1995 |     1 | 828280426.28 |           4 |
| 1995 |     2 | 818992304.21 |           8 |
| 1995 |     3 | 845652776.68 |           1 |
| 1995 |     4 | 824596303.26 |           5 |
| 1996 |     1 | 805551195.59 |          11 |
| 1996 |     2 | 809903462.32 |          10 |
| 1996 |     3 | 841091513.43 |           2 |
| 1996 |     4 | 839827181.45 |           3 |
| 1997 |     1 | 793402839.95 |          12 |
| 1997 |     2 | 824211569.74 |           6 |
| 1997 |     3 | 824176170.61 |           7 |
| 1997 |     4 | 813296140.78 |           9 |
+------+-------+--------------+-------------+

Since the rankings are assigned across the entire result set, there is no need for a partition by clause, because there is only a single data window covering all 12 rows.

ORDER BY OVERLOAD -- Order by clause is overloaded

Unfortunately, the clause used to sort rows within data windows has the same name as the clause used to sort result sets: order by. Keep in mind that using order by within a windowing function (generally within the over(...) clause) does not influence the order of the final result set; if you want your query results to be sorted, you will need another order by clause at the end of your query.

Ranking 

Ranking Functions

There are three main ranking functions, and they differ largely in how ties are handled. For example, if you are generating a top 10 ranking of salespeople, and two of the salespersons tie for first place, do you assign them both a ranking of 1? If so, does the next person on the list get a ranking of 2 or 3? Table 14-1 defines how the ranking functions differ.

Ranking function 	Description
row_number() 		Assigns unique ranking to each row, ties handled arbitrarily, no gaps in ranking
rank() 				Assigns same ranking in case of a tie, leaves gaps in ranking
dense_rank() 		Assigns same ranking in case of a tie, no gaps in ranking

The row_number() function pays no attention to ties, whereas the rank() and dense_rank() functions will assign the same ranking when there is a tie. Additionally, rank() will leave a gap in the rankings when a tie occurs, whereas dense_rank() does not.

The next query counts the number of orders for each customer in 1996, in descending order

select o_custkey, count(*) num_orders
from orders o
where 1996 = date_part(year, o.o_orderdate)
group by o_custkey
order by 2 desc
limit 10;

+-----------+------------+
| O_CUSTKEY | NUM_ORDERS |
|-----------+------------|
|     43645 |          5 |
|     71731 |          4 |
|     55120 |          4 |
|     60250 |          4 |
|     55849 |          4 |
|    104692 |          4 |
|     56992 |          3 |
|    119821 |          3 |
|    108088 |          3 |
|     84740 |          3 |
+-----------+------------+

select o_custkey, count(*) num_orders,
row_number() over (order by count(*) desc)
row_num_rnk,
rank() over (order by count(*) desc)
rank_rnk,
dense_rank() over (order by count(*) desc)
dns_rank_rnk
from orders o
where 1996 = date_part(year, o.o_orderdate)
group by o_custkey
having o_custkey in
(43645,55120,71731,60250,55849,
104692,20743,118636,4618,63620)
order by 2 desc;

+-----------+------------+-------------+----------+--------------+
| O_CUSTKEY | NUM_ORDERS | ROW_NUM_RNK | RANK_RNK | DNS_RANK_RNK |
|-----------+------------+-------------+----------+--------------|
|     43645 |          5 |           1 |        1 |            1 |
|    104692 |          4 |           3 |        2 |            2 |
|     71731 |          4 |           2 |        2 |            2 |
|     60250 |          4 |           4 |        2 |            2 |
|     55120 |          4 |           5 |        2 |            2 |
|     55849 |          4 |           6 |        2 |            2 |
|     20743 |          3 |           7 |        7 |            3 |
|    118636 |          3 |          10 |        7 |            3 |
|      4618 |          3 |           8 |        7 |            3 |
|     63620 |          3 |           9 |        7 |            3 |
+-----------+------------+-------------+----------+--------------+

Top/Bottom/Nth Ranking 

Additionally, you may want to know something about the top- or bottom-ranked row, such as the value of one of the columns in the result set. For this type of functionality, you can use the first_value() and last_value() functions.

Imagine you’ve been asked to calculate the percentage difference between each quarter’s sales and the best and worst quarter’s sales (two separate columns). Here’s how you can identify the best and worst sales across all 12 quarters using first_value() and last_value():

select date_part(year, o_orderdate) year,
date_part(quarter, o_orderdate) qrter,
sum(o_totalprice) tot_sales,
first_value(sum(o_totalprice))
over (order by sum(o_totalprice) desc)
top_sales,
last_value(sum(o_totalprice))
over (order by sum(o_totalprice) desc)
btm_sales
from orders
where date_part(year, o_orderdate) between
1995 and 1997
group by date_part(year, o_orderdate),
date_part(quarter, o_orderdate)
order by 1,2;

+------+-------+--------------+--------------+--------------+
| YEAR | QRTER |    TOT_SALES |    TOP_SALES |    BTM_SALES |
|------+-------+--------------+--------------+--------------|
| 1995 |     1 | 828280426.28 | 845652776.68 | 793402839.95 |
| 1995 |     2 | 818992304.21 | 845652776.68 | 793402839.95 |
| 1995 |     3 | 845652776.68 | 845652776.68 | 793402839.95 |
| 1995 |     4 | 824596303.26 | 845652776.68 | 793402839.95 |
| 1996 |     1 | 805551195.59 | 845652776.68 | 793402839.95 |
| 1996 |     2 | 809903462.32 | 845652776.68 | 793402839.95 |
| 1996 |     3 | 841091513.43 | 845652776.68 | 793402839.95 |
| 1996 |     4 | 839827181.45 | 845652776.68 | 793402839.95 |
| 1997 |     1 | 793402839.95 | 845652776.68 | 793402839.95 |
| 1997 |     2 | 824211569.74 | 845652776.68 | 793402839.95 |
| 1997 |     3 | 824176170.61 | 845652776.68 | 793402839.95 |
| 1997 |     4 | 813296140.78 | 845652776.68 | 793402839.95 |
+------+-------+--------------+--------------+--------------+

select date_part(year, o_orderdate) year,
date_part(quarter, o_orderdate) qrter,
sum(o_totalprice) tot_sales,
round(sum(o_totalprice) /
first_value(sum(o_totalprice))
over (order by sum(o_totalprice) desc)
* 100, 2) pct_top_sales,
round(sum(o_totalprice) /
last_value(sum(o_totalprice))
over (order by sum(o_totalprice) desc)
* 100, 2) pct_btm_sales
from orders
where date_part(year, o_orderdate) between
1995 and 1997
group by date_part(year, o_orderdate),
date_part(quarter, o_orderdate)
order by 1,2;

+------+-------+--------------+---------------+---------------+
| YEAR | QRTER |    TOT_SALES | PCT_TOP_SALES | PCT_BTM_SALES |
|------+-------+--------------+---------------+---------------|
| 1995 |     1 | 828280426.28 |         97.95 |        104.40 |
| 1995 |     2 | 818992304.21 |         96.85 |        103.23 |
| 1995 |     3 | 845652776.68 |        100.00 |        106.59 |
| 1995 |     4 | 824596303.26 |         97.51 |        103.93 |
| 1996 |     1 | 805551195.59 |         95.26 |        101.53 |
| 1996 |     2 | 809903462.32 |         95.77 |        102.08 |
| 1996 |     3 | 841091513.43 |         99.46 |        106.01 |
| 1996 |     4 | 839827181.45 |         99.31 |        105.85 |
| 1997 |     1 | 793402839.95 |         93.82 |        100.00 |
| 1997 |     2 | 824211569.74 |         97.46 |        103.88 |
| 1997 |     3 | 824176170.61 |         97.46 |        103.88 |
| 1997 |     4 | 813296140.78 |         96.17 |        102.51 |
+------+-------+--------------+---------------+---------------+

Next, let’s say that the comparison should be made within each year, rather than across all three. In other words, show
the percentage comparison of each quarter’s sales to the best and worst quarters within the same year.

you just need to add a partition by clause within the first_value() and last_value() functions

select date_part(year, o_orderdate) year,
date_part(quarter, o_orderdate) qrter,
sum(o_totalprice) tot_sales,
round(sum(o_totalprice) /
first_value(sum(o_totalprice))
over (partition by date_part(year,
o_orderdate)
order by sum(o_totalprice) desc)
* 100, 1) pct_top_sales,
round(sum(o_totalprice) /
last_value(sum(o_totalprice))
over (partition by date_part(year,
o_orderdate)
order by sum(o_totalprice) desc)
* 100, 1) pct_btm_sales
from orders
where date_part(year, o_orderdate) between
1995 and 1997
group by date_part(year, o_orderdate),
date_part(quarter, o_orderdate)
order by 1,2;

+------+-------+--------------+---------------+---------------+
| YEAR | QRTER |    TOT_SALES | PCT_TOP_SALES | PCT_BTM_SALES |
|------+-------+--------------+---------------+---------------|
| 1995 |     1 | 828280426.28 |          97.9 |         101.1 |
| 1995 |     2 | 818992304.21 |          96.8 |         100.0 |
| 1995 |     3 | 845652776.68 |         100.0 |         103.3 |
| 1995 |     4 | 824596303.26 |          97.5 |         100.7 |
| 1996 |     1 | 805551195.59 |          95.8 |         100.0 |
| 1996 |     2 | 809903462.32 |          96.3 |         100.5 |
| 1996 |     3 | 841091513.43 |         100.0 |         104.4 |
| 1996 |     4 | 839827181.45 |          99.8 |         104.3 |
| 1997 |     1 | 793402839.95 |          96.3 |         100.0 |
| 1997 |     2 | 824211569.74 |         100.0 |         103.9 |
| 1997 |     3 | 824176170.61 |         100.0 |         103.9 |
| 1997 |     4 | 813296140.78 |          98.7 |         102.5 |
+------+-------+--------------+---------------+---------------+

Along with first_value() and last_value(), you can also use the nth_value() function if you want values from the row with the Nth ranking (2nd, 3rd, etc.) rather than the top of bottom row. The next query uses first_value() and nth_value() to determine the best and second-best quarter number for each year:

select date_part(year, o_orderdate) year,
date_part(quarter, o_orderdate) qrter,
sum(o_totalprice),
first_value(date_part(quarter, o_orderdate))
over (partition by date_part(year, o_orderdate)
order by sum(o_totalprice) desc)
best_qtr,
nth_value(date_part(quarter, o_orderdate),2)
over (partition by date_part(year, o_orderdate)
order by sum(o_totalprice) desc)
next_best_qtr
from orders
where date_part(year, o_orderdate) between
1995 and 1997
group by date_part(year, o_orderdate),
date_part(quarter, o_orderdate)
order by 1,2;

+------+-------+-------------------+----------+---------------+
| YEAR | QRTER | SUM(O_TOTALPRICE) | BEST_QTR | NEXT_BEST_QTR |
|------+-------+-------------------+----------+---------------|
| 1995 |     1 |      828280426.28 |        3 |             1 |
| 1995 |     2 |      818992304.21 |        3 |             1 |
| 1995 |     3 |      845652776.68 |        3 |             1 |
| 1995 |     4 |      824596303.26 |        3 |             1 |
| 1996 |     1 |      805551195.59 |        3 |             4 |
| 1996 |     2 |      809903462.32 |        3 |             4 |
| 1996 |     3 |      841091513.43 |        3 |             4 |
| 1996 |     4 |      839827181.45 |        3 |             4 |
| 1997 |     1 |      793402839.95 |        2 |             3 |
| 1997 |     2 |      824211569.74 |        2 |             3 |
| 1997 |     3 |      824176170.61 |        2 |             3 |
| 1997 |     4 |      813296140.78 |        2 |             3 |
+------+-------+-------------------+----------+---------------+

The nth_value() function has an additional parameter to let you specify the number of value of “N,” which in this case is 2. There is also an option to specify whether you want N rows from the top or bottom of the ranking, so here’s another variation that shows the best quarter and the second-worst quarter per year:

select date_part(year, o_orderdate) year,
date_part(quarter, o_orderdate) qrter,
sum(o_totalprice),
first_value(date_part(quarter, o_orderdate))
over (partition by date_part(year, o_orderdate)
order by sum(o_totalprice) desc)
best_qtr,
nth_value(date_part(quarter, o_orderdate),2) from last    -- From last used to mention second-worst quarter 
over (partition by date_part(year, o_orderdate)
order by sum(o_totalprice) desc)
next_worst_qtr
from orders
where date_part(year, o_orderdate) between
1995 and 1997
group by date_part(year, o_orderdate),
date_part(quarter, o_orderdate)
order by 1,2;

Qualify Clause

Window functions are executed after the where, group by, and having clauses have been evaluated. This means that you can’t add a filter condition in your where clause based on the results of a window function such as rank().

This would generally force you to do something like the following if you wanted to retrieve the five nations having the most suppliers

select name, num_suppliers
from
(select n.n_name as name, count(*) as
num_suppliers,
rank() over (order by count(*) desc) as
rnk
from supplier s
inner join nation n on n.n_nationkey =
s.s_nationkey
group by n.n_name
) top_suppliers
where rnk <= 5;

+-----------+---------------+
| NAME      | NUM_SUPPLIERS |
|-----------+---------------|
| PERU      |           325 |
| ALGERIA   |           318 |
| ARGENTINA |           312 |
| CHINA     |           310 |
| IRAQ      |           309 |
+-----------+---------------+

For this purpose, Snowflake has added a new clause named qualify, which is specifically designed for filtering based on the results of window functions. Here’s the previous query again, but this time using a qualify clause:

select n.n_name as name, count(*) as
num_suppliers,
rank() over (order by count(*) desc) as rnk
from supplier s
inner join nation n on n.n_nationkey =
s.s_nationkey
group by n.n_name
qualify rnk <= 5; 

+-----------+---------------+-----+
| NAME      | NUM_SUPPLIERS | RNK |
|-----------+---------------+-----|
| PERU      |           325 |   1 |
| ALGERIA   |           318 |   2 |
| ARGENTINA |           312 |   3 |
| CHINA     |           310 |   4 |
| IRAQ      |           309 |   5 |
+-----------+---------------+-----+

With qualify, you can put your filter conditions in the same query that calls the window functions, and you can use the column alias (rnk in this case) from the window function in the select clause.

You can also put the window functions within the qualify clause, which is useful if you want the top N rows but don’t need to know the actual rankings. Here’s the previous query, but with the rank() function moved from select to qualify:

select n.n_name as name, count(*) as
num_suppliers
from supplier s
inner join nation n on n.n_nationkey =
s.s_nationkey
group by n.n_name
qualify rank() over (order by count(*) desc) <= 5;

+-----------+---------------+
| NAME      | NUM_SUPPLIERS |
|-----------+---------------|
| PERU      |           325 |
| ALGERIA   |           318 |
| ARGENTINA |           312 |
| CHINA     |           310 |
| IRAQ      |           309 |
+-----------+---------------+

Therefore, the qualify clause can contain filter conditions that reference window functions in the select clause, or it can contain filter conditions that include calls to window functions.

Another way to find the top N rows based on a ranking is to use the top subclause of the select clause. Here’s what that looks like for the top five nation query:

select top 5
n.n_name as name, count(*) as num_suppliers,
rank() over (order by count(*) desc) as rnk
from supplier s
inner join nation n on n.n_nationkey = s.s_nationkey
group by n.n_name
order by 3;

+-----------+---------------+-----+
| NAME      | NUM_SUPPLIERS | RNK |
|-----------+---------------+-----|
| PERU      |           325 |   1 |
| ALGERIA   |           318 |   2 |
| ARGENTINA |           312 |   3 |
| CHINA     |           310 |   4 |
| IRAQ      |           309 |   5 |
+-----------+---------------+-----+

Reporting Functions 

Along with generating rankings, another common use for window functions is to find outliers (e.g., min or max values) or to generate sums or averages across an entire data set.

For these types of uses, you will be using aggregate functions like min(), max(), and sum(), but instead of using them with a group by clause, you will pair them with partition by and/or order by clauses.

query that sums total sales per year for all countries in the Asia region:

select n.n_name, date_part(year, o_orderdate)
as year,
sum(o.o_totalprice) as total_sales
from region r
inner join nation n
on r.r_regionkey = n.n_regionkey
inner join customer c
on n.n_nationkey = c.c_nationkey
inner join orders o
on o.o_custkey = c.c_custkey
where r.r_name = 'ASIA'
group by n.n_name, date_part(year,
o_orderdate)
order by 1,2;

+-----------+------+--------------+
| N_NAME    | YEAR |  TOTAL_SALES |
|-----------+------+--------------|
| CHINA     | 1992 | 139188741.34 |
| CHINA     | 1993 | 128182471.75 |
| CHINA     | 1994 | 147758796.10 |
| CHINA     | 1995 | 136166806.51 |
| CHINA     | 1996 | 140645511.48 |
| CHINA     | 1997 | 129644871.64 |
| CHINA     | 1998 |  80074704.96 |
| INDIA     | 1992 | 136980167.32 |
| INDIA     | 1993 | 129244478.73 |
| INDIA     | 1994 | 127425713.08 |
| INDIA     | 1995 | 129235566.26 |
| INDIA     | 1996 | 132290605.57 |
| INDIA     | 1997 | 128123889.04 |
| INDIA     | 1998 |  83999645.32 |
....
| VIETNAM   | 1996 | 139046819.16 |
| VIETNAM   | 1997 | 128811392.94 |
| VIETNAM   | 1998 |  77484675.94 |
+-----------+------+--------------+
35 Row(s) produced. Time Elapsed: 4.164s

add two additional columns: one to show the total sales per country across all years, and another to show total sales across all countries in each year. To do so, we will use two sum() functions along with partition by clauses to generate the appropriate data windows:

select n.n_name, date_part(year, o_orderdate)
as year,
sum(o.o_totalprice) as total_sales,
sum(sum(o.o_totalprice))
over (partition by n.n_name) as
tot_cntry_sls,
sum(sum(o.o_totalprice))
over (partition by date_part(year,
o_orderdate))
as tot_yrly_sls
from region r
inner join nation n
on r.r_regionkey = n.n_regionkey
inner join customer c
on n.n_nationkey = c.c_nationkey
inner join orders o
on o.o_custkey = c.c_custkey
where r.r_name = 'ASIA'
group by n.n_name, date_part(year,
o_orderdate)
order by 1,2;

+-----------+------+--------------+---------------+--------------+
| N_NAME    | YEAR |  TOTAL_SALES | TOT_CNTRY_SLS | TOT_YRLY_SLS |
|-----------+------+--------------+---------------+--------------|
| CHINA     | 1992 | 139188741.34 |  901661903.78 | 686115935.01 |
| CHINA     | 1993 | 128182471.75 |  901661903.78 | 657074858.39 |
| CHINA     | 1994 | 147758796.10 |  901661903.78 | 654328147.50 |
| CHINA     | 1995 | 136166806.51 |  901661903.78 | 663238458.58 |
| CHINA     | 1996 | 140645511.48 |  901661903.78 | 664099129.65 |
| CHINA     | 1997 | 129644871.64 |  901661903.78 | 653647330.77 |
| CHINA     | 1998 |  80074704.96 |  901661903.78 | 400087316.00 |
| INDIA     | 1992 | 136980167.32 |  867300065.32 | 686115935.01 |
| INDIA     | 1993 | 129244478.73 |  867300065.32 | 657074858.39 |
| INDIA     | 1994 | 127425713.08 |  867300065.32 | 654328147.50 |
| INDIA     | 1995 | 129235566.26 |  867300065.32 | 663238458.58 |
| INDIA     | 1996 | 132290605.57 |  867300065.32 | 664099129.65 |
| INDIA     | 1997 | 128123889.04 |  867300065.32 | 653647330.77 |
| INDIA     | 1998 |  83999645.32 |  867300065.32 | 400087316.00 |
...
| VIETNAM   | 1996 | 139046819.16 |  876033401.99 | 664099129.65 |
| VIETNAM   | 1997 | 128811392.94 |  876033401.99 | 653647330.77 |
| VIETNAM   | 1998 |  77484675.94 |  876033401.99 | 400087316.00 |
+-----------+------+--------------+---------------+--------------+
35 Row(s) produced. Time Elapsed: 1.240s

You may also be interested in comparing to the average or maximum values within a window: This query calculates the maximum sales per country across all years, and the average sales per year across all countries.

select n.n_name, date_part(year, o_orderdate)
as year,
sum(o.o_totalprice) as total_sales,
max(sum(o.o_totalprice))
over (partition by n.n_name) as
max_cntry_sls,
avg(round(sum(o.o_totalprice)))
over (partition by date_part(year,
o_orderdate))
as avg_yrly_sls
from region r
inner join nation n
on r.r_regionkey = n.n_regionkey
inner join customer c
on n.n_nationkey = c.c_nationkey
inner join orders o
on o.o_custkey = c.c_custkey
where r.r_name = 'ASIA'
group by n.n_name, date_part(year,
o_orderdate)
order by 1,2;


+-----------+------+--------------+---------------+---------------+
| N_NAME    | YEAR |  TOTAL_SALES | MAX_CNTRY_SLS |  AVG_YRLY_SLS |
|-----------+------+--------------+---------------+---------------|
| CHINA     | 1992 | 139188741.34 |  147758796.10 | 137223186.800 |
| CHINA     | 1993 | 128182471.75 |  147758796.10 | 131414971.800 |
| CHINA     | 1994 | 147758796.10 |  147758796.10 | 130865629.400 |
| CHINA     | 1995 | 136166806.51 |  147758796.10 | 132647691.600 |
| CHINA     | 1996 | 140645511.48 |  147758796.10 | 132819825.800 |
| CHINA     | 1997 | 129644871.64 |  147758796.10 | 130729466.200 |
| CHINA     | 1998 |  80074704.96 |  147758796.10 |  80017463.200 |
| INDIA     | 1992 | 136980167.32 |  136980167.32 | 137223186.800 |
| INDIA     | 1993 | 129244478.73 |  136980167.32 | 131414971.800 |
| INDIA     | 1994 | 127425713.08 |  136980167.32 | 130865629.400 |
| INDIA     | 1995 | 129235566.26 |  136980167.32 | 132647691.600 |
| INDIA     | 1996 | 132290605.57 |  136980167.32 | 132819825.800 |
| INDIA     | 1997 | 128123889.04 |  136980167.32 | 130729466.200 |
| INDIA     | 1998 |  83999645.32 |  136980167.32 |  80017463.200 |
...
| VIETNAM   | 1996 | 139046819.16 |  141297287.92 | 132819825.800 |
| VIETNAM   | 1997 | 128811392.94 |  141297287.92 | 130729466.200 |
| VIETNAM   | 1998 |  77484675.94 |  141297287.92 |  80017463.200 |
+-----------+------+--------------+---------------+---------------+
35 Row(s) produced. Time Elapsed: 1.344s

Positional Windows

So far in this chapter, all data windows have been created using the partition by clause, which places rows into data windows based on common values.

There are cases, however, when you will want to define data windows based on proximity rather than on values. For example, you may want to calculate rolling averages, which might require a data window to be built for each row including the prior, current, and next row.

Another example is a running total, where data windows are built from the first row up to the current row.

For these types of calculations, you will need to use an order by clause to define how the rows should be ordered, and a rows clause to specify which rows should be included in the data window.

select date_part(year, o_orderdate) year,
date_part(quarter, o_orderdate) qrter,
sum(o_totalprice) as total_sales
from orders
where date_part(year, o_orderdate) between
1995 and 1997
group by date_part(year, o_orderdate),
date_part(quarter, o_orderdate)
order by 1,2;

+------+-------+--------------+
| YEAR | QRTER |  TOTAL_SALES |
|------+-------+--------------|
| 1995 |     1 | 828280426.28 |
| 1995 |     2 | 818992304.21 |
| 1995 |     3 | 845652776.68 |
| 1995 |     4 | 824596303.26 |
| 1996 |     1 | 805551195.59 |
| 1996 |     2 | 809903462.32 |
| 1996 |     3 | 841091513.43 |
| 1996 |     4 | 839827181.45 |
| 1997 |     1 | 793402839.95 |
| 1997 |     2 | 824211569.74 |
| 1997 |     3 | 824176170.61 |
| 1997 |     4 | 813296140.78 |
+------+-------+--------------+
12 Row(s) produced. Time Elapsed: 0.624s

calculate a three-month running average for each quarter, which requires each row to have a data window that includes the prior, current, and next quarters. For example, the three-month rolling average for quarter 1 of 1996 would include the values from quarter 4 of 1995, quarter 1 of 1996, and quarter 2 of 1996.

select date_part(year, o_orderdate) year,
date_part(quarter, o_orderdate) qrter,
sum(o_totalprice) as total_sales,
avg(sum(o_totalprice))

over (order by date_part(year, o_orderdate), date_part(quarter, o_orderdate)
rows between 1 preceding and 1 following
) as rolling_avg

from orders
where date_part(year, o_orderdate) between
1995 and 1997
group by date_part(year, o_orderdate),
date_part(quarter, o_orderdate)
order by 1,2;

+------+-------+--------------+-----------------+
| YEAR | QRTER |  TOTAL_SALES |     ROLLING_AVG |
|------+-------+--------------+-----------------|
| 1995 |     1 | 828280426.28 | 823636365.24500 |    -- Average is calcualted only for two rows
| 1995 |     2 | 818992304.21 | 830975169.05666 |
| 1995 |     3 | 845652776.68 | 829747128.05000 |
| 1995 |     4 | 824596303.26 | 825266758.51000 |
| 1996 |     1 | 805551195.59 | 813350320.39000 |
| 1996 |     2 | 809903462.32 | 818848723.78000 |
| 1996 |     3 | 841091513.43 | 830274052.40000 |
| 1996 |     4 | 839827181.45 | 824773844.94333 |
| 1997 |     1 | 793402839.95 | 819147197.04666 |
| 1997 |     2 | 824211569.74 | 813930193.43333 |
| 1997 |     3 | 824176170.61 | 820561293.71000 |
| 1997 |     4 | 813296140.78 | 818736155.69500 |    -- Average is calcualted only for two rows
+------+-------+--------------+-----------------+
12 Row(s) produced. Time Elapsed: 2.630s

Defining windows positionally depends on an order by clause to determine the ordering of the rows. In this example, the rows clause specifies that the window should include all rows between the prior (one preceding) and next (one following) rows.

you could use rows unbounded preceding to generate a running total of quarterly sales:

select date_part(year, o_orderdate) year,
date_part(quarter, o_orderdate) qrter,
sum(o_totalprice) as total_sales,
sum(sum(o_totalprice))
over (order by date_part(year,
o_orderdate),
date_part(quarter, o_orderdate)
rows unbounded preceding) as running_total
from orders
where date_part(year, o_orderdate) between
1995 and 1997
group by date_part(year, o_orderdate),
date_part(quarter, o_orderdate)
order by 1,2;

+------+-------+--------------+---------------+
| YEAR | QRTER |  TOTAL_SALES | RUNNING_TOTAL |
|------+-------+--------------+---------------|
| 1995 |     1 | 828280426.28 |  828280426.28 |
| 1995 |     2 | 818992304.21 | 1647272730.49 |
| 1995 |     3 | 845652776.68 | 2492925507.17 |
| 1995 |     4 | 824596303.26 | 3317521810.43 |
| 1996 |     1 | 805551195.59 | 4123073006.02 |
| 1996 |     2 | 809903462.32 | 4932976468.34 |
| 1996 |     3 | 841091513.43 | 5774067981.77 |
| 1996 |     4 | 839827181.45 | 6613895163.22 |
| 1997 |     1 | 793402839.95 | 7407298003.17 |
| 1997 |     2 | 824211569.74 | 8231509572.91 |
| 1997 |     3 | 824176170.61 | 9055685743.52 |
| 1997 |     4 | 813296140.78 | 9868981884.30 |
+------+-------+--------------+---------------+

If you only need to get a value from a single row based on its position in the result set, you can use the lag() and lead() functions, which allow you to retrieve a column from a nearby row. how you could use the lag() function to find the prior quarter’s total sales:

lag(sum(o_totalprice),1) to instruct Snowflake to go back one row in the sort order and retrieve the sum(o_totalprice) value.

select 
date_part(year, o_orderdate) year,
date_part(quarter, o_orderdate) qrter,
sum(o_totalprice) as total_sales,

lag(sum(o_totalprice),1)       -- Lag of One record can use lead() for next row
over (order by date_part(year, o_orderdate),
date_part(quarter, o_orderdate)) as prior_qtr

from orders
where date_part(year, o_orderdate) between
1995 and 1997
group by date_part(year, o_orderdate),
date_part(quarter, o_orderdate)
order by 1,2;

+------+-------+--------------+--------------+
| YEAR | QRTER |  TOTAL_SALES |    PRIOR_QTR |
|------+-------+--------------+--------------|
| 1995 |     1 | 828280426.28 |         NULL | -- Lag of One record 
| 1995 |     2 | 818992304.21 | 828280426.28 |
| 1995 |     3 | 845652776.68 | 818992304.21 |
| 1995 |     4 | 824596303.26 | 845652776.68 |
| 1996 |     1 | 805551195.59 | 824596303.26 |
| 1996 |     2 | 809903462.32 | 805551195.59 |
| 1996 |     3 | 841091513.43 | 809903462.32 |
| 1996 |     4 | 839827181.45 | 841091513.43 |
| 1997 |     1 | 793402839.95 | 839827181.45 |
| 1997 |     2 | 824211569.74 | 793402839.95 |
| 1997 |     3 | 824176170.61 | 824211569.74 |
| 1997 |     4 | 813296140.78 | 824176170.61 |
+------+-------+--------------+--------------+
12 Row(s) produced. Time Elapsed: 0.802s

select 
date_part(year, o_orderdate) year,
date_part(quarter, o_orderdate) qrter,
sum(o_totalprice) as total_sales,

lag(sum(o_totalprice),2)    -- Lag of two records can use lead() for next row
over (order by date_part(year, o_orderdate),
date_part(quarter, o_orderdate)) as
prior_qtr

from orders
where date_part(year, o_orderdate) between
1995 and 1997
group by date_part(year, o_orderdate),
date_part(quarter, o_orderdate)
order by 1,2;

+------+-------+--------------+--------------+
| YEAR | QRTER |  TOTAL_SALES |    PRIOR_QTR |
|------+-------+--------------+--------------|
| 1995 |     1 | 828280426.28 |         NULL | -- Lag of two records
| 1995 |     2 | 818992304.21 |         NULL | -- Lag of two records
| 1995 |     3 | 845652776.68 | 828280426.28 |
| 1995 |     4 | 824596303.26 | 818992304.21 |
| 1996 |     1 | 805551195.59 | 845652776.68 |
| 1996 |     2 | 809903462.32 | 824596303.26 |
| 1996 |     3 | 841091513.43 | 805551195.59 |
| 1996 |     4 | 839827181.45 | 809903462.32 |
| 1997 |     1 | 793402839.95 | 841091513.43 |
| 1997 |     2 | 824211569.74 | 839827181.45 |
| 1997 |     3 | 824176170.61 | 793402839.95 |
| 1997 |     4 | 813296140.78 | 824211569.74 |
+------+-------+--------------+--------------+

Other Window Functions

there are functions useful for computing standard deviations and variances, percentiles, and linear regressions.

listagg() will be a handy function any time you need to flatten or pivot a set of values.
The listagg() function pivots data into a single delimited string, as demonstrated by the following query, which returns each region along with a commadelimited list of associated nations:

select r.r_name as region,

listagg(n.n_name, ',') within group 
(order by n.n_name) as nation_list

from region r
inner join nation n
on r.r_regionkey = n.n_regionkey
group by r.r_name
order by 1;

+-------------+----------------------------------------------+
| REGION      | NATION_LIST                                  |
|-------------+----------------------------------------------|
| AFRICA      | ALGERIA,ETHIOPIA,KENYA,MOROCCO,MOZAMBIQUE    |
| AMERICA     | ARGENTINA,BRAZIL,CANADA,PERU,UNITED STATES   |
| ASIA        | CHINA,INDIA,INDONESIA,JAPAN,VIETNAM          |
| EUROPE      | FRANCE,GERMANY,ROMANIA,RUSSIA,UNITED KINGDOM |
| MIDDLE EAST | EGYPT,IRAN,IRAQ,JORDAN,SAUDI ARABIA          |
+-------------+----------------------------------------------+
5 Row(s) produced. Time Elapsed: 1.262s

listagg() has a different syntax than the other window functions and uses a within group clause to specify ordering rather than an over clause. Also, if you want to further split your result set into data windows, you can add an over (partition by ...) clause as well. In some cases, you can use the partition by clause instead of using a group by clause, although you will likely need to add distinct to remove duplicates.

previous query without a group by clause but instead using partition by: producing the same result

select distinct r.r_name as region,

listagg(n.n_name, ',') within group (order by n.n_name)
over (partition by r.r_name) as nation_list

from region r
inner join nation n
on r.r_regionkey = n.n_regionkey
order by 1;

+-------------+----------------------------------------------+
| REGION      | NATION_LIST                                  |
|-------------+----------------------------------------------|
| AFRICA      | ALGERIA,ETHIOPIA,KENYA,MOROCCO,MOZAMBIQUE    |
| AMERICA     | ARGENTINA,BRAZIL,CANADA,PERU,UNITED STATES   |
| ASIA        | CHINA,INDIA,INDONESIA,JAPAN,VIETNAM          |
| EUROPE      | FRANCE,GERMANY,ROMANIA,RUSSIA,UNITED KINGDOM |
| MIDDLE EAST | EGYPT,IRAN,IRAQ,JORDAN,SAUDI ARABIA          |
+-------------+----------------------------------------------+

Excercise - Chap14

select date_part(year, o_orderdate) as
order_year,
count(*) as num_orders, sum(o_totalprice) as
tot_sales
from orders
group by date_part(year, o_orderdate);

+------------+------------+---------------+
| ORDER_YEAR | NUM_ORDERS |     TOT_SALES |
|------------+------------+---------------|
|       1997 |      17408 | 3255086721.08 |
|       1998 |      10190 | 1925196448.52 |
|       1995 |      17637 | 3317521810.43 |
|       1992 |      17506 | 3309734764.39 |
|       1994 |      17479 | 3278473892.67 |
|       1993 |      17392 | 3270416270.14 |
|       1996 |      17657 | 3296373352.79 |
+------------+------------+---------------+
7 Row(s) produced. Time Elapsed: 1.466s

Add two columns to generate rankings for num_orders and tot_sales. The highest value should receive a ranking of 1.

select 
date_part(year, o_orderdate) as order_year,
count(*) as num_orders, 
sum(o_totalprice) as tot_sales,

rank() over (order by count(*) desc) as rnk_no_of_ord,
rank() over (order by sum(o_totalprice) desc) as rnk_tot_price

from orders
group by date_part(year, o_orderdate);

+------------+------------+---------------+---------------+---------------+
| ORDER_YEAR | NUM_ORDERS |     TOT_SALES | RNK_NO_OF_ORD | RNK_TOT_PRICE |
|------------+------------+---------------+---------------+---------------|
|       1995 |      17637 | 3317521810.43 |             2 |             1 |
|       1992 |      17506 | 3309734764.39 |             3 |             2 |
|       1996 |      17657 | 3296373352.79 |             1 |             3 |
|       1994 |      17479 | 3278473892.67 |             4 |             4 |
|       1993 |      17392 | 3270416270.14 |             6 |             5 |
|       1997 |      17408 | 3255086721.08 |             5 |             6 |
|       1998 |      10190 | 1925196448.52 |             7 |             7 |
+------------+------------+---------------+---------------+---------------+

Add a qualify clause to the query in previous query to return only rows where either ranking is 2 or 6.

select 
date_part(year, o_orderdate) as order_year,
count(*) as num_orders, 
sum(o_totalprice) as tot_sales,

rank() over (order by count(*) desc) as rnk_no_of_ord,
rank() over (order by sum(o_totalprice) desc) as rnk_tot_price

from orders
group by date_part(year, o_orderdate)
qualify 
(rnk_no_of_ord in (2,6) or 
rnk_tot_price in (2,6))
;

+------------+------------+---------------+---------------+---------------+
| ORDER_YEAR | NUM_ORDERS |     TOT_SALES | RNK_NO_OF_ORD | RNK_TOT_PRICE |
|------------+------------+---------------+---------------+---------------|
|       1995 |      17637 | 3317521810.43 |             2 |             1 |
|       1992 |      17506 | 3309734764.39 |             3 |             2 |
|       1993 |      17392 | 3270416270.14 |             6 |             5 |
|       1997 |      17408 | 3255086721.08 |             5 |             6 |
+------------+------------+---------------+---------------+---------------+

Starting again with the original query, add a column to compute the total sales across all years (grand total). The value will be the same for each row.

select 
date_part(year, o_orderdate) as order_year,
count(*) as num_orders, 
sum(o_totalprice) as tot_sales,

sum(sum(o_totalprice)) over () as    --- Use without partition to find the total_sum use sum(sum())
tot_sls_over_years

from orders
group by date_part(year, o_orderdate);

+------------+------------+---------------+--------------------+
| ORDER_YEAR | NUM_ORDERS |     TOT_SALES | TOT_SLS_OVER_YEARS |
|------------+------------+---------------+--------------------|
|       1997 |      17408 | 3255086721.08 |     21652803260.02 |
|       1998 |      10190 | 1925196448.52 |     21652803260.02 |
|       1994 |      17479 | 3278473892.67 |     21652803260.02 |
|       1992 |      17506 | 3309734764.39 |     21652803260.02 |
|       1995 |      17637 | 3317521810.43 |     21652803260.02 |
|       1993 |      17392 | 3270416270.14 |     21652803260.02 |
|       1996 |      17657 | 3296373352.79 |     21652803260.02 |
+------------+------------+---------------+--------------------+

Modify the window function from Exercise 14-3 to generate a running sum instead of a grand total. Each row’s value should be the sum of itself and all prior years.

select 
date_part(year, o_orderdate) as order_year,
count(*) as num_orders, 
sum(o_totalprice) as tot_sales,

sum(sum(o_totalprice)) 
over (order by order_year,
order_year rows unbounded preceding) as  
tot_sls_over_years

from orders
group by order_year;

+------------+------------+---------------+--------------------+
| ORDER_YEAR | NUM_ORDERS |     TOT_SALES | TOT_SLS_OVER_YEARS |
|------------+------------+---------------+--------------------|
|       1992 |      17506 | 3309734764.39 |      3309734764.39 |
|       1993 |      17392 | 3270416270.14 |      6580151034.53 |
|       1994 |      17479 | 3278473892.67 |      9858624927.20 |
|       1995 |      17637 | 3317521810.43 |     13176146737.63 |
|       1996 |      17657 | 3296373352.79 |     16472520090.42 |
|       1997 |      17408 | 3255086721.08 |     19727606811.50 |
|       1998 |      10190 | 1925196448.52 |     21652803260.02 |
+------------+------------+---------------+--------------------+

Chap 15 - Snowflake Scripting Language

Snowflake’s procedural language, known as Snowflake Scripting language. This chapter will demonstrate the different language components. like pl/sql in oracle showflake scripting language includes the ability to execute select, delete, update, insert, and merge statements, along with constructs for variable definition, conditional logic (e.g if-then-else), looping (e.g., for and while), and exception handling.

You can build and execute scripts using Snowflake Scripting, and you can also compile and store your programs in the database (known as stored procedures).

Also, Snowflake provides the Snowpark API’s for Java, Scala, and Python, which allow programmers to write programs using their choice of language and run them from inside Snowflake. If you are already familiar with JavaScript, you can use that language to build user-defined functions and procedures in Snowflake. If you are looking for a simple language to write database scripts and stored procedures, however, Snowflake Scripting, which was released in the Spring of 2022, will do the job nicely.

The basic construct for writing scripts using Snowflake Scripting is known as a block and has the below sections

Section 	Functionality
Declare 	Optional start of block, used for declaring variables - only required if you need to declare variables used in            the script
Begin 		Contains SQL and Scripting commands - Required
Exception 	Optional error-handling logic - only needed if you want to explicitly handle any errors thrown during the            execution of the script.
End 		End of block - Required

A block with no name is called an anonymous block, whereas a named block is called a stored procedure. 

The only other thing to know about scripting blocks is that they can be nested, so you can have blocks that contain other blocks. This is especially helpful for lengthy scripts, since you can define variables and catch exceptions locally, rather than having all your variable declarations at the very top of the block and all the exception handling at the very bottom.

begin
  select 'this is from store PROC';   -- just query is issued but no return value from proc
end;

declare 
  ret_Val string(50);
begin
  select 'this is from store PROC' into ret_Val;
  return ret_Val;
end;

declare 
  ret_Val string(5);    -- length of variable less than string expression_error occurs
begin
  select 'this is from store PROC' into ret_Val;
  return ret_Val;
exception
   when expression_error then
     return 'Check all variable size';
end;

Scripting Statements

Value Assignment

If you have defined a variable in the declare section and wish to assign it a value, you can use the variable := value

declare
   v_area number;
begin
   v_area := 5;
end;

You also have the option of defining variables on the fly and assigning values to them using the let statement

declare
  v_area number;
begin
  let v_length number := 6;
  let v_width number := 3;
  v_area := v_length * v_width;
  return v_area;
end;

You can also use let to define a cursor, which is essentially a pointer to a result set. After defining a cursor variable and assigning it to a query, you will open the cursor, fetch the results, and then close the cursor.

declare
  v_cnt number;
begin
  let v_cur_emp cursor for select * from employee;
  return v_cur_emp;    -- Invalid use of cursor exception
end;

declare
  ret_Val string(55);
begin
  let v_cur_emp cursor for select 'return using cursor';
  open v_cur_emp;
  fetch v_cur_emp into ret_val;
  close v_cur_emp;
  return ret_val;    
end;

In this example, I only need to fetch a single row because I know that the query returns a single string. To retrieve more than one row, you need to use loops 

Snowflake is always using cursors when you execute a query, but you can choose whether the cursor is created implicitly (see Figure 15-3) or explicitly, as in this example.

You can also use let to define a resultset variable, which is a variable that holds the result set from a query.

declare    -- Gives unexpected begin because no variable delacred in declare
begin
  let v_emp resultset := (select * from employee);
  return table(v_emp);    
end;

-- Returns all the records from the employee table
begin
  let v_emp resultset := (select * from employee);
  return table(v_emp);     -- Table function is used to return the rows of result set
end;

Stored procedures that return result sets are called table functions.

if Statement

The if statement facilitates conditional logic and can be found in just about any programming language

if (<condition>) then
   <statement(s)>;      -- Statements can also be block
elseif (<condition>) then    -- or use case insted of nested if else
   <statement(s)>;
else
   <statement(s)>;
end if;

let v_bool boolean := true;
if (v_bool) then
   v_bool := false;    -- Statement
   declare             -- Statements can also be block
      v_int number;
   begin
      v_int := 20;
      return v_int;
   end;
else
   declare
      v_int number;
   begin
      v_int := 20;
      return v_int;
   end;
end if;

Case Statement

The case statement is also used for conditional logic, but it is most useful when there are multiple conditions to be evaluated. Case statements are evaluated from top to bottom; once a when clause evaluates as true, the corresponding statements are executed and the case statement execution completes. 

two types of case statements are searched case statement and simple case statement.

searched case statement

case
  when <condition1> then
     <statement(s)1>;
  when <condition2> then
     <statement(s)2>;
...
  when <conditionN> then
     <statement(s)N>;
  else
     <statement(s)>;
end case;

begin
  let v_num := 3;
  case 
     when v_num = 1 then 
	    return 'val is 1';
     when v_num = 2 then 
	    return 'val is 2';
     when v_num = 3 then 
	    return 'val is 3';
     when v_num = 4 then 
	    return 'val is 4';
	 Else
	    return 'unknown value';   
  end case;
end;

simple case statement

case <expression>
   when <expression1> then
     <statement(s)1>;
   when <expression2> then
     <statement(s)2>;
...
   when <expressionN> then
     <statement(s)N>;
   else
     <statement(s)>;
end case;


Declare
  v_num number := 3;
begin
  case v_num
     when 1 then 
	    return 'val is 1';
     when 2 then 
	    return 'val is 2';
     when 3 then 
	    return 'val is 3';
     when 4 then 
	    return 'val is 4';
	 Else
	    return 'unknown value';
  end case;
end;

Case expression (used in sql query) is different from case statements (used in stored proc)

Declare 
  v_num number := 15;
begin 
  let v_str varchar(20) := 
     case when v_num <= 10 then 'small'                  -- this is case Expression
	      when (v_num > 10 and v_num <= 20) then 'med'   -- this is case Expression
		  else 'big' end;                                -- this is case Expression
	 
	 -- Below is case statement
  	 case 
     when v_str = 'small' then 
	    return 'val is less than or equal to 10';
     when v_str = 'med' then 
	    return 'val is more than 10 and less than or equal 20';
	 Else
	    return 'val is Morethan than or equal to 20'; 
  end case;
end;

Cursors

A cursor is an object that allows you to execute a query and then step through the result set. All relational database servers use cursors, and a cursor is opened by the server for every SQL statement. You can choose to let Snowflake open and manage the cursor for you, which is known as an implicit cursor, or you can take control of the cursor yourself, which is an explicit cursor.

Cursor is the pointer to current record in the result set.

cursor life CYCLE
Cursor step Definition
Declare 	Create a cursor variable and assign it a se lect statement.
Open 		Execute the query and move to first row of result set.
Fetch 		Retrieve the current row from result set and move to next row.
Close 		Stop query execution and close the cursor.

These four steps always occur, but depending on the situation you may only explicitly perform zero, one, or all four steps.

Let’s start with the first case demonstrated in Figure 15-13, where a cursor is created and used implicitly for you by the server

declare
  ret_num number;
begin
  select count(*) into ret_num from employee; 
  return 'num of employees : ' || ret_num;    
end;

num of employees : 8

When this script is executed, the server defines a cursor for the select statement, opens the cursor (executes the query), fetches the results from the single row returned by the query, assigns the value 5 to the v_num variable, and then closes the cursor. This is all done for you behind the scenes.

As you can see, it takes a lot more work to explicitly manage the cursor, which probably leaves you wondering why you would do so. The short answer is that you should generally leave it up to the server unless you need more control of the process. One such situation would be iterating over the rows in a result set, which will require multiple fetch statements.

-- Explicitly manage the cursor
declare
  ret_num number;
  v_cur cursor for select count(*) from employee; 
begin
  open v_cur;
  fetch v_cur into ret_num;
  close v_cur;
  return 'num of employees : ' || ret_num;    
end;

Loop statments

Loops are used for iterative processing, which allows the same set of statements to be executed multiple times. While iterative processing is a powerful tool, it is important to understand either how many iterations should occur or what condition needs to be met in order to stop the execution of the loop. Otherwise, you could end up launching an infinite loop, which would continue iterating until your script is killed.

try later how to kill long running query -- 

There are four basic types of loops in Snowflake Scripting, loop, repeat, while, for.

loop

The loop statement runs one or more statements iteratively until a break command is executed.

loop
   <statement(s)>;
   <condition>
      break;
end loop;

declare
  v_num number := 1;
begin 
  loop
    v_num := v_num + 1;
	if (v_num > 99) then 
	   break;  	
	end if;
  end loop;
  return 'no of loop : ' || v_num;
end;

no of loop : 100

repeat 

repeat statement, includes an until clause which specifies the condition by which the loop will terminate. Keep in mind, however, that you can optionally use the break command to stop loop iteration at any time.

declare
  v_num number := 1;
begin 
  repeat 
    v_num := v_num + 1;
	if (v_num > 55) then 
	   break;              -- But this breaks loop at 55 iteration itself without waiting for 100
	end if;
	until(v_num > 99)      -- End after 100 iterations output 'no of loop : 100'
  end repeat;	
  return 'no of loop : ' || v_num;
end;

no of loop : 56

while

Like the repeat command, while includes the loop termination condition, but it is situated at the beginning of the statement

declare
  v_num number := 1;
begin 
  while (v_num < 99) do    -- End after 100 iterations output 'no of loop : 100'
    v_num := v_num + 1;
	if (v_num > 55) then 
	   break;              -- But this breaks loop at 55 iteration itself without waiting for 100
	end if;
  end while;	
  return 'no of loop : ' || v_num;
end;

using while over repeat is better because you can see the termination condition at the top of the statement.

for

The for loop comes in two flavors: counter based and cursor based. Counter based for loops allow you to specify a counter variable used for iteration, without the need to declare the variable first.

declare
  v_num number := 1;
begin 
  for n in 1 to 99 do      -- End after 100 iterations output 'no of loop : 100'
    v_num := v_num + 1;
	if (v_num > 55) then 
	   break;              -- But this breaks loop at 55 iteration itself without waiting for 100
	end if;
  end for;	
  return 'no of loop : ' || v_num;
end;

no of loop : 56

You can also iterate in the opposite direction by adding the reverse keyword

declare
  v_str string := 'countdown : ';
begin 
  for n in reverse 1 to 10 do      
    v_str := concat(v_str , ' ', n)
  end for;	
  return v_str;
end;

countdown :  10 9 8 7 6 5 4 3 2 1

for statement : cursor-based

One interesting aspect of cursor-based for loops is that you define the cursor variable, but you don’t need to issue open,
fetch, or close statements. optionally we can do if we want. This is all done implicitly for you as part of the for loop execution. Therefore, this is one case where you will only need to perform one step of the cursor life cycle and Snowflake does the rest for you.

declare
  v_str varchar(300) := 'Region list : ';
  v_cur cursor for select r_regionkey, r_name from region;
begin 
  for rec in v_cur do      -- Only this for is iterated because end of records reached already
    v_str := concat(v_str, rec.r_regionkey, '-', rec.r_name, ',');
  end for;       
  for rec in v_cur do      -- this for is not looped as end of records is reached before itself
    v_str := concat(v_str, rec.r_regionkey, '-', rec.r_name, ' s ');
  end for;	
  return v_str;
end;

Region list : 0-AFRICA, 1-AMERICA, 2-ASIA, 3-EUROPE, 4-MIDDLE EAST, 

if we close and the open the cursor we can use the same records again.

declare
  v_str varchar(300) := 'Region list : ';
  v_cur cursor for select r_regionkey, r_name from region;
begin 
  for rec in v_cur do      -- End after 100 iterations output 'no of loop : 100'
    v_str := concat(v_str, rec.r_regionkey, '-', rec.r_name, ', ');
  end for;
  close v_cur;  -- Close the cursor so it can used again below as fresh 
  open v_cur;   -- No need of this open becase it will work without this
  
  open v_cu;    -- This will give Uncaught exception of type 'STATEMENT_ERROR' - CURSOR 'V_CUR' is already open.
  
  for rec in v_cur do      -- End after 100 iterations output 'no of loop : 100'
    v_str := concat(v_str, rec.r_regionkey, '-', rec.r_name, 'siva');
  end for;	
  return v_str;
end;

Region list : 0-AFRICA, 1-AMERICA, 2-ASIA, 3-EUROPE, 4-MIDDLE EAST, 0-AFRICAsiva1-AMERICAsiva2-ASIAsiva3-EUROPEsiva4-MIDDLE EASTsiva

Exceptions

Catching exceptions
If you don’t include an exception block to catch exceptions, any errors encountered during the execution of your script will be passed on to the caller. This can be problematic for the caller since the error message returned by Snowflake may not be specific enough to pinpoint the problem.

Also, if there is an open transaction, it may not be apparent to the caller whether to issue a rollback or a commit. At the very least, you should use the catchall exception when other, which will give you the ability to capture any exception thrown by Snowflake.

Exception components
Component Description
SQLCODE 	A signed integer unique for eachexception
SQLERRM 	An error message
SQLSTATE 	A five-character string indicating an exception type

the error number (sqlcode) and message (sqlerrm) are critical pieces of information for troubleshooting.

It would be great to send all three components to the caller, and Snowflake includes a very useful function called object_construct() that is perfect for generating a document containing related information.

This script has a single statement, which is an attempt to divide a number by zero, which causes an exception to be thrown. There is a single exception handler, when other, that catches this (or any) exception. A document is then constructed with the three exception components, and then the document is returned to the caller.

begin
  select 999/0;
Exception
  when other then
    return object_construct(
	   'SQLCODE',SQLCODE,
	   'SQLERRM',SQLERRM,
	   'SQLSTATE',SQLSTATE);
end;

Along with the when other exception handler, Snowflake supplies two more specific handlers: statement_error and expression_error. The first one, statement_error, will catch any errors related to the execution of an SQL statement, while the second, expression_error, will catch any errors related to the evaluation of an expression.


create or replace procedure div_by_zero()
returns object
language sql
As

$$
begin
  select 999/0;
Exception
  when other then
    return object_construct(
	   'SQLCODE',SQLCODE,
	   'SQLERRM',SQLERRM,
	   'SQLSTATE',SQLSTATE);
end;
$$;

-- Try later get the return value from this stored proc and process the object returned. find the type of the object.

Snowflake also lets you declare your own exceptions in the range –20999 to –20000. This range is reserved for your use, and you can use it to throw very specific exceptions.

begin
  select 999/0;
Exception
  when expression_error then
    return object_construct(
	   'Type','expression',
	   'SQLCODE',SQLCODE,
	   'SQLERRM',SQLERRM,
	   'SQLSTATE',SQLSTATE);
  when statement_error then
    return object_construct(
	   'Type','statement',
	   'SQLCODE',SQLCODE,
	   'SQLERRM',SQLERRM,
	   'SQLSTATE',SQLSTATE);	   
  when other then
    return object_construct(
	   'Type','other',
	   'SQLCODE',SQLCODE,
	   'SQLERRM',SQLERRM,
	   'SQLSTATE',SQLSTATE);
end;

{
  "SQLCODE": 100051,
  "SQLERRM": "Division by zero",
  "SQLSTATE": "22012",
  "Type": "statement"
}

Declaring and raising exceptions

Declare
   e_num_days_invalid exception (-20115, 'Number of days cannot be zeor');
begin
  let v_acc_bal number := 145600;
  let v_num_days number := 0;
  if (v_num_days = 0) then
	  raise e_num_days_invalid;    --- Raises user defined Exception
  else
	  return (v_acc_bal / v_num_days);
  end if;
Exception
  when other then
    return object_construct(
	   'SQLCODE',SQLCODE,
	   'SQLERRM',SQLERRM,
	   'SQLSTATE',SQLSTATE);
end;

{
  "SQLCODE": -20115,
  "SQLERRM": "Number of days cannot be zeor",
  "SQLSTATE": "P0001"
}

In the declare section of the script, a variable of type exception is created and assigned the number –20115 and the message 'Number of days cannot be zero!' The script then checks to see if the value of the v_num_days variable equals 0; if so, the e_num_days_invalid exception is raised, and otherwise the calculation proceeds.

The script raises the e_num_days_invalid exception and then catches it in the when other exception handler. If you
prefer to let the exception propagate up to the caller, you can build your own exception handler for your exception, and then issue the raise statement, 

With this below change, instead of receiving a document with the error details, the exception will flow through to the caller,

Declare
   e_num_days_invalid exception (-20115, 'Number of days cannot be zeor');
begin
  let v_acc_bal number := 145600;
  let v_num_days number := 0;
  if (v_num_days = 0) then
	  raise e_num_days_invalid;    --- Raises user defined Exception
  else
	  return (v_acc_bal / v_num_days);
  end if;
Exception
  when e_num_days_invalid then
    raise;
  when other then
    return object_construct(
	   'SQLCODE',SQLCODE,
	   'SQLERRM',SQLERRM,
	   'SQLSTATE',SQLSTATE);
end;

-20115 (P0001): Uncaught exception of type 'E_NUM_DAYS_INVALID' on line 7 at position 3 : Number of days cannot be zeor

Excercise - Chap15  

Write a script that declares a cursor for the query select max(o_totalprice) from orders, opens the cursor,  etches the results into a numeric variable, closes the cursor, and returns the value fetched from the query.


begin
  let v_max_sale_price resultset := (select max(o_totalprice) from orders);
  return table(v_max_sale_price);     -- Table function is used to return the rows of result set
end;

MAX(O_TOTALPRICE)
555285.16

declare 
  v_max_sale number;
begin
  (select max(o_totalprice) into v_max_sale from orders);
  return v_max_sale;
end;

555285

Write a script that uses a counter-based for loop to iterate over the range 1 to 100. Break out of the loop after the 60th
iteration.

declare 
   v_itr_cnt number := 0;
Begin
   for i in 1 to 100 do
      v_itr_cnt := v_itr_cnt + 1;
      if (v_itr_cnt >= 60) then
         break;
      end if;
   end for;
   return 'end value : ' || v_itr_cnt;
end;

Write a script that declares an exception with number – 20200 and the string 'The sky is falling!', raises the exception, catches it, and reraises it.

declare
  exp_sky_fall exception (-20200, 'Sky is falling')
Begin
  raise exp_sky_fall;
end;

-20200 (P0001): Uncaught exception of type 'EXP_SKY_FALL' on line 4 at position 2 : Sky is falling

declare
  exp_sky_fall exception (-20200, 'Sky is falling')
Begin
  raise exp_sky_fall;
end;

-20200 (P0001): Uncaught exception of type 'EXP_SKY_FALL' on line 4 at position 2 : Sky is falling

declare
  exp_sky_fall exception (-20200, 'Sky is falling')
Begin
  raise exp_sky_fall;
exception
  when other then
    return object_construct(
	   'SQLCODE',SQLCODE,
	   'SQLERRM',SQLERRM,
	   'SQLSTATE',SQLSTATE);
end;

{
  "SQLCODE": -20200,
  "SQLERRM": "Sky is falling",
  "SQLSTATE": "P0001"
}

Write a script that uses a cursor-based for loop to iterate through all n_name values in the Nation table. Break out of
the loop when 'EGYPT' is retrieved.

declare
  v_cur cursor for select n_name from nation;
  v_nname varchar(250) := '';
Begin
  for rec in v_cur do
    if(rec.n_name = 'EGYPT') then
	   return v_nname;
	   break;
	else
	   v_nname := v_nname || rec.n_name || ' ';
	end if;
  end for;
  return v_nname;
exception
  when other then
    return object_construct(
	   'SQLCODE',SQLCODE,
	   'SQLERRM',SQLERRM,
	   'SQLSTATE',SQLSTATE);
end;

Chap 16 - Building Stored Procedures 

stored procedures, which are compiled programs written using Snowflake Scripting and residing in Snowflake.

1) Scripts that are used repeatedly can be stored in the database for ease of use and sharing with others.
2) Stored procedure names can be overloaded, meaning that multiple stored procedures may have the same name as long as the parameter types differ.
3) Stored procedures facilitate code reuse and hide complex logic from end users.

Turning a Script into a Stored Procedure 

Changing below script into SP

Declare
   e_num_days_invalid exception (-20115, 'Number of days cannot be zeor');
begin
  let v_acc_bal number := 145600;
  let v_num_days number := 0;
  if (v_num_days = 0) then
	  raise e_num_days_invalid;    --- Raises user defined Exception
  else
	  return (v_acc_bal / v_num_days);
  end if;
Exception
  when e_num_days_invalid then
    raise;
  when other then
    return object_construct(
	   'SQLCODE',SQLCODE,
	   'SQLERRM',SQLERRM,
	   'SQLSTATE',SQLSTATE);
end;

--- Same as stored procedure

create procedure get_avg_bal (p_acc_bal number, p_num_days number)
returns number
language sql    -- Not required as default is sql 
as 
Declare
   e_num_days_invalid exception (-20115, 'Number of days cannot be zeor');
begin
  if (p_num_days = 0) then
	  raise e_num_days_invalid;    --- Raises user defined Exception
  else
	  return (p_acc_bal / p_num_days);
  end if;
Exception
  when e_num_days_invalid then
    raise;
  when other then
    return object_construct(
	   'SQLCODE',SQLCODE,
	   'SQLERRM',SQLERRM,
	   'SQLSTATE',SQLSTATE);
end;

Snowflake stored procedures are required to return something, but if you don’t have anything to return explicitly to the caller you could just return the string 'Success', or return the number of rows modified by the stored procedure.

Stored Procedure Execution

The first and simplest method is to use the call command,

call get_avg_bal(12000,60);
+-------------+
| GET_AVG_BAL |
|-------------|
|  200.000000 |
+-------------+
1 Row(s) produced. Time Elapsed: 0.918s
nesanawsnew#COMPUTE_WH@LEARNING_SQL.PUBLIC>

call get_avg_bal(12000,0);

-20115 (P0001): Uncaught exception of type 'E_NUM_DAYS_INVALID' on line 5 at position 3 : Number of days cannot be zeor

Declare
   v_avg_bal number;
Begin
   call get_avg_bal(12000,8) into :v_avg_bal;
   return v_avg_bal;
end;   

anonymous block
1500

This version uses the into clause of the call command to put the results into variable v_avg_bal.
it would be useful to call the stored procedure from an SQL statement, such as the following:
The stored procedures cannot be called from queries as below, but it is possible to call user-defined functions from queries.

declare
   v_avg_bal number;
begin
   select get_avg_balance(12000,30) into v_avg_bal;  -- Gives error Unknown function GET_AVG_BALANCE
   return v_avg_bal;
end;

Unknown function GET_AVG_BALANCE  -- Error

Doing more with Stored procedures

First, I will build a data warehouse table to store aggregated sales data across countries, years, and months. Here’s the table definition:

create table wh_country_monthly_sales
(sales_year number,
sales_month number,
region_name varchar(20),
country_name varchar(30),
total_sales number
);

Next, create a stored procedure to populate the newtable, and the procedure should do the following things:

Begin a transaction.
Delete any existing data for the given region and year.
Insert rows for the given region and year.
Commit the transaction, or rollback if error raised.
Return the number of rows deleted and inserted as a document.

Stored proc named ins_country_monthly_sales() and will accept two parameters, region_name and year.

create procedure ins_country_monthly_sales(p_region_name varchar, p_year number)
  returns object
  language sql
as
begin
  begin transaction;
  
    delete from wh_country_monthly_sales
      where region_name = :p_region_name
      and sales_year = :p_year;
	  
    let v_num_del number := sqlrowcount; -- sqlrowcount variable, holds the number of rows modified by SQL statement
	
    insert into wh_country_monthly_sales
       (sales_year, sales_month, region_name, country_name, total_sales)

    select 
	  date_part(year, o.o_orderdate) as sales_year,
      date_part(month, o_orderdate) as sales_month,
      r.r_name as region_name,
      n.n_name as country_name,
      sum(o.o_totalprice) as total_sales
    from orders as o
       inner join customer as c
       on o.o_custkey = c.c_custkey
       inner join nation as n
       on c.c_nationkey = n.n_nationkey
       inner join region as r
       on n.n_regionkey = r.r_regionkey
       where r.r_name = :p_region_name
       and date_part(year, o.o_orderdate) = :p_year
    group by 
	   date_part(year, o.o_orderdate),
       date_part(month, o_orderdate),
       r.r_name,
       n.n_name;
	   
    let v_num_ins number := sqlrowcount;   -- sqlrowcount variable, holds the number of rows modified by SQL statement
	   
  commit;
  return object_construct('rows deleted',v_num_del, 'rows inserted',v_num_ins);
exception
  when other then
  rollback;
  raise;
end;

The procedure returns the type object, which is a semistructured data type. The object_construct() function returns type object, so the stored procedure’s return type must be object as well.

When you reference parameters or variables in SQL statements, you must prefix them with :. This is known as a bind variable, meaning that the variable’s value is bound to the statement at execution. :p_year and :p_region_name

Snowflake provides the sqlrowcount variable, which holds the number of rows modified by the prior SQL statement.

call ins_country_monthly_sales('EUROPE', 1997);

+---------------------------+
| INS_COUNTRY_MONTHLY_SALES |
|---------------------------|
| {                         |
|   "rows deleted": 0,      |
|   "rows inserted": 60     |
| }                         |
+---------------------------+
1 Row(s) produced. Time Elapsed: 11.674s

Rerun again

call ins_country_monthly_sales('EUROPE', 1997);

+---------------------------+
| INS_COUNTRY_MONTHLY_SALES |
|---------------------------|
| {                         |
|   "rows deleted": 60,     |   -- old 60 records are deleted
|   "rows inserted": 60     |   -- same 60 records are inserted
| }                         |
+---------------------------+
1 Row(s) produced. Time Elapsed: 2.410s

There are 5 countries in the Europe region and 12 months of data, so 60 rows is the expected number.

Next, let’s say you put this procedure out for other people on your team to use, but some of them would rather pass in
the numeric regionkey instead of the region’s name. No problem; Snowflake allows stored procedures to be overloaded, meaning that two procedures can share the same name as long as the parameter types differ.

create procedure ins_country_monthly_sales(p_regionkey number, p_year number)
  returns object
  language sql
as
declare
  v_region_name varchar(20);
  v_document object;
begin
  select r.r_name into :v_region_name from region as r where r.r_regionkey = :p_regionkey;
  call ins_country_monthly_sales(:v_region_name, :p_year) into :v_document;
  return v_document;
end;

call ins_country_monthly_sales(3, 1997);  -- region key 3 is 'EUROPE'

+---------------------------+
| INS_COUNTRY_MONTHLY_SALES |
|---------------------------|
| {                         |
|   "rows deleted": 60,     |   -- old 60 records are deleted
|   "rows inserted": 60     |   -- same 60 records are inserted
| }                         |
+---------------------------+
1 Row(s) produced. Time Elapsed: 3.331s

STORED PROCEDURES AND TRANSACTIONS

There are some rules you should be aware of regarding how stored procedures can take part in transactions. If a transaction has been started prior to calling a stored procedure, the stored procedure can contribute to the transaction but cannot end the transaction via a commit or rollback. Also, if a transaction is started within a stored procedure, it must be completed (again via commit or rollback) within the same stored procedure.

When multiple transactions are started only the first one will be active. in one session we cant start multiple transactions interactively. but when a transaction is active we can call Stored proc that has transactions within that.

nesanawsnew#COMPUTE_WH@LEARNING_SQL.PUBLIC>begin transaction;
+----------------------------------+
| status                           |
|----------------------------------|
| Statement executed successfully. |
+----------------------------------+

nesanawsnew#COMPUTE_WH@LEARNING_SQL.PUBLIC>show transactions;
+---------------------+-------------+-----------------+--------------------------------------+-------------------------------+---------+-------+
|                  id | user        |         session | name                                 | started_on                    | state   | scope |
|---------------------+-------------+-----------------+--------------------------------------+-------------------------------+---------+-------|
| 1732680974848000000 | NESANAWSNEW | 748007209452838 | 9039c909-2c0c-40a8-8463-3a6e057fecc7 | 2024-11-26 20:16:14.848 -0800 | running |     0 |
+---------------------+-------------+-----------------+--------------------------------------+-------------------------------+---------+-------+
1 Row(s) produced. Time Elapsed: 0.378s

nesanawsnew#COMPUTE_WH@LEARNING_SQL.PUBLIC>begin transaction;

nesanawsnew#COMPUTE_WH@LEARNING_SQL.PUBLIC>begin transaction;

nesanawsnew#COMPUTE_WH@LEARNING_SQL.PUBLIC>show transactions;
+---------------------+-------------+-----------------+--------------------------------------+-------------------------------+---------+-------+
|                  id | user        |         session | name                                 | started_on                    | state   | scope |
|---------------------+-------------+-----------------+--------------------------------------+-------------------------------+---------+-------|
| 1732680974848000000 | NESANAWSNEW | 748007209452838 | 9039c909-2c0c-40a8-8463-3a6e057fecc7 | 2024-11-26 20:16:14.848 -0800 | running |     0 |
+---------------------+-------------+-----------------+--------------------------------------+-------------------------------+---------+-------+

call ins_country_monthly_sales(3, 1997);  -- region key 3 is 'EUROPE'
+---------------------------+
| INS_COUNTRY_MONTHLY_SALES |
|---------------------------|
| {                         |
|   "rows deleted": 60,     |
|   "rows inserted": 60     |
| }                         |
+---------------------------+
1 Row(s) produced. Time Elapsed: 2.537s

nesanawsnew#COMPUTE_WH@LEARNING_SQL.PUBLIC>rollback;
+----------------------------------+
| status                           |
|----------------------------------|
| Statement executed successfully. |
+----------------------------------+
1 Row(s) produced. Time Elapsed: 1.030s

Snowflake stored procedures to the next level is the ability to return result sets. To do so, the returns clause of your stored procedure needs to specify table(a, b, c), where a/b/c are the column names returned by the stored procedure. Snowflake provides the resultset data type to make this process as simple as possible. Here’s an example:

create procedure get_country_names(p_regionkey number)
returns table(key number, name varchar)
language sql
as
declare
   v_results resultset;
begin
   v_results := (select n_nationkey, n_name from nation where n_regionkey = :p_regionkey);
   return table(v_results);
end;

The procedure defines a variable of type resultset, associates it with a query, then returns it using the built-in table() function. the stored procedure returned a result set with column names key and name, which is what was specified in the returns clause of the stored procedure.

nesanawsnew#COMPUTE_WH@LEARNING_SQL.PUBLIC>call get_country_names(3);
+-----+----------------+
| KEY | NAME           |
|-----+----------------|
|   6 | FRANCE         |
|   7 | GERMANY        |
|  19 | ROMANIA        |
|  22 | RUSSIA         |
|  23 | UNITED KINGDOM |
+-----+----------------+
5 Row(s) produced. Time Elapsed: 3.557s

nesanawsnew#COMPUTE_WH@LEARNING_SQL.PUBLIC>call get_country_names(1);
+-----+---------------+
| KEY | NAME          |
|-----+---------------|
|   1 | ARGENTINA     |
|   2 | BRAZIL        |
|   3 | CANADA        |
|  17 | PERU          |
|  24 | UNITED STATES |
+-----+---------------+

Snowflake provides the array, variant, and object data types along with the usual types such as date, number, and varchar. You are free to use any of these data types in your stored procedures, including as parameters.

create or replace procedure get_rgn_country_name(p_region_names array)
returns table(rgn varchar, key number, name  varchar)
language sql
as
declare
   v_results resultset;
begin
   v_results := (select 
      r.r_name, n.n_nationkey, n.n_name from nation n 
	  inner join region r on r.r_regionkey = n.n_regionkey 
      where array_contains(r.r_name::variant, :p_region_names) order by 1);
   return table(v_results);
end;

The get_rgn_country_names() procedure will return a list of nations for one or more regions, based on the array that is passed in.

call get_rgn_country_name(['EUROPE'::variant, 'ASIA'::variant]);
+--------+-----+----------------+
| RGN    | KEY | NAME           |
|--------+-----+----------------|
| ASIA   |   8 | INDIA          |
| ASIA   |   9 | INDONESIA      |
| ASIA   |  12 | JAPAN          |
| ASIA   |  18 | CHINA          |
| ASIA   |  21 | VIETNAM        |
| EUROPE |   6 | FRANCE         |
| EUROPE |   7 | GERMANY        |
| EUROPE |  19 | ROMANIA        |
| EUROPE |  22 | RUSSIA         |
| EUROPE |  23 | UNITED KINGDOM |
+--------+-----+----------------+

it would be even better if the result set returned by a stored procedure could be queried, and Snowflake provides two different mechanisms for doing so. The first mechanism, when executed immediately after a stored procedure that returns a result set, allows the result set to be queried.

select * from table(result_scan(LAST_QUERY_ID())) limit 7;

+--------+-----+-----------+
| RGN    | KEY | NAME      |
|--------+-----+-----------|
| ASIA   |   8 | INDIA     |
| ASIA   |   9 | INDONESIA |
| ASIA   |  12 | JAPAN     |
| ASIA   |  18 | CHINA     |
| ASIA   |  21 | VIETNAM   |
| EUROPE |   6 | FRANCE    |
| EUROPE |   7 | GERMANY   |
+--------+-----+-----------+
7 Row(s) produced. Time Elapsed: 1.028s

query gets the identifier of the latest executed query using last_query_id(), calls the result_scan() function to retrieve the result set associated with that query identifier, and then sends it through the table() function to allow it to be referenced in the from clause of a query.

select LAST_QUERY_ID();
+--------------------------------------+
| LAST_QUERY_ID()                      |
|--------------------------------------|
| 01b8a504-0004-3863-0002-a84f00012856 |
+--------------------------------------+

select * from table(result_scan('01b8a504-0004-3863-0002-a84f00012856'));  -- When you know the query ID you can produce the result of that query anytime with table and result_scan functions.

+--------+-----+-----------+
| RGN    | KEY | NAME      |
|--------+-----+-----------|
| ASIA   |   8 | INDIA     |
| ASIA   |   9 | INDONESIA |
| ASIA   |  12 | JAPAN     |
| ASIA   |  18 | CHINA     |
| ASIA   |  21 | VIETNAM   |
| EUROPE |   6 | FRANCE    |
| EUROPE |   7 | GERMANY   |
+--------+-----+-----------+
7 Row(s) produced. Time Elapsed: 0.416s

second mechanism for querying result set returned by a stored procedure is using table functions.


How array_contains is working
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Returns TRUE if the specified value is found in the specified array. 

ARRAY_CONTAINS( <value_expr> , <array> )  -- True if <value_expr> (table column) is present in <array>

select 
      r.r_name, n.n_nationkey, n.n_name from nation n 
	  inner join region r on r.r_regionkey = n.n_regionkey 
      where array_contains(r.r_name::variant, ['EUROPE'::variant, 'ASIA'::variant]) order by 1;

+--------+-------------+----------------+
| R_NAME | N_NATIONKEY | N_NAME         |
|--------+-------------+----------------|
| ASIA   |           8 | INDIA          |
| ASIA   |           9 | INDONESIA      |
| ASIA   |          12 | JAPAN          |
| ASIA   |          18 | CHINA          |
| ASIA   |          21 | VIETNAM        |
| EUROPE |           6 | FRANCE         |
| EUROPE |           7 | GERMANY        |
| EUROPE |          19 | ROMANIA        |
| EUROPE |          22 | RUSSIA         |
| EUROPE |          23 | UNITED KINGDOM |
+--------+-------------+----------------+

select 
      r.r_name, n.n_nationkey, n.n_name from nation n 
	  inner join region r on r.r_regionkey = n.n_regionkey 
      where array_contains(r.r_name::variant, ['EUROPE'::variant, 'xxx'::variant]) order by 1;

+--------+-------------+----------------+
| R_NAME | N_NATIONKEY | N_NAME         |
|--------+-------------+----------------|
| EUROPE |           6 | FRANCE         |
| EUROPE |           7 | GERMANY        |
| EUROPE |          19 | ROMANIA        |
| EUROPE |          22 | RUSSIA         |
| EUROPE |          23 | UNITED KINGDOM |
+--------+-------------+----------------+

Dynamic SQL

However, you may want to execute a create table statement, which is not part of the Snowflake Scripting language grammar, or you may want to execute a query that needs to be constructed within your script using parameter values passed in by the caller. For these purposes, Snowflake includes the execute immediate statement, which lets you execute a string containing a valid SQL statement or scripting block.

Table name 	Key column 	Name column
Part 		p_partkey 	p_name
Supplier 	s_suppkey 	s_name
Region 		r_regionkey r_name
Customer 	c_custkey 	c_name
nation      n_nationkey n_name


Let’s write a stored procedure that will return key/name values from any of these tables by generating a query dynamically using the parameter values, and then executing the query using execute immediate. The first parameter, p_table_nm, would contain one of the five tables listed previously, and the key_start and key_end parameters would allow the caller to retrieve a subset of rows from the table. For example, executing get_key_name_values ('sup.plier', 1, 100) would return rows with s_suppkey values between 1 and 100.

create procedure get_key_name_values(p_table_nm varchar, key_start number, key_end number)
returns table(key number, name varchar)

steps for stored PROC
~~~~~~~~~~~~~~~~~~~~~
1) Identify the names of the columns that need to be returned using informa.tion_ schema.columns. The key column is always the first column, and the name column is always the second column.
2) Build a string containing the query.
3) Execute the query using execute immediate and retrieve result set.
4) Return result set to caller.

create procedure get_key_name_values(p_table_nm varchar, p_key_start number, p_key_end number)
   returns table(key number, name varchar)
language sql
as
declare
   v_results resultset;
   v_query varchar(200);
   v_keycol varchar(20);
   v_namecol varchar(20);
begin
   -- determine names of key/name columns
   select max(case when ordinal_position = 1 then column_name else null end) key_col,
          max(case when ordinal_position = 2 then column_name else null end) name_col
          into v_keycol, v_namecol
   from information_schema.columns
   where table_schema = 'PUBLIC'
   and table_name = upper(:p_table_nm)
   and ordinal_position < 3;

   -- build query string
   v_query := concat('select ', v_keycol,', 
   ',v_namecol,
   ' from ', p_table_nm,
   ' where ', v_keycol,' between ',
   case when p_key_start is null then '0' else p_key_start end,
   ' and ',
   case when p_key_end is null then '999999' else p_key_end end);
   
   v_results := (execute immediate :v_query);
   return table(v_results);
end;

call get_key_name_values('Part',null,5);

+-----+------+
| KEY | NAME |
|-----+------|
+-----+------+
0 Row(s) produced. Time Elapsed: 1.858s

call get_key_name_values('nation',null,5);   -- NULL gets replaced with 0 in Stored proc

+-----+-----------+
| KEY | NAME      |
|-----+-----------|
|   0 | ALGERIA   |
|   1 | ARGENTINA |
|   2 | BRAZIL    |
|   3 | CANADA    |
|   4 | EGYPT     |
|   5 | ETHIOPIA  |
+-----+-----------+
6 Row(s) produced. Time Elapsed: 1.682s

Excercise - Chap16

Turn the following anonymous script into a stored procedure named rectangle_area() with numeric parameters p_width and p_length:

declare
  v_width number := 5;
  v_height number := 8;
begin
  return v_width * v_height;
end;

create or replace procedure rectangle_area(p_width float, p_height float)
  returns float
language SQL
As
Begin
   return (p_width * p_height);
end;

call rectangle_area(1.2,2.0);
+----------------+
| RECTANGLE_AREA |
|----------------|
|              2 |
+----------------+

Write a stored procedure named get_parts_by_type() with a single parameter p_type_name (type varchar). The stored procedure should return a result set consisting of the p_partkey and p_name columns from the Part table, for rows whose p_type column matches the parameter value. Call the procedure with parameter value 'SMALL PLATED NICKEL' or 'PROMO BRUSHED STEEL', both of which should return 23 rows.

create or replace procedure get_parts_by_type(p_type_name varchar)
  returns table(p_partkey number, p_name varchar)
language SQL
As
declare 
   v_qry varchar(500);
   v_res resultset;
Begin
   v_qry := 'select p_partkey, p_name from part where p_type=\'' || p_type_name ||'\'';
   v_res := (execute immediate :v_qry);
   return table(v_res);
end;

call get_parts_by_type('SMALL PLATED NICKEL');

+-----------+------------------------------------------+
| P_PARTKEY | P_NAME                                   |
|-----------+------------------------------------------|
|    121458 | maroon dark burnished cyan dim           |
|    125608 | khaki rose gainsboro violet black        |
|      2658 | burnished royal lemon steel drab         |
|    135608 | cyan sandy navy floral black             |
|    139208 | wheat dark khaki tomato azure            |
|     13808 | black cyan burlywood chocolate forest    |
|     16358 | navy purple chartreuse plum aquamarine   |
|     17158 | antique burnished light metallic blush   |
|     18708 | aquamarine steel turquoise slate olive   |
|     80208 | slate lavender violet indian floral      |
|     94108 | wheat lace green cream rosy              |
|    101808 | sienna royal floral rosy thistle         |
|     67258 | honeydew maroon firebrick steel seashell |
|     69858 | turquoise aquamarine brown green antique |
|     71758 | puff white salmon lawn seashell          |
|     74308 | tan aquamarine powder steel rosy         |
|     78608 | snow tomato tan indian navy              |
|    145808 | papaya misty medium green lawn           |
|     21658 | maroon spring azure light almond         |
|     30008 | almond forest mint midnight violet       |
|     39808 | cyan firebrick salmon drab red           |
|    170408 | smoke bisque chocolate antique cyan      |
|    111108 | salmon peru cornsilk beige hot           |
+-----------+------------------------------------------+
23 Row(s) produced. Time Elapsed: 1.305s

Chap 17 - Table Functions

User-Defined Functions

even though stored procedures can return result sets, they can’t be called from SQL statements. 

Fortunately, Snowflake also allows you to create user-defined functions using the create function statement. Also known as UDFs, user-defined functions can be called from SQL statements, but unlike stored procedures they are limited to returning a single  expression and cannot take full advantage of the Snowflake Scripting language. UDFs can be written in Python, Java, JavaScript, Scala, and SQL, and this chapter will focus on SQL-based UDFs.

There is no looping, conditional logic, or exception handling allowed in functions.

create procedure rectangle_area(p_width number, p_length number)
returns number
language sql
as
begin
    return p_width * p_length;
end;

Here’s what it looks like as a UDF named fn_rectangle_area():

create function fn_rectangle_area(p_width number, p_length number)
  returns number
language sql
as
'p_width * p_length';

UDF can be called in the sql statement as below.

select rect.x as width, rect.y as length, fn_rectangle_area(rect.x, rect.y) as area from 
(values (2, 6), (4, 7), (8, 12)) as
rect(x,y);

+-------+--------+------+
| WIDTH | LENGTH | AREA |
|-------+--------+------|
|     2 |      6 |   12 |
|     4 |      7 |   28 |
|     8 |     12 |   96 |
+-------+--------+------+
3 Row(s) produced. Time Elapsed: 0.850s

A UDF such as this one is called a scalar user-defined function, in that it returns a single value. Snowflake also allows you to build tabular user-defined functions that return result sets,

Table Function

A table function is a user-defined function that returns a result set and can therefore be included in the from clause of a query and joined to other tables or even other table functions. Table functions must be generated using the create function command and must include a returns table clause specifying the names and types of the columns being returned. Also, the body of the table function must contain a single query and cannot make use of the other features of Snowflake Scripting language, such as scripting blocks and loops.

While this might seem like a serious limitation, table functions can play a critical role in your data access strategy.
For example, if there are many people in your organization creating reports and dashboards from Snowflake data, you
can build a set of table functions to shield them from complex SQL statements and possibly avoid costly performance issues in the process. Taking it to the extreme, you can force all database users to interact with your databases through a set of stored procedures and table functions, otherwise known as a data-access layer, rather than allowing direct access to tables.

You can add where, group by, order by, and any other clauses used in select statements, which means that table functions act just like tables.

To get started, let’s build a table function using the select statement from the ins_country_monthly_sales() procedure

select date_part(year, o.o_orderdate) as sales_year,
  date_part(month, o_orderdate) as sales_month,
  r.r_name as region_name,
  n.n_name as country_name,
  sum(o.o_totalprice) as total_sales
from snowflake_sample_data.tpch_sf1.orders as o
inner join snowflake_sample_data.tpch_sf1.customer
as c
on o.o_custkey = c.c_custkey
inner join snowflake_sample_data.tpch_sf1.nation as n
on c.c_nationkey = n.n_nationkey
inner join snowflake_sample_data.tpch_sf1.region as r
on n.n_regionkey = r.r_regionkey
where r.r_name = :p_region_name
and date_part(year, o.o_orderdate) = :p_year
group by date_part(year, o.o_orderdate),
date_part(month, o_orderdate),
r.r_name,
n.n_name;

this query as table Function

create function get_country_monthly_sales(p_region_name varchar, p_year number)
   returns table(
   sales_year number,
   sales_month number,
   region_name varchar,
   country_name varchar,
   total_sales number)
language sql
as
'select date_part(year, o.o_orderdate) as sales_year,
  date_part(month, o_orderdate) as sales_month,
  r.r_name as region_name,
  n.n_name as country_name,
  sum(o.o_totalprice) as total_sales
from snowflake_sample_data.tpch_sf1.orders as o
inner join snowflake_sample_data.tpch_sf1.customer
as c
on o.o_custkey = c.c_custkey
inner join snowflake_sample_data.tpch_sf1.nation as n
on c.c_nationkey = n.n_nationkey
inner join snowflake_sample_data.tpch_sf1.region as r
on n.n_regionkey = r.r_regionkey
where r.r_name = p_region_name               --   in functions you don’t specify bind variables (using prefix :)
and date_part(year, o.o_orderdate) = p_year  --   in functions you don’t specify bind variables (using prefix :)
group by date_part(year, o.o_orderdate),
date_part(month, o_orderdate),
r.r_name,
n.n_name';


select sales_month, country_name, total_sales from
table(get_country_monthly_sales('EUROPE',1997));

You can add where, group by, order by, and any other clauses used in select statements, which means that table functions act just like tables.

select sales_month, country_name, total_sales from
table(get_country_monthly_sales('EUROPE',1997)) where country_name='ROMANIA' order by sales_month;
+-------------+--------------+-------------+
| SALES_MONTH | COUNTRY_NAME | TOTAL_SALES |
|-------------+--------------+-------------|
|           1 | ROMANIA      |   123156412 |
|           2 | ROMANIA      |   108873334 |
|           3 | ROMANIA      |   120104796 |
|           4 | ROMANIA      |   125031914 |
|           5 | ROMANIA      |   110093370 |
|           6 | ROMANIA      |   119433165 |
|           7 | ROMANIA      |   116342292 |
|           8 | ROMANIA      |   119066485 |
|           9 | ROMANIA      |   112618710 |
|          10 | ROMANIA      |   118360369 |
|          11 | ROMANIA      |   111871074 |
|          12 | ROMANIA      |   123820321 |
+-------------+--------------+-------------+

select cms.sales_month, cms.country_name, cms.total_sales
from
table(get_country_monthly_sales('EUROPE',1997)) as cms
where cms.sales_month = 8
order by 2;
+-------------+----------------+-------------+
| SALES_MONTH | COUNTRY_NAME   | TOTAL_SALES |
|-------------+----------------+-------------|
|           8 | FRANCE         |   125059627 |
|           8 | GERMANY        |   106333217 |
|           8 | ROMANIA        |   119066485 |
|           8 | RUSSIA         |   118034351 |
|           8 | UNITED KINGDOM |   109899097 |
+-------------+----------------+-------------+

select cms.country_name, sum(cms.total_sales)
from
table(get_country_monthly_sales('EUROPE',1997)) as cms
group by 1;
+----------------+----------------------+
| COUNTRY_NAME   | SUM(CMS.TOTAL_SALES) |
|----------------+----------------------|
| GERMANY        |           1345237271 |
| FRANCE         |           1409569148 |
| UNITED KINGDOM |           1322442303 |
| ROMANIA        |           1408772242 |
| RUSSIA         |           1390802674 |
+----------------+----------------------+
5 Row(s) produced. Time Elapsed: 0.810s

You can also join the table function’s result set with other tables. The following query includes a join to the Nation table in order to include the nationkey value:

select cms.sales_month, cms.country_name, cms.total_sales, n.n_nationkey
from
table(get_country_monthly_sales('ASIA',1997)) as cms
inner join nation n on cms.country_name = n.n_name
where cms.sales_month = 8
order by 2;

+-------------+--------------+-------------+-------------+
| SALES_MONTH | COUNTRY_NAME | TOTAL_SALES | N_NATIONKEY |
|-------------+--------------+-------------+-------------|
|           8 | CHINA        |   118733457 |          18 |
|           8 | INDIA        |   105708350 |           8 |
|           8 | INDONESIA    |   113581046 |           9 |
|           8 | JAPAN        |   114890150 |          12 |
|           8 | VIETNAM      |   116167259 |          21 |
+-------------+--------------+-------------+-------------+
5 Row(s) produced. Time Elapsed: 1.259s

Table functions can act just like tables, but what makes table functions even more interesting is that they can also act like correlated subqueries, meaning that they can be executed multiple times using inputs from another table.

There are 5 rows in the Region table, so in this example the table function is called 5 times, once for each region name. On top of it the sum and group by works to give total sales in each country.

One of the benefits to this approach is that you can build a table function to return data for a specific parameter value, but then join to another table to facilitate iterative calls to the table function.

select r.r_name, cms.country_name, sum(cms.total_sales) as region_name
from region r
inner join
table(get_country_monthly_sales(r.r_name,1997)) as cms
group by 1,2
order by 1,2;

+-------------+----------------+-------------+
| R_NAME      | COUNTRY_NAME   | REGION_NAME |
|-------------+----------------+-------------|
| AFRICA      | ALGERIA        |  1378826491 |
| AFRICA      | ETHIOPIA       |  1352717758 |
| AFRICA      | KENYA          |  1361530748 |
| AFRICA      | MOROCCO        |  1360477730 |
| AFRICA      | MOZAMBIQUE     |  1395429817 |
| AMERICA     | ARGENTINA      |  1390643826 |
| AMERICA     | BRAZIL         |  1395361749 |
| AMERICA     | CANADA         |  1361217563 |
| AMERICA     | PERU           |  1356160042 |
| AMERICA     | UNITED STATES  |  1419081800 |
| ASIA        | CHINA          |  1384790729 |
| ASIA        | INDIA          |  1346040021 |
| ASIA        | INDONESIA      |  1414884578 |
| ASIA        | JAPAN          |  1392293534 |
| ASIA        | VIETNAM        |  1372654408 |
| EUROPE      | FRANCE         |  1409569148 |
| EUROPE      | GERMANY        |  1345237271 |
| EUROPE      | ROMANIA        |  1408772242 |
| EUROPE      | RUSSIA         |  1390802674 |
| EUROPE      | UNITED KINGDOM |  1322442303 |
| MIDDLE EAST | EGYPT          |  1336747175 |
| MIDDLE EAST | IRAN           |  1375362096 |
| MIDDLE EAST | IRAQ           |  1358140786 |
| MIDDLE EAST | JORDAN         |  1396943501 |
| MIDDLE EAST | SAUDI ARABIA   |  1347505424 |
+-------------+----------------+-------------+
25 Row(s) produced. Time Elapsed: 1.099s

select cms.sales_month, cms.country_name, cms.total_sales, r.r_name as region_name
from region r
inner join
table(get_country_monthly_sales(r.r_name,1997)) as cms
order by 2;

you can pass in values to both of the table function’s parameters, as shown in the next query:

select yrs.x as year, cms.sales_month as month, cms.country_name, cms.total_sales, r.r_name as region_name
from (values (1996), (1997)) as yrs(x)
cross join region r
cross join table(get_country_monthly_sales(r.r_name, yrs.x)) as cms
order by 1,2,3;

5 regions, 25 countries, 12 months, and 2 years - 5*25*12*2 = 600 rows returned

select yrs.x as year, cms.sales_month as month, cms.country_name, cms.total_sales, r.r_name as region_name
from (values (1996), (1997)) as yrs(x)
cross join region r
cross join table(get_country_monthly_sales(r.r_name, yrs.x)) as cms
where cms.total_sales >= 130272947     -- Where condition
order by 1,2,3;

only 3 rows out of 600 rows with where condition
+------+-------+--------------+-------------+-------------+
| YEAR | MONTH | COUNTRY_NAME | TOTAL_SALES | REGION_NAME |
|------+-------+--------------+-------------+-------------|
| 1996 |     8 | INDONESIA    |   130272947 | ASIA        |
| 1996 |    10 | ETHIOPIA     |   130676065 | AFRICA      |
| 1996 |    12 | FRANCE       |   133879330 | EUROPE      |
+------+-------+--------------+-------------+-------------+
3 Row(s) produced. Time Elapsed: 1.345s

Using Built-In Table Functions

Snowflake provides dozens of built-in table functions some of them such as materialized_view_refresh_history(), are used for very specific purposes, others are more general purpose and useful for various programming tasks.

Data Generation

There are situations when you will want to fabricate data sets, perhaps to construct a set of test data, or to construct a specific set of data such as a row for every day of a year. The generator() function is perfect for these situations, and it allows you either to create a certain number of rows (using the rowcount parameter) or create rows for a certain number of seconds (using the timelimit parameter). This function is a bit odd because it will generate rows without columns, so it is up to you to specify the columns to be returned.

For example, let’s say that you want to generate a row for every day in 2023.

select dateadd(day, seq4() + 1, '31-DEC-2022'::date) cal_date
from table(generator(rowcount => 365));

+------------+
| CAL_DATE   |
|------------|
| 2023-01-01 |
| 2023-01-02 |
| 2023-01-03 |
| 2023-01-04 |
...
| 2023-12-29 |
| 2023-12-30 |
| 2023-12-31 |
+------------+
365 Row(s) produced. Time Elapsed: 0.889s

This example uses the seq4() function to generate a sequence of numbers starting at zero.

select seq4() 
from table(generator(rowcount => 365)); -- Rows from 0 to 364 is generated

+--------+
| SEQ4() |
|--------|
|      0 |
|      1 |
|      2 |
|      3 |
|      4 |
...
|    363 |
|    364 |
+--------+
365 Row(s) produced. Time Elapsed: 2.019s


select *
from table(generator(rowcount => 365));   --    generate rows without columns so gives Error
001080 (42601): SQL compilation error: error line 1 at position 0 - SELECT with no columns

If you need to construct a set of test data, you can use the uniform(), random(), and randstr() functions to create random data values:

select uniform(1, 9999, random()) rnd_num, randstr(10, random()) rnd_str
from table(generator(rowcount => 10));

+---------+------------+
| RND_NUM | RND_STR    |
|---------+------------|
|    3670 | KP8kDCnz7D |
|    7113 | jdK3VJqMj9 |
|    1763 | sqZhNPusQq |
|     179 | sRtqVQqvkr |
|     320 | YvXWN8tqZC |
|    4932 | DSeNWgNEcg |
|    9556 | pFkgc6tvMe |
|    1036 | wtsd7puLbb |
|    6159 | RxaDtrnR0j |
|    9815 | egEN3b3Ai9 |
+---------+------------+
10 Row(s) produced. Time Elapsed: 0.640s

Flattening Rows

Snowflake provides several table functions that can be used  to flatten a set of values contained in a string or document into a set of rows.

select index, value
from table(split_to_table('a1|b2|c3', '|'));

+-------+-------+
| INDEX | VALUE |
|-------+-------|
|     1 | a1    |
|     2 | b2    |
|     3 | c3    |
+-------+-------+
3 Row(s) produced. Time Elapsed: 1.144s

While the split_to_table() function is handy if you need to parse a string, if you are working with documents you will need something a bit more sophisticated. let’s generate a simple JSON document containing the contents of the Employee table by combining Snowflake’s object_construct() and array_agg() functions:

select 
object_construct('employees', 
  array_agg(
     object_construct('empid', empid, 'name', emp_name)
	 )
) emp_doc
from employee where empid < 1004;

+--------------------------------+
| EMP_DOC                        |
|--------------------------------|
| {                              |
|   "employees": [               |
|     {                          |
|       "empid": 1001,           |
|       "name": "Bob Smith"      |
|     },                         |
|     {                          |
|       "empid": 1002,           |
|       "name": "Susan Jackson"  |
|     },                         |
|     {                          |
|       "empid": 1003,           |
|       "name": "Greg Carpenter" |
|     }                          |
|   ]                            |
| }                              |
+--------------------------------+

If you need to turn this document back into a set of rows and columns, you can use Snowflake’s flatten() table function.

select value
from table(flatten(input => parse_json(
'{"employees": [
{"empid": 1001, "name": "Bob Smith"},
{"empid": 1002, "name": "Susan Jackson"},
{"empid": 1003, "name": "Greg Carpenter"},
{"empid": 1004, "name": "Robert Butler"},
{"empid": 1005, "name": "Kim Josephs"},
{"empid": 1006, "name": "John Tyler"},
{"empid": 1007, "name": "John Sanford"}
]}'), path => 'employees'));

+----------------------------+
| VALUE                      |
|----------------------------|
| {                          |
|   "empid": 1001,           |
|   "name": "Bob Smith"      |
| }                          |
| {                          |
|   "empid": 1002,           |
|   "name": "Susan Jackson"  |
| }                          |
| {                          |
|   "empid": 1003,           |
|   "name": "Greg Carpenter" |
| }                          |
| {                          |
|   "empid": 1004,           |
|   "name": "Robert Butler"  |
| }                          |
| {                          |
|   "empid": 1005,           |
|   "name": "Kim Josephs"    |
| }                          |
| {                          |
|   "empid": 1006,           |
|   "name": "John Tyler"     |
| }                          |
| {                          |
|   "empid": 1007,           |
|   "name": "John Sanford"   |
| }                          |
+----------------------------+
7 Row(s) produced. Time Elapsed: 0.731s

select value:empid::number as emp_id,
value:name::varchar as emp_name
from table(flatten(input => parse_json(
'{"employees": [
{"empid": 1001, "name": "Bob Smith"},
{"empid": 1002, "name": "Susan Jackson"},
{"empid": 1003, "name": "Greg Carpenter"},
{"empid": 1004, "name": "Rober Butler"},
{"empid": 1005, "name": "Kim Josephs"},
{"empid": 1006, "name": "John Tyler"},
{"empid": 1007, "name": "John Sanford"}
]}'), path => 'employees'));

+--------+----------------+
| EMP_ID | EMP_NAME       |
|--------+----------------|
|   1001 | Bob Smith      |
|   1002 | Susan Jackson  |
|   1003 | Greg Carpenter |
|   1004 | Rober Butler   |
|   1005 | Kim Josephs    |
|   1006 | John Tyler     |
|   1007 | John Sanford   |
+--------+----------------+
7 Row(s) produced. Time Elapsed: 1.141s

Finding and Retrieving Query Results

Here’s a query that uses the query_history() function in information_schema to retrieve the last 10 queries run in your session

select query_id, substr(query_text, 1, 23) partial_query_text
from 
table(information_schema.query_history(result_limit => 10));

+--------------------------------------+-------------------------+
| QUERY_ID                             | PARTIAL_QUERY_TEXT      |
|--------------------------------------+-------------------------|
| 01b8a5db-0004-3864-0002-a84f0001182a | select query_id, substr |
| 01b8a5d7-0004-386b-0002-a84f000177ca | select value:empid::num |
| 01b8a5d1-0004-386a-0002-a84f000187d6 | select value            |
|                                      | from table              |
| 01b8a5cf-0004-3865-0002-a84f0001f172 | select value            |
|                                      | from table              |
| 01b8a5cd-0004-386b-0002-a84f000177c6 | select                  |
|                                      | object_construc         |
| 01b8a5cd-0004-386c-0002-a84f00016762 | select                  |
|                                      | object_construc         |
| 01b8a5cd-0004-3865-0002-a84f0001f16e | select                  |
|                                      | object_construc         |
| 01b8a5cb-0004-3869-0002-a84f00019852 | select index, value     |
|                                      | fro                     |
| 01b8a5b9-0004-386a-0002-a84f000187d2 | select index, value     |
|                                      | fro                     |
| 01b8a5b7-0004-3987-0002-a84f0001a662 | select uniform(1, 9999, |
+--------------------------------------+-------------------------+
10 Row(s) produced. Time Elapsed: 1.170s

select *
from table(result_scan('01b8a5cb-0004-3869-0002-a84f00019852'));

+-------+-------+
| INDEX | VALUE |
|-------+-------|
|     1 | a1    |
|     2 | b2    |
|     3 | c3    |
+-------+-------+
3 Row(s) produced. Time Elapsed: 0.968s


Excercise - Chap17
 
try later

Chap 18 - Semistructured Data    593 - 623

Not all data is easily expressed as rows and columns. Semistructured data formats such as XML, Parquet, Avro, and JSON allow for flexible data storage without the need to conform to a predefined schema. Snowflake’s architecture was designed from the very beginning to support both structured and semistructured data.

JSON (JavaScript Object Notation) has evolved into the standard format for data interchange. It is easy for both humans and machines to read and write, and while similar to XML it is less verbose and thus more compact. JSON stores data as key-value pairs, so the data is self-describing and there is no need for an external schema.

JSON documents can be generated from relational tables, stored in tables using the variant data type and queried using builtin functions such as flatten().

select 
object_construct('Regions', array_agg(
   object_construct('Region_Key', r_regionkey, 'Region_Name', r_name)))
as my_doc
from region;

+------------------------------------+
| MY_DOC                             |
|------------------------------------|
| {                                  |
|   "Regions": [                     |
|     {                              |
|       "Region_Key": 0,             |
|       "Region_Name": "AFRICA"      |
|     },                             |
|     {                              |
|       "Region_Key": 1,             |
|       "Region_Name": "AMERICA"     |
|     },                             |
|     {                              |
|       "Region_Key": 2,             |
|       "Region_Name": "ASIA"        |
|     },                             |
|     {                              |
|       "Region_Key": 3,             |
|       "Region_Name": "EUROPE"      |
|     },                             |
|     {                              |
|       "Region_Key": 4,             |
|       "Region_Name": "MIDDLE EAST" |
|     }                              |
|   ]                                |
| }                                  |
+------------------------------------+
1 Row(s) produced. Time Elapsed: 1.226s

This query creates an object consisting of two key-value pairs (with keys of Region_Key and Region_Name), and then pivots them into an array. The net result is a single row of output containing a JSON document.

Next, let’s generate a document consisting of an array of objects for each row in the Region table, including the region’s name and array of associated Nation rows. Additionally, total sales will be computed for each Region and Nation row. Here’s what the query looks like:

with
ntn_tot as
   (
   select n.n_regionkey, n.n_nationkey, sum(o.o_totalprice) as tot_ntn_sales, sum(sum(o.o_totalprice))
      over (partition by n.n_regionkey) as tot_rgn_sales
   from orders o
   inner join customer c
   on c.c_custkey = o.o_custkey
   inner join nation n
   on c.c_nationkey = n.n_nationkey
   group by n.n_regionkey, n.n_nationkey
   ),
ntn as
   (
   select n.n_regionkey, array_agg(object_construct('Nation_Name', n.n_name, 'Tot_Nation_Sales', ntn_tot.tot_ntn_sales))   as nation_list
   from nation n
   inner join ntn_tot
   on n.n_nationkey = ntn_tot.n_nationkey
   group by n.n_regionkey
   )
   
   select object_construct('Regions', array_agg(
   object_construct('Region_Name', r.r_name, 'Tot_Region_Sales', rgn_tot.tot_rgn_sales, 'Nations', ntn.nation_list))) as    region_summary_doc
   from region r
   inner join ntn on r.r_regionkey = ntn.n_regionkey
   inner join
   (select distinct n_regionkey, tot_rgn_sales
   from ntn_tot) rgn_tot
   on rgn_tot.n_regionkey = r.r_regionkey;

+--------------------------------------------+
| REGION_SUMMARY_DOC                         |
|--------------------------------------------|
| {                                          |
|   "Regions": [                             |
|     {                                      |
|       "Nations": [                         |
|         {                                  |
|           "Nation_Name": "ALGERIA",        |
|           "Tot_Nation_Sales": 867701407.69 |
|         },                                 |
|         {                                  |
|           "Nation_Name": "ETHIOPIA",       |
|           "Tot_Nation_Sales": 840736933.79 |
|         },                                 |
|         {                                  |
|           "Nation_Name": "KENYA",          |
|           "Tot_Nation_Sales": 830403434.37 |
|         },                                 |
|         {                                  |
|           "Nation_Name": "MOROCCO",        |
|           "Tot_Nation_Sales": 851082088.95 |
|         },                                 |
|         {                                  |
|           "Nation_Name": "MOZAMBIQUE",     |
|           "Tot_Nation_Sales": 849301460.62 |
|         }                                  |
|       ],                                   |
|       "Region_Name": "AFRICA",             |
|       "Tot_Region_Sales": 4239225325.42    |
|     },                                     |
|     {                                      |
|       "Nations": [                         |
...
|     },                                     |
|     {                                      |
|       "Nations": [                         |
|         {                                  |
|           "Nation_Name": "EGYPT",          |
|           "Tot_Nation_Sales": 862118149.8  |
|         },                                 |
|         {                                  |
|           "Nation_Name": "IRAN",           |
|           "Tot_Nation_Sales": 876878109.19 |
|         },                                 |
|         {                                  |
|           "Nation_Name": "IRAQ",           |
|           "Tot_Nation_Sales": 865003574.74 |
|         },                                 |
|         {                                  |
|           "Nation_Name": "JORDAN",         |
|           "Tot_Nation_Sales": 890186225.44 |
|         },                                 |
|         {                                  |
|           "Nation_Name": "SAUDI ARABIA",   |
|           "Tot_Nation_Sales": 828012176.23 |
|         }                                  |
|       ],                                   |
|       "Region_Name": "MIDDLE EAST",        |
|       "Tot_Region_Sales": 4322198235.4     |
|     }                                      |
|   ]                                        |
| }                                          |
+--------------------------------------------+
1 Row(s) produced. Time Elapsed: 1.753s

Storing JSON Documents

the variant data type can be used to store any kind of data, and that includes JSON documents. Before storing the previous document in a table, I want to make sure it is a properly formatted JSON document, so I’m going to call the try_parse_json() function, which takes a string as an argument and returns either null if the string is not a proper JSON document, or else a variant containing the document. Here are the results:

select try_parse_json(
'{
"Regions": [
{
"Nations": [
{
"Nation_Name": "ALGERIA",
"Tot_Nation_Sales": 867701407.69
},
{
"Nation_Name": "ETHIOPIA",
"Tot_Nation_Sales": 840736933.79
},
{
"Nation_Name": "KENYA",
"Tot_Nation_Sales": 830403434.37
},
{
"Nation_Name": "MOROCCO",
"Tot_Nation_Sales": 851082088.95
},
{
"Nation_Name": "MOZAMBIQUE",
"Tot_Nation_Sales": 849301460.62
}
],
"Region_Name": "AFRICA",
"Tot_Region_Sales": 4239225325.42
}
]
}'
)
as check_json_doc;

IF the same Json document is returned that means its proper json document.

+--------------------------------------------+
| CHECK_JSON_DOC                             |
|--------------------------------------------|
| {                                          |
|   "Regions": [                             |
|     {                                      |
|       "Nations": [                         |
|         {                                  |
|           "Nation_Name": "ALGERIA",        |
|           "Tot_Nation_Sales": 867701407.69 |
|         },                                 |
|         {                                  |
|           "Nation_Name": "ETHIOPIA",       |
|           "Tot_Nation_Sales": 840736933.79 |
|         },                                 |
|         {                                  |
|           "Nation_Name": "KENYA",          |
|           "Tot_Nation_Sales": 830403434.37 |
|         },                                 |
|         {                                  |
|           "Nation_Name": "MOROCCO",        |
|           "Tot_Nation_Sales": 851082088.95 |
|         },                                 |
|         {                                  |
|           "Nation_Name": "MOZAMBIQUE",     |
|           "Tot_Nation_Sales": 849301460.62 |
|         }                                  |
|       ],                                   |
|       "Region_Name": "AFRICA",             |
|       "Tot_Region_Sales": 4239225325.42    |
|     }                                      |
|   ]                                        |
| }                                          |
+--------------------------------------------+
1 Row(s) produced. Time Elapsed: 1.039s

for any error it returns NULL 

+----------------+
| CHECK_JSON_DOC |
|----------------|
| NULL           |
+----------------+

create table my_docs (doc variant);    -- Table to store the Documents

insert into my_docs 
with
ntn_tot as
   (
   select n.n_regionkey, n.n_nationkey, sum(o.o_totalprice) as tot_ntn_sales, sum(sum(o.o_totalprice))
      over (partition by n.n_regionkey) as tot_rgn_sales
   from orders o
   inner join customer c
   on c.c_custkey = o.o_custkey
   inner join nation n
   on c.c_nationkey = n.n_nationkey
   group by n.n_regionkey, n.n_nationkey
   ),
ntn as
   (
   select n.n_regionkey, array_agg(object_construct('Nation_Name', n.n_name, 'Tot_Nation_Sales', ntn_tot.tot_ntn_sales))   as nation_list
   from nation n
   inner join ntn_tot
   on n.n_nationkey = ntn_tot.n_nationkey
   group by n.n_regionkey
   )
   
   select object_construct('Regions', array_agg(
   object_construct('Region_Name', r.r_name, 'Tot_Region_Sales', rgn_tot.tot_rgn_sales, 'Nations', ntn.nation_list))) as    region_summary_doc
   from region r
   inner join ntn on r.r_regionkey = ntn.n_regionkey
   inner join
   (select distinct n_regionkey, tot_rgn_sales
   from ntn_tot) rgn_tot
   on rgn_tot.n_regionkey = r.r_regionkey
;

+-------------------------+
| number of rows inserted |
|-------------------------|
|                       1 |
+-------------------------+

The outermost function call in the query is object_construct(), so the data type of the column returned by the query is object. Snowflake can store anything in a column of type variant, so there is no conversion needed.

If you want to load a JSON document from a string, rather than generating it using a query, you can use the parse_json() function, which accepts a string as an argument and returns type variant:

insert into my_docs
select parse_json(
'{
"Regions": [
{
"Nations": [
{
"Nation_Name": "ALGERIA",
"Tot_Nation_Sales": 867701407.69
},
{
"Nation_Name": "ETHIOPIA",
"Tot_Nation_Sales": 840736933.79
},
{
"Nation_Name": "KENYA",
"Tot_Nation_Sales": 830403434.37
},
{
"Nation_Name": "MOROCCO",
"Tot_Nation_Sales": 851082088.95
},
{
"Nation_Name": "MOZAMBIQUE",
"Tot_Nation_Sales": 849301460.62
}
],
"Region_Name": "AFRICA",
"Tot_Region_Sales": 4239225325.42
}
]
}'
);

select * from my_docs;

LIMITATIONS WHEN STORING JSON DOCUMENTS IN VARIANT COLUMNS

While using variant columns to store documents is certainly easy, there are some limitations to consider. First, variant columns are limited to 16MB, so you won’t be able to store very large documents in a single column. Second, temporal data (date, time, and timestamp) fields are stored as strings, so performance can be an issue when performing operations such as add_month() or datediff().

Querying JSON Documents

The first step is to understand what fields (the names of the keys in the key-value pairs) are available in the document.

select distinct d.key, typeof(d.value) as
data_type
from my_docs
inner join lateral flatten(doc,
recursive=>true) d
where typeof(d.value) <> 'OBJECT'
order by 1;

+------------------+-----------+
| KEY              | DATA_TYPE |
|------------------+-----------|
| Nation_Name      | VARCHAR   |
| Nations          | ARRAY     |
| Region_Name      | VARCHAR   |
| Regions          | ARRAY     |
| Tot_Nation_Sales | DECIMAL   |
| Tot_Region_Sales | DECIMAL   |
+------------------+-----------+
6 Row(s) produced. Time Elapsed: 1.597s

select distinct d.key, typeof(d.value) as
data_type
from my_docs
inner join lateral flatten(doc,
recursive=>true) d
order by 1;

+------------------+-----------+
| KEY              | DATA_TYPE |
|------------------+-----------|
| Regions          | ARRAY     |
| NULL             | OBJECT    |
| Nations          | ARRAY     |
| Nation_Name      | VARCHAR   |
| Tot_Nation_Sales | DECIMAL   |
| Tot_Region_Sales | DECIMAL   |
| Region_Name      | VARCHAR   |
+------------------+-----------+
7 Row(s) produced. Time Elapsed: 0.801s

The flatten() function returns several columns, including key and value used in this example, and for this query I use the typeof() function to determine the data type of each field. I see that the Regions field has type array, so I can use the
array_size() function to determine how many elements are in the array:

select array_size(doc:Regions)
from my_docs;

+-------------------------+
| ARRAY_SIZE(DOC:REGIONS) |
|-------------------------|
|                       5 |   -- Record with 5 regions
|                       1 |   -- Record with 1 region
+-------------------------+

delete from my_docs where array_size(doc:Regions)=1;   -- Delete the record with 1 region details
+------------------------+
| number of rows deleted |
|------------------------|
|                      1 |
+------------------------+

select array_size(doc:Regions)
from my_docs;
+-------------------------+
| ARRAY_SIZE(DOC:REGIONS) |
|-------------------------|
|                       5 |
+-------------------------+
1 Row(s) produced. Time Elapsed: 1.015s

Using this information, I can write a query to retrieve the Region_Name values from each of the five elements in the Regions array:

select
doc:Regions[0].Region_Name as R0_Name,
doc:Regions[1].Region_Name as R1_Name,
doc:Regions[2].Region_Name as R2_Name,
doc:Regions[3].Region_Name as R3_Name,
doc:Regions[4].Region_Name as R4_Name
from my_docs;

+----------+-----------+---------+----------+---------------+
| R0_NAME  | R1_NAME   | R2_NAME | R3_NAME  | R4_NAME       |
|----------+-----------+---------+----------+---------------|
| "AFRICA" | "AMERICA" | "ASIA"  | "EUROPE" | "MIDDLE EAST" |
+----------+-----------+---------+----------+---------------+

While this certainly works, there are two problems with this approach: first, I want to be able to write the query to return an arbitrary number of rows without having to know the size of the array; and second, I would like the data pivoted
to have five rows instead of five columns. Once again, the flatten() table function comes to the rescue:

select
r.value:Region_Name::string as region_name    -- region_name is cast as string so " is removed
from my_docs
inner join lateral flatten(input =>
doc:Regions) r;

+-------------+
| REGION_NAME |
|-------------|
| AFRICA      |
| AMERICA     |
| ASIA        |
| EUROPE      |
| MIDDLE EAST |
+-------------+

The next step is to move down another layer and retrieve the values from the Nations array, which will require a second call to the flatten() table function:

select
r.value:Region_Name::string as region_name,
r.value:Tot_Region_Sales::decimal as tot_rgn_sales,
n.value:Nation_Name::string as nation_name,
n.value:Tot_Nation_Sales::decimal as tot_ntn_sales
from my_docs
inner join lateral flatten(input =>
doc:Regions) r
inner join lateral flatten(input =>
r.value:Nations) n;

+-------------+---------------+----------------+---------------+
| REGION_NAME | TOT_RGN_SALES | NATION_NAME    | TOT_NTN_SALES |
|-------------+---------------+----------------+---------------|
| AFRICA      |    4239225325 | ALGERIA        |     867701408 |
| AFRICA      |    4239225325 | ETHIOPIA       |     840736934 |
| AFRICA      |    4239225325 | KENYA          |     830403434 |
| AFRICA      |    4239225325 | MOROCCO        |     851082089 |
| AFRICA      |    4239225325 | MOZAMBIQUE     |     849301461 |
| AMERICA     |    4321075685 | ARGENTINA      |     858702152 |
| AMERICA     |    4321075685 | BRAZIL         |     844227360 |
| AMERICA     |    4321075685 | CANADA         |     879554386 |
| AMERICA     |    4321075685 | PERU           |     866428592 |
| AMERICA     |    4321075685 | UNITED STATES  |     872163195 |
| ASIA        |    4378591176 | INDIA          |     867300065 |
| ASIA        |    4378591176 | INDONESIA      |     866176067 |
| ASIA        |    4378591176 | JAPAN          |     867419738 |
| ASIA        |    4378591176 | CHINA          |     901661904 |
| ASIA        |    4378591176 | VIETNAM        |     876033402 |
| EUROPE      |    4391712838 | FRANCE         |     900059400 |
| EUROPE      |    4391712838 | GERMANY        |     884705812 |
| EUROPE      |    4391712838 | ROMANIA        |     880243090 |
| EUROPE      |    4391712838 | RUSSIA         |     862689505 |
| EUROPE      |    4391712838 | UNITED KINGDOM |     864015030 |
| MIDDLE EAST |    4322198235 | EGYPT          |     862118150 |
| MIDDLE EAST |    4322198235 | IRAN           |     876878109 |
| MIDDLE EAST |    4322198235 | IRAQ           |     865003575 |
| MIDDLE EAST |    4322198235 | JORDAN         |     890186225 |
| MIDDLE EAST |    4322198235 | SAUDI ARABIA   |     828012176 |
+-------------+---------------+----------------+---------------+
25 Row(s) produced. Time Elapsed: 0.616s

The first call to flatten() pivots the array of Regions, and the second call pivots the array of Nations inside of each row generated by the first pivot.
Join the Flattened data with other tables

select rgn.r_regionkey,
r.value:Region_Name::string as region_name,
ntn.n_nationkey,
n.value:Nation_Name::string as nation_name
from my_docs
inner join lateral flatten(input => doc:Regions) r
inner join region rgn on
r.value:Region_Name = rgn.r_name
inner join lateral flatten(input => r.value:Nations) n
inner join nation ntn on n.value:Nation_Name = ntn.n_name
order by 1,3;

+-------------+-------------+-------------+----------------+
| R_REGIONKEY | REGION_NAME | N_NATIONKEY | NATION_NAME    |
|-------------+-------------+-------------+----------------|
|           0 | AFRICA      |           0 | ALGERIA        |
|           0 | AFRICA      |           5 | ETHIOPIA       |
|           0 | AFRICA      |          14 | KENYA          |
|           0 | AFRICA      |          15 | MOROCCO        |
|           0 | AFRICA      |          16 | MOZAMBIQUE     |
|           1 | AMERICA     |           1 | ARGENTINA      |
|           1 | AMERICA     |           2 | BRAZIL         |
|           1 | AMERICA     |           3 | CANADA         |
|           1 | AMERICA     |          17 | PERU           |
|           1 | AMERICA     |          24 | UNITED STATES  |
|           2 | ASIA        |           8 | INDIA          |
|           2 | ASIA        |           9 | INDONESIA      |
|           2 | ASIA        |          12 | JAPAN          |
|           2 | ASIA        |          18 | CHINA          |
|           2 | ASIA        |          21 | VIETNAM        |
|           3 | EUROPE      |           6 | FRANCE         |
|           3 | EUROPE      |           7 | GERMANY        |
|           3 | EUROPE      |          19 | ROMANIA        |
|           3 | EUROPE      |          22 | RUSSIA         |
|           3 | EUROPE      |          23 | UNITED KINGDOM |
|           4 | MIDDLE EAST |           4 | EGYPT          |
|           4 | MIDDLE EAST |          10 | IRAN           |
|           4 | MIDDLE EAST |          11 | IRAQ           |
|           4 | MIDDLE EAST |          13 | JORDAN         |
|           4 | MIDDLE EAST |          20 | SAUDI ARABIA   |
+-------------+-------------+-------------+----------------+
25 Row(s) produced. Time Elapsed: 1.099s


























































































second mechanism for querying result set returned by a stored procedure is using table functions. -- check this


























































































































Master Store proc for user
set some session variables -- think about useful ones
alter session set autocommit=FALSE;    -- set autocommit to false for safer side
alter session set lock_timeout=600;    -- set maximum lock wait to 10 minutes useful to resolve deadlocks also

set warehouse auto_suspend = 600 --600 seconds/10 mins or even 5 mins
set auto_resume = TRUE;

alter warehouse current_warehouse() set auto_suspend = 300, auto_resume = TRUE; -- unable to use context functions
alter warehouse compute_wh set auto_suspend = 300, auto_resume = TRUE; 

create a qhist - Query history storeed proc which returns the last n queries that a run - use LAST_QUERY_ID function to form a table and return that.. 
-- Can do binary search based on SELECT LAST_QUERY_ID(1000); - 500, 250, 125, 75, 60, 50, so on until non NULL value is returned then list those queries 

Create a stored proc to find tables in which column is present based on name - pass col name as parameter


select table_name, column_name,
concat(data_type,
case
when data_type = 'TEXT'
then
concat('(',character_maximum_length,
')')
when data_type = 'NUMBER'
then
concat('(',numeric_precision, ',',
numeric_scale,')')
else ''
end) column_def
from columns
where table_schema = 'PUBLIC'
order by table_name,
ordinal_position;



All Describe commands   -- try how to search for properties displayed by desc 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FILE FORMAT
FUNCTION
NETWORK POLICY
PIPE
RESULT
STAGE
STREAM
TABLE
TASK
USER
VIEW

All SHOW commands  -- limit can be used with show statements
~~~~~~~~~~~~~~~~~~~~~~~~~~~~
COLUMNS
DATABASES
FILE FORMATS
FUNCTIONS
GRANTS
GSINSTANCES
LOCKS
NETWORK POLICIES
OBJECTS
PARAMETERS
PIPES
RESOURCE MONITORS
ROLES
SCHEMAS
SEQUENCES
SERVERS
STAGES
STREAMS
TABLES
TASKS
TRANSACTIONS
USER FUNCTIONS
USERS
VIEWS
WAREHOUSES

All ! commands
~~~~~~~~~~~~~~~~~~~~~~~~~~
!abort
!connect
!define
!edit
!exit
!help
!options
!pause
!print
!queries
!quit
!rehash
!result
!set
!source
!spool
!system
!variables



All Current Functions
~~~~~~~~~~~~~~~~~~~~~~~~
CURRENT_CLIENT
CURRENT_DATABASE
CURRENT_DATE
CURRENT_ROLE
CURRENT_SCHEMA
CURRENT_SCHEMAS
CURRENT_SESSION
CURRENT_STATEMENT
CURRENT_TIME
CURRENT_TIMESTAMP
CURRENT_TRANSACTION
CURRENT_USER
CURRENT_VERSION
CURRENT_WAREHOUSE



try later 
set myvar = table((execute immediate 'select * from nation'));   -- To assign result set to a session variable



try later -- insert different datatypes into variant col of table
insert into my_docs 
(doc) 
values 
   (1),
   ('siva'),
   ((select OBJECT_CONSTRUCT('a', 1, 'b', 'BBBB', 'c', NULL))::variant);
   

insert into my_docs  
(OBJECT_CONSTRUCT('a', 1, 'b', 'BBBB', 'c', NULL));

select typeof(
OBJECT_CONSTRUCT('a', 1, 'b', 'BBBB', 'c', NULL));

+---------------------------------------------------+
| TYPEOF(                                           |
| OBJECT_CONSTRUCT('A', 1, 'B', 'BBBB', 'C', NULL)) |
|---------------------------------------------------|
| OBJECT                                            |
+---------------------------------------------------+



Excercise - Chap18




