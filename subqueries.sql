# 1. Subquery Basics

-- 1. We would like to know which channels send the most traffic per day on average to Parch and Posey

SELECT 
	channel, 
	AVG(event_cnt) AS avg_event_cnt
FROM (
	SELECT 
		DATE_TRUNC('day', occurred_at) AS day, 
		channel, 
		COUNT(*) AS event_cnt
	FROM web_events
	GROUP BY 1, 2) AS tbl
GROUP BY 1
ORDER BY 2 DESC;

/* 2. Use DATE_TRUNC to pull month level information about the first order ever placed in the orders table.
Use the result to find only the orders that took place in the same month and year as the first order, and pull the average for each type of paper qty 
and total amount spent on all orders in this month. */ 

SELECT 
	DATE_TRUNC('month', occurred_at) AS month, 
	AVG(standard_qty) avg_std_qty,
	AVG(gloss_qty) avg_gloss_qty,
	AVG(poster_qty) avg_poster_qty,
	SUM(total_amt_usd) total_sales_usd
FROM orders
WHERE DATE_TRUNC('month', occurred_at) = (
	SELECT 
		DATE_TRUNC('month' , MIN(occurred_at)) AS first_order
	FROM orders
)
GROUP BY 1;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# 2. Inline Subquery - FROM clause

SELECT x.dept_name,
       y.max_gpa
FROM department_db x,
     (SELECT dept_id,
             MAX(gpa) AS max_gpa
      FROM students
      GROUP BY dept_id
     ) y
WHERE x.dept_id = y.dept_id
ORDER BY x.dept_name;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# 3. Scalar Subquery - Single Value

SELECT 
    (SELECT MAX(salary) FROM employees_db) AS top_salary,
    employee_name
FROM employees_db;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# 4. Nested Subquery Example - WHERE clause

SELECT *
FROM students
WHERE student_id
IN (SELECT DISTINCT student_id
    FROM gpa_table
    WHERE gpa>3.5
    );

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# 5. Subquery Practice 

-- 1. Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales.

SELECT 
    rep_sales.sales_rep_name, 
    region_max_sales.region_name, 
    region_max_sales.highest_total
FROM (
    SELECT 
        region_summary.region_name,
        MAX(region_summary.total_sales) AS highest_total
    FROM (
        SELECT 
            s.name AS sales_rep_name, 
            r.name AS region_name,
            SUM(o.total_amt_usd) AS total_sales
        FROM sales_reps s
        JOIN region r ON r.id = s.region_id
        JOIN accounts a ON a.sales_rep_id = s.id
        JOIN orders o ON o.account_id = a.id
        GROUP BY s.name, r.name
    ) AS region_summary
    GROUP BY region_summary.region_name
) AS region_max_sales
JOIN (
    SELECT 
        s.name AS sales_rep_name, 
        r.name AS region_name,
        SUM(o.total_amt_usd) AS total_sales
    FROM sales_reps s
    JOIN region r ON r.id = s.region_id
    JOIN accounts a ON a.sales_rep_id = s.id
    JOIN orders o ON o.account_id = a.id
    GROUP BY s.name, r.name
) AS rep_sales
ON rep_sales.region_name = region_max_sales.region_name
AND rep_sales.total_sales = region_max_sales.highest_total;

-- 2. For the region with the largest (sum) of sales total_amt_usd, how many total (count) orders were placed?

SELECT order_cnt AS top_sales_region_cnt
FROM (
	SELECT 
		r.name region_name, 
		SUM(o.total_amt_usd) total_sales, 
		COUNT(o.id) as order_cnt
	FROM orders o
	JOIN accounts a
	ON o.account_id = a.id
	JOIN sales_reps s
	ON s.id = a.sales_rep_id
	JOIN region r
	ON s.region_id = r.id
	GROUP BY 1
	ORDER BY 2 DESC
	LIMIT 1
);

-- 3. How many accounts had more total purchases than the account name which has bought the most standard_qty paper throughout their lifetime as a customer?

SELECT COUNT(*) account_cnt
FROM (
	SELECT 
		account_id, 
		SUM(total) AS total_sum
	FROM orders
	GROUP BY 1
	HAVING SUM(total) > (
		SELECT 
			highest_total 
			FROM (
				SELECT 
					account_id, 
					SUM(standard_qty) std_qty_sum, 
					SUM(total) highest_total 
				FROM orders
				GROUP BY 1
				ORDER BY 2 DESC
				LIMIT 1
				) AS highest_total_subquery
			)
	) AS filtered_accounts;

-- 4. For the customer that spent the most (in total over their lifetime as a customer) total_amt_usd, how many web_events did they have for each channel?

SELECT 
	channel, 
	COUNT(*) 
FROM web_events 
WHERE account_id = (
	SELECT 
		account_id 
		FROM (
			SELECT 
				account_id, 
				SUM(total_amt_usd) total_spent
				FROM orders o 
				GROUP BY 1 
				ORDER BY 2 DESC
				LIMIT 1
			) AS top_spender
		)
GROUP BY 1
ORDER BY 2 DESC;

-- 5. What is the lifetime average amount spent in terms of total_amt_usd for the top 10 total spending accounts?

SELECT 
    ROUND(AVG(total_spent), 3) AS lifetime_avg
FROM (
    SELECT 
        account_id, 
        SUM(total_amt_usd) AS total_spent
    FROM orders
    GROUP BY account_id
    ORDER BY total_spent DESC
    LIMIT 10
) AS top_spenders;

-- 6. What is the lifetime average amount spent in terms of total_amt_usd, including only the companies that spent more per order, on average, than the average of all orders?

SELECT 
    ROUND(AVG(lifetime_avg), 3) AS rounded_avg_lifetime
FROM (
    SELECT 
        account_id, 
        AVG(total_amt_usd) AS lifetime_avg
    FROM orders
    GROUP BY account_id
    HAVING AVG(total_amt_usd) > (
        SELECT AVG(total_amt_usd) AS order_avg
        FROM orders
    )
) AS accounts_above_avg;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# 6. WITH 

-- Try to perform each of the earlier queries again, but using a WITH instead of a subquery.

-- 1. Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales.

WITH top_sales_rep AS (
    SELECT 
        s.name AS sales_reps_name, 
        r.name AS region_name,
        SUM(o.total_amt_usd) AS total_sales
    FROM region r
    JOIN sales_reps s ON s.region_id = r.id
    JOIN accounts a ON s.id = a.sales_rep_id
    JOIN orders o ON o.account_id = a.id
    GROUP BY r.name, s.name
),

max_sales_by_region AS (
    SELECT 
        region_name, 
        MAX(total_sales) AS max_sales_value
    FROM top_sales_rep
    GROUP BY region_name
)

SELECT 
    t.sales_reps_name, 
    t.region_name, 
    t.total_sales 
FROM top_sales_rep t
JOIN max_sales_by_region m
    ON t.region_name = m.region_name 
    AND t.total_sales = m.max_sales_value
ORDER BY t.total_sales DESC;
                     

-- 2. For the region with the largest sales total_amt_usd, how many total orders were placed?

WITH region_sales AS
(
	SELECT  
		r.name region_name, 
		SUM(o.total_amt_usd) total_sales, 
        COUNT(o.total) order_count
	FROM region r
	JOIN sales_reps s 
	ON r.id = s.region_id 
	JOIN accounts a
	ON s.id = a.sales_rep_id
	JOIN orders o
	ON o.account_id = a.id
	GROUP BY 1
)

SELECT * 
FROM region_sales
ORDER BY 2 DESC
LIMIT 1;

-- 3. How many accounts had more total purchases than the account name which has bought the most standard_qty paper throughout their lifetime as a customer?

WITH highest_total_accounts AS 
(
	SELECT 
		account_id, 
		SUM(standard_qty), 
		SUM(total) total
   FROM orders
   GROUP BY 1
   ORDER BY 2 DESC
   LIMIT 1
)

SELECT a.name, SUM(o.total) total_qty
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY 1
HAVING SUM(o.total) > (SELECT total FROM highest_total_accounts);

-- 4. For the customer that spent the most (in total over their lifetime as a customer) total_amt_usd, how many web_events did they have for each channel?

WITH top_spender AS 
( 
	SELECT 
		account_id, 
		SUM(total_amt_usd)
   FROM orders
   GROUP BY 1
   ORDER BY 2 DESC
   LIMIT 1
)

SELECT 
	w.channel, 
	COUNT(w.id) events_count
FROM web_events w
JOIN top_spender t
ON w.account_id = t.account_id
GROUP BY 1
ORDER BY 2 DESC;

-- 5. What is the lifetime average amount spent in terms of total_amt_usd for the top 10 total spending accounts?

WITH top_spenders AS 
(
	SELECT 
		account_id, 
		SUM(total_amt_usd) AS total_amt_spent
	FROM orders
	GROUP BY 1
	ORDER BY 2 DESC
	LIMIT 10
)

SELECT AVG(total_amt_spent) AS lifetime_avg 
FROM top_spenders;

-- 6. What is the lifetime average amount spent in terms of total_amt_usd, including only the companies that spent more per order, on average, than the average of all orders.

WITH accounts_above_avg AS (
    SELECT 
        a.id AS account_id, 
        AVG(o.total_amt_usd) AS amt_spent_avg
    FROM accounts a
    JOIN orders o ON a.id = o.account_id
    GROUP BY a.id
    HAVING AVG(o.total_amt_usd) > (
        SELECT AVG(total_amt_usd) 
        FROM orders
    )
)

SELECT 
    AVG(amt_spent_avg) AS lifetime_avg
FROM accounts_above_avg;
