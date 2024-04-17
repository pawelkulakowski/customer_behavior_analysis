

-- how many customers registered in the first six months of 2017?

SELECT 
	COUNT(customer_id) AS registration_count
FROM 
    customers
WHERE 
	registration_date >= '2017-01-01' AND
    registration_date < CAST('2017-01-01' AS DATE) + INTERVAL '6' MONTH

-- 164 clients registered in the first six months of 2017

-- Checking how many customers registered in the current week

SELECT
	COUNT(customer_id) AS registrations_current_week
FROM
	customers
WHERE
	DATE_TRUNC('week', registration_date) = DATE_TRUNC('week', CURRENT_TIMESTAMP)

-- 2 clients were registered in the current week

-- How many customers registered in each month of 2017?

SELECT
	DATE_TRUNC('month', registration_date) AS registration_month,
	COUNT(customer_id) AS registration_count
FROM
	customers
WHERE
	EXTRACT(YEAR from registration_date) = 2017
GROUP BY
	DATE_TRUNC('month', registration_date)
ORDER BY
	DATE_TRUNC('month', registration_date)


-- 01: 27, 02: 23, 03: 29, 04: 29, 05: 29, 06: 27, 07: 25, 08: 33, 09: 27, 10: 28, 11: 29, 12: 28

-- How many customers were registered in each month in each year?

SELECT
	DATE_TRUNC('month', registration_date) AS registration_month,
    COUNT(customer_id) AS registration_count
FROM
	customers
GROUP BY
	DATE_TRUNC('month', registration_date)
ORDER BY
	DATE_TRUNC('month', registration_date)

-- A customer cohort is a group of customers that share a common characteristic over a certain time period. 
-- A channel defines how we obtained a customer: from social media, via friend referral 
-- Analyzing how many customers registered in each week by channel

SELECT
	DATE_TRUNC('week', c.registration_date) AS registration_week,
    ch.channel_name,
    COUNT(c.customer_id) AS registration_count
FROM
	customers c
INNER JOIN
	channels ch
ON
	c.channel_id = ch.id
GROUP BY
	DATE_TRUNC('week', c.registration_date),
    ch.channel_name
ORDER BY
	DATE_TRUNC('week', c.registration_date)

-- Analyzing weekly counts of registration cohorts in 2017

SELECT
	DATE_TRUNC('week', registration_date) AS registration_week,
    country,
    COUNT(customer_id) AS registration_count
FROM
	customers
WHERE
	EXTRACT(YEAR from registration_date) = 2017
GROUP BY
	DATE_TRUNC('week', registration_date),
    country
ORDER BY
	DATE_TRUNC('week', registration_date)

-- Analyzing number of registrations in current year

SELECT
	COUNT(customer_id) AS registrations_this_year
FROM
	customers
WHERE
	EXTRACT(YEAR FROM registration_date) = EXTRACT(YEAR FROM CURRENT_TIMESTAMP)


-- Customer conversion is defined as "any desired event or action that is related to customers." A conversion occurs when a customer completes a desired action, 
-- such as signing up for the newsletter, social media share, filling out a form, or making a purchase. We typically talk about conversion rates, 
-- which are the percentages of prospective customers who take a specific action that we want.

SELECT
	customer_id,
    first_order_id,
    first_order_date,
    last_order_id,
    last_order_date
FROM
	customers
WHERE
	city = 'London'

-- we want to calculate the global lifetime conversion rate. In other words, we want to know the percentage of registered customers who've made at least one purchase

SELECT
	COUNT(first_order_id) AS customers_with_purchase,
	COUNT(customer_id) AS all_customers
FROM
	customers
WHERE
	EXTRACT(YEAR FROM registration_date) = 2017

-- 334 all customers, 307 with purchase in 2017.

SELECT
	ROUND(COUNT(first_order_id) / CAST(COUNT(customer_id) AS Numeric)*100.0, 2) AS conversion_rate
FROM
	customers
WHERE
	EXTRACT(YEAR FROM registration_date) = 2017

-- conversion rate 91.92%

-- Analyzing conversion rate for each customer channel

SELECT
	channel_name,
    ROUND(COUNT(first_order_id) / CAST(COUNT(customer_id) AS Numeric)*100.0, 2) AS conversion_rate
FROM
	customers
INNER JOIN
	channels
ON
	customers.channel_id = channels.id
GROUP BY
	channel_name

-- Paid Search and Social with highest conversion rate!

-- Analyzing conversion rates in monthly cohorts

SELECT
	DATE_TRUNC('month', registration_date) AS month,
    ROUND(COUNT(first_order_id) / CAST(COUNT(customer_id) AS Numeric), 3) AS conversion_rate
FROM
	customers
GROUP BY
	DATE_TRUNC('month', registration_date)
ORDER BY
	DATE_TRUNC('month', registration_date)

-- Declining trend in conversion rate within months

-- Analyzing conversion rates for weekly registration cohorts in each registration channel based on customers registered in 2017
SELECT
	DATE_TRUNC('week', registration_date) AS week,
    channel_name,
    ROUND(COUNT(first_order_id) / CAST(COUNT(customer_id) AS Numeric)*100.0, 1) AS conversion_rate
FROM
	customers
INNER JOIN
	channels
ON
	customers.channel_id = channels.id
WHERE
	EXTRACT(YEAR FROM registration_date) = 2017
GROUP BY
	DATE_TRUNC('week', registration_date),
    channel_name
ORDER BY
	DATE_TRUNC('week', registration_date),
    channel_name
    

-- Analyzing interval between customer first pruchase date and registration date
SELECT
	email,
    first_order_date - registration_date as difference
FROM
	customers

--  global average time from registration to first order by channel.

SELECT
	channel_name,
    AVG(first_order_date - registration_date) AS avg_days_to_first_order
FROM
	customers
INNER JOIN
	channels
ON
	customers.channel_id = channels.id
GROUP BY
	channel_name

-- Paid Search, Referral, Social with the quickest purchasing

-- Analyzing average number of days between registration and first order in quarterly registration cohots
SELECT
	DATE_TRUNC('quarter', registration_date) AS quarter,
    AVG(first_order_date - registration_date) AS avg_days_to_first_order
FROM
	customers
GROUP BY
	DATE_TRUNC('quarter', registration_date)
ORDER BY
	DATE_TRUNC('quarter', registration_date)

-- Analyzing average time to first order for weekly registration cohorts in 2017 in each registration channel
SELECT
	DATE_TRUNC('week', registration_date) AS week,
    channel_name,
    AVG(first_order_date - registration_date) AS avg_days_to_first_order
FROM
	customers
INNER JOIN
	channels
ON
	customers.channel_id = channels.id
WHERE
	EXTRACT(YEAR FROM registration_date) = 2017
GROUP BY
	DATE_TRUNC('week', registration_date),
    channel_name

-- Getting customers details who place first order within one month from registration date and their last order within three months from registration
SELECT
	email,
    full_name,
    first_order_date,
    last_order_date
FROM
	customers
WHERE 
	first_order_date - registration_date <= INTERVAL '1' MONTH AND
    last_order_date - registration_date <= INTERVAL '3' MONTH


-- grouping customers by e-store thre versions of the registration form (ver1 - introduced  when the e-store started; ver2 - introduced on 2017-03-14; ver3 - 2018-01-01)
SELECT
	customer_id,
    registration_date,
    CASE
    	WHEN registration_date < '2017-03-14' THEN 'ver1'
        WHEN registration_date < '2018-01-01' THEN 'ver2'
        ELSE 'ver3'
    END AS
    registration_form
FROM
	customers

-- checking how many customers made their first purchase on the registration day
SELECT
	COUNT
    	(CASE WHEN first_order_date - registration_date < INTERVAL '1' DAY THEN customer_id END) AS order_on_registration_date,
    COUNT
    	(CASE WHEN first_order_date - registration_date >= INTERVAL '1' DAY THEN customer_id END) AS
    order_after_registration_date
FROM
	customers

-- 32 customer made the order within one-day; 729 after the registration date

-- conversion chart for monthly registration cohorts
SELECT
	DATE_TRUNC('month', registration_date) AS month,
    COUNT(customer_id) AS registered_count,
    COUNT(CASE WHEN first_order_date IS NULL THEN customer_id END) AS no_sale,
    COUNT(CASE WHEN first_order_date - registration_date < INTERVAL '3' DAY THEN customer_id END) AS three_days,
    COUNT(CASE WHEN first_order_date - registration_date BETWEEN INTERVAL '3' DAY AND INTERVAL '6' DAY THEN customer_id END) AS first_week,
    COUNT(CASE WHEN first_order_date - registration_date >= INTERVAL '7' DAY THEN customer_id END) AS after_first_week
FROM
	customers
GROUP BY
	DATE_TRUNC('month', registration_date)
ORDER BY
	DATE_TRUNC('month', registration_date)

-- conversion chart for monthly registration cohorts in 2017 for each channel

SELECT
	DATE_TRUNC('month', registration_date) AS month,
    channel_name,
    COUNT(customer_id) AS registered_count,
    COUNT(CASE WHEN first_order_id IS NULL THEN customer_id END) AS no_sale,
    COUNT(CASE WHEN first_order_date - registration_date < INTERVAL '7' DAY THEN customer_id END) AS one_week,
    COUNT(CASE WHEN first_order_date - registration_date >= INTERVAL '7' DAY THEN customer_id END) AS after_one_week
FROM
	customers
INNER JOIN
	channels
ON
	customers.channel_id = channels.id
WHERE
	EXTRACT(YEAR FROM registration_date) = 2017
GROUP BY
	DATE_TRUNC('month', registration_date),
    channel_name
ORDER BY
	DATE_TRUNC('month', registration_date)

-- Global average time that passed between the registration and the first order
SELECT
	AVG(first_order_date - registration_date) AS avg_time_to_first_order
FROM
	customers
-- 22 days

-- Counting number of customers who placed their most recent order in 2018
SELECT
	COUNT(customer_id) AS count_2018_customers
FROM
	customers
WHERE
	EXTRACT(YEAR FROM last_order_date) = 2018

-- Active customers by country
SELECT
	country,
    COUNT(customer_id) AS active_customers
FROM
	customers
WHERE 
	CURRENT_DATE - last_order_date < INTERVAL '30' DAY
GROUP BY
	country

-- Active customers in particular cohorts
SELECT
	DATE_TRUNC('month', registration_date) AS month,
    COUNT(customer_id) AS active_customers
FROM
	customers
WHERE
	EXTRACT(YEAR FROM registration_date) = 2017 AND
    CURRENT_DATE - last_order_date < INTERVAL '30' DAY
GROUP BY
	DATE_TRUNC('month', registration_date)
ORDER BY
	DATE_TRUNC('month', registration_date)


-- Number of active customers in quarterly registration cohorts
SELECT
	DATE_TRUNC('quarter', registration_date) AS quarter,
    COUNT(customer_id) AS active_customers
FROM
	customers
WHERE
	CURRENT_DATE - last_order_date < INTERVAL '14' DAY
GROUP BY
	DATE_TRUNC('quarter', registration_date)
ORDER BY
	DATE_TRUNC('quarter', registration_date)

-- Average orer value for weekly registration cohorts from 2017 for orders shipped to Germany
SELECT
	DATE_TRUNC('week', registration_date) AS week,
    AVG(total_amount) AS average_order_value
FROM
	customers
INNER JOIN
	orders
ON
	customers.customer_id = orders.customer_id
WHERE
	EXTRACT(YEAR FROM registration_date) = 2017 AND
    LOWER(ship_country) = 'germany' 
GROUP BY
	DATE_TRUNC('week', registration_date)
ORDER BY
	DATE_TRUNC('week', registration_date) DESC

-- Each country's average order value per customer
WITH average_per_country AS (
SELECT
  	c.customer_id,
	c.country,
    AVG(o.total_amount) AS avg_order_value
FROM
	customers c
INNER JOIN
	orders o
ON
	c.customer_id = o.customer_id
GROUP BY
	c.customer_id, c.country
ORDER BY
	AVG(o.total_amount) ASC)
    
SELECT
	country,
	AVG(avg_order_value) AS avg_order_value
FROM
	average_per_country
GROUP BY
	country
ORDER BY
	AVG(avg_order_value) ASC

-- Average number of orders placed in the last 180 days by customers who have been active (made a purchase) in the last 30 days

WITH orders_count AS(
SELECT
	c.customer_id,
    COUNT(o.order_id) AS order_count
FROM
	customers c
INNER JOIN
	orders o
ON
	c.customer_id = o.customer_id
WHERE
	CURRENT_DATE - last_order_date < INTERVAL '30' DAY AND
    CURRENT_DATE - o.order_date < INTERVAL '180' DAY
GROUP BY
	c.customer_id)


SELECT
	AVG(order_count) AS avg_order_count
FROM
	orders_count

-- Good customers in France

SELECT
	c.customer_id,
    c.full_name,
    AVG(o.total_amount) AS avg_order_value
FROM
	customers c
INNER JOIN
	orders o
ON
	c.customer_id = o.customer_id
WHERE
	c.country = 'France'
GROUP BY
	c.customer_id,
    c.full_name
HAVING
	AVG(o.total_amount) > 1564.853
ORDER BY
	AVG(o.total_amount) DESC

--Number of good customers in quarterly registion cohorts
WITH good_customers AS (
SELECT
  c.customer_id,
  c.registration_date,
  c.full_name,
  c.country,
  AVG(total_amount) AS avg_order_value
FROM customers c
JOIN orders o
  ON c.customer_id = o.customer_id
GROUP BY
  c.customer_id,
  c.registration_date,
  c.full_name,
  c.country
HAVING AVG(total_amount) > 1905.9063
ORDER BY AVG(total_amount) DESC)

SELECT
	DATE_TRUNC('quarter', registration_date) AS quarter,
	COUNT(customer_id) AS good_customers
FROM 
	good_customers
GROUP BY
	DATE_TRUNC('quarter', registration_date)
ORDER BY
	DATE_TRUNC('quarter', registration_date)


WITH good_customers AS (
  SELECT
    c.customer_id,
    c.registration_date,
    c.country,
    AVG(total_amount) AS avg_order_value
  FROM customers c
  JOIN orders o
    ON c.customer_id = o.customer_id
  GROUP BY
    c.customer_id,
    c.registration_date,
    c.country
  HAVING AVG(total_amount) > 1905.9063
)

SELECT
  DATE_TRUNC('quarter', registration_date) AS quarter,
  country,
  COUNT(*) AS good_customers
FROM good_customers
GROUP BY
  DATE_TRUNC('quarter', registration_date),
  country
ORDER BY DATE_TRUNC('quarter', registration_date);

-- number of good customers (avg above 1500.00) in weekly registration and city cohorts
WITH good_customers AS (
SELECT
	c.customer_id,
    c.registration_date,
    c.city,
    AVG(o.total_amount) AS avg_order_value
FROM customers c
INNER JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY
	c.customer_id,
    c.registration_date,
    c.city
HAVING
	AVG(o.total_amount) > 1500)
    
SELECT
	DATE_TRUNC('week', registration_date) AS week,
    city,
    COUNT(*) AS good_customers
FROM
	good_customers
GROUP BY
	DATE_TRUNC('week', registration_date),
    city
ORDER BY
	DATE_TRUNC('week', registration_date)

-- Number of active customers in each month of 2017

SELECT
	DATE_TRUNC('month', registration_date) AS month,
    COUNT(CASE WHEN CURRENT_DATE - last_order_date < INTERVAL '60' DAY THEN customer_id END) AS active_customers
FROM
	customers
WHERE
	EXTRACT(YEAR FROM registration_date) = 2017
GROUP BY
	DATE_TRUNC('month', registration_date)
ORDER BY
	DATE_TRUNC('month', registration_date)

-- Number of churned customers registered in 2017

SELECT
	COUNT(customer_id) AS churned_customers
FROM
	customers
WHERE
	CURRENT_DATE - last_order_date > INTERVAL '60' day AND
    EXTRACT(YEAR FROM registration_date) = 2017

-- Number of churned customers in monthly registration cohorts from 2017
SELECT
	DATE_TRUNC('month', registration_date) AS month,
    COUNT(customer_id) AS churned_customers
FROM
	customers
WHERE
	CURRENT_DATE - last_order_date > INTERVAL '45' DAY AND
    EXTRACT(YEAR FROM registration_date) = 2017
GROUP BY
	DATE_TRUNC('month', registration_date)
ORDER BY
	DATE_TRUNC('month', registration_date)

-- Ratio of churned customers in monthly cohorts in 2017
SELECT
    DATE_TRUNC('month', registration_date) AS month,
    COUNT(customer_id) AS all_customers,
    COUNT(CASE WHEN CURRENT_DATE - last_order_date > INTERVAL '45' DAY THEN customer_id END) AS churned_customers,
    COUNT(CASE WHEN CURRENT_DATE - last_order_date > INTERVAL '45' DAY THEN customer_id END) *100.0 / CAST(COUNT(customer_id) AS Numeric) AS churned_percentage
FROM 
    customers
WHERE 
    registration_date >= '2017-01-01' AND registration_date < '2018-01-01'
GROUP BY 
    DATE_TRUNC('month', registration_date)
ORDER BY 
    DATE_TRUNC('month', registration_date);

-- Customer retention chart

SELECT
  DATE_TRUNC('week', registration_date) AS week,
  COUNT(CASE
    WHEN last_order_date - registration_date > INTERVAL '10' day
    THEN customer_id
  END) * 100.0 / COUNT(customer_id) AS percent_active_10d,
  COUNT(CASE
    WHEN last_order_date - registration_date > INTERVAL '30' day
    THEN customer_id
  END) * 100.0 / COUNT(customer_id) AS percent_active_30d,
  COUNT(CASE
    WHEN last_order_date - registration_date > INTERVAL '60' day
    THEN customer_id
  END) * 100.0 / COUNT(customer_id) AS percent_active_60d
FROM 
	customers
WHERE 
	registration_date >= '2017-01-01' AND registration_date < '2018-01-01'
GROUP BY 
	DATE_TRUNC('week', registration_date)
ORDER BY 
	DATE_TRUNC('week', registration_date);
    


-- Report that compares the number of acquired customers in weekly registration cohorts across selected channels (first quarter 2017)

SELECT
	DATE_TRUNC('week', registration_date) AS registration_week,
    COUNT(CASE WHEN channel_name = 'Direct' THEN customer_id END) AS direct_count,
    COUNT(CASE WHEN channel_name = 'Social' THEN customer_id END) AS social_count,
    COUNT(CASE WHEN channel_name = 'Referral' THEN customer_id END) AS referral_count
FROM
	customers
INNER JOIN
	channels
ON
	customers.channel_id = channels.id
WHERE
	registration_date BETWEEN '2017-01-01' AND '2017-03-31'
GROUP BY
	DATE_TRUNC('week', registration_date)
ORDER BY
	DATE_TRUNC('week', registration_date)

-- Conversion chart showing the 2017 Q1 monthly registration cohorts and the number of conversations in first week/two weeks/more than two weeks after registration
SELECT
	DATE_TRUNC('month', registration_date) AS month,
    COUNT(CASE WHEN first_order_id IS NULL THEN customer_id END) AS no_sale,
    COUNT(CASE WHEN first_order_date - registration_date < INTERVAL '7' DAY THEN customer_id END) AS first_week,
    COUNT(CASE WHEN first_order_date - registration_date >= INTERVAL '7' day AND 
                  first_order_date - registration_date <  INTERVAL '14' day THEN customer_id END) AS second_week,
    COUNT(CASE WHEN first_order_date - registration_date >= INTERVAL '14' DAY THEN customer_id END) AS after_second_week
FROM
	customers
WHERE 
	registration_date >= '2017-01-01' AND registration_date < '2017-04-01'
GROUP BY
	DATE_TRUNC('month', registration_date)
ORDER BY
	DATE_TRUNC('month', registration_date)