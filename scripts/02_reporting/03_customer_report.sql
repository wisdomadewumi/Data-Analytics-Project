/*
-------------------------------------
	Step 6 - Build Customer Report
-------------------------------------
Purpose:
    - This report consolidates key customer metrics and behaviors

Highlights:
    1. Gathers essential fields such as names, ages, and transaction details.
	2. Aggregates customer-level metrics:
	   - total orders
	   - total sales
	   - total quantity purchased
	   - total products
	   - lifespan (in months)
	3. Segments customers into categories (VIP, Regular, New) and age groups.
    4. Calculates valuable KPIs:
	    - recency (months since last order)
		- average order value
		- average monthly spend
-------------------------------------
*/
IF OBJECT_ID ('gold.report_customers', 'V') IS NOT NULL
	DROP VIEW gold.report_customers;
GO

CREATE VIEW gold.report_customers AS

WITH base_data AS (
-- Gather main columns from table
	SELECT
		f.order_date,
		f.order_number,
		f.product_key,
		f.quantity,
		f.sales_amount,
		c.customer_key,
		c.customer_number,
		CONCAT(c.first_name, ' ' , c.last_name) AS customer_name,
		DATEDIFF(YEAR, c.date_of_birth, GETDATE()) AS age
	FROM gold.fact_sales AS f
	LEFT JOIN gold.dim_customers AS c
		ON c.customer_key = f.customer_key
	WHERE f.order_date IS NOT NULL
)
, customer_aggregated_metrics AS (
-- Aggregate customer-level metrics
	SELECT
		customer_key,
		customer_number,
		customer_name,
		age,
		COUNT(DISTINCT order_number) AS total_orders,
		SUM(sales_amount) AS total_sales,
		SUM(quantity) AS total_quantity,
		COUNT(DISTINCT product_key) AS total_products,
		MAX(order_date) AS last_order_date,
		DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS months_of_history
	FROM base_data
	GROUP BY
		customer_key,
		customer_number,
		customer_name,
		age
)
SELECT
	customer_key,
	customer_number,
	customer_name,
	age,
	-- Segment customers into age groups
	CASE
		WHEN age < 20 THEN 'Under 20'
		WHEN age BETWEEN 20 AND 29 THEN '20-29'
		WHEN age BETWEEN 30 AND 39 THEN '30-39'
		WHEN age BETWEEN 40 AND 49 THEN '40-49'
		WHEN age BETWEEN 50 AND 59 THEN '50-59'
		ELSE '60 and above'
	END AS age_group,
	-- Profile customers into categories
	CASE
		WHEN months_of_history >= 12 AND total_sales > 5000 THEN 'VIP'
		WHEN months_of_history >= 12 AND total_sales <= 5000 THEN 'Regular'
		ELSE 'New'
	END AS customer_profile,
	last_order_date,
	-- Calculate how long since last order was placed
	DATEDIFF(MONTH, last_order_date, GETDATE()) AS recency,
	total_orders,
	total_products,
	total_quantity,
	CONCAT('$', total_sales) AS total_sales,
	months_of_history,
	-- Calculate average order value
	CONCAT('$',CASE
		WHEN total_orders = 0 THEN 0
		ELSE total_sales / total_orders
	END) AS average_order_value,
	-- Calculate average monthly spend
	CONCAT('$', CASE
		WHEN months_of_history = 0 THEN total_sales
		ELSE total_sales / months_of_history
	END) AS average_monthly_spend
FROM customer_aggregated_metrics
;



-- Overall Report query
SELECT * FROM gold.report_customers