/********************************************                              *******************************************
                                                 Case Study #5 Data Mart
*********************************************                              ******************************************/

/* 1. Data Cleansing Steps
In a single query, perform the following operations and generate a new table in the data_mart schema named clean_weekly_sales:
Convert the week_date to a DATE format
Add a week_number as the second column for each week_date value, for example any value from the 1st of January to 7th of January will be 1, 8th to 14th will be 2 etc
Add a month_number with the calendar month for each week_date value as the 3rd column
Add a calendar_year column as the 4th column containing either 2018, 2019 or 2020 values
Add a new column called age_band after the original segment column using the following mapping on the number inside the segment value
Add a new demographic column using the following mapping for the first letter in the segment values:
Ensure all null string values with an "unknown" string value in the original segment column as well as the new age_band and demographic columns
Generate a new avg_transaction column as the sales value divided by transactions rounded to 2 decimal places for each record
*/


CREATE TABLE clean_weekly_sales AS  
SELECT  
    STR_TO_DATE(week_date, '%d/%m/%y') AS week_date,  
    WEEK(week_date, 1) AS week_number,  
    MONTH(week_date) AS month_number,  
    YEAR(week_date) AS calendar_year,  
    region,  
    platform,  
    segment,  
    CASE  
        WHEN segment REGEXP '[0-9]+' THEN  
            CASE  
                WHEN CAST(REGEXP_SUBSTR(segment, '[0-9]+') AS UNSIGNED) BETWEEN 1 AND 15 THEN 'Young Adults'  
                WHEN CAST(REGEXP_SUBSTR(segment, '[0-9]+') AS UNSIGNED) BETWEEN 16 AND 30 THEN 'Middle Aged'  
                WHEN CAST(REGEXP_SUBSTR(segment, '[0-9]+') AS UNSIGNED) BETWEEN 31 AND 50 THEN 'Older Adults'  
                ELSE 'Unknown'  
            END  
        ELSE 'Unknown'  
    END AS age_band,  
    CASE  
        WHEN segment LIKE 'C%' THEN 'Couples'  
        WHEN segment LIKE 'F%' THEN 'Families'  
        ELSE 'Unknown'  
    END AS demographic,  
    customer_type,  
    transactions,  
    sales,  
    ROUND(sales / NULLIF(transactions, 0), 2) AS avg_transaction  
FROM weekly_sales;




-- 2. Data Exploration
-- What day of the week is used for each week_date value?

SELECT DISTINCT DAYNAME(week_date)  FROM clean_weekly_sales;

-- What range of week numbers are missing from the dataset?

WITH week_data AS(
SELECT n AS week_number
FROM (SELECT ROW_NUMBER() OVER () AS n FROM information_schema.columns) AS numbers
WHERE n <= 52),

ws_Data AS (
SELECT DISTINCT week_number FROM clean_weekly_sales)


SELECT WD.week_number FROM week_data WD
LEFT JOIN ws_Data WS
ON WD.week_number = WS.week_number
WHERE WS.week_number IS NULL;


-- How many total transactions were there for each year in the dataset?

SELECT YEAR(week_date) year, SUM(transactions) total_trans FROM  clean_weekly_sales
GROUP BY year;

-- What is the total sales for each region for each month?

SELECT DATE_FORMAT(week_date, '%Y-%m') month, region, SUM(sales) total_sales FROM clean_weekly_sales
GROUP BY month, region;

-- What is the total count of transactions for each platform

SELECT platform, COUNT(*) trans_count FROM clean_weekly_sales
GROUP BY platform;

-- What is the percentage of sales for Retail vs Shopify for each month?

SELECT ROUND(100.0*SUM(CASE WHEN platform= 'Retail'THEN sales ELSE 0 END)/SUM(sales), 2) retail_perc, 
ROUND(100.0*SUM(CASE WHEN platform= 'Shopify'THEN sales ELSE 0 END)/SUM(sales), 2) shopify_perc
FROM clean_weekly_sales;

-- What is the percentage of sales by demographic for each year in the dataset?

WITH sales_demog AS(
SELECT YEAR(week_date) year_, 
demographic,
SUM(sales) curnt_year_sales, 
COALESCE(LAG(SUM(sales)) OVER(PARTITION BY demographic ORDER BY YEAR(week_date)),0) prev_year_sales
FROM clean_weekly_sales
GROUP BY year_, demographic)

SELECT year_,demographic, curnt_year_sales, prev_year_sales,
COALESCE(ROUND(100.0*(curnt_year_sales-prev_year_sales)/prev_year_sales, 2), 0) percentage
FROM sales_demog
ORDER BY year_ DESC;

-- Which age_band and demographic values contribute the most to Retail sales?

WITH age_demog AS (
SELECT age_band, demographic,
SUM(sales) total_sales, 
DENSE_RANK() OVER(ORDER BY SUM(sales) DESC) rank_
FROM clean_weekly_sales
WHERE platform = 'Retail'
GROUP BY age_band, demographic)

SELECT age_band, demographic, total_sales FROM age_demog
WHERE rank_ = 1;

-- Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?

SELECT YEAR(week_date) year_, platform, ROUND(SUM(sales) / SUM(transactions), 2) avg_trans_size FROM clean_weekly_sales
GROUP BY year_, platform;


-- 3. Before & After Analysis
-- This technique is usually used when we inspect an important event and want to inspect the impact before and after a certain point in time.
-- Taking the week_date value of 2020-06-15 as the baseline week where the Data Mart sustainable packaging changes came into effect.
-- We would include all week_date values for 2020-06-15 as the start of the period after the change and the previous week_date values would be before
-- Using this analysis approach - answer the following questions:

SELECT * FROM clean_weekly_sales
WHERE week_date < '2020-06-15';

SELECT * FROM clean_weekly_sales
WHERE week_date >= '2020-06-15';

-- What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales?

SELECT 
SUM(CASE 
	WHEN week_date BETWEEN DATE_SUB('2020-06-15', INTERVAL 4 WEEK) AND DATE_SUB('2020-06-15', INTERVAL 1 WEEK)  
    THEN sales
    ELSE 0
END)
    total_sales4before,
SUM(CASE 
	WHEN week_date BETWEEN '2020-06-15' AND DATE_ADD('2020-06-15', INTERVAL 4 WEEK)
    THEN sales
    ELSE 0
END)
    total_sales4after
FROM clean_weekly_sales;


-- What about the entire 12 weeks before and after?

SELECT 
SUM(CASE 
	WHEN week_date BETWEEN DATE_SUB('2020-06-15', INTERVAL 12 WEEK) AND DATE_SUB('2020-06-15', INTERVAL 1 WEEK)
    THEN sales
    ELSE 0
END)
    total_sales12before,
SUM(CASE 
	WHEN week_date BETWEEN '2020-06-15' AND DATE_ADD('2020-06-15', INTERVAL 12 WEEK)
    THEN sales
    ELSE 0
END)
    total_sales12after
FROM clean_weekly_sales;

-- How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?


-- 4. Bonus Question
-- Which areas of the business have the highest negative impact in sales metrics performance in 2020 for the 12 week before and after period?
-- region
-- platform
-- age_band
-- demographic
-- customer_type



