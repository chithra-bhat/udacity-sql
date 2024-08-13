# 1. SUM 

-- 1. Find the total amount of poster_qty paper ordered in the orders table.

SELECT SUM(poster_qty) AS total_poster_sales
FROM orders;

-- 2. Find the total amount of standard_qty paper ordered in the orders table.

SELECT SUM(standard_qty) AS total_standard_sales
FROM orders;

-- 3. Find the total dollar amount of sales using the total_amt_usd in the orders table.

SELECT SUM(total_amt_usd) AS total_sales
FROM orders;

/* 4. Find the total amount spent on standard_amt_usd and gloss_amt_usd paper for each order in the orders table. 
This should give a dollar amount for each order in the table. */

SELECT standard_amt_usd + gloss_amt_usd AS total
FROM orders;

-- 5. Find the standard_amt_usd per unit of standard_qty paper. Your solution should use both aggregation and a mathematical operator.

SELECT SUM(standard_amt_usd)/SUM(standard_qty) AS std_unit_price
FROM orders; 

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# 2. MIN, MAX AND AVG

-- 1. When was the earliest order ever placed? You only need to return the date.

SELECT MIN(occurred_at) AS earliest_date
FROM orders;

-- 2. Try performing the same query as in question 1 without using an aggregation function.

SELECT occurred_at AS earliest_date
FROM orders
ORDER BY occurred_at
LIMIT 1;

-- 3. When did the most recent (latest) web_event occur?

SELECT MAX(occurred_at) AS latest_web_event
FROM web_events;

-- 4. Try to perform the result of the previous query without using an aggregation function.

SELECT occurred_at AS latest_web_event
FROM web_events
ORDER BY occurred_at DESC
LIMIT 1;

/* 5. Find the mean (AVERAGE) amount spent per order on each paper type, as well as the mean amount of each paper type purchased per order. Your final answer should 
have 6 values - one for each paper type for the average number of sales, as well as the average amount.*/

SELECT AVG(standard_qty) AS avg_std_qty,
AVG(gloss_qty) AS avg_gloss_qty,
AVG(poster_qty) AS avg_poster_qty,
AVG(standard_amt_usd) AS avg_std_amt,
AVG(gloss_amt_usd) AS avg_gloss_amt,
AVG(poster_amt_usd) AS avg_poster_amt
FROM orders;

/* 6. Via the video, you might be interested in how to calculate the MEDIAN. Though this is more advanced than what we have covered so far try finding - what is the 
MEDIAN total_usd spent on all orders? */

SELECT AVG(total_amt_usd) AS median
FROM (SELECT total_amt_usd
      FROM (SELECT total_amt_usd
            FROM orders
            ORDER BY total_amt_usd
            LIMIT 3457)
      ORDER BY total_amt_usd DESC
      LIMIT 2);

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# 3. GROUP BY 

-- 1. Which account (by name) placed the earliest order? Your solution should have the account name and the date of the order.

SELECT a.name, o.occurred_at
FROM accounts a
JOIN orders o
ON a.id = o.account_id
ORDER BY o.occurred_at
LIMIT 1;

-- 2. Find the total sales in usd for each account. You should include two columns - the total sales for each company's orders in usd and the company name.

SELECT a.name, SUM(o.total_amt_usd)
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.name
ORDER BY a.name;

/* 3. Via what channel did the most recent (latest) web_event occur, which account was associated with this web_event? 
Your query should return only three values - the date, channel, and account name. */

SELECT w.channel, w.occurred_at, a.name
FROM web_events w
JOIN accounts a
ON a.id = w.account_id
ORDER BY w.occurred_at DESC
LIMIT 1;

/* 4. Find the total number of times each type of channel from the web_events was used. 
Your final table should have two columns - the channel and the number of times the channel was used. */

SELECT channel, COUNT(*) AS channel_count
FROM web_events
GROUP BY channel
ORDER BY channel_count;

-- 5. Who was the primary contact associated with the earliest web_event?

SELECT a.primary_poc
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
ORDER BY w.occurred_at
LIMIT 1;

/* 6. What was the smallest order placed by each account in terms of total usd. Provide only two columns - the account name and the total usd. 
Order from smallest dollar amounts to largest. */

SELECT a.name, MIN(o.total_amt_usd) AS min_order
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.name
ORDER BY min_order;

/* 7. Find the number of sales reps in each region. Your final table should have two columns - the region and the number of sales_reps. 
Order from the fewest reps to most reps. */

SELECT r.name, COUNT(s.id) AS reps_count
FROM region r
JOIN sales_reps s
ON r.id = s.region_id
GROUP BY r.name
ORDER BY reps_count;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# 4. GROUP BY II

/* 1. For each account, determine the average amount of each type of paper they purchased across their orders. 
Your result should have four columns - one for the account name and one for the average quantity purchased for each of the paper types for each account. */

SELECT a.name, 
AVG(o.standard_qty) avg_std_qty, 
AVG(o.gloss_qty) avg_gloss_qty, 
AVG(o.poster_qty) avg_poster_qty
FROM accounts a
JOIN orders o 
ON a.id = o.account_id
GROUP BY a.name
ORDER BY a.name;

/* 2. For each account, determine the average amount spent per order on each paper type. 
Your result should have four columns - one for the account name and one for the average amount spent on each paper type. */

SELECT a.name, 
AVG(o.standard_amt_usd) avg_std_amt, 
AVG(o.gloss_amt_usd) avg_gloss_amt, 
AVG(o.poster_amt_usd) avg_poster_amt
FROM accounts a
JOIN orders o 
ON a.id = o.account_id
GROUP BY a.name
ORDER BY a.name;

/* 3. Determine the number of times a particular channel was used in the web_events table for each sales rep. 
Your final table should have three columns - the name of the sales rep, the channel, and the number of occurrences. 
Order your table with the highest number of occurrences first. */

SELECT s.name sales_rep_name, w.channel, COUNT(w.channel) channel_count
FROM web_events w
JOIN accounts a
ON a.id = w.account_id
JOIN sales_reps s
ON a.sales_rep_id = s.id
GROUP BY s.name, w.channel
ORDER BY s.name, channel_count DESC, w.channel;

/* 4. Determine the number of times a particular channel was used in the web_events table for each region. 
Your final table should have three columns - the region name, the channel, and the number of occurrences. Order your table with the highest number of occurrences first. */

SELECT r.name, w.channel, COUNT(w.channel) AS channel_count
FROM web_events w
JOIN accounts a 
ON a.id = w.account_id
JOIN sales_reps s
ON a.sales_rep_id = s.id
JOIN region r
ON r.id = s.region_id
GROUP BY r.name, w.channel
ORDER BY r.name, channel_count DESC;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# 5. DISTINCT

-- 1. Use DISTINCT to test if there are any accounts associated with more than one region.

SELECT DISTINCT a.name as company, r.name region
FROM accounts a 
JOIN sales_reps s
ON a.sales_rep_id = s.id
JOIN region r
ON s.region_id = r.id
ORDER BY a.name;

-- 2. Have any sales reps worked on more than one account?

SELECT DISTINCT s.name as sales_rep, COUNT(a.id) AS acc_cnt
FROM sales_reps s
JOIN accounts a 
ON s.id = a.sales_rep_id
GROUP BY s.name
ORDER BY acc_cnt DESC, sales_rep;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# 6. HAVING

-- 1. How many of the sales reps have more than 5 accounts that they manage?

SELECT COUNT(*) AS sales_rep_count 
FROM (SELECT s.id, s.name, COUNT(*) AS account_cnt
      FROM accounts a
      JOIN sales_reps s
      ON a.sales_rep_id = s.id
      GROUP BY s.id, s.name
      HAVING COUNT(*) > 5) AS tbl;

-- 2. How many accounts have more than 20 orders?

SELECT COUNT(*) AS acc_count 
FROM (SELECT a.name, COUNT(*) AS order_cnt
	 FROM accounts a 
	 JOIN orders o 
	 ON a.id = o.account_id
	 GROUP BY a.name
	 HAVING COUNT(*) > 20) AS tbl;

-- 3. Which account has the most orders?

SELECT a.name, COUNT(*) AS order_cnt
FROM accounts a 
JOIN orders o 
ON a.id = o.account_id
GROUP BY a.name
ORDER BY 2 DESC
LIMIT 1;

-- 4. Which accounts spent more than 30,000 usd total across all orders?

SELECT a.name, SUM(o.total_amt_usd) AS order_amt
FROM accounts a 
JOIN orders o 
ON a.id = o.account_id
GROUP BY a.name
HAVING SUM(o.total_amt_usd) > 30000
ORDER BY 2 DESC;

-- 5. Which accounts spent less than 1,000 usd total across all orders?

SELECT a.name, SUM(o.total_amt_usd) AS order_amt
FROM accounts a 
JOIN orders o 
ON a.id = o.account_id
GROUP BY a.name
HAVING SUM(o.total_amt_usd) < 1000
ORDER BY 2;

-- 6. Which account has spent the most with us?

SELECT a.name, SUM(o.total_amt_usd)
FROM accounts a
JOIN orders o 
ON a.id = o.account_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- 7. Which account has spent the least with us?

SELECT a.name, SUM(o.total_amt_usd)
FROM accounts a
JOIN orders o 
ON a.id = o.account_id
GROUP BY 1
ORDER BY 2 
LIMIT 1;

-- 8. Which accounts used facebook as a channel to contact customers more than 6 times?

SELECT a.name, COUNT(w.channel)
FROM web_events w
JOIN accounts a
ON a.id = w.account_id
WHERE w.channel = 'facebook'
GROUP BY a.name
HAVING COUNT(w.channel) > 6
ORDER BY 2 DESC;

-- 9. Which account used facebook most as a channel?

SELECT a.name, COUNT(w.channel)
FROM web_events w
JOIN accounts a
ON a.id = w.account_id
WHERE w.channel = 'facebook'
GROUP BY a.name
ORDER BY 2 DESC
LIMIT 1;

-- 10. Which channel was most frequently used by most accounts?

SELECT w.channel, COUNT(*)
FROM web_events w
JOIN accounts a
ON a.id = w.account_id
GROUP BY w.channel
ORDER BY 2 DESC
LIMIT 1;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# 7. DATE Functions

-- 1. Find the sales in terms of total dollars for all orders in each year, ordered from greatest to least. Do you notice any trends in the yearly sales totals?

SELECT DATE_PART('year', occurred_at) AS year, SUM(total_amt_usd) total_sales
FROM orders
GROUP BY 1 
ORDER BY 2 DESC;

-- 2. Which month did Parch & Posey have the greatest sales in terms of total dollars? Are all months evenly represented by the dataset?

SELECT DATE_PART('month', occurred_at) AS month, SUM(total_amt_usd) total_sales
FROM orders
WHERE occurred_at BETWEEN '2014-01-01' AND '2017-01-01'
GROUP BY 1 
ORDER BY 2 DESC
LIMIT 1;

-- 3. Which year did Parch & Posey have the greatest sales in terms of the total number of orders? Are all years evenly represented by the dataset?

SELECT DATE_PART('year', occurred_at) AS year, COUNT(id) total_orders
FROM orders
GROUP BY 1 
ORDER BY 2 DESC
LIMIT 1;

-- 4. Which month did Parch & Posey have the greatest sales in terms of the total number of orders? Are all months evenly represented by the dataset?

SELECT DATE_PART('month', occurred_at) AS month, COUNT(id) total_orders
FROM orders
WHERE DATE_PART('year', occurred_at) BETWEEN 2014 AND 2016
GROUP BY 1 
ORDER BY 2 DESC
LIMIT 1;

-- 5. In which month of which year did Walmart spend the most on gloss paper in terms of dollars?

SELECT a.id, a.name account_name, 
DATE_PART('month', o.occurred_at) AS month, 
SUM(o.gloss_amt_usd) gloss_amt
FROM orders o
JOIN accounts a
ON a.id = o.account_id
WHERE a.name = 'Walmart' AND DATE_PART('year', occurred_at) BETWEEN 2014 AND 2016
GROUP BY 1, 2, 3
ORDER BY 4 DESC
LIMIT 1;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# 8. CASE 

/* 1. Write a query to display for each order, the account ID, the total amount of the order, and the level of the order - ‘Large’ or ’Small’ - 
depending on if the order is $3000 or more, or smaller than $3000. */
SELECT account_id, total_amt_usd,
CASE 
	WHEN total_amt_usd >= 3000 THEN 'Large'
	ELSE 'Small' END AS order_level
FROM orders;


/* 2. Write a query to display the number of orders in each of three categories, based on the total number of items in each order. 
The three categories are: 'At Least 2000', 'Between 1000 and 2000' and 'Less than 1000'. */

SELECT CASE 
	WHEN total >= 2000 THEN 'At Least 2000'
	WHEN total BETWEEN 1000 AND 1999 THEN 'Between 1000 and 2000'
    ELSE 'Less than 1000' END AS category,
COUNT(*) AS order_count
FROM orders
GROUP BY 1;

/* 3. We would like to understand 3 different levels of customers based on the amount associated with their purchases. 
The top-level includes anyone with a Lifetime Value (total sales of all orders) greater than 200,000 usd. 
The second level is between 200,000 and 100,000 usd. The lowest level is anyone under 100,000 usd. 
Provide a table that includes the level associated with each account. You should provide the account name, the total sales of all orders for the customer, and the level. 
Order with the top spending customers listed first. */

SELECT a.name account_name, SUM(total_amt_usd),
CASE 
	WHEN SUM(total_amt_usd)  > 200000 THEN 'top'
	WHEN SUM(total_amt_usd)  BETWEEN 100000 AND 200000 THEN 'middle'
	ELSE 'low' END AS level
FROM orders o
JOIN accounts a 
ON a.id = o.account_id
GROUP BY 1
ORDER BY 2 DESC;


/* 4. We would now like to perform a similar calculation to the first, but we want to obtain the total amount spent by customers only in 2016 and 2017. 
Keep the same levels as in the previous question. Order with the top spending customers listed first. */

SELECT a.name account_name, SUM(total_amt_usd),
CASE 
	WHEN SUM(total_amt_usd) > 200000 THEN 'top'
	WHEN SUM(total_amt_usd)  BETWEEN 100000 AND 200000 THEN 'middle'
	ELSE 'low' END AS level
FROM orders o
JOIN accounts a 
ON a.id = o.account_id
WHERE DATE_PART('year', o.occurred_at) BETWEEN 2016 AND 2017
GROUP BY 1
ORDER BY 2 DESC;

/* 5. We would like to identify top-performing sales reps, which are sales reps associated with more than 200 orders. 
Create a table with the sales rep name, the total number of orders, and a column with top or not depending on if they have more than 200 orders. 
Place the top salespeople first in your final table. */

SELECT s.name, COUNT(o.id) AS num_orders,
CASE 
	WHEN COUNT(o.id) > 200 THEN 'top' ELSE 'not' END AS is_top 
FROM orders o 
JOIN accounts a
ON a.id = o.account_id
JOIN sales_reps s
ON a.sales_rep_id = s.id
GROUP BY s.name
ORDER BY 2 DESC;

/* 6. The previous didn't account for the middle, nor the dollar amount associated with the sales. Management decides they want to see these characteristics represented as well. 
We would like to identify top-performing sales reps, which are sales reps associated with more than 200 orders or more than 750000 in total sales. 
The middle group has any rep with more than 150 orders or 500000 in sales. 
Create a table with the sales rep name, the total number of orders, total sales across all orders, and a column with top, middle, or low depending on these criteria. 
Place the top salespeople based on the dollar amount of sales first in your final table. You might see a few upset salespeople by this criteria! */

SELECT s.name, 
COUNT(o.id) AS num_orders,
SUM(o.total_amt_usd) AS total_sales,
CASE 
	WHEN COUNT(o.id) > 200 OR SUM(o.total_amt_usd) > 750000 THEN 'top' 
	WHEN COUNT(o.id) > 150 OR SUM(o.total_amt_usd) > 500000 THEN 'middle'
	ELSE 'LOW' END AS category 
FROM orders o 
JOIN accounts a
ON a.id = o.account_id
JOIN sales_reps s
ON a.sales_rep_id = s.id
GROUP BY s.name
ORDER BY 3 DESC;

