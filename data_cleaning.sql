# 1. LEFT and RIGHT 

/* 1. In the accounts table, there is a column holding the website for each company. The last three digits specify what type of web address they are using. 
A list of extensions (and pricing) is provided iwantmyname.com. 
Pull these extensions and provide how many of each website type exist in the accounts table. */

SELECT RIGHT(website, 4) extensions, COUNT(*) AS extension_cnt
FROM accounts 
GROUP BY extensions;

/* 2. There is much debate about how much the name (or even the first letter of a company name) matters. 
Use the accounts table to pull the first letter of each company name to see the distribution of company names that begin with each letter (or number). */

SELECT LEFT(name, 1) first_letter, COUNT(*) AS count
FROM accounts
GROUP BY first_letter
ORDER BY 2 DESC;

/* 3. Use the accounts table and a CASE statement to create two groups: one group of company names that start with a number and the second group of those company names 
that start with a letter. What proportion of company names start with a letter? */

WITH count_category AS(
SELECT 
    CASE 
        WHEN LEFT(name, 1) SIMILAR TO '[0-9]' THEN 'number' 
        ELSE 'letter' END AS category, 
    COUNT(*) AS category_count
FROM accounts
GROUP BY category
),
sum_total AS
(
  SELECT COUNT(name) AS total 
  FROM accounts 
)

SELECT ROUND(c.category_count * 1.0/ s.total, 4) * 100 AS letter_percentage
FROM count_category c
CROSS JOIN sum_total s
WHERE c.category = 'letter';

-- 4. Consider vowels as a, e, i, o, and u. What proportion of company names start with a vowel, and what percent start with anything else?

WITH count_by_category AS
(SELECT 
    CASE 
        WHEN UPPER(LEFT(name, 1)) IN ('A', 'E', 'I', 'O', 'U') THEN 'vowel'
        ELSE 'others' END AS category, 
    COUNT(*) AS category_count
FROM accounts
GROUP BY category
),
sum_total AS
(
	SELECT COUNT(name) AS total
	FROM accounts
)

SELECT ROUND((category_count * 1.0 / total) * 100, 4)
FROM count_by_category
CROSS JOIN sum_total
WHERE category = 'vowel';

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# 2. CONCAT

/* 1. Suppose the company wants to assess the performance of all the sales representatives. Each sales representative is assigned to work in a particular region. 
To make it easier to understand for the HR team, display the concatenated sales_reps.id, ‘_’ (underscore), and region.name as EMP_ID_REGION for each sales representative. */

SELECT CONCAT(s.id, '_', r.name) AS EMP_ID_REGION
FROM sales_reps s
LEFT JOIN region r
ON r.id = s.region_id;


/* 2. From the accounts table, display the name of the client, the coordinate as concatenated (latitude, longitude), email id of the primary point of contact 
as <first letter of the primary_poc><last letter of the primary_poc>@<extracted name and domain from the website>. */

SELECT 
	name,
	CONCAT('( ', lat, ', ', long, ' )') coordinate,
	CONCAT(
		LEFT(primary_poc, 1), 
		RIGHT(primary_poc, 1), 
		'@',
		CASE 
			WHEN website LIKE 'www.%' THEN SUBSTR(website, 5) 
			WHEN website LIKE 'http.%' THEN SUBSTR(website, 6)
			WHEN website LIKE 'https.%' THEN SUBSTR(website, 7) 
			ELSE SUBSTR(website,11) END) email
FROM accounts
ORDER BY 1;

/* 3. From the web_events table, display the concatenated value of account_id, '_' , channel, '_', count of web events of the particular channel. */

WITH count_channel AS (
	SELECT 
		account_id, 
		channel, 
		COUNT(*) AS channel_count 
	FROM web_events
	GROUP BY 1, 2
)

SELECT CONCAT(account_id, '_', channel, '_', channel_count) id
FROM count_channel
ORDER BY 1;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# 3. CAST

-- 1. Convert the 'date' column in mm/dd/yyyy with times format to yyyy-mm-dd with times.

SELECT 
	date, 
	CAST(
		CONCAT(
			DATE_PART('year', date::date), '-',
			DATE_PART('month', date::date), '-',
			DATE_PART('day', date::date), ' ',
			SUBSTR(date, 12)
			) AS DATE
		) modified_date
FROM sf_crime_data;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# 4. POSITION and STRPOS

-- 1. Use the accounts table to create first and last name columns that hold the first and last names for the primary_poc.

SELECT 
	primary_poc, 
	LEFT(primary_poc, STRPOS(primary_poc, ' ')) AS first,
	SUBSTR(primary_poc, STRPOS(primary_poc, ' ')) AS last
FROM accounts;

-- 2. Now see if you can do the same thing for every rep name in the sales_reps table. Again provide first and last name columns.

SELECT 
	name, 
	LEFT(name, STRPOS(name, ' ')) AS first,
	SUBSTR(name, STRPOS(name, ' ')) AS last                          
FROM sales_reps;   

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# 5. CONCAT and STRPOS 

/* 1. Each company in the accounts table wants to create an email address for each primary_poc. 
The email address should be the first name of the primary_poc . last name primary_poc @ company name .com. */

SELECT 
	primary_poc,
	CONCAT(
		LEFT(primary_poc, STRPOS(primary_poc, ' ') - 1), '.',
		SUBSTR(primary_poc, STRPOS(primary_poc, ' ') + 1), '@',
		name, '.com') AS email  
FROM accounts
ORDER BY 1;

/* 2. You may have noticed that in the previous solution some of the company names include spaces, which will certainly not work in an email address. 
See if you can create an email address that will work by removing all of the spaces in the account name, but otherwise, your solution should be just as in question 1. */

SELECT 
	primary_poc,
	CONCAT(
		LEFT(primary_poc, STRPOS(primary_poc, ' ') - 1), '.',
		SUBSTR(primary_poc, STRPOS(primary_poc, ' ') + 1), '@',
		REPLACE(name, ' ', ''), '.com') AS email  
FROM accounts
ORDER BY 1;

/* 3. We would also like to create an initial password, which they will change after their first log in. 
The first password will be the first letter of the primary_poc's first name (lowercase), then the last letter of their first name (lowercase), 
the first letter of their last name (lowercase), the last letter of their last name (lowercase), the number of letters in their first name, 
the number of letters in their last name, and then the name of the company they are working with, all capitalized with no spaces. */

WITH pwd_content AS (
	SELECT 
		primary_poc,
		LOWER(LEFT(primary_poc, STRPOS(primary_poc, ' ') - 1)) AS first,
		LOWER(SUBSTR(primary_poc, STRPOS(primary_poc, ' ') + 1)) AS last,
		UPPER(REPLACE(name, ' ', '')) AS company
	FROM accounts
)

SELECT 
	primary_poc, 
	CONCAT(
		LEFT(first, 1), 
		RIGHT(first, 1),
		LEFT(last, 1),
		RIGHT(last, 1),
		LENGTH(first),
		LENGTH(last),
		company) AS init_pwd
FROM pwd_content
ORDER BY 2;
