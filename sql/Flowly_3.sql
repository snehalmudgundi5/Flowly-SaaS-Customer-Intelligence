WITH customer_activity AS
(
    SELECT
        customer_id,
        COUNT(*) AS total_events,
        SUM(session_minutes) AS total_session_minutes,
        AVG(CAST(session_minutes AS DECIMAL(10,2))) AS avg_session_minutes,
        COUNT(DISTINCT activity_date) AS active_days
    FROM user_activity
    GROUP BY customer_id
)

SELECT *
FROM customer_activity
ORDER BY total_events DESC;

WITH customer_activity AS
(
    SELECT
        customer_id,
        COUNT(*) AS total_events,
        SUM(session_minutes) AS total_session_minutes,
        AVG(CAST(session_minutes AS DECIMAL(10,2))) AS avg_session_minutes,
        COUNT(DISTINCT activity_date) AS active_days
    FROM user_activity
    GROUP BY customer_id
)

SELECT *
FROM customer_activity
ORDER BY total_events DESC;

WITH customer_activity AS
(
    SELECT
        customer_id,
        COUNT(*) AS total_events,
        SUM(session_minutes) AS total_session_minutes,
        AVG(CAST(session_minutes AS DECIMAL(10,2))) AS avg_session_minutes,
        COUNT(DISTINCT activity_date) AS active_days
    FROM user_activity
    GROUP BY customer_id
)

SELECT
    c.customer_id,
    c.company_name,
    c.country,
    c.customer_segment,
    s.[plan],
    s.seats,
    s.monthly_price,
    s.end_date,
    ca.total_events,
    ca.total_session_minutes,
    ca.avg_session_minutes,
    ca.active_days
FROM customers c
LEFT JOIN subscriptions s
    ON c.customer_id = s.customer_id
LEFT JOIN customer_activity ca
    ON c.customer_id = ca.customer_id;

    WITH customer_revenue AS
(
    SELECT
        customer_id,
        SUM(amount) AS total_revenue,
        COUNT(payment_id) AS successful_payments
    FROM payments
    WHERE payment_status = 'Paid'
    GROUP BY customer_id
)

SELECT
    c.customer_id,
    c.company_name,
    s.[plan],
    COALESCE(cr.total_revenue, 0) AS total_revenue,
    COALESCE(cr.successful_payments, 0) AS successful_payments
FROM customers c
LEFT JOIN subscriptions s
    ON c.customer_id = s.customer_id
LEFT JOIN customer_revenue cr
    ON c.customer_id = cr.customer_id
ORDER BY total_revenue DESC;

WITH customer_activity AS
(
    SELECT
        customer_id,
        COUNT(*) AS total_events,
        SUM(session_minutes) AS total_session_minutes,
        COUNT(DISTINCT activity_date) AS active_days
    FROM user_activity
    GROUP BY customer_id
),

customer_analysis AS
(
    SELECT
        s.customer_id,
        s.[plan],
        CASE
            WHEN s.end_date IS NULL THEN 0
            ELSE 1
        END AS is_churned,
        COALESCE(ca.total_events, 0) AS total_events,
        COALESCE(ca.total_session_minutes, 0) AS total_session_minutes,
        COALESCE(ca.active_days, 0) AS active_days
    FROM subscriptions s
    LEFT JOIN customer_activity ca
        ON s.customer_id = ca.customer_id
)

SELECT
    is_churned,
    COUNT(*) AS customers,
    AVG(CAST(total_events AS DECIMAL(10,2))) AS avg_events,
    AVG(CAST(total_session_minutes AS DECIMAL(10,2))) AS avg_session_minutes,
    AVG(CAST(active_days AS DECIMAL(10,2))) AS avg_active_days
FROM customer_analysis
GROUP BY is_churned;

WITH customer_revenue AS
(
    SELECT
        customer_id,
        SUM(amount) AS total_revenue
    FROM payments
    WHERE payment_status = 'Paid'
    GROUP BY customer_id
)

SELECT
    customer_id,
    total_revenue,
    RANK() OVER (
        ORDER BY total_revenue DESC
    ) AS revenue_rank
FROM customer_revenue
ORDER BY revenue_rank;

WITH customer_revenue AS
(
    SELECT
        p.customer_id,
        s.[plan],
        SUM(p.amount) AS total_revenue
    FROM payments p
    JOIN subscriptions s
        ON p.customer_id = s.customer_id
    WHERE p.payment_status = 'Paid'
    GROUP BY
        p.customer_id,
        s.[plan]
)

SELECT
    customer_id,
    [plan],
    total_revenue,
    RANK() OVER (
        PARTITION BY [plan]
        ORDER BY total_revenue DESC
    ) AS plan_revenue_rank
FROM customer_revenue
ORDER BY
    [plan],
    plan_revenue_rank;

    WITH customer_revenue AS
(
    SELECT
        p.customer_id,
        s.[plan],
        SUM(p.amount) AS total_revenue
    FROM payments p
    JOIN subscriptions s
        ON p.customer_id = s.customer_id
    WHERE p.payment_status = 'Paid'
    GROUP BY
        p.customer_id,
        s.[plan]
),

ranked_customers AS
(
    SELECT
        customer_id,
        [plan],
        total_revenue,
        ROW_NUMBER() OVER (
            PARTITION BY [plan]
            ORDER BY total_revenue DESC
        ) AS rn
    FROM customer_revenue
)

SELECT *
FROM ranked_customers
WHERE rn <= 5
ORDER BY
    [plan],
    rn;

    WITH monthly_revenue AS
(
    SELECT
        DATEFROMPARTS(
            YEAR(payment_date),
            MONTH(payment_date),
            1
        ) AS payment_month,
        SUM(amount) AS revenue
    FROM payments
    WHERE payment_status = 'Paid'
    GROUP BY
        DATEFROMPARTS(
            YEAR(payment_date),
            MONTH(payment_date),
            1
        )
)

SELECT
    payment_month,
    revenue,
    LAG(revenue) OVER (
        ORDER BY payment_month
    ) AS previous_month_revenue
FROM monthly_revenue
ORDER BY payment_month;

WITH monthly_revenue AS
(
    SELECT
        DATEFROMPARTS(
            YEAR(payment_date),
            MONTH(payment_date),
            1
        ) AS payment_month,
        SUM(amount) AS revenue
    FROM payments
    WHERE payment_status = 'Paid'
    GROUP BY
        DATEFROMPARTS(
            YEAR(payment_date),
            MONTH(payment_date),
            1
        )
),

revenue_comparison AS
(
    SELECT
        payment_month,
        revenue,
        LAG(revenue) OVER (
            ORDER BY payment_month
        ) AS previous_month_revenue
    FROM monthly_revenue
)

SELECT
    payment_month,
    revenue,
    previous_month_revenue,
    CAST(
        100.0 * (revenue - previous_month_revenue)
        / NULLIF(previous_month_revenue, 0)
        AS DECIMAL(10,2)
    ) AS mom_growth_percent
FROM revenue_comparison
ORDER BY payment_month;

WITH monthly_revenue AS
(
    SELECT
        DATEFROMPARTS(
            YEAR(payment_date),
            MONTH(payment_date),
            1
        ) AS payment_month,
        SUM(amount) AS revenue
    FROM payments
    WHERE payment_status = 'Paid'
    GROUP BY
        DATEFROMPARTS(
            YEAR(payment_date),
            MONTH(payment_date),
            1
        )
)

SELECT
    payment_month,
    revenue,
    SUM(revenue) OVER (
        ORDER BY payment_month
        ROWS BETWEEN UNBOUNDED PRECEDING
        AND CURRENT ROW
    ) AS cumulative_revenue
FROM monthly_revenue
ORDER BY payment_month;

WITH customer_cohort AS
(
    SELECT
        customer_id,
        DATEFROMPARTS(
            YEAR(signup_date),
            MONTH(signup_date),
            1
        ) AS cohort_month
    FROM customers
)

SELECT *
FROM customer_cohort
ORDER BY cohort_month;

WITH customer_cohort AS
(
    SELECT
        customer_id,
        DATEFROMPARTS(
            YEAR(signup_date),
            MONTH(signup_date),
            1
        ) AS cohort_month
    FROM customers
),

cohort_activity AS
(
    SELECT
        cc.customer_id,
        cc.cohort_month,
        DATEFROMPARTS(
            YEAR(ua.activity_date),
            MONTH(ua.activity_date),
            1
        ) AS activity_month
    FROM customer_cohort cc
    JOIN user_activity ua
        ON cc.customer_id = ua.customer_id
    GROUP BY
        cc.customer_id,
        cc.cohort_month,
        DATEFROMPARTS(
            YEAR(ua.activity_date),
            MONTH(ua.activity_date),
            1
        )
)

SELECT
    cohort_month,
    activity_month,
    COUNT(DISTINCT customer_id) AS active_customers
FROM cohort_activity
GROUP BY
    cohort_month,
    activity_month
ORDER BY
    cohort_month,
    activity_month;

    WITH customer_cohort AS
(
    SELECT
        customer_id,
        DATEFROMPARTS(
            YEAR(signup_date),
            MONTH(signup_date),
            1
        ) AS cohort_month
    FROM customers
),

cohort_activity AS
(
    SELECT DISTINCT
        cc.customer_id,
        cc.cohort_month,
        DATEFROMPARTS(
            YEAR(ua.activity_date),
            MONTH(ua.activity_date),
            1
        ) AS activity_month
    FROM customer_cohort cc
    JOIN user_activity ua
        ON cc.customer_id = ua.customer_id
)

SELECT
    cohort_month,
    activity_month,
    DATEDIFF(
        MONTH,
        cohort_month,
        activity_month
    ) AS months_since_signup,
    COUNT(DISTINCT customer_id) AS active_customers
FROM cohort_activity
GROUP BY
    cohort_month,
    activity_month
ORDER BY
    cohort_month,
    months_since_signup;

    WITH customer_cohort AS
(
    SELECT
        customer_id,
        DATEFROMPARTS(
            YEAR(signup_date),
            MONTH(signup_date),
            1
        ) AS cohort_month
    FROM customers
),

cohort_activity AS
(
    SELECT DISTINCT
        cc.customer_id,
        cc.cohort_month,
        DATEFROMPARTS(
            YEAR(ua.activity_date),
            MONTH(ua.activity_date),
            1
        ) AS activity_month
    FROM customer_cohort cc
    JOIN user_activity ua
        ON cc.customer_id = ua.customer_id
),

cohort_data AS
(
    SELECT
        cohort_month,
        DATEDIFF(
            MONTH,
            cohort_month,
            activity_month
        ) AS months_since_signup,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM cohort_activity
    GROUP BY
        cohort_month,
        DATEDIFF(
            MONTH,
            cohort_month,
            activity_month
        )
),

cohort_size AS
(
    SELECT
        cohort_month,
        COUNT(DISTINCT customer_id) AS cohort_customers
    FROM customer_cohort
    GROUP BY cohort_month
)

SELECT
    cd.cohort_month,
    cd.months_since_signup,
    cd.active_customers,
    cs.cohort_customers,
    CAST(
        100.0 * cd.active_customers
        / NULLIF(cs.cohort_customers, 0)
        AS DECIMAL(5,2)
    ) AS retention_rate
FROM cohort_data cd
JOIN cohort_size cs
    ON cd.cohort_month = cs.cohort_month
ORDER BY
    cd.cohort_month,
    cd.months_since_signup;

    SELECT
    feature_name,
    COUNT(DISTINCT customer_id) AS customers_using_feature,
    COUNT(*) AS usage_records,
    SUM(usage_count) AS total_usage
FROM feature_usage
GROUP BY feature_name
ORDER BY customers_using_feature DESC;

SELECT
    feature_name,
    COUNT(DISTINCT customer_id) AS customers_using_feature,
    CAST(
        100.0 * COUNT(DISTINCT customer_id)
        / (SELECT COUNT(*) FROM customers)
        AS DECIMAL(5,2)
    ) AS adoption_rate
FROM feature_usage
GROUP BY feature_name
ORDER BY adoption_rate DESC;

SELECT
    category,
    COUNT(*) AS total_tickets,
    AVG(resolution_hours) AS avg_resolution_hours,
    AVG(satisfaction_score) AS avg_satisfaction
FROM support_tickets
GROUP BY category
ORDER BY total_tickets DESC;

SELECT
    CASE
        WHEN s.end_date IS NULL THEN 'Active'
        ELSE 'Churned'
    END AS customer_status,
    COUNT(DISTINCT s.customer_id) AS customers,
    AVG(st.resolution_hours) AS avg_resolution_hours,
    AVG(st.satisfaction_score) AS avg_satisfaction
FROM subscriptions s
LEFT JOIN support_tickets st
    ON s.customer_id = st.customer_id
GROUP BY
    CASE
        WHEN s.end_date IS NULL THEN 'Active'
        ELSE 'Churned'
    END;

    WITH customer_activity AS
(
    SELECT
        customer_id,
        COUNT(*) AS total_events,
        SUM(session_minutes) AS total_session_minutes,
        COUNT(DISTINCT activity_date) AS active_days
    FROM user_activity
    GROUP BY customer_id
),

engagement_thresholds AS
(
    SELECT
        PERCENTILE_CONT(0.25)
        WITHIN GROUP (ORDER BY total_events)
        OVER () AS low_threshold,

        PERCENTILE_CONT(0.75)
        WITHIN GROUP (ORDER BY total_events)
        OVER () AS high_threshold
    FROM customer_activity
)

SELECT DISTINCT
    ca.customer_id,
    ca.total_events,
    ca.total_session_minutes,
    ca.active_days,
    CASE
        WHEN ca.total_events <= et.low_threshold
            THEN 'Low'
        WHEN ca.total_events > et.high_threshold
            THEN 'High'
        ELSE 'Medium'
    END AS engagement_level
FROM customer_activity ca
CROSS JOIN engagement_thresholds et;

WITH customer_activity AS
(
    SELECT
        customer_id,
        COUNT(*) AS total_events
    FROM user_activity
    GROUP BY customer_id
),

engagement_thresholds AS
(
    SELECT
        PERCENTILE_CONT(0.25)
        WITHIN GROUP (ORDER BY total_events)
        OVER () AS low_threshold,

        PERCENTILE_CONT(0.75)
        WITHIN GROUP (ORDER BY total_events)
        OVER () AS high_threshold
    FROM customer_activity
),

customer_analysis AS
(
    SELECT DISTINCT
        s.customer_id,
        CASE
            WHEN s.end_date IS NULL THEN 0
            ELSE 1
        END AS is_churned,

        CASE
            WHEN ca.total_events <= et.low_threshold
                THEN 'Low'
            WHEN ca.total_events > et.high_threshold
                THEN 'High'
            ELSE 'Medium'
        END AS engagement_level
    FROM subscriptions s
    LEFT JOIN customer_activity ca
        ON s.customer_id = ca.customer_id
    CROSS JOIN engagement_thresholds et
)

SELECT
    engagement_level,
    COUNT(*) AS customers,
    SUM(is_churned) AS churned_customers,
    CAST(
        100.0 * SUM(is_churned) / COUNT(*)
        AS DECIMAL(5,2)
    ) AS churn_rate
FROM customer_analysis
GROUP BY engagement_level
ORDER BY churn_rate DESC;

WITH customer_activity AS
(
    SELECT
        customer_id,
        COUNT(*) AS total_events,
        SUM(session_minutes) AS total_session_minutes,
        AVG(CAST(session_minutes AS DECIMAL(10,2))) AS avg_session_minutes,
        COUNT(DISTINCT activity_date) AS active_days
    FROM user_activity
    GROUP BY customer_id
),

customer_features AS
(
    SELECT
        customer_id,
        COUNT(DISTINCT feature_name) AS features_used,
        SUM(usage_count) AS total_feature_usage
    FROM feature_usage
    GROUP BY customer_id
),

customer_revenue AS
(
    SELECT
        customer_id,
        SUM(amount) AS total_revenue,
        COUNT(payment_id) AS successful_payments
    FROM payments
    WHERE payment_status = 'Paid'
    GROUP BY customer_id
),

customer_support AS
(
    SELECT
        customer_id,
        COUNT(*) AS support_tickets,
        AVG(resolution_hours) AS avg_resolution_hours,
        AVG(satisfaction_score) AS avg_satisfaction
    FROM support_tickets
    GROUP BY customer_id
)

SELECT
    c.customer_id,
    c.company_name,
    c.country,
    c.industry,
    c.customer_segment,

    s.[plan],
    s.seats,
    s.monthly_price,
    s.start_date,
    s.end_date,

    CASE
        WHEN s.end_date IS NULL THEN 'Active'
        ELSE 'Churned'
    END AS customer_status,

    COALESCE(ca.total_events, 0) AS total_events,
    COALESCE(ca.total_session_minutes, 0) AS total_session_minutes,
    COALESCE(ca.avg_session_minutes, 0) AS avg_session_minutes,
    COALESCE(ca.active_days, 0) AS active_days,

    COALESCE(cf.features_used, 0) AS features_used,
    COALESCE(cf.total_feature_usage, 0) AS total_feature_usage,

    COALESCE(cr.total_revenue, 0) AS total_revenue,
    COALESCE(cr.successful_payments, 0) AS successful_payments,

    COALESCE(cs.support_tickets, 0) AS support_tickets,
    cs.avg_resolution_hours,
    cs.avg_satisfaction

FROM customers c

LEFT JOIN subscriptions s
    ON c.customer_id = s.customer_id

LEFT JOIN customer_activity ca
    ON c.customer_id = ca.customer_id

LEFT JOIN customer_features cf
    ON c.customer_id = cf.customer_id

LEFT JOIN customer_revenue cr
    ON c.customer_id = cr.customer_id

LEFT JOIN customer_support cs
    ON c.customer_id = cs.customer_id;