USE SalesDB

SELECT *
FROM Sales.Orders

/*
DATE & TIME Functions
*/

SELECT
	OrderID,
	OrderDate, --Datatype: DATE
	ShipDate, --Datatype: DATE
	CreationTime --Datatype: DATETIME2
FROM Sales.Orders


-- Sources of Dates
SELECT
	OrderID,
	CreationTime, /*Date derived from column in the database*/
	'2028-06-28' HardCoded, /*Constant string value manually entered*/
	GETDATE() Today /*This function returns current date and time at the time query is run*/
FROM Sales.Orders

/*
13 Date & Time Functions
*/

-- 1. DAY()
SELECT
	OrderID,
	CreationTime,
	DAY(CreationTime) AS Day -- Extracts DAY info from DATE
FROM Sales.Orders

-- 2. MONTH()
SELECT
	OrderID,
	CreationTime,
	MONTH(CreationTime) AS Month -- Extracts MONTH info from DATE
FROM Sales.Orders

-- 3. YEAR()
SELECT
	OrderID,
	CreationTime,
	YEAR(CreationTime) AS Year -- Extracts YEAR info from DATE
FROM Sales.Orders

-- 4. DATEPART()
-- We are able to extract much more using this function. It accepts 2 arguments: the part and the column containing a date.
SELECT
	OrderID,
	CreationTime,
	DATEPART(QUARTER, CreationTime) AS Quarter_dp,
	DATEPART(WEEK, CreationTime) AS Week_dp,
	DATEPART(WEEKDAY, CreationTime) AS Weekday_dp,
	DATEPART(YEAR, CreationTime) AS Year_dp,
	DATEPART(MONTH, CreationTime) AS Month_dp,
	DATEPART(DAY, CreationTime) AS Day_dp,
	DATEPART(HOUR, CreationTime) AS Hour_dp,
	DATEPART(MINUTE, CreationTime) AS Minutes_dp,
	YEAR(CreationTime) AS Year, -- Extracts YEAR info from DATE
	MONTH(CreationTime) AS Month, -- Extracts MONTH info from DATE
	DAY(CreationTime) AS Day -- Extracts DAY info from DATE
FROM Sales.Orders


-- 5. DATENAME()
-- This returns the name (string value) of a specific part of a date. It accepts 2 arguments: the part and the column containing a date.
SELECT
	OrderID,
	CreationTime,
	-- DATENAME exmaples
	DATENAME(MONTH, CreationTime) AS Month_dn,
	DATENAME(WEEKDAY, CreationTime) AS Weekday_dn, -- We use WEEKDAY instead of DAY to get actual days of the week
	DATENAME(DAY, CreationTime) AS Day_dn, -- This will return the day but as a string value and not INT same thing for YEAR
	-- DATEPART examples
	DATEPART(QUARTER, CreationTime) AS Quarter_dp,
	DATEPART(WEEK, CreationTime) AS Week_dp,
	DATEPART(WEEKDAY, CreationTime) AS Weekday_dp,
	DATEPART(YEAR, CreationTime) AS Year_dp,
	DATEPART(MONTH, CreationTime) AS Month_dp,
	DATEPART(DAY, CreationTime) AS Day_dp,
	DATEPART(HOUR, CreationTime) AS Hour_dp,
	DATEPART(MINUTE, CreationTime) AS Minutes_dp,
	YEAR(CreationTime) AS Year, -- Extracts YEAR info from DATE
	MONTH(CreationTime) AS Month, -- Extracts MONTH info from DATE
	DAY(CreationTime) AS Day -- Extracts DAY info from DATE
FROM Sales.Orders


-- 6. DATETRUNC()
-- This returns a date to a truncated part. It accepts 2 arguments: the part and the column containing a date. Any detail after the specified part is reset to default.
SELECT
	OrderID,
	CreationTime,
	-- DATETRUNC examples
	DATETRUNC(YEAR, CreationTime) AS Year_dt,
	DATETRUNC(DAY, CreationTime) AS Day_dt,
	DATETRUNC(MINUTE, CreationTime) AS Minute_dt,
	-- DATENAME exmaples
	DATENAME(MONTH, CreationTime) AS Month_dn,
	DATENAME(WEEKDAY, CreationTime) AS Weekday_dn, -- We use WEEKDAY instead of DAY to get actual days of the week
	DATENAME(DAY, CreationTime) AS Day_dn, -- This will return the day but as a string value and not INT same thing for YEAR
	-- DATEPART examples
	DATEPART(QUARTER, CreationTime) AS Quarter_dp,
	DATEPART(WEEK, CreationTime) AS Week_dp,
	DATEPART(WEEKDAY, CreationTime) AS Weekday_dp,
	DATEPART(YEAR, CreationTime) AS Year_dp,
	DATEPART(MONTH, CreationTime) AS Month_dp,
	DATEPART(DAY, CreationTime) AS Day_dp,
	DATEPART(HOUR, CreationTime) AS Hour_dp,
	DATEPART(MINUTE, CreationTime) AS Minutes_dp,
	YEAR(CreationTime) AS Year, -- Extracts YEAR info from DATE
	MONTH(CreationTime) AS Month, -- Extracts MONTH info from DATE
	DAY(CreationTime) AS Day -- Extracts DAY info from DATE
FROM Sales.Orders


-- Where would I need to use DATETRUNC()?
-- Task: How many orders a present per month?
SELECT
	CreationTime, -- Lowest level of aggregation
	COUNT(*)
FROM Sales.Orders
GROUP BY CreationTime
-- Because the granularity level is at the seconds part, we won't be able to solve this using the above query, instead we have,
SELECT
	DATETRUNC(YEAR, CreationTime) AS OrderYear, -- Highest aggregation level
	-- DATETRUNC(MONTH, CreationTime) AS OrderMonth,
	COUNT(*) AS NumOfOrders
FROM Sales.Orders
GROUP BY DATETRUNC(YEAR, CreationTime)


-- 7. EOMONTH()
-- This returns the last day of the month. It accepts 1 argument: the column containing dates.
SELECT
	OrderID,
	CreationTime,
	EOMONTH(CreationTime) AS EndOfMonth,
	-- To get the first day of the month, we can use DATETRUNC()
	CAST(DATETRUNC(MONTH, CreationTime) AS DATE) AS StartOfMonth -- CAST(... AS DATE) changes the format to look like EOMONTH()
FROM Sales.Orders


-- Task: How many orders were placed each year?
SELECT
	YEAR(OrderDate) AS Year,
	COUNT(*) AS NumOfOrders
FROM Sales.Orders
GROUP BY YEAR(OrderDate)

-- Task: How many orders were placed each month?
SELECT
	DATENAME(MONTH,OrderDate) AS Month,
	COUNT(*) AS NumOfOrders
FROM Sales.Orders
GROUP BY DATENAME(MONTH,OrderDate)

-- Task: Show all orders that were placed in the month of February
SELECT
	*
FROM Sales.Orders
WHERE MONTH(OrderDate) = 2



/*
ALL DATE Formats
*/

-- All possible parts can be used in DATEPART SQL Function
SELECT 
    'Year' AS DatePart, 
    DATEPART(year, GETDATE()) AS DatePart_Output,
    DATENAME(year, GETDATE()) AS DateName_Output,
    DATETRUNC(year, GETDATE()) AS DateTrunc_Output
UNION ALL
SELECT 
    'YY', 
    DATEPART(yy, GETDATE()) AS DatePart_Output,
    DATENAME(yy, GETDATE()) AS DateName_Output, 
    DATETRUNC(yy, GETDATE()) AS DateTrunc_Output
UNION ALL
SELECT 
    'YYYY', 
    DATEPART(yyyy, GETDATE()) AS DatePart_Output,
    DATENAME(yyyy, GETDATE()) AS DateName_Output, 
    DATETRUNC(yyyy, GETDATE()) AS DateTrunc_Output
UNION ALL
SELECT 
    'Quarter', 
    DATEPART(quarter, GETDATE()) AS DatePart_Output,
    DATENAME(quarter, GETDATE()) AS DateName_Output, 
    DATETRUNC(quarter, GETDATE()) AS DateTrunc_Output
UNION ALL
SELECT 
    'QQ', 
    DATEPART(qq, GETDATE()) AS DatePart_Output,
    DATENAME(qq, GETDATE()) AS DateName_Output, 
    DATETRUNC(qq, GETDATE()) AS DateTrunc_Output
UNION ALL
SELECT 
    'Q', 
    DATEPART(q, GETDATE()) AS DatePart_Output,
    DATENAME(q, GETDATE()) AS DateName_Output, 
    DATETRUNC(q, GETDATE()) AS DateTrunc_Output
UNION ALL
SELECT 
    'Month', 
    DATEPART(month, GETDATE()) AS DatePart_Output,
    DATENAME(month, GETDATE()) AS DateName_Output, 
    DATETRUNC(month, GETDATE()) AS DateTrunc_Output
UNION ALL
SELECT 
    'MM', 
    DATEPART(mm, GETDATE()) AS DatePart_Output,
    DATENAME(mm, GETDATE()) AS DateName_Output, 
    DATETRUNC(mm, GETDATE()) AS DateTrunc_Output
UNION ALL
SELECT 
    'M', 
    DATEPART(m, GETDATE()) AS DatePart_Output,
    DATENAME(m, GETDATE()) AS DateName_Output, 
    DATETRUNC(m, GETDATE()) AS DateTrunc_Output
UNION ALL
SELECT 
    'DayOfYear', 
    DATEPART(dayofyear, GETDATE()) AS DatePart_Output,
    DATENAME(dayofyear, GETDATE()) AS DateName_Output, 
    DATETRUNC(dayofyear, GETDATE()) AS DateTrunc_Output
UNION ALL
SELECT 
    'DY', 
    DATEPART(dy, GETDATE()) AS DatePart_Output,
    DATENAME(dy, GETDATE()) AS DateName_Output, 
    DATETRUNC(dy, GETDATE()) AS DateTrunc_Output
UNION ALL
SELECT 
    'Y', 
    DATEPART(y, GETDATE()) AS DatePart_Output,
    DATENAME(y, GETDATE()) AS DateName_Output, 
    DATETRUNC(y, GETDATE()) AS DateTrunc_Output
UNION ALL
SELECT 
    'Day', 
    DATEPART(day, GETDATE()) AS DatePart_Output,
    DATENAME(day, GETDATE()) AS DateName_Output, 
    DATETRUNC(day, GETDATE()) AS DateTrunc_Output
UNION ALL
SELECT 
    'DD', 
    DATEPART(dd, GETDATE()) AS DatePart_Output,
    DATENAME(dd, GETDATE()) AS DateName_Output, 
    DATETRUNC(dd, GETDATE()) AS DateTrunc_Output
UNION ALL
SELECT 
    'D', 
    DATEPART(d, GETDATE()) AS DatePart_Output,
    DATENAME(d, GETDATE()) AS DateName_Output, 
    DATETRUNC(d, GETDATE()) AS DateTrunc_Output
UNION ALL
SELECT 
    'Week', 
    DATEPART(week, GETDATE()) AS DatePart_Output,
    DATENAME(week, GETDATE()) AS DateName_Output, 
    DATETRUNC(week, GETDATE()) AS DateTrunc_Output
UNION ALL
SELECT 
    'WK', 
    DATEPART(wk, GETDATE()) AS DatePart_Output,
    DATENAME(wk, GETDATE()) AS DateName_Output, 
    DATETRUNC(wk, GETDATE()) AS DateTrunc_Output
UNION ALL
SELECT 
    'WW', 
    DATEPART(ww, GETDATE()) AS DatePart_Output,
    DATENAME(ww, GETDATE()) AS DateName_Output, 
    DATETRUNC(ww, GETDATE()) AS DateTrunc_Output
UNION ALL
SELECT 
    'Weekday', 
    DATEPART(weekday, GETDATE()) AS DatePart_Output,
    DATENAME(weekday, GETDATE()) AS DateName_Output, 
    NULL AS DateTrunc_Output
UNION ALL
SELECT 
    'DW', 
    DATEPART(dw, GETDATE()) AS DatePart_Output,
    DATENAME(dw, GETDATE()) AS DateName_Output, 
    NULL AS DateTrunc_Output
UNION ALL
SELECT 
    'Hour', 
    DATEPART(hour, GETDATE()) AS DatePart_Output,
    DATENAME(hour, GETDATE()) AS DateName_Output, 
    DATETRUNC(hour, GETDATE()) AS DateTrunc_Output
UNION ALL
SELECT 
    'HH', 
    DATEPART(hh, GETDATE()) AS DatePart_Output,
    DATENAME(hh, GETDATE()) AS DateName_Output, 
    DATETRUNC(hh, GETDATE()) AS DateTrunc_Output
UNION ALL
SELECT 
    'Minute', 
    DATEPART(minute, GETDATE()) AS DatePart_Output,
    DATENAME(minute, GETDATE()) AS DateName_Output, 
    DATETRUNC(minute, GETDATE()) AS DateTrunc_Output
UNION ALL
SELECT 
    'MI', 
    DATEPART(mi, GETDATE()) AS DatePart_Output,
    DATENAME(mi, GETDATE()) AS DateName_Output, 
    DATETRUNC(mi, GETDATE()) AS DateTrunc_Output
UNION ALL
SELECT 
    'N', 
    DATEPART(n, GETDATE()) AS DatePart_Output,
    DATENAME(n, GETDATE()) AS DateName_Output, 
    DATETRUNC(n, GETDATE()) AS DateTrunc_Output
UNION ALL
SELECT 
    'Second', 
    DATEPART(second, GETDATE()) AS DatePart_Output,
    DATENAME(second, GETDATE()) AS DateName_Output, 
    DATETRUNC(second, GETDATE()) AS DateTrunc_Output
UNION ALL
SELECT 
    'SS', 
    DATEPART(ss, GETDATE()) AS DatePart_Output,
    DATENAME(ss, GETDATE()) AS DateName_Output, 
    DATETRUNC(ss, GETDATE()) AS DateTrunc_Output
UNION ALL
SELECT 
    'S', 
    DATEPART(s, GETDATE()) AS DatePart_Output,
    DATENAME(s, GETDATE()) AS DateName_Output, 
    DATETRUNC(s, GETDATE()) AS DateTrunc_Output
UNION ALL
SELECT 
    'Millisecond', 
    DATEPART(millisecond, GETDATE()) AS DatePart_Output,
    DATENAME(millisecond, GETDATE()) AS DateName_Output, 
    DATETRUNC(millisecond, GETDATE()) AS DateTrunc_Output
UNION ALL
SELECT 
    'MS', 
    DATEPART(ms, GETDATE()) AS DatePart_Output,
    DATENAME(ms, GETDATE()) AS DateName_Output, 
    DATETRUNC(ms, GETDATE()) AS DateTrunc_Output
UNION ALL
SELECT 
    'Microsecond', 
    DATEPART(microsecond, GETDATE()) AS DatePart_Output,
    DATENAME(microsecond, GETDATE()) AS DateName_Output, 
    NULL AS DateTrunc_Output
UNION ALL
SELECT 
    'MCS', 
    DATEPART(mcs, GETDATE()) AS DatePart_Output,
    DATENAME(mcs, GETDATE()) AS DateName_Output, 
    NULL AS DateTrunc_Output
UNION ALL
SELECT 
    'Nanosecond', 
    DATEPART(nanosecond, GETDATE()) AS DatePart_Output,
    DATENAME(nanosecond, GETDATE()) AS DateName_Output, 
    NULL AS DateTrunc_Output
UNION ALL
SELECT 
    'NS', 
    DATEPART(ns, GETDATE()) AS DatePart_Output,
    DATENAME(ns, GETDATE()) AS DateName_Output, 
    NULL AS DateTrunc_Output
UNION ALL
SELECT 
    'ISOWeek', 
    DATEPART(iso_week, GETDATE()) AS DatePart_Output,
    DATENAME(iso_week, GETDATE()) AS DateName_Output, 
    DATETRUNC(iso_week, GETDATE()) AS DateTrunc_Output
UNION ALL
SELECT 
    'ISOWK', 
    DATEPART(isowk, GETDATE()) AS DatePart_Output,
    DATENAME(isowk, GETDATE()) AS DateName_Output, 
    DATETRUNC(isowk, GETDATE()) AS DateTrunc_Output
UNION ALL
SELECT 
    'ISOWW', 
    DATEPART(isoww, GETDATE()) AS DatePart_Output,
    DATENAME(isoww, GETDATE()) AS DateName_Output, 
    DATETRUNC(isoww, GETDATE()) AS DateTrunc_Output;


-- 8. FORMAT()
SELECT
	OrderID,
	CreationTime,
	FORMAT(CreationTime, 'dd.MM.yyyy') AS DE_DateFormat,
	FORMAT(CreationTime, 'dd-MM-yyyy') AS EU_DateFormat,
	FORMAT(CreationTime, 'MM-dd-yyyy') AS USA_DateFormat,
	FORMAT(CreationTime, 'dd') AS dd,
	FORMAT(CreationTime, 'ddd') AS ddd,
	FORMAT(CreationTime, 'dddd') AS dddd,
	FORMAT(CreationTime, 'MM') AS MM,
	FORMAT(CreationTime, 'MMM') AS MMM,
	FORMAT(CreationTime, 'MMMM') AS MMMM
FROM Sales.Orders

-- Task: Show CreationTime using the following format: Day Wed Jan Q1 2025 12:34:56 PM
SELECT
	OrderID,
	CreationTime,
	'Day ' + FORMAT(CreationTime, 'ddd MMM') +
	' Q' + DATENAME(QUARTER, CreationTime) + ' ' +
	FORMAT(CreationTime, 'yyyy hh:mm:ss tt') AS StrangeFormat
FROM Sales.Orders


-- USE CASE for FORMAT() in Data Aggregation
SELECT
	FORMAT(OrderDate, 'MMM yy') AS OrderDate,
	COUNT(*) AS Orders
FROM Sales.Orders
GROUP BY FORMAT(OrderDate, 'MMM yy')
;


-- All Time & Date Format Specifiers
SELECT 
    'D' AS FormatType, 
    FORMAT(GETDATE(), 'D') AS FormattedValue,
    'Full date pattern' AS Description
UNION ALL
SELECT 
    'd', 
    FORMAT(GETDATE(), 'd'), 
    'Short date pattern'
UNION ALL
SELECT 
    'dd', 
    FORMAT(GETDATE(), 'dd'), 
    'Day of month with leading zero'
UNION ALL
SELECT 
    'ddd', 
    FORMAT(GETDATE(), 'ddd'), 
    'Abbreviated name of day'
UNION ALL
SELECT 
    'dddd', 
    FORMAT(GETDATE(), 'dddd'), 
    'Full name of day'
UNION ALL
SELECT 
    'M', 
    FORMAT(GETDATE(), 'M'), 
    'Month without leading zero'
UNION ALL
SELECT 
    'MM', 
    FORMAT(GETDATE(), 'MM'), 
    'Month with leading zero'
UNION ALL
SELECT 
    'MMM', 
    FORMAT(GETDATE(), 'MMM'), 
    'Abbreviated name of month'
UNION ALL
SELECT 
    'MMMM', 
    FORMAT(GETDATE(), 'MMMM'), 
    'Full name of month'
UNION ALL
SELECT 
    'yy', 
    FORMAT(GETDATE(), 'yy'), 
    'Two-digit year'
UNION ALL
SELECT 
    'yyyy', 
    FORMAT(GETDATE(), 'yyyy'), 
    'Four-digit year'
UNION ALL
SELECT 
    'hh', 
    FORMAT(GETDATE(), 'hh'), 
    'Hour in 12-hour clock with leading zero'
UNION ALL
SELECT 
    'HH', 
    FORMAT(GETDATE(), 'HH'), 
    'Hour in 24-hour clock with leading zero'
UNION ALL
SELECT 
    'm', 
    FORMAT(GETDATE(), 'm'), 
    'Minutes without leading zero'
UNION ALL
SELECT 
    'mm', 
    FORMAT(GETDATE(), 'mm'), 
    'Minutes with leading zero'
UNION ALL
SELECT 
    's', 
    FORMAT(GETDATE(), 's'), 
    'Seconds without leading zero'
UNION ALL
SELECT 
    'ss', 
    FORMAT(GETDATE(), 'ss'), 
    'Seconds with leading zero'
UNION ALL
SELECT 
    'f', 
    FORMAT(GETDATE(), 'f'), 
    'Tenths of a second'
UNION ALL
SELECT 
    'ff', 
    FORMAT(GETDATE(), 'ff'), 
    'Hundredths of a second'
UNION ALL
SELECT 
    'fff', 
    FORMAT(GETDATE(), 'fff'), 
    'Milliseconds'
UNION ALL
SELECT 
    'T', 
    FORMAT(GETDATE(), 'T'), 
    'Full AM/PM designator'
UNION ALL
SELECT 
    't', 
    FORMAT(GETDATE(), 't'), 
    'Single character AM/PM designator'
UNION ALL
SELECT 
    'tt', 
    FORMAT(GETDATE(), 'tt'), 
    'Two character AM/PM designator'
;

-- All Number Format Specifiers
-- All numeric format specifiers can be used in FORMAT SQL Function	
SELECT 'N' AS FormatType, FORMAT(1234.56, 'N') AS FormattedValue
UNION ALL
SELECT 'P' AS FormatType, FORMAT(1234.56, 'P') AS FormattedValue
UNION ALL
SELECT 'C' AS FormatType, FORMAT(1234.56, 'C') AS FormattedValue
UNION ALL
SELECT 'E' AS FormatType, FORMAT(1234.56, 'E') AS FormattedValue
UNION ALL
SELECT 'F' AS FormatType, FORMAT(1234.56, 'F') AS FormattedValue
UNION ALL
SELECT 'N0' AS FormatType, FORMAT(1234.56, 'N0') AS FormattedValue
UNION ALL
SELECT 'N1' AS FormatType, FORMAT(1234.56, 'N1') AS FormattedValue
UNION ALL
SELECT 'N2' AS FormatType, FORMAT(1234.56, 'N2') AS FormattedValue
UNION ALL
SELECT 'N_de-DE' AS FormatType, FORMAT(1234.56, 'N', 'de-DE') AS FormattedValue
UNION ALL
SELECT 'N_en-US' AS FormatType, FORMAT(1234.56, 'N', 'en-US') AS FormattedValue
;

-- 9. CONVERT()
-- It can be used to CAST and as well FORMAT values from one data type to another
SELECT
	CONVERT(INT, '584') AS [String to INT Convert],
	CONVERT(DATE, '1995-03-26') AS [String to Date Convert],
	CreationTime,
	CONVERT(DATE, CreationTime) AS [DATETIME to Date Convert],
	CONVERT(VARCHAR, CreationTime, 32) AS [USA Standard Date, Style: 32],
	CONVERT(VARCHAR, CreationTime, 34) AS [EUR Standard Date, Style: 34],
	CONVERT(VARCHAR, CreationTime, 104) AS [DE Standard Date, Style: 104]
FROM Sales.Orders
;

-- All culture codes can be used in FORMAT SQL Function	
SELECT 'en-US' AS CultureCode,
       FORMAT(1234567.89, 'N', 'en-US') AS FormattedNumber,
       FORMAT(GETDATE(), 'D', 'en-US') AS FormattedDate
UNION ALL
SELECT 'en-GB' AS CultureCode,
       FORMAT(1234567.89, 'N', 'en-GB') AS FormattedNumber,
       FORMAT(GETDATE(), 'D', 'en-GB') AS FormattedDate
UNION ALL
SELECT 'fr-FR' AS CultureCode,
       FORMAT(1234567.89, 'N', 'fr-FR') AS FormattedNumber,
       FORMAT(GETDATE(), 'D', 'fr-FR') AS FormattedDate
UNION ALL
SELECT 'de-DE' AS CultureCode,
       FORMAT(1234567.89, 'N', 'de-DE') AS FormattedNumber,
       FORMAT(GETDATE(), 'D', 'de-DE') AS FormattedDate
UNION ALL
SELECT 'es-ES' AS CultureCode,
       FORMAT(1234567.89, 'N', 'es-ES') AS FormattedNumber,
       FORMAT(GETDATE(), 'D', 'es-ES') AS FormattedDate
UNION ALL
SELECT 'zh-CN' AS CultureCode,
       FORMAT(1234567.89, 'N', 'zh-CN') AS FormattedNumber,
       FORMAT(GETDATE(), 'D', 'zh-CN') AS FormattedDate
UNION ALL
SELECT 'ja-JP' AS CultureCode,
       FORMAT(1234567.89, 'N', 'ja-JP') AS FormattedNumber,
       FORMAT(GETDATE(), 'D', 'ja-JP') AS FormattedDate
UNION ALL
SELECT 'ko-KR' AS CultureCode,
       FORMAT(1234567.89, 'N', 'ko-KR') AS FormattedNumber,
       FORMAT(GETDATE(), 'D', 'ko-KR') AS FormattedDate
UNION ALL
SELECT 'pt-BR' AS CultureCode,
       FORMAT(1234567.89, 'N', 'pt-BR') AS FormattedNumber,
       FORMAT(GETDATE(), 'D', 'pt-BR') AS FormattedDate
UNION ALL
SELECT 'it-IT' AS CultureCode,
       FORMAT(1234567.89, 'N', 'it-IT') AS FormattedNumber,
       FORMAT(GETDATE(), 'D', 'it-IT') AS FormattedDate
UNION ALL
SELECT 'nl-NL' AS CultureCode,
       FORMAT(1234567.89, 'N', 'nl-NL') AS FormattedNumber,
       FORMAT(GETDATE(), 'D', 'nl-NL') AS FormattedDate
UNION ALL
SELECT 'ru-RU' AS CultureCode,
       FORMAT(1234567.89, 'N', 'ru-RU') AS FormattedNumber,
       FORMAT(GETDATE(), 'D', 'ru-RU') AS FormattedDate
UNION ALL
SELECT 'ar-SA' AS CultureCode,
       FORMAT(1234567.89, 'N', 'ar-SA') AS FormattedNumber,
       FORMAT(GETDATE(), 'D', 'ar-SA') AS FormattedDate
UNION ALL
SELECT 'el-GR' AS CultureCode,
       FORMAT(1234567.89, 'N', 'el-GR') AS FormattedNumber,
       FORMAT(GETDATE(), 'D', 'el-GR') AS FormattedDate
UNION ALL
SELECT 'tr-TR' AS CultureCode,
       FORMAT(1234567.89, 'N', 'tr-TR') AS FormattedNumber,
       FORMAT(GETDATE(), 'D', 'tr-TR') AS FormattedDate
UNION ALL
SELECT 'he-IL' AS CultureCode,
       FORMAT(1234567.89, 'N', 'he-IL') AS FormattedNumber,
       FORMAT(GETDATE(), 'D', 'he-IL') AS FormattedDate
UNION ALL
SELECT 'hi-IN' AS CultureCode,
       FORMAT(1234567.89, 'N', 'hi-IN') AS FormattedNumber,
       FORMAT(GETDATE(), 'D', 'hi-IN') AS FormattedDate
;

-- 10. CAST()
-- converts a value to a different data type. No formats are accepted or can be specified
SELECT
	CAST('786' AS INT) AS [String to INT Cast],
	CAST(785 AS VARCHAR) AS [INT to String Cast],
	CAST('786.02' AS FLOAT) AS [String to FLOAT Cast],
	CAST('2026-05-14' AS DATE) AS [String to Date Cast],
	CAST('2026-05-14' AS DATETIME2) AS [String to DateTime2 Cast],
	CreationTime,
	CAST(CreationTime AS DATE) AS [Datetime2 to Date Cast]
FROM Sales.Orders
;


-- 11. DATEADD()
SELECT
	OrderID,
	OrderDate,
	DATEADD(DAY,-10,OrderDate) AS TenDaysAgo,
	DATEADD(MONTH,3,OrderDate) AS ThreeMonthsLater,
	DATEADD(YEAR,2,OrderDate) AS TwoYearsLater
FROM Sales.Orders
;


-- 12. DATEDIFF()

-- Task: Calculate the age of employees
SELECT
	EmployeeID,
	FirstName,
	LastName,
	BirthDate,
	DATEDIFF(YEAR, BirthDate, GETDATE()) AS Age
FROM Sales.Employees
;


-- Task: Find the average shipping duration in days for each month
SELECT
	FORMAT(OrderDate, 'MMM yy') AS Month,
	AVG(DATEDIFF(DAY, OrderDate, ShipDate)) AS ShipDuration
FROM Sales.Orders
GROUP BY FORMAT(OrderDate, 'MMM yy')
;


-- Time Gap Analysis
-- Task: Find the number of days between each order and previous order
SELECT
	OrderID,
	OrderDate AS CurrentOrderDate,
	COALESCE(LAG(OrderDate) OVER(ORDER BY OrderDate), OrderDate) AS PrevOrderDate,
	DATEDIFF(DAY, COALESCE(LAG(OrderDate) OVER(ORDER BY OrderDate), OrderDate), OrderDate) AS DaysDiff
FROM Sales.Orders
;


-- 13. ISDATE()
-- Checks if a value is a date and returns 1 if TRUE or 0 if FALSE
SELECT
	ISDATE('123') DateCheck1,
	ISDATE('1991-05-30') DateCheck2, -- SQL recognizes this date format
	ISDATE('30-05-1991') DateCheck3, -- SQL won't validate this as a date since it doesn't follow the yyyy-MM-dd format automatically recognized by SQL
	ISDATE('4998') DateCheck4, -- SQL will recognize a 4-digit string as a Year
	ISDATE('05') DateCheck5 -- SQL won't recognize a 2-digit sting as a Month or Day
;

-- When might it be required to use ISDATE()?
SELECT
	-- CAST(OrderDate AS DATE)
	OrderDate,
	ISDATE(OrderDate), -- This helps us find data quality issues with Dates
	CASE WHEN ISDATE(OrderDate) = 1 THEN CAST(OrderDate AS DATE)
		ELSE '9999-01-01' -- We can input an unreal date to handle NULLs
	END NewOrderDate
FROM
(
	SELECT '2025-04-20' AS OrderDate UNION
	SELECT '2025-05-11' UNION
	SELECT '2025-06-14' UNION
	SELECT '2025-07-25' UNION
	SELECT '2025-08'
) t
-- WHERE ISDATE(OrderDate) = 0 -- We can find records with Date data quality issues using this filter