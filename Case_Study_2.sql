/********************************************                              *******************************************
											   Case Study #2 Pizza Runner
*********************************************                              ******************************************/


CREATE TABLE runners (
    runner_id INTEGER,
    registration_date DATE
);

INSERT INTO runners
  (runner_id, registration_date)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


CREATE TABLE customer_orders (
    order_id INTEGER,
    customer_id INTEGER,
    pizza_id INTEGER,
    exclusions VARCHAR(4),
    extras VARCHAR(4),
    order_time TIMESTAMP
);

INSERT INTO customer_orders
  (order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');



CREATE TABLE runner_orders (
    order_id INTEGER,
    runner_id INTEGER,
    pickup_time VARCHAR(19),
    distance VARCHAR(7),
    duration VARCHAR(10),
    cancellation VARCHAR(23)
);

INSERT INTO runner_orders
  (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


CREATE TABLE pizza_names (
    pizza_id INTEGER,
    pizza_name TEXT
);

INSERT INTO pizza_names
  (pizza_id, pizza_name)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


CREATE TABLE pizza_recipes (
    pizza_id INTEGER,
    toppings TEXT
);

INSERT INTO pizza_recipes
  (pizza_id, toppings)
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');

CREATE TABLE pizza_toppings (
    topping_id INTEGER,
    topping_name TEXT
);

INSERT INTO pizza_toppings
  (topping_id, topping_name)
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
  
  
    /******************** -------------------- ********************
                          Data Cleaning
   ******************** -------------------- ********************/
  
SELECT 
    *
FROM
    customer_orders;

SELECT 
    *
FROM
    customer_orders
WHERE
    exclusions = 'null';

SELECT 
    *
FROM
    customer_orders
WHERE
    extras = 'null';

UPDATE customer_orders 
SET 
    exclusions = NULL
WHERE
    exclusions = 'null';

UPDATE customer_orders 
SET 
    extras = NULL
WHERE
    extras = 'null';

SELECT 
    *
FROM
    customer_orders
WHERE
    extras = '';

SELECT 
    *
FROM
    customer_orders
WHERE
    exclusions = '';

UPDATE customer_orders 
SET 
    exclusions = NULL
WHERE
    exclusions = '';

UPDATE customer_orders 
SET 
    extras = NULL
WHERE
    extras = '';

SELECT 
    *
FROM
    runner_orders;

SELECT 
    *
FROM
    runner_orders
WHERE
    duration = 'null';

UPDATE runner_orders 
SET 
    distance = NULL
WHERE
    distance = 'null';

UPDATE runner_orders 
SET 
    cancellation = NULL
WHERE
    cancellation = 'null';

UPDATE runner_orders 
SET 
    cancellation = NULL
WHERE
    cancellation = '';

SELECT 
    *
FROM
    runner_orders;

UPDATE runner_orders 
SET 
    distance = CAST(TRIM(REPLACE(distance, 'km', '')) AS DECIMAL (5 , 2 ));

UPDATE runner_orders 
SET 
    duration = TRIM(REPLACE(duration, 'minutes', ''));

UPDATE runner_orders 
SET 
    duration = TRIM(REPLACE(duration, ' mins', ''));


UPDATE runner_orders 
SET 
    duration = TRIM(REPLACE(duration, ' minute', ''));

UPDATE runner_orders 
SET 
    duration = TRIM(REPLACE(duration, 'mins', ''));

ALTER TABLE runner_orders 
MODIFY COLUMN duration INT;


 /******************** -------------------- ********************
                        Case Study Questions
   ******************** -------------------- ********************/
   
SELECT 
    COUNT(pizza_id) AS ordered_pizzas
FROM
    customer_orders;

-- How many unique customer orders were made?

SELECT 
    COUNT(DISTINCT order_id) unique_customers
FROM
    customer_orders;

-- How many successful orders were delivered by each runner?

SELECT 
    runner_id, COUNT(DISTINCT order_id) AS succ_delivered
FROM
    runner_orders
WHERE
    cancellation IS NULL
GROUP BY runner_id;

-- How many of each type of pizza was delivered?

SELECT 
    CO.pizza_id, pizza_name, COUNT(*) pizza_delv
FROM
    customer_orders CO
        INNER JOIN
    runner_orders RO USING (order_id)
        INNER JOIN
    pizza_names PN USING (pizza_id)
WHERE
    RO.cancellation IS NULL
GROUP BY CO.pizza_id , pizza_name;

-- How many Vegetarian and Meatlovers were ordered by each customer?

SELECT 
    CO.customer_id, PN.pizza_name, COUNT(*) pizzas_ord
FROM
    customer_orders CO
INNER JOIN pizza_names PN 
USING (pizza_id)
WHERE PN.pizza_name IN ('Vegetarian', 'Meatlovers')
GROUP BY CO.customer_id , PN.pizza_name
ORDER BY CO.customer_id;

-- What was the maximum number of pizzas delivered in a single order?

SELECT 
    CO.order_id, COUNT(*) delv_count
FROM
    customer_orders CO
        INNER JOIN
    runner_orders RO USING (order_id)
WHERE
    RO.cancellation IS NULL
GROUP BY CO.order_id
ORDER BY delv_count DESC
LIMIT 1;

-- For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

SELECT 
    COUNT(*) total_delv_pizzas,
    SUM(CO.exclusions IS NOT NULL
        OR CO.extras IS NOT NULL) chaged_pizzas,
    SUM(CO.exclusions IS NULL
        AND CO.extras IS NULL) not_chaged_pizzas
FROM
    customer_orders CO
        INNER JOIN
    runner_orders RO USING (order_id)
WHERE
    RO.cancellation IS NULL;

-- How many pizzas were delivered that had both exclusions and extras?

SELECT 
    COUNT(*) total_delv_pizzas,
    SUM(CO.exclusions IS NOT NULL
        AND CO.extras IS NOT NULL) chaged_pizzas
FROM
    customer_orders CO
        INNER JOIN
    runner_orders RO USING (order_id)
WHERE
    RO.cancellation IS NULL;

-- What was the total volume of pizzas ordered for each hour of the day?

SELECT 
    HOUR(order_time) hour, COUNT(*) volume
FROM
    customer_orders
GROUP BY hour
ORDER BY hour;

-- What was the volume of orders for each day of the week?

SELECT 
    WEEKDAY(order_time) weekday, COUNT(*) volume
FROM
    customer_orders
GROUP BY weekday
ORDER BY weekday;

-- B. Runner and Customer Experience
-- How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

SELECT 
    WEEK(registration_date) week, COUNT(*) runners_count
FROM
    runners
WHERE
    registration_date >= '2021-01-01'
GROUP BY week
ORDER BY week;

-- What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

SELECT 
    RO.runner_id,
    AVG(TIMESTAMPDIFF(MINUTE,
        CO.order_time,
        RO.pickup_time)) min_diff
FROM
    customer_orders CO
        JOIN
    runner_orders RO USING (order_id)
WHERE
    RO.pickup_time IS NOT NULL
GROUP BY RO.runner_id;


-- Is there any relationship between the number of pizzas and how long the order takes to prepare?

SELECT 
    CO.order_id,
    MAX(TIMESTAMPDIFF(MINUTE,
        order_time,
        pickup_time)) diff_time,
    COUNT(pizza_id) pizza_count
FROM
    customer_orders CO
        JOIN
    runner_orders RO USING (order_id)
WHERE
    RO.pickup_time IS NOT NULL
GROUP BY CO.order_id
ORDER BY pizza_count DESC , diff_time DESC;

-- What was the average distance travelled for each customer?

SELECT 
    customer_id, ROUND(AVG(distance), 2) avg_dist
FROM
    runner_orders RO
        INNER JOIN
    customer_orders CO USING (order_id)
WHERE
    distance IS NOT NULL
GROUP BY customer_id;

-- What was the difference between the longest and shortest delivery times for all orders?

SELECT 
    MAX(duration) - MIN(duration) diff_in_delv
FROM
    runner_orders
WHERE
    duration IS NOT NULL;

-- What was the average speed for each runner for each delivery and do you notice any trend for these values?

SELECT 
    runner_id,
    ROUND(AVG(distance / (duration / 60)), 2) AS `speed(km/hr)`
FROM
    runner_orders
GROUP BY runner_id;

-- What is the successful delivery percentage for each runner?

WITH total_delv AS(
SELECT runner_id, COUNT(*) tol_delv FROM runner_orders
GROUP BY runner_id
)

SELECT 
RO.runner_id, ROUND((COUNT(*)/tol_delv)*100, 2) perc_suss_delv
FROM runner_orders RO
JOIN total_delv TD
USING(runner_id)
WHERE cancellation IS NULL
GROUP BY runner_id;

-- C. Ingredient Optimisation
-- What are the standard ingredients for each pizza?

WITH recipe AS(
SELECT P.pizza_id, T.topping_name
FROM pizza_recipes P
JOIN pizza_toppings T
ON FIND_IN_SET(T.topping_id, REPLACE(P.toppings, ' ', ''))
ORDER BY P.pizza_id, T.topping_id)

SELECT pizza_id, GROUP_CONCAT(topping_name ORDER BY topping_name SEPARATOR ', ') standard_ingredients
FROM recipe
GROUP BY pizza_id;

-- What was the most commonly added extra?

WITH extras_added AS(
SELECT T.topping_id, T.topping_name, COUNT(*) t_count
FROM customer_orders CO
JOIN pizza_toppings T
ON FIND_IN_SET(T.topping_id, REPLACE(CO.extras, ' ', ''))
WHERE CO.extras IS NOT NULL
GROUP BY T.topping_id, T.topping_name)

SELECT topping_name most_ord_extras FROM extras_added
WHERE t_count = (SELECT MAX(t_count) FROM extras_added);


-- What was the most common exclusion?

WITH exclusion_added AS(
SELECT T.topping_id, T.topping_name, COUNT(*) t_count
FROM customer_orders CO
JOIN pizza_toppings T
ON FIND_IN_SET(T.topping_id, REPLACE(CO.exclusions, ' ', ''))
WHERE CO.exclusions IS NOT NULL
GROUP BY T.topping_id)

SELECT topping_name most_comm_exclusion FROM exclusion_added
WHERE t_count = (SELECT MAX(t_count) FROM exclusion_added);


/* Generate an order item for each record in the customers_orders table in the format of one of the following:
Meat Lovers
Meat Lovers - Exclude Beef
Meat Lovers - Extra Bacon
Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers*/

WITH exc AS(
SELECT CO.order_id, CO.pizza_id, T.topping_id, T.topping_name
FROM customer_orders CO
JOIN pizza_toppings T
ON FIND_IN_SET(T.topping_id, REPLACE(CO.exclusions, ' ', ''))
WHERE CO.exclusions IS NOT NULL),

ext AS(
SELECT CO.order_id, CO.pizza_id, T.topping_id, T.topping_name
FROM customer_orders CO
JOIN pizza_toppings T
ON FIND_IN_SET(T.topping_id, REPLACE(CO.extras, ' ', ''))
WHERE CO.extras IS NOT NULL
),
Extras AS (
SELECT order_id, GROUP_CONCAT(topping_name ORDER BY topping_name SEPARATOR ', ') extras
FROM pizza_names PN
JOIN ext EX
USING(pizza_id)
WHERE pizza_name = 'Meatlovers'
AND topping_name IN ('Bacon', 'Cheese')
GROUP BY order_id),

Exclusions AS(
SELECT order_id, GROUP_CONCAT(topping_name ORDER BY topping_name SEPARATOR ', ') Exclusions
FROM exc
JOIN pizza_names
USING(pizza_id)
WHERE pizza_name = 'Meatlovers'
AND topping_name IN ('Mushrooms', 'Peppers')
GROUP BY order_id)

(SELECT COALESCE(EXC.order_id,EXT.order_id) order_id, Exclusions, extras FROM Exclusions EXC
LEFT JOIN Extras EXT
ON EXC.order_id = EXT.order_id)
UNION
(SELECT COALESCE(EXC.order_id,EXT.order_id) order_id, Exclusions, extras FROM Exclusions EXC
RIGHT JOIN Extras EXT
ON EXC.order_id = EXT.order_id);

/*Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
  For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"*/



-- What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

WITH extras_count AS(
SELECT T.topping_name, COUNT(*) ext_qnt FROM customer_orders CO
JOIN runner_orders RO
USING(order_id)
JOIN pizza_toppings T
ON FIND_IN_SET(T.topping_id, REPLACE(CO.extras, ' ', '') )
WHERE RO.cancellation IS NULL
GROUP BY T.topping_name),

exclusion_count AS(
SELECT T.topping_name, COUNT(*) exc_qnt FROM customer_orders CO
JOIN runner_orders RO
USING(order_id)
JOIN pizza_toppings T
ON FIND_IN_SET(T.topping_id, REPLACE(CO.exclusions, ' ', '') )
WHERE RO.cancellation IS NULL
GROUP BY T.topping_name),

stand_indg_count AS(
SELECT T.topping_name, COUNT(*) s_qnt FROM pizza_recipes PR
JOIN pizza_toppings T
ON FIND_IN_SET(T.topping_id, REPLACE(PR.toppings, ' ', ''))
GROUP BY T.topping_name)

SELECT topping_name, 
COALESCE(s_qnt,0) - COALESCE(exc_qnt,0) + COALESCE(ext_qnt,0) total_quantity
FROM pizza_toppings PT
LEFT JOIN stand_indg_count SIC
USING(topping_name)
LEFT JOIN exclusion_count EXC
USING(topping_name)
LEFT JOIN extras_count EXT
USING(topping_name);


-- D. Pricing and Ratings
-- If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?

SELECT SUM(IF(PN.pizza_name = 'Meatlovers', 12, 10)) total_earning FROM customer_orders CO
JOIN pizza_names PN
USING(pizza_id)
JOIN runner_orders RO
USING(order_id)
WHERE RO.cancellation IS NULL;


/* What if there was an additional $1 charge for any pizza extras?
   Add cheese is $1 extra */

WITH earnings AS (
SELECT SUM(IF(PN.pizza_name = 'Meatlovers', 12, 10)) earning FROM customer_orders CO
JOIN pizza_names PN
USING(pizza_id)
JOIN runner_orders RO
USING(order_id)
WHERE RO.cancellation IS NULL),

eaxtra_earnings AS(
SELECT SUM(IF(T.topping_name = 'Cheese', 2, 1)) e_earning FROM customer_orders CO
JOIN pizza_toppings T
ON FIND_IN_SET(T.topping_id, REPLACE(CO.extras, ' ', ''))
JOIN runner_orders RO
USING(order_id)
WHERE RO.cancellation IS NULL)

SELECT earning + e_earning total_earning FROM earnings, eaxtra_earnings;


-- The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.

CREATE TABLE runner_ratings(
	runner_id INT, 
    order_id INT,
    customer_id INT, 
    order_time TIMESTAMP, 
    distance DECIMAL(5 , 2), 
    duration INT, 
    rating INT
);

INSERT INTO runner_ratings (runner_id, order_id, customer_id, order_time, distance, duration, rating)
SELECT runner_id, order_id, customer_id, order_time, distance, duration, rating FROM
(
WITH avg_speed AS (
SELECT ROUND(AVG(distance) / AVG(duration/60)) `spead(km/hr)`
FROM runner_orders
WHERE cancellation IS NULL),

rating AS (
SELECT 
RO.runner_id, RO.order_id, CO.customer_id, CO.order_time, RO.distance, RO.duration,
CASE
	WHEN ROUND(RO.distance / (RO.duration/60)) < 16 THEN 1
    WHEN ROUND(RO.distance / (RO.duration/60)) BETWEEN 16 AND 25 THEN 2
    WHEN ROUND(RO.distance / (RO.duration/60)) BETWEEN 26 AND 35 THEN 3
    WHEN ROUND(RO.distance / (RO.duration/60)) BETWEEN 36 AND 45 THEN 4
    ELSE 5
END rating, ROW_NUMBER() OVER(PARTITION BY RO.runner_id, RO.order_id) row_num
FROM customer_orders CO
JOIN runner_orders RO
USING(order_id)
WHERE cancellation IS NULL)

SELECT runner_id, order_id, customer_id, order_time, distance, duration, rating FROM rating
WHERE row_num = 1
) sub_query;

SELECT * FROM runner_ratings;

/*  Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
	customer_id
	order_id
	runner_id
	rating
	order_time
	pickup_time
	Time between order and pickup
	Delivery duration
	Average speed
	Total number of pizzas */
    
SELECT CO.customer_id,
	CO.order_id,
	RO.runner_id,
	RR.rating,
	CO.order_time,
	RO.pickup_time,
	TIMESTAMPDIFF(MINUTE, CO.order_time, RO.pickup_time) time_diff_min,
	RO.duration,
	ROUND(RO.distance/(RO.duration/60),2) Average_speed,
	COUNT(*) Total_num_pizza
FROM runner_ratings RR
JOIN runner_orders RO
USING(runner_id, order_id)
JOIN customer_orders CO
USING(order_id)
WHERE RO.cancellation IS NULL
GROUP BY CO.customer_id,
	CO.order_id,
	RO.runner_id;
    
-- If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?

SELECT 
RO.runner_id, 
ROUND(SUM(IF(PN.pizza_name = 'Meatlovers', 12, 10)) + (SUM(distance)*0.30)) runner_earning
FROM runner_orders RO
JOIN customer_orders CO
USING(order_id)
JOIN pizza_names PN
USING(pizza_id)
GROUP BY RO.runner_id;
