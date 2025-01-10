CREATE SCHEMA dannys_diner;


CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);

INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
  
  
  /*********************** -------------------- ***********************
						   Case Study Questions
   *********************** -------------------- ***********************/
   
   SELECT * FROM sales;
   
   SELECT * FROM menu;
   
   SELECT * FROM members;
   
-- 1. What is the total amount each customer spent at the restaurant?

SELECT 
S.customer_id, SUM(M.price) total_amount
FROM sales S
INNER JOIN menu M
ON S.product_id = M.product_id
GROUP BY S.customer_id;

-- 2. How many days has each customer visited the restaurant?

SELECT 
S.customer_id, COUNT(DISTINCT order_date) no_visits
FROM sales S
GROUP BY S.customer_id;

-- 3. What was the first item from the menu purchased by each customer?

SELECT 
S.customer_id, M.product_name, order_date
FROM sales S
INNER JOIN menu M
ON S.product_id = M. product_id
WHERE (S.customer_id, S. order_date) IN 
(SELECT customer_id, MIN(order_date) From sales GROUP BY customer_id);

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT 
M.product_name, 
COUNT(*) AS purchase_count
FROM sales S
INNER JOIN menu M
ON S.product_id = M.product_id
GROUP BY M.product_name
ORDER BY purchase_count DESC
LIMIT 1;

-- 5. Which item was the most popular for each customer?

WITH purchase_count AS
(SELECT 
S.customer_id, M.product_name,
ROW_NUMBER() OVER(partition by S.customer_id  ORDER BY COUNT(*) DESC) row_num
FROM sales S
INNER JOIN menu M
ON S.product_id = M.product_id
GROUP BY S.customer_id, M.product_name)

SELECT 
customer_id,product_name
FROM purchase_count
WHERE row_num =1;


-- 6. Which item was purchased first by the customer after they became a member?

WITH first_purchase AS(
SELECT S.customer_id, MIN(S.order_date) order_date
FROM sales S
INNER JOIN members M
ON M.customer_id = S.customer_id
WHERE S.order_date >= M.join_date
GROUP BY S.customer_id)

SELECT FP.customer_id, FP.order_date, M.product_name
FROM first_purchase FP
INNER JOIN sales S
ON S.customer_id = FP.customer_id
AND S.order_date = FP.order_date
INNER JOIN menu M
ON M.product_id = S.product_id;

-- 7. Which item was purchased just before the customer became a member?

WITH first_purchase AS(
SELECT S.customer_id, MAX(S.order_date) order_date
FROM sales S
INNER JOIN members M
ON M.customer_id = S.customer_id
WHERE S.order_date < M.join_date
GROUP BY S.customer_id)

SELECT FP.customer_id, FP.order_date, M.product_name
FROM first_purchase FP
INNER JOIN sales S
ON S.customer_id = FP.customer_id
AND S.order_date = FP.order_date
INNER JOIN menu M
ON M.product_id = S.product_id;


-- 8. What is the total items and amount spent for each member before they became a member?

SELECT 
S.customer_id, COUNT(*) total_items, SUM(MU.price) total_spent
FROM sales S
INNER JOIN members M
ON M.customer_id = S.customer_id
AND M.join_date >S.order_date
INNER JOIN menu MU
ON MU.product_id = S.product_id
GROUP BY S.customer_id;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

WITH total_spent AS (
SELECT 
S.customer_id, M.product_name, 
CASE
	WHEN product_name = 'sushi' THEN 2* (SUM(price)*10)
    ELSE SUM(price) * 10 
END points
FROM sales S
INNER JOIN menu M
ON M.product_id = S.product_id
GROUP BY S.customer_id, M.product_name)

SELECT customer_id, SUM(points) total_points
FROM total_spent
GROUP BY customer_id;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

WITH before_membership AS (
SELECT 
S.customer_id, M.product_name, 
CASE
	WHEN product_name = 'sushi' THEN 2* (SUM(price)*10)
    ELSE SUM(price) * 10 
END points
FROM sales S
INNER JOIN menu M
ON M.product_id = S.product_id
INNER JOIN members ME
ON ME.customer_id = S.customer_id
WHERE S.order_date < ME.join_date
GROUP BY S.customer_id, M.product_name),

first_week AS (
SELECT 
S.customer_id, M.product_name, 2* (SUM(price)*10) points
FROM sales S
INNER JOIN menu M
ON M.product_id = S.product_id
INNER JOIN members ME
ON ME.customer_id = S.customer_id
WHERE S.order_date BETWEEN ME.join_date AND ME.join_date + INTERVAL 6 DAY
GROUP BY S.customer_id, M.product_name
 ),

after_aweek AS(
SELECT 
S.customer_id, M.product_name,  
CASE
	WHEN product_name = 'sushi' THEN 2* (SUM(price)*10)
    ELSE SUM(price) * 10 
END points
FROM sales S
INNER JOIN menu M
ON M.product_id = S.product_id
INNER JOIN members ME
ON ME.customer_id = S.customer_id
WHERE S.order_date > ME.join_date + INTERVAL 6 DAY
AND S.order_date < '2021-02-01'
GROUP BY S.customer_id, M.product_name),

combined_points AS(

SELECT customer_id, points FROM after_aweek
UNION ALL
SELECT customer_id, points FROM before_membership
UNION ALL
SELECT customer_id, points FROM first_week

)

SELECT customer_id, SUM(points) total_points FROM combined_points
GROUP BY customer_id;
