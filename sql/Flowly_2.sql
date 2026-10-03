SELECT 
    COUNT(DISTINCT customer_id) AS total_customers
FROM customers;

SELECT
    country,
    COUNT(*) AS customer_count
FROM customers
GROUP BY country
ORDER BY customer_count DESC;

SELECT
    customer_segment,
    COUNT(*) AS customer_count
FROM customers
GROUP BY customer_segment
ORDER BY customer_count DESC;

USE Flowly_SaaS_Analytics;
GO

SELECT
    [plan],
    COUNT(DISTINCT customer_id) AS customer_count
FROM subscriptions
GROUP BY [plan]
ORDER BY customer_count DESC;


SELECT
    COUNT(*) AS total_customers,

    SUM(
        CASE
            WHEN end_date IS NOT NULL THEN 1
            ELSE 0
        END
    ) AS churned_customers,

    CAST(
        100.0 *
        SUM(
            CASE
                WHEN end_date IS NOT NULL THEN 1
                ELSE 0
            END
        ) / COUNT(*)
        AS DECIMAL(5,2)
    ) AS churn_rate

FROM subscriptions;

USE Flowly_SaaS_Analytics;
GO

SELECT
    [plan],

    COUNT(*) AS total_customers,

    SUM(
        CASE
            WHEN end_date IS NOT NULL THEN 1
            ELSE 0
        END
    ) AS churned_customers,

    CAST(
        100.0 *
        SUM(
            CASE
                WHEN end_date IS NOT NULL THEN 1
                ELSE 0
            END
        ) / COUNT(*)
        AS DECIMAL(5,2)
    ) AS churn_rate

FROM subscriptions

GROUP BY [plan]

ORDER BY churn_rate DESC;

SELECT
    s.[plan],

    COUNT(DISTINCT p.customer_id) AS paying_customers,

    SUM(p.amount) AS total_revenue,

    AVG(p.amount) AS avg_payment

FROM payments p

INNER JOIN subscriptions s
    ON p.customer_id = s.customer_id

WHERE p.payment_status = 'Paid'

GROUP BY s.[plan]

ORDER BY total_revenue DESC;

SELECT
    DATEFROMPARTS(
        YEAR(payment_date),
        MONTH(payment_date),
        1
    ) AS payment_month,

    SUM(amount) AS monthly_revenue

FROM payments

WHERE payment_status = 'Paid'

GROUP BY
    DATEFROMPARTS(
        YEAR(payment_date),
        MONTH(payment_date),
        1
    )

ORDER BY payment_month;