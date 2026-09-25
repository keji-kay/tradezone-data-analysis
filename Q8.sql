/* QUESTION 8: Top Seller Bonus Qualification
Identify top 10 sellers in 2024 by total revenue 
Completed at least 10 orders
Have average customer rating of 4.0 or above
Include total orders, average rating, total revenue.*/

SELECT 
    s.seller_id,
    s.seller_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(AVG(r.rating), 2) AS avg_rating,
    ROUND(SUM(o.total_amount), 2) AS total_revenue
FROM sellers s
JOIN orders o ON s.seller_id = o.seller_id
LEFT JOIN reviews r ON o.order_id = r.order_id
WHERE o.order_date >= '2024-01-01'
  AND o.order_date <= '2024-12-31'
  AND o.order_status != 'Cancelled'
GROUP BY s.seller_id, s.seller_name
HAVING COUNT(DISTINCT o.order_id) >= 10
   AND ROUND(AVG(r.rating), 2) >= 4.0
ORDER BY total_revenue DESC
LIMIT 10;