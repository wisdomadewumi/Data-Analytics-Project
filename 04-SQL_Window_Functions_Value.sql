USE SalesDB

SELECT *
FROM Sales.Orders

/*
1. LAG() Value Function
*/

-- Task: Analyse the Month-over-Month (MoM) performance by finding the percentage change in sales between the current and previous months
WITH t AS (
SELECT
	MONTH(OrderDate) Monat,
	SUM(Sales) CurrentMonthSales,
	LAG(SUM(Sales)) OVER (ORDER BY MONTH(OrderDate)) PrevMonthSales,
	CAST(SUM(Sales) - LAG(SUM(Sales)) OVER (ORDER BY MONTH(OrderDate)) AS Float) MonthDiff
FROM Sales.Orders
GROUP BY MONTH(OrderDate)
)
SELECT
	CASE
		WHEN Monat = 1 THEN 'January'
		WHEN Monat = 2 THEN 'February'
		WHEN Monat = 3 THEN 'March'
	END Month,
	CurrentMonthSales,
	PrevMonthSales,
	MonthDiff,
	CONCAT(ROUND(MonthDiff / PrevMonthSales * 100, 2), '%') PercentChange
FROM t

/*
2. LEAD() Value Function
*/

-- Customer Retention Analysis
-- Task: Analyze customer loyalty by ranking customers based on the average number of days between orders.
WITH cte_orders AS (SELECT
	OrderID,
	CustomerID,
	OrderDate,
	LEAD(OrderDate) OVER (PARTITION BY CustomerID ORDER BY OrderDate) NextOrderDate,
	DATEDIFF(DAY, OrderDate, LEAD(OrderDate) OVER (PARTITION BY CustomerID ORDER BY OrderDate)) NumDays
FROM Sales.Orders)

SELECT
	CustomerID,
	AVG(NumDays) AvgNumDays,
	RANK() OVER (ORDER BY COALESCE(AVG(NumDays), 9999)) CustRank
FROM cte_orders
GROUP BY CustomerID


/*
3. FIRST_VALUE() Value Function
*/

-- Task 1: Find the Lowest and Highest sales for each product
-- Task 2: Find the difference in sales between the current and lowest sales

SELECT
	OrderID,
	ProductID,
	Sales,
	FIRST_VALUE(Sales) OVER (PARTITION BY ProductID ORDER BY Sales DESC) HighestSale, -- Way 1 to solve task
	FIRST_VALUE(Sales) OVER (PARTITION BY ProductID ORDER BY Sales) LowestSale, -- Way 2 to solve task
	--LAST_VALUE(Sales) OVER (PARTITION BY ProductID ORDER BY Sales DESC
	--RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) LowestSale2, -- Way 1 to solve task
	--LAST_VALUE(Sales) OVER (PARTITION BY ProductID ORDER BY Sales
	--RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) HighestSale2, -- Way 2 to solve task
	--MIN(Sales) OVER (PARTITION BY ProductID) LowestSale3, -- Way 3 to solve task
	--MAX(Sales) OVER (PARTITION BY ProductID) HighestSale3 -- Way 3 to solve task
	Sales - FIRST_VALUE(Sales) OVER (PARTITION BY ProductID ORDER BY Sales) SalesDeltaFromMin
FROM Sales.Orders