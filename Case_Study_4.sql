/********************************************                              *******************************************
                                                 Case Study #4 Data Bank
*********************************************                              ******************************************/
 
--  A. Customer Nodes Exploration
-- How many unique nodes are there on the Data Bank system?

SELECT COUNT(DISTINCT node_id) unique_nodes FROM customer_nodes;

-- What is the number of nodes per region?

SELECT region_name, COUNT(node_id) node_per_region FROM customer_nodes CN
JOIN regions R
USING(region_id)
GROUP BY region_name;

-- How many customers are allocated to each region?

SELECT region_name, COUNT(DISTINCT customer_id)  FROM customer_nodes
JOIN regions R
USING(region_id)
GROUP BY region_name;

-- How many days on average are customers reallocated to a different node?

SELECT 
ROUND(AVG(TIMESTAMPDIFF(DAY, start_date, end_date))) avg_days 
FROM customer_nodes
WHERE YEAR(end_date) <> '9999'
ORDER BY customer_Id, start_date;


-- What is the median, 80th and 95th percentile for this same reallocation days metric for each region?

WITH perc_rankt AS
(SELECT region_id, TIMESTAMPDIFF(DAY, start_date, end_date) reall_days,
PERCENT_RANK() OVER(PARTITION BY region_id ORDER BY TIMESTAMPDIFF(DAY, start_date, end_date)) perc_rank
FROM customer_nodes
WHERE YEAR(end_date) <> '9999')

SELECT region_name,
MAX(CASE WHEN perc_rank <= 0.5 THEN reall_days END) median,
MAX(CASE WHEN perc_rank <= 0.8 THEN reall_days END) per_80,
MAX(CASE WHEN perc_rank <= 0.9 THEN reall_days END) per_90
FROM perc_rankt
JOIN regions
USING(region_id)
GROUP BY region_name;


-- B. Customer Transactions
-- What is the unique count and total amount for each transaction type?

SELECT txn_type, COUNT(DISTINCT customer_id) unique_count, SUM(txn_amount) total_amount FROM customer_transactions
GROUP BY txn_type;

-- What is the average total historical deposit counts and amounts for all customers?

WITH hist_dep_data AS
(SELECT customer_id, SUM(IF(txn_type='deposit', 1, 0)) d_count, SUM(IF(txn_type='deposit', txn_amount, 0)) d_amount
FROM customer_transactions
GROUP BY customer_id)

SELECT ROUND(AVG(d_count),2) avg_dep_count, ROUND(AVG(d_amount),2) avg_dep_amount FROM hist_dep_data;

-- For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?

WITH CTE AS
(SELECT DATE_FORMAT(txn_date, '%Y-%m') month_, customer_id,
SUM(IF(txn_type = 'deposit', 1, 0)) d_count, SUM(IF(txn_type <> 'deposit', 1, 0)) WP_count
FROM customer_transactions
GROUP BY month_, customer_id)

SELECT month_, COUNT(*) cust_counts FROM CTE
WHERE d_count > 1 AND WP_count >= 1
GROUP BY month_
ORDER BY month_;

-- What is the closing balance for each customer at the end of the month?

WITH balance AS(
SELECT DATE_FORMAT(txn_date, '%Y-%m') month_, customer_id,
SUM(CASE 
		WHEN txn_type= 'deposit' THEN txn_amount
        ELSE 0
	END) dep_amnt, 
SUM(CASE 
		WHEN txn_type <> 'deposit' THEN txn_amount
        ELSE 0
	END) spent_amnt
FROM customer_transactions
GROUP BY month_, customer_id)

SELECT month_, customer_id, (dep_amnt - spent_amnt) closing_balance FROM balance;

-- What is the percentage of customers who increase their closing balance by more than 5%?

WITH closing_sheet AS
(SELECT customer_id, DATE_FORMAT(txn_date, '%Y-%m') month_,
(SUM(IF(txn_type = 'deposit', txn_amount,0)) - SUM(IF(txn_type <> 'deposit', txn_amount,0))) closing_balance
FROM customer_transactions
GROUP BY customer_id, month_),

prev_closing_sheet AS
(SELECT customer_id, month_, closing_balance,
LAG(closing_balance) OVER(PARTITION BY customer_id ORDER BY month_) prev_closing_balance
FROM closing_sheet),

incresed_flags AS(
SELECT
*,
CASE WHEN closing_balance > prev_closing_balance*1.05 THEN 1 ELSE 0 END flag
FROM prev_closing_sheet
WHERE prev_closing_balance IS NOT NULL),

cust_with_flag AS(
SELECT customer_id, MAX(flag) flag FROM incresed_flags
GROUP BY customer_id)

SELECT ROUND(100*SUM(flag)/(SELECT COUNT(DISTINCT customer_id) FROM customer_transactions), 2) percentage FROM cust_with_flag;


/* 
   C. Data Allocation Challenge
To test out a few different hypotheses - the Data Bank team wants to run an experiment where different groups of customers would be allocated data using 3 different options:

Option 1: data is allocated based off the amount of money at the end of the previous month
Option 2: data is allocated on the average amount of money kept in the account in the previous 30 days
Option 3: data is updated real-time
For this multi-part challenge question - you have been requested to generate the following data elements to help the Data Bank team estimate how much data will need to be provisioned for each option:

running customer balance column that includes the impact each transaction
customer balance at the end of each month
minimum, average and maximum values of the running balance for each customer
Using all of the data available - how much data would have been required for each option on a monthly basis? 
*/
 