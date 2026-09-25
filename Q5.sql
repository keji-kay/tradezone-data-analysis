/*QUESTION 5: Customer Spend Segmentation
Segment customers by total spend in 2024 into:
High Spenders: >= ₦100,000
Medium Spenders: ₦50,000 - ₦99,999
Low Spenders: < ₦50,000
 Calculate customer count, average spend, total revenue.*/
WITH customer_spend AS (
    -- Calculate total spend per customer in 2024
    SELECT 
        o.customer_id,
        SUM(o.total_amount) AS total_spend
    FROM orders o
    WHERE o.order_date >= '2024-01-01'
      AND o.order_date <= '2024-12-31'
      AND o.order_status != 'Cancelled'
    GROUP BY o.customer_id
),
segmented AS (
    -- Assign each customer to a spending group
    SELECT 
        customer_id,
        total_spend,
        CASE 
            WHEN total_spend >= 100000 THEN 'High Spender'
            WHEN total_spend >= 50000  THEN 'Medium Spender'
            ELSE 'Low Spender'
        END AS spend_segment
    FROM customer_spend
)
SELECT 
    spend_segment,
    COUNT(customer_id) AS customer_count,
    ROUND(AVG(total_spend), 2) AS avg_spend_per_customer,
    ROUND(SUM(total_spend), 2) AS total_revenue_contribution
FROM segmented
GROUP BY spend_segment
ORDER BY total_revenue_contribution DESC;