/*
1. COUNT() OVER()
*/

-- Find the total number of orders
USE SalesDB

SELECT *
FROM Sales.Orders
;

SELECT
	COUNT(*) TotalOrders
FROM Sales.Orders

-- Find the total number of orders, and provide added details like OrderID and OrderDate
SELECT
	OrderID,
	OrderDate,
	COUNT(*) OVER() TotalOrders
FROM Sales.Orders

-- Find the total number of orders for each customer, and provide added details like OrderID and OrderDate
SELECT
	OrderID,
	OrderDate,
	CustomerID,
	COUNT(*) OVER() TotalOrders,
	COUNT(*) OVER(PARTITION BY CustomerID) OrdersByCustomer
FROM Sales.Orders

-- Find total number of customers, and provide customer details in addition.
SELECT
	*,
	COUNT(*) OVER() NumberofCustomers,
	COUNT(1) OVER() NumberofCustomersOne
FROM Sales.Customers

-- Find the total number of score
SELECT
	*,
	COUNT(score) OVER() NumberofScore
FROM Sales.Customers


-- We can use COUNT() to check for data quality in the case of duplicates
-- Check whether 'Orders' table has duplicate rows
-- First we need to ID the primary key of the table and use that to identify any duplicates
SELECT
	OrderID,
	COUNT(*) OVER (PARTITION BY OrderID) CheckPK
FROM Sales.Orders
/* Result shows no PK duplicates */

-- Check whether 'OrdersArchive' table has duplicate rows
SELECT
	OrderID,
	COUNT(*) OVER (PARTITION BY OrderID) CheckPK
FROM Sales.OrdersArchive
/* Result shows 1 duplicate for OrderID '4' and 2 duplicates for OrderID '6' */

-- Using subquery to isolate duplicate OrderID
SELECT *
FROM (
	SELECT
		OrderID,
		COUNT(*) OVER (PARTITION BY OrderID) CheckPK
	FROM Sales.OrdersArchive)t
WHERE CheckPK > 1

/*
2. SUM() OVER()
*/

-- Find the total sales across all orders and the total sales for each product, additionally provide details such as OrderID and OrderDate.
SELECT
	OrderID,
	OrderDate,
	ProductID,
	Sales,
	SUM(Sales) OVER () TotalSales,
	SUM(Sales) OVER (PARTITION BY ProductID) SalesByProduct
FROM Sales.Orders

-- Comparison Use Case
-- Part-to-Whole Analysis
-- Find the % contribution of each product's sale to the total sales
SELECT
	OrderID,
	ProductID,
	Sales,
	SUM(Sales) OVER () TotalSales,
	ROUND(CAST(Sales AS Float) / SUM(Sales) OVER () * 100, 2) PercentContribution -- Dividing an INT by another INT will produce 0 in SQL so we use this function -> CAST(column_in_INT AS Float) will convert an INT column to a column with decimals. Then we can use ROUND() to round up the results as desired
FROM Sales.Orders

/*
3. AVG() OVER()
*/

-- Find the average sales across all orders and the average sales for each product, additionally provide details such as OrderID and OrderDate.
SELECT
	OrderID,
	OrderDate,
	ProductID,
	Sales,
	AVG(Sales) OVER () AvgSales,
	AVG(Sales) OVER (PARTITION BY ProductID) AvgSalesByProduct
FROM Sales.Orders

-- Find the average score of customers, additionally provide details such as Customer ID and Last Name
SELECT
	CustomerID,
	LastName,
	Score,
	COALESCE(Score,0) TrueCustomerScore,
	AVG(Score) OVER () AvgScore, -- Here SQL is dividing by the number of not-NULL rows
	AVG(COALESCE(Score, 0)) OVER() TrueAvgScore -- Here SQL dividing by the total number of rows in the dataset
FROM Sales.Customers

-- Find all orders where sales are higher than the average sales across all orders
-- Using a CTE (a subquery is also an option)
WITH SalesAverage AS (
	SELECT
		OrderID,
		ProductID,
		Sales,
		AVG(Sales) OVER() AvgSales
	FROM Sales.Orders)
SELECT *
FROM SalesAverage
WHERE Sales > AvgSales

/*
4. MIN() OVER()
5. MAX() OVER()
*/

-- Find the highest & lowest sales across all orders and the highest & lowest sales for each product, additionally provide details such as OrderID and OrderDate.
SELECT
	OrderID,
	OrderDate,
	ProductID
	Sales,
	MIN(Sales) OVER () MinSales,
	MAX(Sales) OVER () MaxSales,
	MIN(Sales) OVER (PARTITION BY ProductID) MinSalesByProduct,
	MAX(Sales) OVER (PARTITION BY ProductID) MaxSalesByProduct
FROM Sales.Orders

-- Show the employees with the highest salary
WITH MaxSal AS (
	SELECT
		*,
		MAX(Salary) OVER(ORDER BY Salary DESC) HighestSalary
	FROM Sales.Employees)

SELECT *
FROM MaxSal
WHERE Salary = HighestSalary

-- Calculate the deviation of each sale both from the maximum and minimum sales amounts
SELECT
	OrderID,
	OrderDate,
	Sales,
	MAX(Sales) OVER () MaxSales,
	MAX(Sales) OVER () - Sales DevFromMax,
	MIN(Sales) OVER () MinSales,
	Sales - MIN(Sales) OVER () DevFromMin
FROM Sales.Orders

/*
5. Running & Rolling Total
*/

-- Calculate the moving average of sales for each product over time
SELECT
	OrderID,
	OrderDate,
	ProductID,
	Sales,
	AVG(Sales) OVER (PARTITION BY ProductID ORDER BY OrderDate) MovingAverage
FROM Sales.Orders

-- Calculate the moving average of sales for each product over time, including only the next order
SELECT
	OrderID,
	OrderDate,
	ProductID,
	Sales,
	AVG(Sales) OVER (PARTITION BY ProductID ORDER BY OrderDate) MovingAverage,
	AVG(Sales) OVER (PARTITION BY ProductID ORDER BY OrderDate ROWS BETWEEN CURRENT ROW AND 1 FOLLOWING) RollingAverage
FROM Sales.Orders