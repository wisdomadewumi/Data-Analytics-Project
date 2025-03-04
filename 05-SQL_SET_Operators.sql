/*
SET Operators
*/

USE SalesDB

SELECT * -- 8 columns
FROM Sales.Employees

SELECT * -- 5 columns
FROM Sales.Customers

-- Rule 1: ORDER BY can only appear once after the last query. The rest like WHERE, JOIN, GROUP BY and HAVING don't have such issue
SELECT
	FirstName,
	LastName
FROM Sales.Customers
WHERE Country = 'Germany'

UNION

SELECT
	FirstName,
	LastName
FROM Sales.Employees
WHERE Gender = 'M'
ORDER BY FirstName -- ORDER BY can only appear here


-- Rule 2: The number of columns in each query must be the same
SELECT * -- 8 columns
FROM Sales.Employees

UNION

SELECT * -- 5 columns
FROM Sales.Customers


-- Rule 3: Data types of columns in each query must match
SELECT
	CustomerID,
	LastName
FROM Sales.Customers

UNION

SELECT
	FirstName,
	LastName
FROM Sales.Employees


-- Rule 4: Order of columns must be the same
SELECT
	CustomerID,
	LastName
FROM Sales.Customers

UNION

SELECT
	LastName,
	EmployeeID
FROM Sales.Employees

-- Rule 5: Column names will bear the alias of the columns in the very 1st query. Any aliases in subsequent queries will not count.
SELECT
	CustomerID AS All_IDs,
	LastName
FROM Sales.Customers

UNION

SELECT
	EmployeeID,
	LastName
FROM Sales.Employees


-- Rule 6: Even if all previous rules are met, you may still get inaccurate results

/*
1. UNION: 
*/

-- Task: Combine the data from employees and customers into one table
SELECT
	FirstName,
	LastName
FROM Sales.Customers

UNION

SELECT
	FirstName,
	LastName
FROM Sales.Employees

-- Task: Combine the data from employees and customers into one table, including duplicates
SELECT
	FirstName,
	LastName
FROM Sales.Customers

UNION ALL

SELECT
	FirstName,
	LastName
FROM Sales.Employees


-- Task: Find employees who are NOT also customers
SELECT
	FirstName,
	LastName
FROM Sales.Employees

EXCEPT

SELECT
	FirstName,
	LastName
FROM Sales.Customers


-- Task: Find customers who are NOT also employees, we need to be certain of the query order based on the question
SELECT
	FirstName,
	LastName
FROM Sales.Customers

EXCEPT

SELECT
	FirstName,
	LastName
FROM Sales.Employees


-- Task: Find employees who are also customers
SELECT
	FirstName,
	LastName
FROM Sales.Employees

INTERSECT

SELECT
	FirstName,
	LastName
FROM Sales.Customers


-- Task: Orders are stored in separate tables ('Orders' and 'OrdersArchive'). Combine all orders into one report without duplicates
SELECT
	'Orders' AS SourceTable
	,[OrderID]
	,[ProductID]
	,[CustomerID]
	,[SalesPersonID]
	,[OrderDate]
	,[ShipDate]
	,[OrderStatus]
	,[ShipAddress]
	,[BillAddress]
	,[Quantity]
	,[Sales]
	,[CreationTime]
FROM Sales.Orders

UNION

SELECT
	'OrdersArchive' AS SourceTable
	,[OrderID]
	,[ProductID]
	,[CustomerID]
	,[SalesPersonID]
	,[OrderDate]
	,[ShipDate]
	,[OrderStatus]
	,[ShipAddress]
	,[BillAddress]
	,[Quantity]
	,[Sales]
	,[CreationTime]
FROM Sales.OrdersArchive
ORDER BY OrderID
