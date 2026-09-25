-- PART A: DATA CLEANING & PREPARATION
-- TradeZone E-Commerce Platform


-- SECTION 1: STANDARDISE CITY NAMES
-- INITCAP converts to Title Case, TRIM removes extra spaces
UPDATE customers
SET city = INITCAP(TRIM(city));

UPDATE sellers
SET city = INITCAP(TRIM(city));

-- Fix Port Harcourt variations 
UPDATE customers
SET city = 'Port Harcourt'
WHERE LOWER(TRIM(city)) IN ('port-harcourt', 'portharcourt');

UPDATE sellers
SET city = 'Port Harcourt'
WHERE LOWER(TRIM(city)) IN ('port-harcourt', 'portharcourt');

-- SECTION 2: NORMALISE PRODUCT CATEGORY TO TITLE CASE
UPDATE products
SET category = INITCAP(TRIM(category));

UPDATE sellers
SET product_category = INITCAP(TRIM(product_category));

-- SECTION 3: CHECK FOR DUPLICATE CUSTOMERS (view only, safe to keep)
SELECT email, COUNT(*) as count
FROM customers
GROUP BY email
HAVING COUNT(*) > 1;

-- SECTION 4: FLAG AND REMOVE INVALID REVIEW RATINGS (must be 1-5)
-- Rating of 0 found in REV00718 — deleting as it is invalid
DELETE FROM reviews
WHERE rating < 1 OR rating > 5;

-- SECTION 5: CHECK FOR NEGATIVE PRODUCT PRICES
SELECT product_id, product_name, unit_price 
FROM products 
WHERE unit_price < 0;

-- SECTION 6: FLAG ORDER AMOUNT MISMATCHES GREATER THAN ₦10
SELECT 
    o.order_id,
    o.total_amount AS recorded_total,
    SUM(oi.line_total) AS calculated_total,
    ABS(o.total_amount - SUM(oi.line_total)) AS difference
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id, o.total_amount
HAVING ABS(o.total_amount - SUM(oi.line_total)) > 10
ORDER BY difference DESC;

-- SECTION 7: CHECK NULL VALUES IN CRITICAL COLUMNS
SELECT * FROM customers 
WHERE first_name IS NULL OR last_name IS NULL 
   OR email IS NULL OR signup_date IS NULL;

SELECT * FROM orders 
WHERE customer_id IS NULL OR order_date IS NULL 
   OR total_amount IS NULL;

SELECT * FROM products 
WHERE product_name IS NULL OR unit_price IS NULL;