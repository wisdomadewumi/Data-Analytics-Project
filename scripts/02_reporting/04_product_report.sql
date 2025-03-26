/*
-------------------------------------
	Step 7 - Build Product Report
-------------------------------------
Purpose:
    - This report consolidates key product metrics and behaviors.

Highlights:
    1. Gathers essential fields such as product name, category, subcategory, and cost.
    2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
    3. Aggregates product-level metrics:
       - total orders
       - total sales
       - total quantity sold
       - total customers (unique)
       - lifespan (in months)
    4. Calculates valuable KPIs:
       - recency (months since last sale)
       - average order revenue (AOR)
       - average monthly revenue
-------------------------------------
*/
IF OBJECT_ID ('gold.report_products', 'V') IS NOT NULL
	DROP VIEW gold.report_products;
GO

CREATE VIEW gold.report_products AS

WITH base_data AS (
-- Gather main columns from table
	SELECT
		f.customer_key,
		f.order_date,
		f.order_number,
		f.product_key,
		f.quantity,
		f.sales_amount,
		p.category,
		p.subcategory,
		p.product_number,
		p.product_name,
		p.cost
	FROM gold.fact_sales AS f
	LEFT JOIN gold.dim_products AS p
		ON f.product_key = p.product_key
	WHERE f.order_date IS NOT NULL
)
, product_aggregated_metrics AS (
-- Aggregate product-level metrics
	SELECT
		product_key,
		product_name,		
		category,
		subcategory,
		cost,
		MAX(order_date) AS last_sale_date,
		DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS months_of_availability,		
		COUNT(DISTINCT order_number) AS total_orders,
		SUM(sales_amount) AS total_sales,
		SUM(quantity) AS total_quantity,
		COUNT(DISTINCT customer_key) AS total_customers,
		ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)), 2) AS average_selling_price
	FROM base_data
	GROUP BY
		product_key,
		product_name,		
		category,
		subcategory,
		cost
)
SELECT
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	last_sale_date,
	-- Calculate how long since last order was placed
	DATEDIFF(MONTH, last_sale_date, GETDATE()) AS recency_in_months,
	-- Segment products by revenue into: High-Performers, Mid-Range, or Low-Performers
	CASE
		WHEN total_sales > 100000 THEN 'High-Performer'
		WHEN total_sales BETWEEN 10000 AND 100000 THEN 'Mid-Range'
		ELSE 'Low-Performer'
	END AS product_behaviour,
	months_of_availability,
	total_customers,
	total_orders,
	average_selling_price,
	total_quantity,
	CONCAT('$', total_sales) AS total_sales,

	-- Calculate average order revenue
	CONCAT('$', CASE
		WHEN total_orders = 0 THEN 0
		ELSE total_sales / total_orders
	END) AS average_order_revenue,

	-- Calculate average monthly revenue
	CONCAT('$', CASE
		WHEN months_of_availability = 0 THEN total_sales
		ELSE total_sales / months_of_availability
	END) AS average_monthly_revenue

FROM product_aggregated_metrics
;



-- Overall Report query
SELECT * FROM gold.report_products
;