USE SalesDB

SELECT *
FROM Sales.Orders

/*
INTEGER-BASED Ranking
1. ROW_NUMBER() OVER (ORDER BY column_name)
*/
-- This Window Function assigns a unique integer to each row (not skips nor gaps) and doesn't make an exception if two or more rows share the same value.

-- Rank the orders based on their sales from highest to lowest
SELECT
	OrderID,
	Sales,
	ROW_NUMBER() OVER (ORDER BY Sales DESC) SalesRank_Row
FROM Sales.Orders

/* Use cases */
-- 1. Top N Analysis
-- Task: Find the top highest sales for each product
WITH t AS (
	SELECT
		OrderID,
		ProductID,
		Sales,
		ROW_NUMBER() OVER (PARTITION BY ProductID ORDER BY Sales DESC) TopSalesRankByProduct
	FROM Sales.Orders
)
SELECT *
FROM t
WHERE TopSalesRankByProduct = 1

-- 2. Bottom N Analysis
-- Task: Find the lowest 2 customers by their total sales
WITH low2 AS (
	SELECT
		CustomerID,
		SUM(Sales) TotalSales,
		ROW_NUMBER() OVER (ORDER BY SUM(Sales)) LowRank
	FROM Sales.Orders
	GROUP BY CustomerID
)
SELECT *
FROM low2
WHERE LowRank <= 2



-- Showing results with customer name using Join
WITH low2 AS (
	SELECT
		CustomerID,
		SUM(Sales) TotalSales,
		ROW_NUMBER() OVER (ORDER BY SUM(Sales)) LowRank
	FROM Sales.Orders
	GROUP BY CustomerID
)
SELECT
	l.CustomerID,
	c.FirstName,
	c.LastName,
	l.TotalSales,
	l.LowRank
FROM low2 AS l
INNER JOIN Sales.Customers AS c
ON c.CustomerID = l.CustomerID
WHERE l.LowRank <= 2

-- Task: Assign unique IDs to the rows of 'OrdersArchive' table
SELECT
	ROW_NUMBER() OVER (ORDER BY OrderDate) UniqueID,
	*
FROM Sales.OrdersArchive

-- Task: Identify duplicate rows in the 'OrdersArchive' table and return a clean result without any duplicate
-- First, we partition by the PK and then order by an Attribution that gives us a more up-to-date information like 'CreationTime'
SELECT *
FROM (
	SELECT
		ROW_NUMBER() OVER (PARTITION BY OrderID ORDER BY CreationTime DESC) row_num,
		*
	FROM Sales.OrdersArchive) t
WHERE row_num = 1
-- If it results in any value > than 1 then it is a duplicate
-- So we make a subquery to isolate results where row_num = 1

-- We could make a report to the data quality managers by select row_num > 1
SELECT *
FROM (
	SELECT
		ROW_NUMBER() OVER (PARTITION BY OrderID ORDER BY CreationTime DESC) row_num,
		*
	FROM Sales.OrdersArchive) t
WHERE row_num > 1


/*
INTEGER-BASED Ranking
2. RANK() OVER (ORDER BY column_name)
*/
-- This Window Function assigns a rank to each row and handles ties by giving the same rank to rows that share the same value. This sharing of ranks leaves gaps

-- Rank the orders based on their sales from highest to lowest
SELECT
	OrderID,
	Sales,
	RANK() OVER (ORDER BY Sales DESC) SalesRank_Rank
FROM Sales.Orders


/*
INTEGER-BASED Ranking
3. DENSE_RANK() OVER (ORDER BY column_name)
*/
-- This Window Function assigns a rank to each row and handles ties by giving the same rank to rows that share the same value. Although ranks are shared, none of them is skipped.

-- Rank the orders based on their sales from highest to lowest
SELECT
	OrderID,
	Sales,
	ROW_NUMBER() OVER (ORDER BY Sales DESC) SalesRank_Row,
	RANK()		 OVER (ORDER BY Sales DESC) SalesRank_Rank,
	DENSE_RANK() OVER (ORDER BY Sales DESC) SalesRank_Dense
FROM Sales.Orders


/*
INTEGER-BASED Ranking
4. NTILE(INT) OVER (ORDER BY column_name)
*/

-- This window function divides the rows into a specified number of approx. equal groups or buckets
-- Example:
SELECT
	OrderID,
	Sales,
	NTILE(1) OVER (ORDER BY Sales DESC) OneBucket,
	NTILE(2) OVER (ORDER BY Sales DESC) TwoBuckets,
	NTILE(3) OVER (ORDER BY Sales DESC) ThreeBuckets,
	NTILE(4) OVER (ORDER BY Sales DESC) FourBuckets
FROM Sales.Orders

-- Use Case 1: Data Segmentation
-- Task: Segment all orders into 3 categories: high, medium and low sales

WITH t AS (SELECT
		OrderID,
		Sales,
		NTILE(3) OVER (ORDER BY Sales DESC) Bucket
	FROM Sales.Orders)
SELECT
	*,
	CASE
		WHEN Bucket = 1 THEN 'High Sales'
		WHEN Bucket = 2 THEN 'Medium Sales'
		ELSE 'Low Sales'
	END Category
FROM t

-- Use Case 2: Equalizing Loads
-- Task: In order to export the data, divide the orders into 2 groups
SELECT
	NTILE(2) OVER (ORDER BY OrderID) OrderGroup,
	*
FROM Sales.Orders



/*
Percentage-BASED Ranking
5. CUME_DIST() OVER (ORDER BY column_name)
*/
-- This window function calculates cumulative distribution of data points within a window using position number. It deals with ties in a peculiar way.
SELECT
	OrderID,
	Sales,
	CUME_DIST() OVER (ORDER BY Sales DESC) Cumul_Dist
FROM Sales.Orders

SELECT *
FROM Sales.Products

-- Find the products that fall within the highest 40% of the prices
-- Using CUME_DIST()
SELECT
	*,
	CONCAT(DistRank * 100, '%') DistRankP
FROM (SELECT
	ProductID,
	Product,
	Price,
	CUME_DIST() OVER (ORDER BY Price DESC) DistRank
FROM Sales.Products) t
WHERE DistRank <= 0.4


/*
Percentage-BASED Ranking
6. PERCENT_RANK() OVER (ORDER BY column_name)
*/

-- This window function calculates the relative position of each row in a window.

SELECT
	OrderID,
	Sales,
	PERCENT_RANK() OVER (ORDER BY Sales DESC) Percent_Rank
FROM Sales.Orders

-- Find the products that fall within the highest 40% of the prices
-- Using PERCENT_RANK()
SELECT
	*,
	CONCAT(PercentRank * 100, '%') PercentRankP
FROM (SELECT
	ProductID,
	Product,
	Price,
	PERCENT_RANK() OVER (ORDER BY Price DESC) PercentRank
FROM Sales.Products) t
WHERE PercentRank <= 0.4