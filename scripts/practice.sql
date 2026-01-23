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
-- Source: DataLemur
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
-- Source: DataLemur
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
-- Source: DataLemur
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
-- Source: DataLemur
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
-- Source: DataLemur
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

-- Challenge 6: Cards Issued Difference
-- Source: DataLemur
-- Solution:
SELECT card_name,
      MAX(issued_amount) - MIN(issued_amount) AS difference
FROM monthly_cards_issued
GROUP BY card_name
ORDER BY MAX(issued_amount) - MIN(issued_amount) DESC

-- Challenge 7: Patient Support Analysis
-- Source: DataLemur
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

-- Challenge 8: User's Third Transaction
-- Source: DataLemur
-- Solution:
WITH cte AS(
SELECT user_id,
       transaction_date,
       spend,
       ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY transaction_date) AS trans_num
FROM transactions
)

SELECT user_id,
       transaction_date, 
       spend
FROM cte 
WHERE trans_num = 3

-- Challenge 9: Pharmacy Analytics
-- Solution: 
SELECT drug,
       (total_sales - cogs) AS total_profit
FROM pharmacy_sales
GROUP BY drug, 
          total_sales,
          cogs
ORDER BY (total_sales - cogs) DESC
LIMIT 3;


-- Challenge 10: Pharmacy Analytics (Part 2)
-- Source: DataLemur
-- Solution:
SELECT
  manufacturer,
  COUNT(drug) AS drug_count,
  ABS(SUM(total_sales - cogs)) AS total_loss
FROM pharmacy_sales
WHERE total_sales - cogs <= 0
GROUP BY manufacturer
ORDER BY total_loss DESC;

-- Challenge 11: Pharmacy Analytics(Part 3)
-- Source: DataLemur
-- Solution:
SELECT manufacturer,
     CONCAT('$', ROUND(SUM(total_sales)/1000000), ' million') AS sales
FROM pharmacy_sales
GROUP BY manufacturer
ORDER BY (SUM(total_sales)/1000000) DESC,
        manufacturer;

-- Challenge 12: Final Account Balance
-- Source: DataLemur
-- Solution:
WITH cte AS(
SELECT account_id,
       SUM(amount) AS amount,
      transaction_type
FROM transactions 
GROUP BY account_id, transaction_type)

SELECT account_id, 
      SUM(amount) FILTER (WHERE transaction_type = 'Deposit') -
      SUM(amount) FILTER (WHERE transaction_type = 'Withdrawal') AS final_balance
FROM cte
GROUP BY account_id

-- Challenge 13: Compressed Mode
-- Source: DataLemur
-- Solution:
SELECT item_count AS mode
FROM items_per_order
WHERE order_occurrences =
      (SELECT MAX(order_occurrences) FROM items_per_order)
ORDER BY order_occurrences ASC

-- Challenge 13: Histogram of Users and Purchases
-- Source: DataLemur(medium)
-- Solution:
With latest AS(
    SELECT MAX(transaction_date) AS transaction_date,
          user_id
    FROM user_transactions
    GROUP BY user_id
)
SELECT
  l.transaction_date,
  l.user_id,
  COUNT(ut.product_id) AS purchase_count
FROM latest l 
JOIN user_transactions ut 
  ON ut.user_id=l.user_id
  AND ut.transaction_date=l.transaction_date
GROUP BY l.transaction_date, l.user_id
ORDER BY l.transaction_date, l. user_id;

/*
Lesson Learned:
1. The initial product count was incorrect because it counted all products instead of only the product on the latest data.
	Thus, I have created cte, so I will be able to calculate the count of the products.
2. The latest date requires MAX()
3. Other (simple) solutions are also possible.
*/

-- Challenge 14: FAANG Stock Min-Max (Part 1)
-- Source: DataLemur(medium)
-- Solution:

WITH cte AS(
SELECT 
    ticker,
    open,
    TO_CHAR(date, 'Mon-YYYY') AS month,
    ROW_NUMBER() OVER (PARTITION BY ticker ORDER BY open DESC) AS rn_highest,
    ROW_NUMBER() OVER (PARTITION BY ticker ORDER BY open ASC) AS rn_lowest
FROM stock_prices
),

cte_high AS(
  SELECT ticker,
          month AS highest_mth,
          open AS highest_open
  FROM cte
  WHERE rn_highest = 1

),

cte_low AS(
  SELECT ticker,
          month AS lowest_mth,
          open AS lowest_open
  FROM cte
  WHERE rn_lowest = 1

)

SELECT h.ticker,
       h.highest_mth, h.highest_open,
       l.lowest_mth,  l.lowest_open
FROM cte_high AS h 
JOIN cte_low AS l 
USING (ticker)
ORDER BY h.ticker


-- Challenge 15: 182 Duplicate Emails
-- Source: Leetcode
-- Solution:

-- Write your PostgreSQL query statement below
with cte AS(
SELECT email,
        COUNT(email) AS count_email
FROM Person
GROUP BY email 
HAVING COUNT(email) > 1)

SELECT email
FROM cte

-- Challenge 15: Sales Analysis III
-- Source: Leetcode
-- Solution:
-- Write your PostgreSQL query statement below
SELECT p.product_id,
       p.product_name
FROM Product AS p
JOIN Sales AS s
ON p.product_id=s.product_id
GROUP BY p.product_id,p.product_name
HAVING MIN(s.sale_date) >= '2019-01-01' AND 
        MAX(s.sale_date) < '2019-03-31'

-- Challenge 15: Not Boring Movie
-- Source: Leetcode
-- Solution:

SELECT *
FROM Cinema
WHERE id % 2 = 1 AND
    description != 'boring'
ORDER BY rating DESC

-- Challenge 16: 
-- Source: Leetcode
-- Solution:
