-- Show table schema 
\d+ retail;

-- Show first 10 rows
SELECT * FROM retail limit 10;

-- Check # of records
SELECT COUNT(*) FROM retail;

-- number of clients (unique customer_id)
SELECT COUNT(DISTINCT customer_id) FROM retail;

-- date range
SELECT MAX(invoice_date), MIN(invoice_date) FROM retail;

-- number of unique SKU
SELECT COUNT(DISTINCT stock_code) FROM retail;

-- average invoice amount (excluding negative)
SELECT AVG(total_amount) 
FROM (
    SELECT invoice_no,
           SUM(unit_price * quantity) AS total_amount
    FROM retail
    GROUP BY invoice_no
    HAVING SUM(unit_price * quantity) > 0
) AS t;

-- total revenue
SELECT SUM(unit_price * quantity) FROM retail;

-- total revenue by YYYYMM
SELECT (EXTRACT(YEAR FROM invoice_date)::int * 100 +
        EXTRACT(MONTH FROM invoice_date)::int) AS yyyymm,
       SUM(unit_price * quantity)
FROM retail
GROUP BY yyyymm
ORDER BY yyyymm;

