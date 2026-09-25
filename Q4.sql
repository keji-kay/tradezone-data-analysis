/*QUESTION 4: Quarterly Revenue Trends
Compare quarterly revenue across 2023 and 2024.
Calculate total revenue, average order value, total orders.
Identify which quarter showed strongest growth 2023 to 2024.*/

SELECT 
    EXTRACT(YEAR FROM order_date) AS year,
    EXTRACT(QUARTER FROM order_date) AS quarter,
    COUNT(order_id) AS total_orders,
    ROUND(SUM(total_amount), 2) AS total_revenue,
    ROUND(AVG(total_amount), 2) AS avg_order_value
FROM orders
WHERE order_status != 'Cancelled'
GROUP BY year, quarter
ORDER BY year, quarter;