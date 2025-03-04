USE SalesDB
SELECT *
FROM Sales.Customers
/*
SQL NULL Functions
*/

/*
1. Using ISNULL or COALESCE to handle nulls
*/

-- Find the average scores for customers
SELECT
	AVG(Score) avg_score,
	AVG(COALESCE(Score, 0)) avg_score_no_null
FROM Sales.Customers

-- Task: Display the full name of customers in a single field by merging their first and last names. Add 10 bonus points to each customer's score.
SELECT
	CustomerID,
	CONCAT(FirstName, ' ', LastName) AS FullName,
	Score,
	Score +10 AS TenBonus,
	COALESCE(Score, 0) AS Score2,
	COALESCE(Score,0) +10 AS TenBonus2
FROM Sales.Customers

--Task: Sort the customers from lowest to highest scores with nulls appearing last
SELECT
	CustomerID,
	Score
FROM Sales.Customers
ORDER BY Score

-- Method: Use a flag system with CASE statement
SELECT
	CustomerID,
	Score
FROM Sales.Customers
ORDER BY CASE WHEN Score IS NULL THEN 1 ELSE 0 END, Score -- By using this CASE statement, we can push the null values down the list then sort the score on the first sorting

SELECT
	CustomerID,
	Score,
	NULLIF (Score, 500)
FROM Sales.Customers

/*
3. NULLIF - takes two arguments and returns a NULL if both arguments are equal
*/

-- Find the sales price for each order by dividing sales by quantity
SELECT
	OrderID,
	Quantity,
	Sales,
	Sales / NULLIF(Quantity,0) AS SalesPrice -- Using NULLIF because a record in quantity show zero
FROM Sales.Orders

/*
4. IS NULL or IS NOT NULL
*/

-- Identify the customers who have no scores
SELECT
	*
FROM Sales.Customers
WHERE Score IS NULL

-- Show a list of customers who have scores
SELECT
	*
FROM Sales.Customers
WHERE Score IS NOT NULL

-- Task: List all details of customers who have not placed any orders
SELECT
	c.*,
	o.OrderID
FROM Sales.Customers c
LEFT JOIN Sales.Orders o
ON c.CustomerID = o.CustomerID
WHERE o.CustomerID IS NULL -- This line will fetch all customers who haven't placed an order


/*
Difference between NULL, Empty String & Blank space
*/

WITH Orders AS (
SELECT 1 Id, 'A' Category UNION
SELECT 2, NULL UNION --NULL value: nothing, valueless
SELECT 3, '' UNION --Empty string: value with 0 character
SELECT 4, '  ' --Blank space: string value with 1 space character
)

SELECT
	*,
	TRIM(Category) Policy1,
	NULLIF(TRIM(Category), '') Policy2,
	COALESCE(NULLIF(TRIM(Category), ''), 'unknown') Policy3 -- These policies are what we use to clean data and bring it up to proper standard before analysis
	-- DATALENGTH(Category) CategoryLen -- We can use this function to figure out the number of characters within a record
FROM Orders