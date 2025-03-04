/*
USE SalesDB

SELECT *
FROM Sales.Orders


Common Table Expressions (CTE) | WITH Clause
*/
;

/*
1. Non-Recursive (Standalone & Nested)
*/
-- Task: Step 1 - Find the total sales per customer (Standalone CTE)
-- CTE query
WITH CTE_Total_Sales AS
(
	SELECT
		CustomerID,
		SUM(Sales) AS TotalSales
	FROM Sales.Orders
	GROUP BY CustomerID
)

-- Task: Step 2 - Find the last order date for each customer (Standalone CTE)
, CTE_Last_Order AS
(
	SELECT
		CustomerID,
		MAX(OrderDate) AS LastOrderDate
	FROM Sales.Orders
	GROUP BY CustomerID
)
-- Task: Step 3 - Rank customers based on total sales per customers (Nested CTE)
, CTE_Customer_Rank AS
(
	SELECT
		CustomerID,
		RANK() OVER(ORDER BY TotalSales DESC) AS CustomerRank
	FROM CTE_Total_Sales
)
-- Task: Step 4 - Segment customers based on their total sales as High, Medium and Low (Nested CTE)
, CTE_Customer_Segments AS
(
	SELECT
		CustomerID,
		CASE
			WHEN TotalSales > 100 THEN 'High'
			WHEN TotalSales > 80 THEN 'Medium'
			ELSE 'Low'
		END AS CustomerSegment
	FROM CTE_Total_Sales
)
-- Main query
SELECT
	c.CustomerID,
	c.FirstName,
	c.LastName,
	cts.TotalSales,
	clo.LastOrderDate,
	ccr.CustomerRank,
	ccs.CustomerSegment
FROM Sales.Customers AS c
LEFT JOIN CTE_Total_Sales AS cts
ON cts.CustomerID = c.CustomerID
LEFT JOIN CTE_Last_Order AS clo
ON clo.CustomerID = c.CustomerID
LEFT JOIN CTE_Customer_Rank AS ccr
ON ccr.CustomerID = c.CustomerID
LEFT JOIN CTE_Customer_Segments AS ccs
ON ccs.CustomerID = c.CustomerID
;

/*
2. Recursive
*/
-- Task: Generate a sequence of numbers from 1 to 20
WITH CTE_Series AS
(
	-- Anchor Query
	SELECT
		1 AS MyNumber

	UNION ALL
	
	SELECT
		MyNumber + 1
	FROM CTE_Series -- CTE table name is self-referenced
	WHERE MyNumber < 1000
)
-- Main query
SELECT *
FROM CTE_Series
OPTION (MAXRECURSION 2000) -- This line allows for a specific number of iterations before the query breaks. SQL default is 100


-- Task: Show the employee hierachy by displaying each employee's level within the organization. Hint: ManagerID shows which employee oversees another employee
WITH CTE_Emp_Hierarchy AS
(
	-- Anchor Query
	SELECT
		EmployeeID,
		FirstName,
		LastName,
		ManagerID,
		1 AS Level
	FROM Sales.Employees
	WHERE ManagerID IS NULL

	UNION ALL
	-- Recursive query
	SELECT
		e.EmployeeID,
		e.FirstName,
		e.LastName,
		e.ManagerID,
		Level + 1
	FROM Sales.Employees AS e
	INNER JOIN CTE_Emp_Hierarchy AS ceh
	ON e.ManagerID = ceh.EmployeeID
)
/*
SELECT *
FROM CTE_Emp_Hierarchy
*/
SELECT
	m.EmployeeID,
	m.FirstName,
	COUNT(e.EmployeeID) AS direct_reports
FROM CTE_Emp_Hierarchy AS m
LEFT JOIN Sales.Employees AS e
ON m.EmployeeID = e.ManagerID
GROUP BY m.EmployeeID, m.FirstName
ORDER BY direct_reports DESC