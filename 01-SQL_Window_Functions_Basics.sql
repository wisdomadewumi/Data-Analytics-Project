/* SQL Window Functions - Basics (beyond GROUP BY function) */

-- Use the SalesDB database
USE SalesDB
;

-- Task: Find the total sales across all orders
-- Checking the table Orders
SELECT *
FROM Sales.Orders

SELECT
	Sales
FROM Sales.Orders

-- Using Aggregate function SUM(), TotalSales = 380
SELECT
	SUM(Sales) TotalSales
FROM Sales.Orders


-- Task: Find the total sales for each product
SELECT
	ProductID,
	SUM(Sales) TotalSales
FROM Sales.Orders
GROUP BY ProductID
-- We have 4 rows and not 10 rows because we have 4 products. The number of rows in the output is defined by the dimension.


-- Task: Find the total sales for each product and additionally provide details such as OrderID and OrderDate
/*
Due to the limitation of GROUP BY, we cannot get the extra details when the extra columns aren't in the SELECT statement. So Window functions can intervene here.
*/
SELECT
	OrderID,
	OrderDate,
	ProductID,
	SUM(Sales) OVER() TotalSales --OVER() tells SQL that we are using Window Functions
FROM Sales.Orders
-- We have 10 rows because we have 10 orders. Granularity doesn't change. Also, we get a result even though not all listed columns are included in the OVER() function.

-- Adding PARTITION BY, the equivalent of GROUP BY but for WINDOW Functions. This clause divides the result set into groups/windows based on columns
SELECT
	OrderID,
	OrderDate,
	ProductID,
	SUM(Sales) OVER(PARTITION BY ProductID) TotalSalesByProduct
FROM Sales.Orders


-- Task: Find the total sales across all orders and additionally provide details such as OrderID and OrderDate
SELECT
	OrderID,
	OrderDate,
	SUM(Sales) OVER() TotalSales --This task doesn't require a PARTITION BY so we leave th OVER() function empty
FROM Sales.Orders


-- Task: Find the total sales for each product and additionally provide details such as OrderID and OrderDate
-- This task will require a PARTITION Clause
SELECT
	OrderID,
	OrderDate,
	ProductID,
	SUM(Sales) OVER(PARTITION BY ProductID) TotalSales
FROM Sales.Orders
-- Result shows the data divided into 4 windows based on ProductID (101, 102, 104 and 105)


-- Task: Find the total sales across all orders, for each product and additionally provide details such as OrderID and OrderDate
SELECT
	OrderID,
	OrderDate,
	ProductID,
	Sales,
	SUM(Sales) OVER(PARTITION BY ProductID) SalesByProduct,
	SUM(Sales) OVER() TotalSales
	-- Window functions allow for varying detail levels of granularity
FROM Sales.Orders


-- Task: Find the total sales across all orders, for each product, for combination of product & orderstatus and additionally provide details such as OrderID and OrderDate
SELECT
	OrderID,
	OrderDate,
	ProductID,
	OrderStatus,
	Sales,
	SUM(Sales) OVER(PARTITION BY ProductID, OrderStatus) SalesByProductAndStatus, -- Result shows 6 window groups for this function
	SUM(Sales) OVER(PARTITION BY ProductID) SalesByProduct,
	SUM(Sales) OVER() TotalSales
FROM Sales.Orders


-- Task: Rank each order based on their sales from highest to lowest and additionally provide details such as OrderID and OrderDate
SELECT
	OrderID,
	OrderDate,
	Sales,
	RANK() OVER(ORDER BY Sales DESC) RankSales
FROM Sales.Orders


-- Exercise: Looking at Frame Clauses
SELECT
	OrderID,
	OrderDate,
	OrderStatus,
	Sales,
	SUM(Sales) OVER(PARTITION BY OrderStatus ORDER BY OrderDate ROWS BETWEEN CURRENT ROW AND 2 FOLLOWING) MovingTotalSales
FROM Sales.Orders


SELECT
	OrderID,
	OrderDate,
	OrderStatus,
	Sales,
	SUM(Sales) OVER(PARTITION BY OrderStatus ORDER BY OrderDate ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) MovingTotalSales -- FRAME Clause result won't change if "...ROWS BETWEEN 2 PRECEDING AND CURRENT ROW" became "...ROWS 2 PRECEDING". In this case, the CURRENT ROW is not compulsory in the Higher boundary position Mind you: This only works for the Lower boundary, errors will display if the Higher boundary is called.
FROM Sales.Orders

-- An alternative COMPACT FRAME OF THE QUERY ABOVE
SELECT
	OrderID,
	OrderDate,
	OrderStatus,
	Sales,
	SUM(Sales) OVER(PARTITION BY OrderStatus ORDER BY OrderDate ROWS UNBOUNDED PRECEDING) MovingTotalSales
FROM Sales.Orders


-- Task: Rank Customers based on their total sales
-- Remember: GROUP BY can be used with Window Functions if the same columns are used.
SELECT
	CustomerID,
	SUM(Sales) TotalSales,
	RANK() OVER(ORDER BY SUM(Sales) /* Same column as in line 137 */ DESC) CustomerRank -- 2nd Step: Add Window Function RANK()
FROM Sales.Orders
GROUP BY CustomerID -- 1st Step: Add GROUP BY