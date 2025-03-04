/********************************************                              *******************************************
										Case Study #7 Balanced Tree Clothing Co.
*********************************************                              ******************************************/

-- High Level Sales Analysis
-- What was the total quantity sold for all products?

SELECT product_name, SUM(qty) total_qty_sold FROM sales S
JOIN product_details PD
ON PD.product_id = S.prod_id
GROUP BY product_name
ORDER BY product_name;

-- What is the total generated revenue for all products before discounts?

SELECT SUM(qty*price) revenue FROM sales;

-- What was the total discount amount for all products?

SELECT SUM(qty * price * discount / 100) AS total_discount  FROM sales;

-- Transaction Analysis
-- How many unique transactions were there?

SELECT COUNT(DISTINCT txn_id) trans FROM sales;

-- What is the average unique products purchased in each transaction?

WITH products AS
(SELECT txn_id, COUNT(DISTINCT prod_id) prod_count FROM sales
GROUP BY txn_id)

SELECT ROUND(AVG(prod_count)) avg_prod FROM products;

-- What are the 25th, 50th and 75th percentile values for the revenue per transaction?



-- What is the average discount value per transaction?

WITH txn_discounts AS (
    SELECT txn_id, SUM(qty *price* discount/100) AS total_discount
    FROM sales
    GROUP BY txn_id
)
SELECT ROUND(AVG(total_discount), 2) AS avg_discount_per_txn FROM txn_discounts;

-- What is the percentage split of all transactions for members vs non-members?

SELECT 
	ROUND(100*COUNT(CASE WHEN member = 't' THEN 1 END)/COUNT(*), 2) member_perc_trans,
    ROUND(100*COUNT(CASE WHEN member = 'f' THEN 1 END)/COUNT(*), 2) non_member_perc_trans
FROM sales;

-- What is the average revenue for member transactions and non-member transactions?

SELECT 
	ROUND(AVG(CASE WHEN member = 't' THEN qty*price END), 2) member_avg_revenue,
    ROUND(AVG(CASE WHEN member = 'f' THEN qty*price END), 2) non_member_avg_revenue
FROM sales;

-- Product Analysis
-- What are the top 3 products by total revenue before discount?

SELECT 
	PD.product_name, SUM(S.qty*S.price) revenue
FROM sales S
JOIN product_details PD
ON S.prod_id = PD.product_id
GROUP BY product_name
ORDER BY revenue DESC
LIMIT 3;

-- What is the total quantity, revenue and discount for each segment?

SELECT PD.segment_name, SUM(S.qty) total_qty, SUM(S.qty*S.price) revenue, 
SUM(S.qty * S.price * S.discount / 100) AS total_discount FROM sales S
JOIN product_details PD
ON S.prod_id = PD.product_id
GROUP BY PD.segment_name;

-- What is the top selling product for each segment?

WITH products AS
(SELECT PD.segment_name, PD.product_name, SUM(S.qty) total_qty,
DENSE_RANK() OVER(PARTITION BY PD.segment_name ORDER BY SUM(S.qty) DESC) rank_
FROM sales S
JOIN product_details PD
ON S.prod_id = PD.product_id
GROUP BY PD.segment_name, PD.product_name)

SELECT segment_name, product_name, total_qty FROM products
WHERE rank_ =1;

-- What is the total quantity, revenue and discount for each category?

SELECT PD.category_name, SUM(S.qty) total_qty, SUM(S.qty*S.price) revenue, 
SUM(S.qty * S.price * S.discount / 100)  total_discount FROM sales S
JOIN product_details PD
ON S.prod_id = PD.product_id
GROUP BY PD.category_name;

-- What is the top selling product for each category?

WITH products AS
(SELECT PD.category_name, PD.product_name, SUM(S.qty) total_qty,
DENSE_RANK() OVER(PARTITION BY PD.category_name ORDER BY SUM(S.qty) DESC) rank_
FROM sales S
JOIN product_details PD
ON S.prod_id = PD.product_id
GROUP BY PD.category_name, PD.product_name)

SELECT category_name, product_name, total_qty FROM products
WHERE rank_ =1;

-- What is the percentage split of revenue by product for each segment?

SELECT
	PD.segment_name, PD.product_name,
    ROUND(100*SUM(S.qty*S.price)/(SELECT SUM(qty*price) FROM sales), 2) percentage
FROM product_details PD
JOIN sales S
ON S.prod_id = PD.product_id
GROUP BY PD.segment_name, PD.product_name
ORDER BY PD.segment_name, PD.product_name;


-- What is the percentage split of revenue by segment for each category?

SELECT
	PD.category_name, PD.segment_name,
    ROUND(100*SUM(S.qty*S.price)/(SELECT SUM(qty*price) FROM sales), 2) percentage
FROM product_details PD
JOIN sales S
ON S.prod_id = PD.product_id
GROUP BY PD.category_name, PD.segment_name
ORDER BY percentage DESC;

-- What is the percentage split of total revenue by category?

SELECT
	PD.category_name,
    ROUND(100*SUM(S.qty*S.price)/(SELECT SUM(qty*price) FROM sales), 2) percentage
FROM product_details PD
JOIN sales S
ON S.prod_id = PD.product_id
GROUP BY PD.category_name
ORDER BY percentage DESC;

-- What is the total transaction “penetration” for each product? (hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)



-- What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?

WITH concat_products AS
(SELECT txn_id, GROUP_CONCAT(PD.product_name ORDER BY PD.product_name SEPARATOR ', ') products FROM sales S
JOIN product_details PD
ON PD.product_id = S.prod_id
WHERE S.qty >= 1
GROUP BY txn_id
HAVING COUNT(*) = 3)

SELECT p1.products FROM concat_products p1
JOIN concat_products p2
USING(products)
GROUP BY p1.products
HAVING COUNT(*) > 1
ORDER BY COUNT(*) DESC
LIMIT 1;

