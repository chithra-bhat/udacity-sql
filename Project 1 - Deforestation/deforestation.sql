/* Create forestation View joining all three tables - forest_area, land_area, and regions. The forest_area and land_area tables join on both country_code AND year. The regions table joins these based on only country_code. */

CREATE VIEW forestation AS 
(
	SELECT 
		fa.country_code,
		fa.country_name,
		fa.year,
		fa.forest_area_sqkm,
		la.total_area_sq_mi, 
		(fa.forest_area_sqkm / (la.total_area_sq_mi * 2.59)) * 100 AS forest_cover_percent,
		r.region,
		r.income_group
	FROM forest_area fa
	JOIN land_area la
	ON fa.country_code = la.country_code AND fa.year = la.year
	JOIN regions r
	ON la.country_code = r.country_code
)

---------------------------------------------------------------------------------------------------------------------------------

# Part 1 - Global Situation

-- a. What was the total forest area (in sq km) of the world in 1990? Please keep in mind that you can use the country record denoted as “World" in the region table.

SELECT 
	forest_area_sqkm 
FROM forestation
WHERE year = 1990 AND country_name = 'World';

-- b. What was the total forest area (in sq km) of the world in 2016? Please keep in mind that you can use the country record in the table is denoted as “World.”

SELECT 
	forest_area_sqkm 
FROM forestation
WHERE year = 2016 AND country_name = 'World';

-- c. What was the change (in sq km) in the forest area of the world from 1990 to 2016?

WITH forest_1990 AS 
(
  SELECT forest_area_sqkm 
  FROM forestation 
  WHERE country_name = 'World' AND year = 1990
),
forest_2016 AS
(
  SELECT forest_area_sqkm 
  FROM forestation 
  WHERE country_name = 'World' AND year = 2016
)

SELECT forest_1990.forest_area_sqkm - forest_2016.forest_area_sqkm AS lost_forest_area
FROM forest_1990, forest_2016


-- OR We can use SELF JOIN to get the same result

SELECT 
  f1.forest_area_sqkm - f2.forest_area_sqkm AS lost_forest_area
FROM forestation f1
JOIN forestation f2
ON f1.country_name = f2.country_name 
AND f1.year = 1990 AND f2.year = 2016
WHERE f1.country_name = 'World';

-- d. What was the percent change in forest area of the world between 1990 and 2016?

WITH forest_1990 AS (
  SELECT forest_area_sqkm 
  FROM forestation 
  WHERE country_name = 'World' AND year = 1990
),
forest_2016 AS (
  SELECT forest_area_sqkm 
  FROM forestation 
  WHERE country_name = 'World' AND year = 2016
)

SELECT
	ROUND(
		CAST(
				(f1990.forest_area_sqkm - f2016.forest_area_sqkm) / f1990.forest_area_sqkm * 100.0 AS NUMERIC
			), 
		2) AS pct_forest_lost
FROM forest_1990 f1990, forest_2016 f2016 

-- OR We can use SELF JOIN to get the same result

SELECT 
  ROUND(
    CAST(
          (f1.forest_area_sqkm - f2.forest_area_sqkm) / f1.forest_area_sqkm AS NUMERIC) * 100, 
    2) AS pct_forest_lost
FROM forestation f1
JOIN forestation f2
ON f1.country_name = f2.country_name 
AND f1.year = 1990 AND f2.year = 2016
WHERE f1.country_name = 'World';


-- e. If you compare the amount of forest area lost between 1990 and 2016, to which country's total area in 2016 is it closest to?

WITH forest_1990 AS (
  SELECT forest_area_sqkm 
  FROM forestation 
  WHERE country_name = 'World' AND year = 1990
),

forest_2016 AS (
  SELECT forest_area_sqkm 
  FROM forestation 
  WHERE country_name = 'World' AND year = 2016
),

forest_loss AS (
  SELECT 
    forest_1990.forest_area_sqkm - forest_2016.forest_area_sqkm AS lost_forest_area
  FROM 
    forest_1990, 
    forest_2016
)

SELECT 
	country_name, 
	year, 
	ROUND(
		CAST
		(
			ABS((total_area_sq_mi * 2.59) - (SELECT lost_forest_area FROM forest_loss)) AS NUMERIC
		), 2) AS closest_land_area
FROM land_area  
WHERE year = 2016
ORDER BY 3
LIMIT 1;

---------------------------------------------------------------------------------------------------------------------------------

# Part 2 - Regional Outlook 

-- 1. Create a table that shows the Regions and their percent forest area (sum of forest area divided by the sum of land area) in 1990 and 2016. (Note 1 sq mi = 2.59 sq km).

SELECT
    r.region,
    fa.year,
    ROUND(
    	CAST(
    		SUM(fa.forest_area_sqkm) / SUM((la.total_area_sq_mi * 2.59)) AS NUMERIC
    		) * 100, 
    	2) AS forest_percent
FROM forest_area fa
JOIN land_area la 
ON fa.country_code = la.country_code AND fa.year = la.year
JOIN regions r ON la.country_code = r.country_code
WHERE fa.year IN (1990, 2016)
GROUP BY 1, 2
ORDER BY 2, 3 DESC, 1;

-- I have created a view named regional_outlook using the table above to address all of the following questions.

a. What was the percent forest of the entire world in 2016? Which region had the HIGHEST percent forest in 2016, and which had the LOWEST, to 2 decimal places?

-- Forest percent of the entire world in 2016 

SELECT * 
FROM regional_outlook 
WHERE region = 'World' AND year = 2016;

-- Highest forest percent in 2016 

SELECT * 
FROM regional_outlook 
WHERE year = 2016 
ORDER BY forest_percent DESC 
LIMIT 1;

-- Least forest percent in 2016

SELECT * 
FROM regional_outlook 
WHERE year = 2016 
ORDER BY forest_percent 
LIMIT 1;

b. What was the percent forest of the entire world in 1990? Which region had the HIGHEST percent forest in 1990, and which had the LOWEST, to 2 decimal places?

-- Forest percent of the entire world in 1990 

SELECT * 
FROM regional_outlook 
WHERE region = 'World' AND year = 1990;

-- Highest forest percent in 1990 

SELECT * 
FROM regional_outlook 
WHERE year = 1990 
ORDER BY forest_percent DESC 
LIMIT 1;

-- Least forest percent in 1990

SELECT * 
FROM regional_outlook 
WHERE year = 1990 
ORDER BY forest_percent 
LIMIT 1;

c. Based on the table you created, which regions of the world DECREASED in forest area from 1990 to 2016?

WITH regional_outlook_1990 AS
(
  SELECT region, forest_percent AS forest_1990 
  FROM regional_outlook
  WHERE year = 1990
),
regional_outlook_2016 AS
(
  SELECT region, forest_percent AS forest_2016
  FROM regional_outlook
  WHERE year = 2016
)

SELECT r1.region, r1.forest_1990, r2.forest_2016
FROM regional_outlook_1990 r1
JOIN regional_outlook_2016 r2
ON r1.region = r2.region
WHERE r1.forest_1990 > r2.forest_2016
AND r1.region != 'World';

---------------------------------------------------------------------------------------------------------------------------------

# Part 3 - Country-Level Detail 

-- a. Which 5 countries saw the largest amount decrease in forest area from 1990 to 2016? What was the difference in forest area for each?

WITH forest_area_change AS 
(
  SELECT
    country_name,
    SUM(CASE WHEN year = 1990 THEN forest_area_sqkm ELSE 0 END) AS forest_area_1990, 
    SUM(CASE WHEN year = 2016 THEN forest_area_sqkm ELSE 0 END) AS forest_area_2016
  FROM forest_area
  WHERE year IN (1990, 2016) AND country_name != 'World'
  GROUP BY 1
)

SELECT
    fac.country_name,
    r.region,
    ROUND(CAST(fac.forest_area_1990 - fac.forest_area_2016 AS NUMERIC), 2) AS difference
FROM forest_area_change fac
JOIN regions r 
ON fac.country_name = r.country_name
ORDER BY 3 DESC
LIMIT 5;

-- b. Which 5 countries saw the largest percent decrease in forest area from 1990 to 2016? What was the percent change to 2 decimal places for each?

WITH forest_area_change AS 
(
	SELECT
		country_name,
        SUM(CASE WHEN year = 1990 THEN forest_area_sqkm ELSE 0 END) AS forest_area_1990, 
        SUM(CASE WHEN year = 2016 THEN forest_area_sqkm ELSE 0 END) AS forest_area_2016
    FROM forest_area
    WHERE year IN (1990, 2016) AND country_name != 'World'
    GROUP BY 1
)

SELECT
    fac.*,
    r.region,
    ROUND(
      CAST(
      	CASE WHEN fac.forest_area_1990 > 0 THEN (fac.forest_area_1990 - fac.forest_area_2016)/fac.forest_area_1990 * 100 ELSE 0 END AS NUMERIC
      	), 
      2) AS pct_difference
FROM forest_area_change fac
JOIN regions r 
ON fac.country_name = r.country_name
WHERE fac.forest_area_1990 > 0 AND fac.forest_area_2016 > 0
ORDER BY 5 DESC
LIMIT 5;

-- c. If countries were grouped by percent forestation into 4 equal static intervals, which group had the most countries in it in 2016?

WITH forest_interval AS
(
  SELECT 
    country_name, 
    region,
    ROUND(CAST(forest_cover_percent AS NUMERIC), 5) AS forest_cover_percent,
    CASE 
      WHEN forest_cover_percent <= 25 THEN '0 - 25' 
      WHEN forest_cover_percent > 25 AND forest_cover_percent <= 50 THEN '25 - 50' 
      WHEN forest_cover_percent > 50 AND forest_cover_percent <= 75 THEN '50 - 75' 
      ELSE '75 - 100' END AS interval
  FROM forestation
  WHERE year = 2016 AND forest_cover_percent IS NOT NULL AND country_name != 'World'
  ORDER BY 3
)

SELECT interval , COUNT(*) AS interval_count
FROM forest_interval
GROUP BY 1
ORDER BY 2 DESC;

-- If countries were grouped by percent forestation in quartiles, which group had the most countries in it in 2016?

WITH forest_quartile AS 
(
  SELECT 
    country_name,
    forest_cover_percent,
    NTILE(4) OVER (ORDER BY forest_cover_percent) AS quartile
  FROM forestation
  WHERE year = 2016 AND forest_cover_percent IS NOT NULL AND country_name != 'World'
)

SELECT quartile, COUNT(*) AS quartile_count
FROM forest_quartile
GROUP BY 1
ORDER BY 1;


-- d. List all of the countries that were in the 4th quartile (percent forest > 75%) in 2016.

WITH countries_ranked AS
(
  SELECT 
    country_name, 
    region,
    ROUND(CAST(forest_cover_percent AS NUMERIC), 5) AS forest_cover_percent,
    CASE 
      WHEN forest_cover_percent <= 25 THEN 1 
      WHEN forest_cover_percent > 25 AND forest_cover_percent <= 50 THEN 2 
      WHEN forest_cover_percent > 50 AND forest_cover_percent <= 75 THEN 3 
      ELSE 4 END AS ntile
  FROM forestation
  WHERE year = 2016 
  AND forest_cover_percent IS NOT NULL 
  AND country_name != 'World'
  ORDER BY 3
)

SELECT * 
FROM countries_ranked
WHERE ntile = 4;

-- e. How many countries had a percent forestation higher than the United States in 2016?

WITH US_forestation AS
(
  SELECT
  ROUND(CAST(forest_cover_percent AS NUMERIC), 2) AS forest_percent
  FROM forestation 
  WHERE year = 2016 AND country_name LIKE '%United States%'
)
SELECT 
  country_name, 
  year,
  ROUND(CAST(forest_cover_percent AS NUMERIC), 2) AS forest_cover_percent
FROM forestation f, US_forestation us
WHERE f.year = 2016 AND f.forest_cover_percent IS NOT NULL 
AND f.country_name != 'World' AND f.forest_cover_percent > us.forest_percent
ORDER BY 1;


