/*QUESTION 1: Customer Acquisition & 30-Day Conversion
a. Find top 5 states by new customer sign-ups in 2024.
b. For each state, calculate % of new customers who made
c. at least one purchase within their first 30 days.
 */

WITH new_customers_2024 AS (
    SELECT 
        customer_id,
        state,
        signup_date
    FROM customers
    WHERE signup_date >= '2024-01-01' 
      AND signup_date <= '2024-12-31'
),
converted AS (
    -- Confirm new customer's ordered within 30 days
    SELECT 
        nc.customer_id,
        nc.state
    FROM new_customers_2024 nc
    JOIN orders o ON nc.customer_id = o.customer_id
    WHERE o.order_date <= nc.signup_date + INTERVAL '30 days'
)
SELECT 
    nc.state,
    COUNT(DISTINCT nc.customer_id) AS new_customers,
    COUNT(DISTINCT c.customer_id) AS converted_customers,
    ROUND(
        COUNT(DISTINCT c.customer_id) * 100.0 / 
        COUNT(DISTINCT nc.customer_id), 2
    ) AS conversion_rate_percent
FROM new_customers_2024 nc
LEFT JOIN converted c ON nc.customer_id = c.customer_id
GROUP BY nc.state
ORDER BY new_customers DESC
LIMIT 5;