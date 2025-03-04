/*
SQL VIEWS
*/
SELECT *
FROM Sales.Orders
WHERE OrderID % 2 = 1
;

/*
USE CASE 1: Central Complex Query Logic
*/

-- Task: Find the total running sales for each month
WITH CTE_Monthly_Sales AS
(
	SELECT
		DATETRUNC(MONTH, OrderDate) AS OrderMonth,
		SUM(Sales) AS TotalSales,
		COUNT(*) AS TotalOrders,
		SUM(Quantity) AS TotalQuantities
	FROM Sales.Orders
	GROUP BY DATETRUNC(MONTH, OrderDate)
)

SELECT
	*,
	SUM(TotalSales) OVER(ORDER BY OrderMonth) AS RunningTotal
FROM CTE_Monthly_Sales
;

-- Now, we create a view to store the query result of the CTE
CREATE VIEW V_Monthly_Summary AS
(
	SELECT
		DATETRUNC(MONTH, OrderDate) AS OrderMonth,
		SUM(Sales) AS TotalSales,
		COUNT(*) AS TotalOrders,
		SUM(Quantity) AS TotalQuantities
	FROM Sales.Orders
	GROUP BY DATETRUNC(MONTH, OrderDate)
)

-- Now we query the View we just created
SELECT *
FROM V_Monthly_Summary

-- To include the proper schema in the View name, we add 'Sales.' just before it.
CREATE VIEW Sales.V_Monthly_Summary AS
(
	SELECT
		DATETRUNC(MONTH, OrderDate) AS OrderMonth,
		SUM(Sales) AS TotalSales,
		COUNT(*) AS TotalOrders,
		SUM(Quantity) AS TotalQuantities
	FROM Sales.Orders
	GROUP BY DATETRUNC(MONTH, OrderDate)
)

-- To delete the first View we created with the default schema 'dbo.', we can use the DDL command DROP
DROP VIEW V_Monthly_Summary

-- To replace the logic within a View we can DROP the table using T-SQL (a programming language within SQL Server) and Create the View again with new query options
IF OBJECT_ID ('Sales.V_Monthly_Summary', 'V' /*V stands for View*/) IS NOT NULL
	DROP VIEW Sales.V_Monthly_Summary;
GO
CREATE VIEW Sales.V_Monthly_Summary AS
(
	SELECT
		DATETRUNC(MONTH, OrderDate) AS OrderMonth,
		SUM(Sales) AS TotalSales,
		COUNT(*) AS TotalOrders
	FROM Sales.Orders
	GROUP BY DATETRUNC(MONTH, OrderDate)
)

-- Now we query the View we just dropped and recreated (updated)
SELECT *
FROM Sales.V_Monthly_Summary
;

/*
USE CASE 2: Hide Complexity
*/

-- Task: Provide a view that combines details from orders, products, customers, and employees.
CREATE VIEW Sales.V_Order_Details AS
(
	SELECT
		o.OrderID,
		o.OrderDate,
		COALESCE(c.FirstName,'') + ' ' + COALESCE(c.LastName,'') AS CustomerName,
		c.Country AS CustomerCountry,
		p.Category,
		p.Product,
		o.Quantity,
		o.Sales,
		COALESCE(e.FirstName,'') + ' ' + COALESCE(e.LastName,'') AS EmployeeName,
		e.Department
	FROM Sales.Orders AS o
	LEFT JOIN Sales.Products AS p
	ON p.ProductID = o.ProductID
	LEFT JOIN Sales.Customers AS c
	ON c.CustomerID = o.CustomerID
	LEFT JOIN Sales.Employees AS e
	ON e.EmployeeID = o.SalesPersonID
)

--
SELECT *
FROM Sales.V_Order_Details


/*
USE CASE 3: Data Security
*/
-- Row-Level Security
-- Task: Provide a View for the EU Sales team that combines details from all tables and excludes data related to the USA
CREATE VIEW Sales.V_Order_Details_EU AS
(
	SELECT
		o.OrderID,
		o.OrderDate,
		COALESCE(c.FirstName,'') + ' ' + COALESCE(c.LastName,'') AS CustomerName,
		c.Country AS CustomerCountry,
		p.Category,
		p.Product,
		o.Quantity,
		o.Sales,
		COALESCE(e.FirstName,'') + ' ' + COALESCE(e.LastName,'') AS EmployeeName,
		e.Department
	FROM Sales.Orders AS o
	LEFT JOIN Sales.Products AS p
	ON p.ProductID = o.ProductID
	LEFT JOIN Sales.Customers AS c
	ON c.CustomerID = o.CustomerID
	LEFT JOIN Sales.Employees AS e
	ON e.EmployeeID = o.SalesPersonID
	WHERE c.Country != 'USA'
)

SELECT *
FROM Sales.V_Order_Details_EU