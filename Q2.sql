/* QUESTION 2: Product Performance
 Identify top 10 products by total revenue in 2024.
Include product name, category, total revenue, total orders.
Sort by revenue descending.*/

SELECT 
    p.product_id,
    p.product_name,
    p.category,
    SUM(oi.line_total) AS total_revenue,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date >= '2024-01-01' 
  AND o.order_date <= '2024-12-31'
GROUP BY p.product_id, p.product_name, p.category
ORDER BY total_revenue DESC
LIMIT 10;