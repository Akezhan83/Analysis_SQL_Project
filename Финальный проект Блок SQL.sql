/* SQL project
Student: Nurzhan Akezhanov
Tables used:
customer_info
transactions_info

Analysis period:
01.06.2015 – 01.06.2016
*/


/* ---- 1. Клиенты с непрерывной историей ---- */

SELECT
t.customer_id,
COUNT(*) AS operations_total,
ROUND(AVG(t.amount),2) AS avg_check_year,
ROUND(SUM(t.amount)/12,2) AS avg_spent_per_month

FROM transactions_info t

WHERE t.transaction_date >= '2015-06-01'
AND t.transaction_date < '2016-06-01'

GROUP BY t.customer_id

HAVING COUNT(DISTINCT DATE_TRUNC('month', t.transaction_date)) = 12;



/* ---- 2. Метрики по месяцам ---- */

SELECT
    DATE_FORMAT(t.transaction_date,'%Y-%m') AS month,

    COUNT(*) AS operations_month,

    COUNT(DISTINCT t.customer_id) AS active_customers,

    ROUND(
        COUNT(*) * 1.0 /
        (SELECT COUNT(*) 
         FROM transactions_info
         WHERE transaction_date >= '2015-06-01'
         AND transaction_date < '2016-06-01'),
    4) AS operations_share

FROM transactions_info t

WHERE t.transaction_date >= '2015-06-01'
AND t.transaction_date < '2016-06-01'

GROUP BY DATE_FORMAT(t.transaction_date,'%Y-%m')

ORDER BY month;



/* ---- 3. Анализ M / F / NA ---- */

SELECT
    DATE_FORMAT(t.transaction_date,'%Y-%m') AS month,

    COUNT(*) AS operations,

    ROUND(SUM(t.amount),0) AS total_spent,

    ROUND(
        SUM(t.amount) * 1.0 /
        (SELECT SUM(amount)
         FROM transactions_info
         WHERE transaction_date >= '2015-06-01'
         AND transaction_date < '2016-06-01'),
    4) AS spend_share

FROM transactions_info t

WHERE t.transaction_date >= '2015-06-01'
AND t.transaction_date < '2016-06-01'

GROUP BY DATE_FORMAT(t.transaction_date,'%Y-%m')

ORDER BY month;



/* ---- 4. Возрастные группы ---- */

SELECT

CASE
WHEN age IS NULL THEN 'Unknown'
WHEN age < 20 THEN '0-19'
WHEN age BETWEEN 20 AND 29 THEN '20-29'
WHEN age BETWEEN 30 AND 39 THEN '30-39'
WHEN age BETWEEN 40 AND 49 THEN '40-49'
WHEN age BETWEEN 50 AND 59 THEN '50-59'
ELSE '60+'
END AS age_group,

DATE_TRUNC('quarter', t.transaction_date) AS quarter,

COUNT(*) AS operations,

COUNT(DISTINCT t.customer_id) AS customers,

ROUND(SUM(t.amount),0) AS total_spent,

ROUND(AVG(t.amount),2) AS avg_check

FROM transactions_info t

LEFT JOIN customer_info c
ON t.customer_id = c.customer_id

WHERE t.transaction_date >= '2015-06-01'
AND t.transaction_date < '2016-06-01'

GROUP BY age_group, quarter

ORDER BY age_group, quarter;