/********************************************                              *******************************************
                                                 Case Study #3 Foodi-fi
*********************************************                              ******************************************/
 
-- A. Customer Journey
/*
Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.

Try to keep it as short as possible - you may also want to run some sort of join to make your explanations a bit easier!
*/

SELECT 
customer_id,
CONCAT('Customer ', customer_id, ' Journey is started from ', MIN(start_date), ' with plans like ',
GROUP_CONCAT(plan_name ORDER BY plan_id SEPARATOR ', '))
Journey
FROM subscriptions S
JOIN plans P
USING(plan_id)
GROUP BY customer_id;

-- B. Data Analysis Questions
-- How many customers has Foodie-Fi ever had?

SELECT COUNT(DISTINCT customer_id) customers FROM subscriptions;

-- What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value

SELECT DATE_FORMAT(start_date, '%Y-%m') month_, COUNT(*) monthly_distr 
FROM subscriptions
GROUP BY month_
ORDER BY month_;

-- What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name

SELECT P.plan_name, COUNT(*) plans_count FROM subscriptions S
JOIN plans P
USING(plan_id)
WHERE start_date >= '2021-01-01'
GROUP BY P.plan_name
ORDER BY plans_count DESC;

-- What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

WITH cust_count AS(
SELECT COUNT(DISTINCT customer_id) c_cust_count FROM subscriptions
)

SELECT (SELECT c_cust_count FROM cust_count) customer_count,
ROUND((COUNT(customer_id)*100.0/(SELECT c_cust_count FROM cust_count)), 1) churn_pernt
FROM subscriptions
JOIN plans
USING(plan_id)
WHERE plan_name = 'churn';

-- How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

WITH sub_data AS (
SELECT customer_id, plan_name, 
LEAD(plan_name) OVER(PARTITION BY customer_id ORDER BY start_date) recent_plan
FROM subscriptions S
JOIN plans P
USING(plan_id)
),

cust_count AS(
SELECT COUNT(DISTINCT customer_id) c_cust_count FROM subscriptions
)

SELECT COUNT(*) direct_churn, 
ROUND(COUNT(*)*100.0/(SELECT c_cust_count FROM cust_count)) direct_churn_pernt  FROM sub_data
WHERE plan_name = 'trial' AND recent_plan = 'churn';

-- What is the number and percentage of customer plans after their initial free trial?

WITH subsc AS (
SELECT customer_id, plan_name, 
LEAD(plan_name) OVER(PARTITION BY customer_id ORDER BY start_date) 2nd_plan
FROM subscriptions S
JOIN plans P
USING(plan_id)
),

cust_count AS(
SELECT COUNT(DISTINCT customer_id) c_cust_count FROM subscriptions
)

SELECT
2nd_plan plan, COUNT(*) direct_plancount_after_trail, 
ROUND(COUNT(*)*100.0/(SELECT c_cust_count FROM cust_count), 2) direct_plan_percentage
FROM subsc
WHERE plan_name = 'trial'
GROUP BY plan;


-- What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

WITH cust_count AS(
SELECT COUNT(DISTINCT customer_id) c_cust_count FROM subscriptions
WHERE start_date = '2020-12-31'
)

SELECT P.plan_name, COUNT(S.customer_id) customer_count,
ROUND(COUNT(S.customer_id)*100.0/(SELECT c_cust_count FROM cust_count), 2) percentage
FROM plans P 
LEFT JOIN subscriptions S
ON 
    P.plan_id = S.plan_id 
    AND S.start_date = '2020-12-31'
GROUP BY plan_name;