USE SalesDB

/*
Subqueries
*/

-- Categories of Subqueries
-- 1. Result types
-- 1.1 Scalar
SELECT
	AVG(Sales)
FROM Sales.Orders

-- 1.2 Row
SELECT
	OrderID
FROM Sales.Orders

-- 1.3 Table
SELECT
	OrderID,
	OrderDate,
	Quantity,
	Sales
FROM Sales.Orders
;

-- 2. Location | Clauses
-- 2.1 FROM
-- Task: Find the products that have a price higher than the average price of all products
SELECT
	*
FROM ( -- FROM Subquery
	SELECT
		ProductID,
		Product,
		Price,
		AVG(Price) OVER() AvgPrice
	FROM Sales.Products
) AS t
WHERE Price > AvgPrice


-- Task: Rank Customers based on their total amount of sales
SELECT
	*,
	RANK() OVER(ORDER BY TotalSpent DESC) RankTotalSpent
FROM(
	SELECT
		CustomerID,
		SUM(Sales) TotalSpent
	FROM Sales.Orders
	GROUP BY CustomerID
) AS t


-- 2.2 SELECT: It will only accept scalar subqueries (single values)
-- Task: Show the product IDs, product names, prices, and the total number of orders
SELECT
	ProductID,
	Product,
	Price,
	(SELECT	COUNT(*) FROM Sales.Orders) AS TotalOrders
FROM Sales.Products


-- 2.3 JOIN
-- Task: Show all customer details and find the total orders of each customer
SELECT
	c.*,
	o.TotalOrders
FROM Sales.Customers AS c
LEFT JOIN ( -- Subquery
	SELECT
		CustomerID,
		COUNT(*) TotalOrders
	FROM Sales.Orders
	GROUP BY CustomerID) AS o
ON o.CustomerID = c.CustomerID


-- 2.4 WHERE
-- 2.4.1 Comparison Operators
-- Task: Find the products that have a price higher than the average price of all products
SELECT
	ProductID,
	Product,
	Price
FROM Sales.Products
WHERE Price > (SELECT AVG(Price) AS Avg FROM Sales.Products)

-- 2.4 WHERE
-- 2.4.2 Logical Operator: IN
-- Task: Show the details of orders made by customers in Germany
SELECT
	*
FROM Sales.Orders
WHERE CustomerID IN (-- Subquery
					SELECT
						CustomerID
					FROM Sales.Customers
					WHERE Country = 'Germany')
;

-- 2.4.3 Logical Operator: NOT IN
-- Task: Show the details of orders made by customers not from Germany
SELECT
	*
FROM Sales.Orders
WHERE CustomerID NOT IN (/* We add a NOT IN here to complete the task or... */
					-- Subquery
					SELECT
						CustomerID
					FROM Sales.Customers
					WHERE Country = /* we could also place a NOT EQUAL TO here '!=' */ 'Germany')
;

-- 2.4 WHERE
-- 2.4.4 Logical Operator: ANY
-- Task: Find female employees whose salaries are greater than the salaries of any male employee
SELECT
	EmployeeID,
	FirstName,
	Gender,
	Salary
FROM Sales.Employees
WHERE Gender = 'F'
AND Salary >ANY (SELECT Salary FROM Sales.Employees WHERE Gender = 'M')
;

-- 2.4 WHERE
-- 2.4.5 Logical Operator: ALL
-- Task: Find female employees whose salaries are greater than the salaries of all male employees
SELECT
	EmployeeID,
	FirstName,
	Gender,
	Salary
FROM Sales.Employees
WHERE Gender = 'F'
AND Salary >ALL (SELECT Salary FROM Sales.Employees WHERE Gender = 'M')
;




-- 3. Dependency
-- 3.1 Non-Correlated Subquery: The subquery is independent from the main query. All the previous categories we've executed fall under this umbrella.
-- 3.2 Correlated Subquery: The subquery relies on values from the Main Query.
-- Task: Show all customer details and find the total orders of each customer
SELECT
	*,
	(SELECT	COUNT(*) FROM Sales.Orders AS o WHERE o.CustomerID = c.CustomerID) AS TotalOrders
FROM Sales.Customers AS c

-- 3.2.1 Logical Operator: EXISTS
-- Task: Show the details of orders made by customers in Germany
SELECT
	*
FROM Sales.Orders AS o
WHERE EXISTS (SELECT 1
			  FROM Sales.Customers AS c
			  WHERE c.CustomerID = o.CustomerID /* We cannot run this query by itself because this 'o.CustomerID' column is from the main query */
			  AND Country = 'Germany'
			  )
;