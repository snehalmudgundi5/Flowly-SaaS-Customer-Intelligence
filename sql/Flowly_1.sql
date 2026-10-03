CREATE DATABASE Flowly_SaaS_Analytics;
GO

USE Flowly_SaaS_Analytics;
GO

USE Flowly_SaaS_Analytics;
GO

SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE';

SELECT 'customers' AS table_name, COUNT(*) AS row_count
FROM customers

UNION ALL

SELECT 'subscriptions', COUNT(*)
FROM subscriptions

UNION ALL

SELECT 'users', COUNT(*)
FROM users

UNION ALL

SELECT 'user_activity', COUNT(*)
FROM user_activity

UNION ALL

SELECT 'feature_usage', COUNT(*)
FROM feature_usage

UNION ALL

SELECT 'payments', COUNT(*)
FROM payments

UNION ALL

SELECT 'support_tickets', COUNT(*)
FROM support_tickets;

SELECT TOP 5 *
FROM customers;

SELECT TOP 5 *
FROM subscriptions;

SELECT TOP 5 *
FROM user_activity;

SELECT TOP 5 *
FROM payments;