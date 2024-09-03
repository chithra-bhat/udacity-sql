CREATE VIEW forestation AS 
(
	SELECT 
		fa.country_code,
		r.country_name,
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

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Part 1 - Global Situation

-- a. What was the total forest area (in sq km) of the world in 1990? Please keep in mind that you can use the country record denoted as “World" in the region table.

SELECT 
	forest_area_sqkm 
FROM forestation
WHERE year = 1990 AND country_name = 'World'; -- 41282694.9

-- b. What was the total forest area (in sq km) of the world in 2016? Please keep in mind that you can use the country record in the table is denoted as “World.”

SELECT 
	forest_area_sqkm 
FROM forestation
WHERE year = 2016 AND country_name = 'World'; -- 39958245.9

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
            (
                (f1990.forest_area_sqkm - f2016.forest_area_sqkm) / f1990.forest_area_sqkm * 100.0
            ) AS NUMERIC
        ), 
        2
    ) AS percent_change
FROM forest_1990 f1990, forest_2016 f2016 
    

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

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Part 2 - Regional Outlook 

