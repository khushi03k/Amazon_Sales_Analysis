1) Top Customers by Total Spending

Find the top 10 customers who spent the most in total purchases. 


SELECT c.customername, SUM(od.quantity * p.price) AS total_spent
FROM orderdetails od
JOIN orders o ON od.orderid = o.orderid
JOIN customers c ON o.customerid = c.customerid
JOIN products p ON od.productid = p.productid
GROUP BY c.customername
ORDER BY total_spent DESC
LIMIT 10;



2. Monthly Sales Trend

Show total monthly revenue for the current year.

SELECT DATE_TRUNC('month', o.orderdate) AS month, 
       SUM(od.quantity * p.price) AS revenue
FROM orders o
JOIN orderdetails od ON o.orderid = od.orderid
JOIN products p ON od.productid = p.productid
WHERE EXTRACT(YEAR FROM o.orderdate) = EXTRACT(YEAR FROM CURRENT_DATE)
GROUP BY month
ORDER BY month;


3. Most Popular Product Categories

Find top 5 categories by total number of items sold.

SELECT p.category, SUM(od.quantity) AS total_sold
FROM orderdetails od
JOIN products p ON od.productid = p.productid
GROUP BY p.category
ORDER BY total_sold DESC
LIMIT 5;

4. Gender-Based Purchase Behavior

Compare average order value between male and female customers

SELECT c.gender, AVG(od.quantity * p.price) AS avg_order_value
FROM customers c
JOIN orders o ON c.customerid = o.customerid
JOIN orderdetails od ON o.orderid = od.orderid
JOIN products p ON od.productid = p.productid
GROUP BY c.gender;

5. Late Shipments Analysis

Find how many orders were shipped after 5 days of being placed

SELECT COUNT(*) AS late_orders
FROM orders
WHERE (shipdate - orderdate) > 5;



6. Top Profitable Products

Find 10 products that generated the highest total profit.

SELECT p.productname, SUM(od.profit) AS total_profit
FROM orderdetails od
JOIN products p ON od.productid = p.productid
GROUP BY p.productname
ORDER BY total_profit DESC
LIMIT 10;


7. Sales by Country

Total revenue by each country

SELECT c.country, SUM(od.quantity * p.price) AS total_revenue
FROM orders o
JOIN customers c ON o.customerid = c.customerid
JOIN orderdetails od ON o.orderid = od.orderid
JOIN products p ON od.productid = p.productid
GROUP BY c.country
ORDER BY total_revenue DESC;


8. Average Delivery Time by State

Compute the average delivery days per state.

SELECT c.state, AVG(shipdate - orderdate) AS avg_delivery_days
FROM orders o
JOIN customers c ON o.customerid = c.customerid
GROUP BY c.state
ORDER BY avg_delivery_days;


9. Average Product Rating per Category
SELECT p.category, ROUND(AVG(r.rating), 2) AS avg_rating
FROM reviews r
JOIN products p ON r.productid = p.productid
GROUP BY p.category
ORDER BY avg_rating DESC;

10. Customers with More Than 5 Orders
SELECT c.customername, COUNT(o.orderid) AS total_orders
FROM customers c
JOIN orders o ON c.customerid = o.customerid
GROUP BY c.customername
HAVING COUNT(o.orderid) > 5
ORDER BY total_orders DESC;



11. Identify Discount Impact on Profit

Check correlation between discount level and average profit.

SELECT ROUND(discount,2) AS discount_rate, ROUND(AVG(profit),2) AS avg_profit
FROM orderdetails
GROUP BY discount_rate
ORDER BY discount_rate;

12. Top 3 Products per Category by Sales

Using window function:

SELECT category, productname, total_sales
FROM (
  SELECT p.category, p.productname, SUM(od.quantity * p.price) AS total_sales,
         RANK() OVER (PARTITION BY p.category ORDER BY SUM(od.quantity * p.price) DESC) AS rank
  FROM orderdetails od
  JOIN products p ON od.productid = p.productid
  GROUP BY p.category, p.productname
) ranked
WHERE rank <= 3;


12. Top 3 Products per Category by Sales

Using window function:

SELECT category, productname, total_sales
FROM (
  SELECT p.category, p.productname, SUM(od.quantity * p.price) AS total_sales,
         RANK() OVER (PARTITION BY p.category ORDER BY SUM(od.quantity * p.price) DESC) AS rank
  FROM orderdetails od
  JOIN products p ON od.productid = p.productid
  GROUP BY p.category, p.productname
) ranked
WHERE rank <= 3;


13. Year-over-Year Sales Growth
SELECT EXTRACT(YEAR FROM orderdate) AS year,
       SUM(od.quantity * p.price) AS total_sales,
       LAG(SUM(od.quantity * p.price)) OVER (ORDER BY EXTRACT(YEAR FROM orderdate)) AS prev_year_sales,
       ROUND((SUM(od.quantity * p.price) - LAG(SUM(od.quantity * p.price)) OVER (ORDER BY EXTRACT(YEAR FROM orderdate))) 
       / LAG(SUM(od.quantity * p.price)) OVER (ORDER BY EXTRACT(YEAR FROM orderdate)) * 100, 2) AS growth_percent
FROM orders o
JOIN orderdetails od ON o.orderid = od.orderid
JOIN products p ON od.productid = p.productid
GROUP BY year
ORDER BY year;


14. Detect Customers with Declining Purchases

Customers whose last month spending is less than the month before.

WITH monthly_spending AS (
  SELECT c.customerid, DATE_TRUNC('month', o.orderdate) AS month,
         SUM(od.quantity * p.price) AS total_spent
  FROM customers c
  JOIN orders o ON c.customerid = o.customerid
  JOIN orderdetails od ON o.orderid = od.orderid
  JOIN products p ON od.productid = p.productid
  GROUP BY c.customerid, month
)
SELECT customerid
FROM (
  SELECT customerid, month, total_spent,
         LAG(total_spent) OVER (PARTITION BY customerid ORDER BY month) AS prev_month_spent
  FROM monthly_spending
) t
WHERE total_spent < prev_month_spent;


15. Find Most Active Customers by Reviews
SELECT c.customername, COUNT(r.reviewid) AS total_reviews
FROM reviews r
JOIN customers c ON r.customerid = c.customerid
GROUP BY c.customername
ORDER BY total_reviews DESC
LIMIT 10;

16. Products with Rating Below 3 and High Sales
SELECT p.productname, AVG(r.rating) AS avg_rating, SUM(od.quantity) AS total_sales
FROM reviews r
JOIN products p ON r.productid = p.productid
JOIN orderdetails od ON p.productid = od.productid
GROUP BY p.productname
HAVING AVG(r.rating) < 3
ORDER BY total_sales DESC;

17. Peak Sales Hours (Time-Based)

Assuming orderdate has timestamp:

SELECT EXTRACT(HOUR FROM orderdate) AS hour, COUNT(*) AS order_count
FROM orders
GROUP BY hour
ORDER BY order_count DESC;


18. Profit Contribution per Category
SELECT p.category, ROUND(SUM(od.profit),2) AS total_profit,
       ROUND(SUM(od.profit) * 100.0 / SUM(SUM(od.profit)) OVER(), 2) AS percent_contribution
FROM orderdetails od
JOIN products p ON od.productid = p.productid
GROUP BY p.category
ORDER BY percent_contribution DESC;


19. Find Top States with Highest Average Order Value
SELECT c.state, ROUND(AVG(od.quantity * p.price), 2) AS avg_order_value
FROM customers c
JOIN orders o ON c.customerid = o.customerid
JOIN orderdetails od ON o.orderid = od.orderid
JOIN products p ON od.productid = p.productid
GROUP BY c.state
ORDER BY avg_order_value DESC
LIMIT 10;


20. Detect Repeat Purchases of Same Product
SELECT customerid, productid, COUNT(*) AS times_purchased
FROM orderdetails od
JOIN orders o ON od.orderid = o.orderid
GROUP BY customerid, productid
HAVING COUNT(*) > 1
ORDER BY times_purchased DESC;