/*
============================================================
SQL Practice
============================================================

Note:
	The dataset for this script not available.

 Date:
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

