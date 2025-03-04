/* 
SELECT Statement explained https://youtu.be/082lfHzdTe8
*/
-- Task: retrieve all data from customers
SELECT *
FROM db_sql_tutorial.customers
;

-- Task: retrieve all data from orders
SELECT *
FROM orders
;

-- Task: retrieve only first name and country from customers
SELECT
	first_name,
    country
FROM customers
;

/*SELECT DISTINCT*/
-- Task: list all countries of all customers without duplicates
SELECT DISTINCT
	country
FROM customers
;

/* ORDER Clause */
-- Task: retrieve all data from customers, sort result by score (smallest first)
SELECT *
FROM customers
ORDER BY score ASC
;

-- Task: retrieve all data from customers, sort result by score (highest first)
SELECT *
FROM customers
ORDER BY score DESC
;

-- Task: retrieve all data from customers, sort result by country (alphabetically), THEN score (highest first)
SELECT *
FROM customers
ORDER BY country ASC, score DESC
;

-- Task: retrieve all data from customers, sort result by country (alphabetically), THEN score (highest first) - using positions instead of column names
SELECT *
FROM customers
ORDER BY 4 ASC, 5 DESC
;

/* WHERE Clause - Filtering before grouping */
-- Task: retrieve all data from customers from Germany
SELECT *
FROM customers
WHERE country ='Germany'
;


/* Comparison Operators */
-- Task: find all customers whose score score is greater than 500
SELECT *
FROM customers
WHERE score > 500
;

-- Task: find all customers whose score is less than 500
SELECT *
FROM customers
WHERE score < 500
;

-- Task: find all customers whose score is less than or equal to 500
SELECT *
FROM customers
WHERE score <= 500
;

-- Task: find all customers whose score score is greater than or equal to 500
SELECT *
FROM customers
WHERE score >= 500
;

-- Task: find all non-german customers
SELECT *
FROM customers
WHERE country != 'Germany' # '<>' could also be used instead of '!='
;

/* Logical Operators*/

# AND
-- Task: find all german customers and whose score is less than 400
SELECT *
FROM customers
WHERE country = 'Germany'
AND score < 400
;

# OR
-- Task: find all customers from Germany or whose score is less than 400
SELECT *
FROM customers
WHERE country = 'Germany'
OR score < 400
;

# NOT
-- Task: find all customers whose score is not less than 400
SELECT *
FROM customers
WHERE NOT score < 400 -- 'NOT' comes before the column
;

# BETWEEN
-- Task: find all customers whose score is between 100 & 500
SELECT *
FROM customers
WHERE score BETWEEN 100 AND 500
;

-- Alternative approach 
#Best practice
SELECT *
FROM customers
WHERE score >= 100 AND score <= 500
; # this is used by some developers as they can remember what values are included in the range

# IN - asks if a value is found in the list?
-- Task: find all customers whose ID 1, 2 or 5
SELECT *
FROM customers
WHERE customer_id IN (1,2,5) # brackets are used here
;

-- Alternative approach
#This is not a best practice
SELECT *
FROM customers
WHERE customer_id = 1
OR customer_id = 2
OR customer_id = 5
;

# LIKE
-- It helps search for case sensitive data
/* Percent % acts as a wildcard while Underscore _ is for one specific value */
-- Task: Find names that begin with 'M' = M%
SELECT *
FROM customers
WHERE first_name LIKE 'M%'
;

-- Task: Find names that end with 'n' = %n
SELECT *
FROM customers
WHERE first_name LIKE '%n'
;
-- Task: Find names that contain 'r' = &r%
SELECT *
FROM customers
WHERE first_name LIKE '%r%'
;
-- Task: Find names that contain 'r' at the 3rd position = __r%
SELECT *
FROM customers
WHERE first_name LIKE '__r%'
;

/*
SQL Aliases could be used to rename tables or column when working with multiple tables
*/
-- rename is only in script and results, it doesn't affect the main table or column
SELECT
	c.customer_id AS cid
FROM customers AS c
;

/* SQL INNER JOIN */
SELECT
	c.customer_id,
    c.first_name,
    o.order_id,
    o.quantity
FROM customers AS c
INNER JOIN orders AS o
ON c.customer_id = o.customer_id
;

/* SQL LEFT JOIN */
SELECT
	c.customer_id,
    c.first_name,
    o.order_id,
    o.quantity
FROM customers AS c
LEFT JOIN orders AS o
ON c.customer_id = o.customer_id
;

/* SQL RIGHT JOIN */
SELECT
	c.customer_id,
    c.first_name,
    o.order_id,
    o.quantity
FROM customers AS c
RIGHT JOIN orders AS o
ON c.customer_id = o.customer_id
;

/* SQL FULL JOIN */ -- Avoid using it as it is harmful could cause performance problems, slow query time especially when working with big tables
-- FULL JOIN doesn't work in MySQL but there's a work around
SELECT
	c.customer_id,
    c.first_name,
    o.order_id,
    o.quantity
FROM customers AS c
LEFT JOIN orders AS o
ON c.customer_id = o.customer_id
UNION -- We add UNION to the join two statements above and below
SELECT
	c.customer_id,
    c.first_name,
    o.order_id,
    o.quantity
FROM customers AS c
RIGHT JOIN orders AS o
ON c.customer_id = o.customer_id
;

/* UNION */ -- This call is used to combine rows from two tables and removes any duplicates
-- Pay attention to the number of columns as well as order. Also ensure that the data types of the columns match exactly or else an error wil ensue
SELECT 
	c.first_name,
    c.last_name,
    c.country
FROM customers AS c
UNION
SELECT
	e.first_name,
    e.last_name,
    e.emp_country
FROM employees AS e
;

/* UNION ALL */ -- This call is used to combine rows from two tables without removing any duplicates
SELECT 
	c.first_name,
    c.last_name,
    c.country
FROM customers AS c
UNION ALL
SELECT
	e.first_name,
    e.last_name,
    e.emp_country
FROM employees AS e
;

/* SQL Aggregate Functions */
-- COUNT()
SELECT COUNT(*) AS total_customers
FROM customers; #counting with the asterisk counts every available row

SELECT COUNT(score) AS total_customers
FROM customers; #counting by column counts every row with a value but ignores the nulls

-- SUM()
SELECT SUM(quantity) AS total_quan
FROM orders
;

-- AVG()
SELECT AVG(score) AS avg_score
FROM customers
;

-- MAX()
SELECT MAX(score) AS max_score
FROM customers
;

#Latest order date
SELECT MAX(order_date) AS max_order_date
FROM orders
;

-- MIN()
SELECT MIN(score) AS min_score
FROM customers
;

#Earliest Order date
SELECT MIN(order_date) AS min_order_date
FROM orders
;

/* SQL String Funtions */
-- We can use these to clean data

-- CONCAT()
#Task: List all customer names, where the name is a combination of first and last names
SELECT
	CONCAT(first_name, ' ', last_name) AS customer_full_name
FROM customers
;

-- LOWER()
#Task: List the first name of all customers in lowercase
SELECT
    LOWER(first_name) AS customer_name_lowercase
FROM customers
;

-- UPPER()
#Task: List the first name of all customers in uppercase
SELECT
	UPPER(first_name) AS customer_name_uppercase
FROM customers
;

-- TRIM(): removes spaces from both left and right sides
-- To remove left spaces we use LTRIM() while RTRIM() removes right white spaces
#Task: List last name of all customers and remove all white spaces in the names
SELECT
	last_name,
    TRIM(last_name) AS clean_last_name
FROM customers
;

-- LENGTH(): gives the number of characters in one string
SELECT
	last_name,
    LENGTH(last_name) AS len_last_name,
    TRIM(last_name) AS clean_last_name,
	LENGTH(TRIM(last_name)) AS len_clean_last_name
FROM customers
;

-- SUBSTRING(column, start, length): this will extract a part of a whole string
#Task: Extract 3 characters from the last name of all customers, starting from 2nd position
SELECT
	last_name,
    SUBSTRING(last_name, 2, 3) AS sub_last_name
FROM customers
;


/* GROUB BY Clause */
-- This clause helps us group rows based on column values
#Task: Find the total number of customers for each country
SELECT
	country,
	COUNT(*) AS total_customers
FROM customers
GROUP BY country
ORDER BY COUNT(*)
;

#Task: Find the highest score of customers for each country
SELECT
	MAX(score) AS max_score,
    country
FROM customers
GROUP BY country
ORDER BY max_score DESC
;

/* HAVING */
#Task: Find the total number of customers for each country and only include countries that have more than 1 customer
SELECT
	COUNT(*) AS total_customers,
    country
FROM customers
GROUP BY country
HAVING total_customers > 1
;

/* SQL Subquery - Using EXISTS & IN */
-- This is a query or a group of queries nested within another query
#Task: Find all orders placed from customers whose score is higher than 500 using the customer ID
SELECT *
FROM orders
WHERE customer_id IN (
	SELECT customer_id
	FROM customers
	WHERE score > 500
); -- Here, subquery is in the IN statement

-- Using EXISTS #This is recommended over using IN to avoid issues with query performance when large tables are in play. However, its writeup is a little more complicated than IN
SELECT *
FROM orders AS o
WHERE EXISTS (
	SELECT 1
    FROM customers AS c
    WHERE c.customer_id = o.customer_id
    AND score > 500
); -- Need more testing here

/* SQL INSERT */
-- DESCRIBE: We use this to get essential info about the makeup of table columns
DESCRIBE customers;

-- Task: Insert new customer Anna Nixon from UK
# Strings need to be in quotes while INT without quotes
INSERT INTO customers
VALUES (DEFAULT, 'Anna', 'Nixon', 'UK', NULL);
# Using DEFAULT and NULL could be cumbersome with a set of large data collection so another option which is Best Practice is to include the columns where we wish to input data and insert those values. See task below:

-- Task: Insert new customer Max Lang
INSERT INTO customers
(first_name, last_name)
VALUES ('Max', 'Lang');

-- Checking table with new additions
SELECT *
FROM customers;

/* UPDATE Statement: Edits values of an already existing row */
-- Task: Edit country of customer_id 7
UPDATE customers
SET country = 'Germany'
WHERE customer_id = 7
;

-- Task: Change the score of customer Anna to 100 and country from UK to USA
UPDATE customers
SET score = 100,
	country = 'USA'
WHERE customer_id = 6
;

/* DELETE Statement */
-- Task: Delete both new customers Anna & Max from our database
DELETE FROM customers
WHERE customer_id IN (6,7)
;

-- Use TRUNCATE instead of DELETE when you wish to delete all rows in a table. This would take less time in SQL whereas DELETE would go by each row which isn't time/resource efficient.

TRUNCATE customers;

/* SQL CREATE table */

-- Task: Create new table called "persons" with 4 columns: ID, person name, birth date and phone
CREATE TABLE db_sql_tutorial.persons (
person_id INT PRIMARY KEY AUTO_INCREMENT,
person_name VARCHAR(50) NOT NULL,
birth_date DATE,
phone VARCHAR(20) NOT NULL UNIQUE
);

-- Checking new table
SELECT *
FROM persons;

-- Table column details
DESCRIBE persons;

-- Task: Alter table by adding a column of email to TABLE 'persons'
ALTER TABLE persons
ADD email VARCHAR(50) NOT NULL
;

-- Delete the new table Perons from database
DROP TABLE persons;