/*
===================================================
	SQL Exploratory Data Analysis (EDA) Project
===================================================

Script Description:

This SQL script is part of an exploratory data analysis (EDA) project designed to analyze and extract insights from a data warehouse.
It focuses on querying and exploring data stored in a structured format, specifically within the Gold Layer of the Medallion Architecture.
The script covers a wide range of analytical tasks, including database exploration, dimensional analysis, date exploration, key business metrics, magnitude analysis, and ranking analysis.

Steps Overview:
	1. Database Exploration
	2. Dimensions Exploration
	3. Date Exploration
	4. Measures Exploration (Big Numbers)
	5. Magnitude Analysis
	6. Ranking Analysis (Top N - Bottom N)

*/

-- Select Database of Interest
USE DataWarehouse

/*
-------------------------------------
	Step 1 - Database Exploration
-------------------------------------
*/

-- Task 1:
-- Show content of all Objects (Tables) in the database
SELECT 
	TABLE_CATALOG,
	TABLE_SCHEMA,
	TABLE_NAME,
	TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES
;


-- Task 2:
-- Show content of all Columns (Fields) in the database
SELECT
	TABLE_CATALOG,
	TABLE_SCHEMA,
	TABLE_NAME,
	COLUMN_NAME,
	DATA_TYPE,
	CHARACTER_MAXIMUM_LENGTH,
	IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
-- WHERE TABLE_NAME = 'dim_customers' OR 'dim_products' OR 'fact_sales'
;


/*
-------------------------------------
	Step 2 - Dimensions Exploration
-------------------------------------
*/

-- Task 3:
-- Show all unique countries of origin of customers
SELECT DISTINCT
	country
FROM gold.dim_customers
ORDER BY country
;


-- Task 4:
-- Show all unique categories, subcategories, product lines, and products
SELECT DISTINCT
	category,
	subcategory,
	product_line,
	product_name
FROM gold.dim_products
ORDER BY 1,2,3,4
;


/*
-------------------------------------
	Step 3 - Date Exploration
-------------------------------------
*/

-- Task 5:
-- Determine the first and last order date and the total duration in months and years
SELECT
	MIN(order_date) AS first_order_date,
	MAX(order_date) AS last_order_date,
	DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS orders_month_range,
	DATEDIFF(YEAR, MIN(order_date), MAX(order_date)) AS orders_year_range
FROM gold.fact_sales
;


-- Task 6:
-- Find the youngest and oldest customer based on birthdate
SELECT
	MIN(date_of_birth) AS oldest_date_of_birth,
	DATEDIFF(YEAR, MIN(date_of_birth), GETDATE()) AS oldest_age,
	MAX(date_of_birth) AS latest_date_of_birth,
	DATEDIFF(YEAR, MAX(date_of_birth), GETDATE()) AS youngest_age
FROM gold.dim_customers
;


-- Task 7:
-- Find the oldest and latest product
SELECT
	MIN(start_date) AS date_oldest_product,
	MAX(start_date) AS date_latest_product
FROM gold.dim_products
;


/*
-------------------------------------
	Step 4 - Measures Exploration (Big Numbers)
-------------------------------------
*/

-- Task 8:
-- Find the total sales
SELECT
	SUM(sales_amount) AS total_sales
FROM gold.fact_sales
;


-- Task 9:
-- Find how many items were sold
SELECT
	SUM(quantity) AS total_items_sold
FROM gold.fact_sales
;


-- Task 10:
-- Find the average selling price
SELECT
	AVG(price) AS average_price
FROM gold.fact_sales
;


-- Task 11:
-- Find the total number of unique orders
SELECT
	COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales
;


-- Task 12:
-- Find the total number of products ordered
SELECT
	COUNT(product_key) AS total_products_ordered
FROM gold.fact_sales
;


-- Task 13:
-- Find the total number of products
SELECT
	COUNT(product_name) AS total_products
FROM gold.dim_products
;


-- Task 14:
-- Find the total number of customers
SELECT
	COUNT(customer_id) AS total_customers
FROM gold.dim_customers
;


-- Task 15:
-- Find the total number of customers that have placed an order
SELECT
	COUNT(DISTINCT customer_key) AS customers_one_or_more_orders
FROM gold.fact_sales
;


-- Task 16:
-- Generate a Report that shows all key metrics of the business
SELECT
	'Total Products' AS measure_name,
	COUNT(product_name) AS measure_value
FROM gold.dim_products
UNION ALL
SELECT
	'Total Customers',
	COUNT(customer_id)
FROM gold.dim_customers
UNION ALL
SELECT
	'Total Orders',
	COUNT(DISTINCT order_number)
FROM gold.fact_sales
UNION ALL
SELECT
	'Total Products Ordered',
	COUNT(product_key)
FROM gold.fact_sales
UNION ALL
SELECT
	'Total Quantity',
	SUM(quantity)
FROM gold.fact_sales
UNION ALL
SELECT
	'Average Price',
	AVG(price)
FROM gold.fact_sales
UNION ALL
SELECT 
	'Total Revenue',
	SUM(sales_amount)
FROM gold.fact_sales
;

/*
-------------------------------------
	Step 5 - Magnitude Analysis
-------------------------------------
*/


-- Task 17:
-- Find total customers by country
SELECT
	country,
	COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY country
ORDER BY total_customers DESC
;


-- Task 18:
-- Find total customers by gender
SELECT
	gender,
	COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY gender
ORDER BY total_customers DESC
;


-- Task 19:
-- Find total customers by marital status
SELECT
	marital_status,
	COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY marital_status
ORDER BY total_customers DESC
;


-- Task 20:
-- Find total products by category
SELECT
	category,
	COUNT(product_key) AS total_products
FROM gold.dim_products
GROUP BY category
ORDER BY total_products DESC
;


-- Task 21:
-- What is the average cost in each category?
SELECT
	category,
	AVG(cost) AS average_cost
FROM gold.dim_products
GROUP BY category
ORDER BY average_cost DESC
;


-- Task 22:
-- What is the total revenue generated for each category?
SELECT
	p.category,
	SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p
	ON p.product_key = f.product_key
GROUP BY p.category
ORDER BY total_revenue DESC
;


-- Task 23:
-- Do customers who are married bring in the most revenue on average?
SELECT
	c.marital_status,
	AVG(f.sales_amount) AS total_revenue
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customers AS c
	ON c.customer_key = f.customer_key
GROUP BY c.marital_status
ORDER BY total_revenue DESC
;


-- Task 24:
-- What is the total revenue generated by each customer?
SELECT
	c.customer_key,
	c.first_name,
	c.last_name,
	SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customers AS c
	ON c.customer_key = f.customer_key
GROUP BY
	c.customer_key,
	c.first_name,
	c.last_name
ORDER BY total_revenue DESC
;


-- Task 25:
-- What is the distribution of sold items across countries?
SELECT
	c.country,
	SUM(f.quantity) AS total_items_sold
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customers AS c
	ON c.customer_key = f.customer_key
GROUP BY c.country
ORDER BY total_items_sold DESC
;


-- Task 26:
-- Which countries make the most purchase on average?
SELECT
	c.country,
	AVG(f.sales_amount) AS average_purchase_made
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customers AS c
	ON c.customer_key = f.customer_key
GROUP BY c.country
ORDER BY average_purchase_made DESC
;


/*
-------------------------------------
	Step 6 - Ranking Analysis (Top N - Bottom N)
-------------------------------------
*/

-- Task 27:
-- Which 5 products Generating the Highest Revenue?
	-- Simple Rank
SELECT TOP 5
	p.product_name,
	SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p
	ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue DESC
;


	-- Complex but Flexibly Ranking Using Window Functions
WITH ranked_products AS (
	SELECT
		p.product_name AS product_name,
		SUM(f.sales_amount) AS total_revenue,
		RANK() OVER(ORDER BY SUM(f.sales_amount) DESC) AS ranking
	FROM gold.fact_sales AS f
	LEFT JOIN gold.dim_products AS p
		ON p.product_key = f.product_key
	GROUP BY p.product_name
)
SELECT *
FROM ranked_products
WHERE ranking <= 5
;


-- Task 28:
-- What are the 5 worst-performing products in terms of sales?
SELECT TOP 5
	p.product_name,
	SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p
	ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue
;


-- Task 29:
-- What are the 5 best-preforming products in terms of revenue by Married and Single customers?
SELECT *
FROM (
	SELECT
		c.marital_status,
		p.product_name,
		SUM(f.sales_amount) AS total_revenue,
		RANK() OVER(PARTITION BY c.marital_status ORDER BY SUM(f.sales_amount) DESC) AS ranking
	FROM gold.fact_sales AS f
	LEFT JOIN gold.dim_customers AS c
		ON c.customer_key = f.customer_key
	LEFT JOIN gold.dim_products AS p
		ON p.product_key = f.product_key
	GROUP BY
		c.marital_status,
		p.product_name
) AS best_performing_products
WHERE ranking <= 5
;


-- Task 30:
-- Find the top 10 customers who have generated the highest revenue
SELECT TOP 10
	c.customer_key,
	c.first_name,
	c.last_name,
	SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customers AS c
	ON c.customer_key = f.customer_key
GROUP BY
	c.customer_key,
	c.first_name,
	c.last_name
ORDER BY total_revenue DESC
;


-- Task 31:
-- The 3 customers with the fewest orders placed
SELECT TOP 3
	c.customer_key,
	c.first_name,
	c.last_name,
	COUNT(DISTINCT f.order_number) AS total_orders
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customers AS c
	ON c.customer_key = f.customer_key
GROUP BY
	c.customer_key,
	c.first_name,
	c.last_name
ORDER BY total_orders
;


-- Task 32:
-- What are the 3 best-preforming products in terms of average revenue by Country?
SELECT *
FROM (
	SELECT
		c.country AS country,
		p.subcategory AS subcategory,
		AVG(f.sales_amount) AS average_revenue,
		ROW_NUMBER() OVER(PARTITION BY c.country ORDER BY AVG(f.sales_amount) DESC) AS ranking
	FROM gold.fact_sales AS f
	LEFT JOIN gold.dim_customers AS c
		ON c.customer_key = f.customer_key
	LEFT JOIN gold.dim_products AS p
		ON p.product_key = f.product_key
	GROUP BY
		c.country,
		p.subcategory
) AS best_performing_subcategory
WHERE ranking <= 3
ORDER BY country, average_revenue DESC
;


-- Task 33:
-- Worst 3 performing products by total revenue by Country
SELECT *
FROM (
	SELECT
		c.country AS country,
		p.product_name AS product_name,
		SUM(f.sales_amount) AS total_revenue,
		RANK() OVER(PARTITION BY c.country ORDER BY SUM(f.sales_amount)) AS ranking
	FROM gold.fact_sales AS f
	LEFT JOIN gold.dim_customers AS c
		ON c.customer_key = f.customer_key
	LEFT JOIN gold.dim_products AS p
		ON p.product_key = f.product_key
	GROUP BY
		c.country,
		p.product_name
) AS worst_performing_products
WHERE ranking <= 3
ORDER BY country, total_revenue
;