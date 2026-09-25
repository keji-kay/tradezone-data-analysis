/* QUESTION 7: Review Ratings and Sales Performance
Group products by average review rating into:
 High Rated: 4.0 and above
-Mid Rated: 3.0 - 3.99
Low Rated: Below 3.0
Calculate product count, total revenue, average unit price.*/

WITH product_ratings AS (
    -- Calculate average rating per product
    SELECT 
        p.product_id,
        p.product_name,
        p.category,
        p.unit_price,
        ROUND(AVG(r.rating), 2) AS avg_rating,
        SUM(oi.line_total) AS total_revenue
    FROM products p
    LEFT JOIN reviews r ON p.product_id = r.product_id
    LEFT JOIN order_items oi ON p.product_id = oi.product_id
    GROUP BY p.product_id, p.product_name, p.category, p.unit_price
),
rated AS (
    -- Assign rating category
    SELECT *,
        CASE 
            WHEN avg_rating >= 4.0 THEN 'High Rated'
            WHEN avg_rating >= 3.0 THEN 'Mid Rated'
            WHEN avg_rating < 3.0  THEN 'Low Rated'
            ELSE 'No Rating'
        END AS rating_category
    FROM product_ratings
)
SELECT 
    rating_category,
    COUNT(product_id) AS product_count,
    ROUND(SUM(total_revenue), 2) AS total_revenue,
    ROUND(AVG(unit_price), 2) AS avg_unit_price
FROM rated
GROUP BY rating_category
ORDER BY total_revenue DESC;