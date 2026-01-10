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

--- Challenge # 3: Second Day Confirmation 
-- Solution 1:
SELECT  e.user_id
FROM emails AS e 
LEFT JOIN texts AS t 
   ON e.email_id=t.email_id
WHERE signup_action='Confirmed' AND
  date(action_date)-date(signup_date)=1

-- Solution 2: 
SELECT e.user_id
FROM emails 
JOIN text t
	ON e.email_id = t.email.id
GROUP BY e.user_id, e.signup_date::date
HAVING 
	MAX(CASE WHEN t.signup_action = 'Confirmed' AND
		t.action_date::date = e.signup_date::date + 1
		THEN 1 ELSE 0 END) = 1
AND
	MAX(CASE WHEN t.signup_action = 'Confirmed'
	AND t.action_date::date = e.signup_date::date
	THEN 1 ELSE 0 END) = 0;



/*
Lesson Learned:
1. You can use CASE WHEN in HAVING clause
*/

-- Challenge # 4
-- Solution:
SELECT u.city,
      COUNT(order_id) AS total_orders
FROM trades t 
LEFT JOIN users u 
ON t.user_id = u.user_id
WHERE t.status = 'Completed'
GROUP BY u.city
ORDER BY COUNT(order_id)  DESC
LIMIT 3 

-- Challenge # 5
-- Solution:
SELECT 
      EXTRACT (MONTH FROM submit_date) AS mth, 
      product_id,
      ROUND(AVG(stars),2) AS avg_stars
FROM reviews 
GROUP BY product_id, 
        EXTRACT (MONTH FROM submit_date)
ORDER BY EXTRACT (MONTH FROM submit_date) ASC,
        product_id

-- Challenge 5: Cards Issued Difference
-- Solution:
SELECT card_name,
      MAX(issued_amount) - MIN(issued_amount) AS difference
FROM monthly_cards_issued
GROUP BY card_name
ORDER BY MAX(issued_amount) - MIN(issued_amount) DESC

-- Patient Support Analysis
-- Solution:
WITH cte AS(
  SELECT policy_holder_id, 
  COUNT(case_id)
  FROM callers
  GROUP BY policy_holder_id
  HAVING COUNT(case_id) >= 3
)

SELECT COUNT(DISTINCT policy_holder_id) AS policy_holder_count
FROM cte

