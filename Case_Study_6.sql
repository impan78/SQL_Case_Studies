/********************************************                              *******************************************
										        Case Study #6 Clique Bait
*********************************************                              ******************************************/

-- 2. Digital Analysis
-- Using the available datasets - answer the following questions using a single query for each one:
-- How many users are there?

SELECT COUNT(DISTINCT user_id) users FROM users;

-- How many cookies does each user have on average?

SELECT ROUND(AVG(count), 2) avg_c FROM
(SELECT user_id, COUNT(cookie_id) count FROM users
GROUP BY user_id) sub_query;

-- What is the unique number of visits by all users per month?

SELECT DATE_FORMAT(event_time, '%Y-%m') month_, COUNT(DISTINCT visit_id) visits FROM events
GROUP BY month_;

-- What is the number of events for each event type?

SELECT event_name, COUNT(*) num_events FROM event_identifier
JOIN events
USING(event_type)
GROUP BY event_name;

-- What is the percentage of visits which have a purchase event?

SELECT event_name, ROUND(100.0*COUNT(DISTINCT visit_id)/ (SELECT COUNT(DISTINCT visit_id) FROM events), 2) purchase_percentage FROM event_identifier
JOIN events
USING(event_type)
WHERE event_name = 'Purchase'
GROUP BY event_name;   

-- What is the percentage of visits which view the checkout page but do not have a purchase event?

WITH pur_visits AS
(SELECT DISTINCT visit_id FROM event_identifier
JOIN events
USING(event_type)
WHERE event_name ='Purchase')


SELECT ROUND(100*COUNT(visit_id)/(SELECT COUNT(visit_id) FROM events), 2) perc FROM event_identifier
JOIN events
USING(event_type)
WHERE visit_id NOT IN (SELECT visit_id FROM pur_visits)
AND event_name ='Page View';


-- What are the top 3 pages by number of views?

WITH page_view AS(
SELECT page_name, COUNT(*) page_visited_count,  
DENSE_RANK() OVER(ORDER BY COUNT(*) DESC) rank_
FROM event_identifier
JOIN events
USING(event_type)
JOIN page_hierarchy
USING(page_id)
WHERE event_name ='Page View'
GROUP BY page_name)

SELECT page_name, page_visited_count
FROM page_view
WHERE rank_ < 4;

-- What is the number of views and cart adds for each product category?

SELECT product_category,
SUM(CASE
		WHEN event_name ='Page View' THEN 1 ELSE 0
	END) no_views,
SUM(CASE
		WHEN event_name ='Add to Cart' THEN 1 ELSE 0
	END) no_carts_added
FROM page_hierarchy
JOIN events
USING(page_id)
JOIN event_identifier
USING(event_type)
WHERE product_category IS NOT NULL
GROUP BY product_category;

-- What are the top 3 products by purchases?

SELECT product_id, COUNT(*) purchases
FROM page_hierarchy
JOIN events
USING(page_id)
JOIN event_identifier
USING(event_type)
WHERE event_name = 'Purchase'
GROUP BY product_id
ORDER BY purchases;

-- 3. Product Funnel Analysis
-- Using a single SQL query - create a new output table which has the following details:
-- How many times was each product viewed?
-- How many times was each product added to cart?
-- How many times was each product added to a cart but not purchased (abandoned)?
-- How many times was each product purchased?

CREATE TABLE product_funnel_analysis AS
SELECT 
    p.product_id,
    COUNT(CASE WHEN ei.event_name = 'Page View' THEN 1 END) AS product_views,
    COUNT(CASE WHEN ei.event_name = 'Add to Cart' THEN 1 END) AS cart_adds,
    COUNT(CASE WHEN ei.event_name = 'Add to Cart' 
               AND p.product_id NOT IN (
                   SELECT DISTINCT p2.product_id
                   FROM events e2
                   JOIN page_hierarchy p2 ON e2.page_id = p2.page_id
                   JOIN event_identifier ei2 ON e2.event_type = ei2.event_type
                   WHERE ei2.event_name = 'Purchase'
               ) THEN 1 END) AS cart_abandonments,
    COUNT(CASE WHEN ei.event_name = 'Purchase' THEN 1 END) AS purchases
FROM events e
JOIN page_hierarchy p ON e.page_id = p.page_id
JOIN event_identifier ei ON e.event_type = ei.event_type
GROUP BY p.product_id
ORDER BY product_views DESC;


-- Additionally, create another table which further aggregates the data for the above points but this time for each product category instead of individual products.


CREATE TABLE product_funnel_analysis_by_category AS
SELECT 
    p.product_category,
    COUNT(CASE WHEN ei.event_name = 'Page View' THEN 1 END) AS product_views,
    COUNT(CASE WHEN ei.event_name = 'Add to Cart' THEN 1 END) AS cart_adds,
    COUNT(CASE WHEN ei.event_name = 'Add to Cart' 
               AND p.product_id NOT IN (
                   SELECT DISTINCT p2.product_id
                   FROM events e2
                   JOIN page_hierarchy p2 ON e2.page_id = p2.page_id
                   JOIN event_identifier ei2 ON e2.event_type = ei2.event_type
                   WHERE ei2.event_name = 'Purchase'
               ) THEN 1 END) AS cart_abandonments,
    COUNT(CASE WHEN ei.event_name = 'Purchase' THEN 1 END) AS purchases
FROM events e
JOIN page_hierarchy p ON e.page_id = p.page_id
JOIN event_identifier ei ON e.event_type = ei.event_type
GROUP BY p.product_category;

