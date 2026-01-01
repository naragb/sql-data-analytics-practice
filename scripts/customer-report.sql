/*
=========================================================================================
Customer Report 
=========================================================================================

PURPOSE: 
	- This report consolidates key customer metrics and behaviors.

HIGHLIGHTS:
	1. Gathers essential fields 
	2. Segments customers into categories and age groups.
	3. Aggregate customer-level metrics.
=========================================================================================
*/


-- 1. Base Query: Retrieves core columns from tables

CREATE VIEW gold.report_customers AS
WITH base_query AS(
/*
Base Query: Retrieves core columns from tables
*/
SELECT
f.order_number,
f.product_key,
f.order_date,
f.sales_amount,
f.quantity,
c.customer_key,
c.customer_number,
c.first_name AS first_name,
c.last_name AS last_name,
CONCAT(c.first_name, ' ', c.last_name)  AS customer_name,
DATEDIFF(year, c.birthdate, GETDATE()) AS age
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customers AS c
ON c.customer_key = f.customer_key
WHERE order_date IS NOT NULL)

, customer_aggregation AS(
/*
2 Customer Aggregation: Summarizes key metrics at the customer level
*/
SELECT 
customer_key,
customer_number, 
customer_name,
age,
COUNT(DISTINCT order_number) AS total_orders,
SUM(sales_amount) AS total_sales, 
SUM(quantity) AS total_quantity,
COUNT(DISTINCT product_key) AS total_products,
MAX(order_date) AS last_order_date,
DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
FROM base_query
GROUP BY 
	customer_key,
	customer_number, 
	customer_name,
	age
)

SELECT 
	customer_key,
	customer_number, 
	customer_name,
	age,
	CASE WHEN age < 20 THEN 'Under 20'
		 WHEN age between 20 and 29 THEN '20-29'
		 WHEN age between 40 and 49 THEN '40-49'
		 ELSE '50 and above'
		 END AS age_group,
	total_orders,
	total_sales, 
	total_quantity,
	total_products,
	last_order_date,
	lifespan
	FROM customer_aggregation
