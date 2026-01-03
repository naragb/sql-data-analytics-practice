/*
============================================================
SQL Practice
============================================================

Note:
	The dataset for this script not available. 
	The purpose of this script is to record the practices on SQL and lessons learned.  

 Start date:
	January 1, 2026

Source:
	Data with Baraa

*/

-- ==========================================================
-- View
-- ===========================================================

-- Find the running total of sales for each month 

-- In PostGres you can use CREATE OR REPLACE VIEW   
-- DROP VIEW V_Monthly_Summary

IF OBJECT_ID ('V_Monthly_Summary', 'V') IS NOT NULL
	DROP VIEW V_Monthly_Summary
GO


CREATE VIEW V_Monthly_Summary AS(
SELECT 
	DATETRUNC(month, OrderDate) OrderMonth,
	SUM(Sales) TotalSales,
	COUNT(OrderID) TotalOrders,
	SUM(Quantity) TotalQuantities
FROM Sales.Orders
GROUP BY DATETRUNC(month, OrderDate)
)

SELECT 
	OrderMonth,
	TotalSales,
	SUM(TotalSales) OVER(ORDER BY OrderMonth) AS RunningTotal
FROM CTE_Monthly_Summary


-- TASK: Provide view that combines details from orderds, products, customers, and employees
CREATE VIEW Sales.V_Order_Details AS(
	SELECT
	o.OrderID,
	o.OrderDate,
	p.Product,
	p.Category,
	COALESCE(c.FirstName, '') + ' ' + COALESCE(c.LastName, '') CustomerName,
	c.Country, CustomerCountry,
	COALESCE(e.FirstName, '') + ' ' + COALESCE(e.LastName, '') CustomerName,
	o.Department,
	o.Sales,
	o.Quantity
	FROM Sales.Orders
	LEFT JOIN Sales.Products
	ON p.ProductID = o.ProductID
	LEFT JOIN Sales.Customers c
	ON c.CustomerID = o.CustomerID
	LEFT JOIN Sales.Employees e
	ON e.EmployeeID  = o.SalesPersonID

)


/*
==============================================================================================================================================================================
Data Lemur: Practice and Lessons 
==============================================================================================================================================================================
*/

-- Challenge #1: Teams Power Users
-- Solution:
SELECT
    sender_id,
    COUNT(message_id) AS message_count
FROM messages
WHERE sent_date >= '2022-08-01' AND
      sent_date < '2022-09-01'
GROUP BY sender_id
ORDER BY COUNT(message_id) DESC
LIMIT 2

/*
Lesson Learned:
1. Consider always to put the date in the following format 'YYYY-MM-DD'. Otherwise, the query might not work.
2. If you are executing ANY calculation in the SELECT query, always think of adding GROUP BY 
*/

-- Challenge #2: 
-- Solution:
SELECT 
    user_id,
    MAX(post_date::DATE) - 
    MIN (post_date::DATE) AS days_between
FROM posts
WHERE post_date >= '01/01/2021' AND
      post_date < '01/01/2022' 
GROUP BY user_id
HAVING (MAX(post_date::DATE) - 
        MIN (post_date::DATE)) != 0
/*
Lesson Learned:
1. If you are asked of subtracting last and first date, consider using MIN() and MAX()
2. Use GROUP BY, which helps to categorize.
*/
