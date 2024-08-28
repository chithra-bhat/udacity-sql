# 1. Window Functions

/* 1. Create a running total of standard_amt_usd (in the orders table) over order time with no date truncation. 
Your final table should have two columns: one with the amount being added for each new row, and a second with the running total. */

SELECT 
	standard_amt_usd,
    SUM(standard_amt_usd) OVER (ORDER BY occurred_at) AS running_total
FROM orders;

/* 2. create a running total of standard_amt_usd (in the orders table) over order time, but this time, date truncate occurred_at by year 
and partition by that same year-truncated occurred_at variable. 

Your final table should have three columns:

One with the amount being added for each row
One for the truncated date,
A final column with the running total within each year */

SELECT 
	DATE_TRUNC('year', occurred_at) AS year,
	standard_amt_usd,
	SUM(standard_amt_usd) OVER (PARTITION BY DATE_TRUNC('year', occurred_at) ORDER BY occurred_at) AS running_total
FROM orders;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# 2. ROW_NUMBER, RANK, DENSE_RANK

/* 1. Select the id, account_id, and total variable from the orders table, then create a column called total_rank that ranks 
this total amount of paper ordered (from highest to lowest) for each account using a partition. */

SELECT 
	id,
	account_id,
	total, 
	DENSE_RANK() OVER(PARTITION BY account_id ORDER BY total DESC) AS total_rank
FROM orders;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# 3. Aliases

/* 1. Create and use an alias to shorten the following query. Name the alias account_year_window

SELECT id,
       account_id,
       DATE_TRUNC('year',occurred_at) AS year,
       DENSE_RANK() OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at)) AS dense_rank,
       total_amt_usd,
       SUM(total_amt_usd) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at)) AS sum_total_amt_usd,
       COUNT(total_amt_usd) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at)) AS count_total_amt_usd,
       AVG(total_amt_usd) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at)) AS avg_total_amt_usd,
       MIN(total_amt_usd) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at)) AS min_total_amt_usd,
       MAX(total_amt_usd) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at)) AS max_total_amt_usd
FROM orders; */


SELECT id,
       account_id,
       DATE_TRUNC('year',occurred_at) AS year,
       DENSE_RANK() OVER (account_year_window) AS dense_rank,
       total_amt_usd,
       SUM(total_amt_usd) OVER (account_year_window) AS sum_total_amt_usd,
       COUNT(total_amt_usd) OVER (account_year_window) AS count_total_amt_usd,
       AVG(total_amt_usd) OVER (account_year_window) AS avg_total_amt_usd,
       MIN(total_amt_usd) OVER (account_year_window) AS min_total_amt_usd,
       MAX(total_amt_usd) OVER (account_year_window) AS max_total_amt_usd
FROM orders
WINDOW account_year_window AS (
	PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at));   

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# 4. LAG and LEAD

SELECT account_id,
       standard_sum,
       LAG(standard_sum) OVER (ORDER BY standard_sum) AS lag,
       LEAD(standard_sum) OVER (ORDER BY standard_sum) AS lead,
       standard_sum - LAG(standard_sum) OVER (ORDER BY standard_sum) AS lag_difference,
       LEAD(standard_sum) OVER (ORDER BY standard_sum) - standard_sum AS lead_difference
FROM (
SELECT account_id,
       SUM(standard_qty) AS standard_sum
  FROM orders 
 GROUP BY 1
 ) sub

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# 5. PERCENTILE

-- Note: To make it easier to interpret the results, order by the account_id in each of the queries.

/* 1. Use the NTILE functionality to divide the accounts into 4 levels in terms of the amount of standard_qty for their orders. Your resulting table should have the account_id, 
the occurred_at time for each order, the total amount of standard_qty paper purchased, and one of four levels in a standard_quartile column. */

SELECT 
	account_id, 
	occurred_at, 
	standard_qty, 
	NTILE(4) OVER (PARTITION BY account_id ORDER BY standard_qty) AS standard_quartile
FROM orders
ORDER BY 1;

/* 2. Use the NTILE functionality to divide the accounts into two levels in terms of the amount of gloss_qty for their orders. Your resulting table should have the account_id, 
the occurred_at time for each order, the total amount of gloss_qty paper purchased, and one of two levels in a gloss_half column. */

SELECT 
	account_id, 
	occurred_at, 
	gloss_qty, 
	NTILE(2) OVER (PARTITION BY account_id ORDER BY gloss_qty) AS gloss_half
FROM orders
ORDER BY 1;

/* 3. Use the NTILE functionality to divide the orders for each account into 100 levels in terms of the amount of total_amt_usd for their orders. Your resulting table should 
have the account_id, the occurred_at time for each order, the total amount of total_amt_usd paper purchased, and one of 100 levels in a total_percentile column. */

SELECT 
	account_id, 
	occurred_at, 
	total_amt_usd, 
	NTILE(100) OVER(PARTITION BY account_id ORDER BY total_amt_usd) AS total_percentile
FROM orders
ORDER BY 1;
