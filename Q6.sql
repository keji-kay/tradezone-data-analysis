 /* QUESTION 6: Payment Method Preferences by State
 Analyse payment method preferences across each state.
 Show transaction count and total amount per payment method.
Identify the most popular method per state.*/

WITH payment_summary AS (
    SELECT 
        c.state,
        p.payment_method,
        COUNT(p.payment_id) AS transaction_count,
        ROUND(SUM(p.amount), 2) AS total_amount
    FROM payments p
    JOIN orders o ON p.order_id = o.order_id
    JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY c.state, p.payment_method
),
ranked AS (
    -- Rank payment methods per state by transaction count
    SELECT *,
        RANK() OVER (
            PARTITION BY state 
            ORDER BY transaction_count DESC
        ) AS rank
    FROM payment_summary
)
SELECT 
    state,
    payment_method,
    transaction_count,
    total_amount,
    CASE WHEN rank = 1 THEN 'Most Popular' ELSE '' END AS popularity
FROM ranked
ORDER BY state, transaction_count DESC;