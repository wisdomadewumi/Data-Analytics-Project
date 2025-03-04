USE SalesDB

/*
CASE Statements
*/

SELECT *
FROM Sales.Orders

-- Task: Create report showing total sales for each category: High (sales over 50), Medium (sales 21 to 50), Low (sales 20 or less). Sort the categories from highest to lowest.

SELECT
	Category,
	SUM(Sales) TotalSales
FROM (
	SELECT
		OrderID,
		ProductID,
		Sales,
		CASE
			WHEN Sales > 50 THEN 'High'
			WHEN Sales > 20 THEN 'Medium'
			ELSE 'Low'
		END AS Category
	FROM Sales.Orders
	) t
GROUP BY Category
ORDER BY TotalSales DESC

-- Retrieve employee details with gender displayed as full text
SELECT
	EmployeeID,
	FirstName,
	LastName,
	Department,
	BirthDate,
	CASE
		WHEN Gender = 'F' THEN 'Female'
		WHEN Gender = 'M' THEN 'Male'
		ELSE 'Not Available'
	END AS GenderText,
	Salary,
	ManagerID
FROM Sales.Employees


-- Retrieve customer details with abbreviated country code
-- The query below will allow you to view all possible values before you begin with the CASE statement
SELECT DISTINCT
	Country
FROM Sales.Customers

SELECT
	CustomerID,
	FirstName,
	LastName,
	-- Here's the full form
	CASE
		WHEN Country = 'Germany' THEN 'DE'
		WHEN Country = 'USA'	 THEN 'US'
		ELSE 'Not Available'
	END AS CountryCode,
	-- Example of a quick form
	CASE Country
		WHEN 'Germany' THEN 'DE'
		WHEN 'USA'	   THEN 'US'
		ELSE 'Not Available'
	END AS CountryCode2
FROM Sales.Customers


-- Find the average score of customers and treat NULLs as 0, and provide added deatils such as CustomerID and LastName
SELECT 
	CustomerID,
	LastName,
	Score,
	CASE
		WHEN Score IS NULL THEN 0
		ELSE Score
	END AS ScoreAdj,
	AVG(Score) OVER() AvgScore,
	AVG(
		CASE
			WHEN Score IS NULL THEN 0
			ELSE Score
		END) OVER() AvgScoreAdj
FROM Sales.Customers


-- Count how many times a customer has made an order with sales greater than 30
SELECT
	CustomerID,
	SUM(
		CASE
			WHEN Sales > 30 THEN 1
			ELSE 0
		END
	) AS HighOrders,
	COUNT(*) TotalOrders
FROM Sales.Orders
GROUP BY CustomerID