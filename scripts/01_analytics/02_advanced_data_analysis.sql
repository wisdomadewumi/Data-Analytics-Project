/*
===================================================
	SQL Advanced Data Analytics Project
===================================================
*/

-- Select Database of Interest
USE DataWarehouse

/*
-------------------------------------
	Step 1 - Change-Over-Time Analysis  (Trends)
-------------------------------------
*/

-- Task 1: Analyze sales performance over time
-- Changes over indivdual months
SELECT
	DATETRUNC(MONTH, order_date) AS monthly_orders,
	SUM(sales_amount) AS total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(MONTH, order_date)
ORDER BY DATETRUNC(MONTH, order_date)
;


-- Trend over separate years
SELECT
	YEAR(order_date) AS yearly_orders,
	SUM(sales_amount) AS total_sales,
	AVG(sales_amount) AS average_sales,
	COUNT(DISTINCT customer_key) AS total_customers
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date)
;


-- Trend over grouped months to assess seasonal patterns
SELECT
	MONTH(order_date) AS grouped_monthly_orders,
	SUM(sales_amount) AS total_sales,
	AVG(sales_amount) AS average_sales,
	COUNT(DISTINCT customer_key) AS total_customers
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY MONTH(order_date)
ORDER BY MONTH(order_date)
;


-- Trend of New Products over the years
SELECT
	YEAR(start_date) AS year_recent_products,
	COUNT(product_name) AS products_introduced
FROM gold.dim_products
GROUP BY YEAR(start_date)
ORDER BY YEAR(start_date)
;

/*
-------------------------------------
	Step 2 - Cumulative Analysis
-------------------------------------
*/

-- Task 2: 
-- Calculate the total sales per month and the running total of sales over time
-- Find the moving price average
SELECT
	monthly_orders,
	total_sales,
	SUM(total_sales) OVER (ORDER BY monthly_orders) AS running_total_sales,
	average_price,
	AVG(average_price) OVER (ORDER BY monthly_orders) AS moving_average_price
FROM (
	SELECT
		DATETRUNC(MONTH, order_date) AS monthly_orders,
		SUM(sales_amount) AS total_sales,
		AVG(price) AS average_price
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATETRUNC(MONTH, order_date)
) t
;


/*
-------------------------------------
	Step 3 - Performance Analysis
-------------------------------------
*/

-- Task 3: Analyze the yearly performance of products by comparing their sales to both the average sales performance of the product and the previous year's sales
WITH yearly_product_sales AS (
	SELECT
		YEAR(f.order_date) AS order_year,
		p.product_name,
		SUM(f.sales_amount) AS current_sales
	FROM gold.fact_sales AS f
	LEFT JOIN gold.dim_products AS p
		ON f.product_key = p.product_key
	WHERE f.order_date IS NOT NULL
	GROUP BY YEAR(f.order_date), p.product_name
)
SELECT
	order_year,
	product_name,
	current_sales,
	AVG(current_sales) OVER (PARTITION BY product_name) AS average_sales,
	current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_average,
	CASE
		WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Average'
		WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Average'
		ELSE 'Average'
	END AS average_delta,
	LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) AS previous_year_sales,
	current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) AS diff_previous_year,
	CASE
		WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
		WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
		ELSE 'No Change'
	END AS previous_year_delta
FROM yearly_product_sales
ORDER BY product_name, order_year
;


/*
-------------------------------------
	Step 4 - Part-To-Whole (Proportion)
-------------------------------------
*/

-- Task 4: Which categories contribute the most to overall sales?
WITH category_sales AS (
	SELECT
		p.category,
		SUM(f.sales_amount) AS total_sales,
		SUM(SUM(f.sales_amount)) OVER() AS overall_sales
	FROM gold.fact_sales AS f
	LEFT JOIN gold.dim_products AS p
		ON f.product_key = p.product_key
	GROUP BY p.category
)
SELECT
	category,
	total_sales,
	overall_sales,
	CONCAT(ROUND(100 * CAST(total_sales AS FLOAT) / overall_sales, 2), '%') AS percent_of_total
FROM category_sales
ORDER BY total_sales DESC
;


-- Task 5: Which countries contribute the most to overall orders?
WITH country_orders AS (
	SELECT
		c.country,
		COUNT(f.order_number) AS total_orders,
		SUM(COUNT(f.order_number)) OVER() AS overall_orders
	FROM gold.fact_sales AS f
	LEFT JOIN gold.dim_customers AS c
		ON c.customer_key = f.customer_key
	GROUP BY c.country
)
SELECT
	country,
	total_orders,
	overall_orders,
	CONCAT(ROUND(100 * CAST(total_orders AS FLOAT) / overall_orders, 2), '%') AS percent_of_total
FROM country_orders
ORDER BY total_orders DESC
;


-- Task 6: What subcategories are popular amongst customers?
WITH subcategory_customers AS (
	SELECT
		p.subcategory,
		COUNT(DISTINCT f.customer_key) AS total_customers,
		SUM(COUNT(DISTINCT f.customer_key)) OVER() AS overall_customers
	FROM gold.fact_sales AS f
	LEFT JOIN gold.dim_products AS p
		ON f.product_key = p.product_key
	GROUP BY p.subcategory
)
SELECT
	subcategory,
	total_customers,
	overall_customers,
	CONCAT(ROUND(100 * CAST(total_customers AS FLOAT) / overall_customers, 2), '%') AS percent_of_total
FROM subcategory_customers
ORDER BY total_customers DESC
;


-- Task 7: Percentage of customers above age 55
SELECT
	age_group,
	COUNT(age) AS customer_count,
	SUM(COUNT(age)) OVER () AS total_customers,
	CONCAT(ROUND(100 * CAST(COUNT(age) AS FLOAT) / SUM(COUNT(age)) OVER (), 2), '%') AS customer_percent
FROM (
	SELECT
		customer_key,
		first_name,
		last_name,
		DATEDIFF(YEAR, date_of_birth, GETDATE()) AS age,
		CASE
			WHEN DATEDIFF(YEAR, date_of_birth, GETDATE()) > 55 THEN 'Above 55'
			ELSE 'Under 55'
		END AS age_group
	FROM gold.dim_customers
) t
GROUP BY age_group
;


/*
-------------------------------------
	Step 5 - Data Segmentation
-------------------------------------
*/


-- Task 8: Segment products into cost ranges and count how many products fall into each segment
SELECT
	cost_range,
	COUNT(product_name) AS product_count
FROM (
	SELECT
		product_key,
		product_name,
		cost,
		CASE
			WHEN cost < 100 THEN 'Below $100'
			WHEN cost BETWEEN 100 AND 500 THEN '$100 - $500'
			WHEN cost BETWEEN 500 AND 1000 THEN '$500 - $1000'
			ELSE 'Above $1000'
		END AS cost_range
	FROM gold.dim_products
) t
GROUP BY cost_range
ORDER BY product_count DESC
;


/*
-- Task 9: Group customers into three segments based on their spending behavior:
	- VIP: Customers with at least 12 months of history and spending more than €5,000.
	- Regular: Customers with at least 12 months of history but spending €5,000 or less.
	- New: Customers with a lifespan less than 12 months.
And find the total number of customers by each group
*/
WITH customer_spending AS (
	SELECT
		c.customer_key,
		SUM(f.sales_amount) AS total_spent,
		MIN(f.order_date) AS first_order,
		MAX(f.order_date) AS last_order,
		DATEDIFF(MONTH, MIN(f.order_date), MAX(f.order_date)) AS months_of_history	
	FROM gold.fact_sales AS f
	LEFT JOIN gold.dim_customers AS c
		ON c.customer_key = f.customer_key
	GROUP BY c.customer_key
)
, customers_segmented AS (
	SELECT
	customer_key,
		CASE
			WHEN months_of_history >= 12 AND total_spent > 5000 THEN 'VIP'
			WHEN months_of_history >= 12 AND total_spent <= 5000 THEN 'Regular'
			ELSE 'New'
		END AS customer_profile
	FROM customer_spending
)

SELECT
	customer_profile,
	COUNT(customer_key) AS customer_count
FROM customers_segmented
GROUP BY customer_profile
ORDER BY customer_count DESC
;
