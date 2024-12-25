-- CREATE DATABASE netflix;
USE netflix;
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(	
	show_id VARCHAR(10),
	type	VARCHAR(10),
	title	VARCHAR(150),
	director VARCHAR(208),
	cast	VARCHAR(1000),
	country	VARCHAR(150),
	date_added	VARCHAR(50),
	release_year	INT,
	rating	VARCHAR(10),
	duration	VARCHAR(15),
	listed_in	VARCHAR(100),
	description VARCHAR(250)
);
-- Exploratory Data Analysis
SELECT count(*)
FROM netflix;

-- 1. Count the number of Movies vs TV Shows
SELECT type,COUNT(type) AS Movies_TV_shows
FROM netflix
GROUP BY type;
-- 2. Find the most common rating for movies and TV shows
SELECT type,ratings_count, rankk
FROM ( select type, rating,count(rating) as ratings_count,
RANK() OVER (PARTITION BY type ORDER BY count(rating) DESC) AS rankk
FROM netflix
GROUP BY type,rating) AS tablee
WHERE rankk = 1;

-- 3. List all movies released in a specific year (e.g., 2020)
select * from netflix;
SELECT title
from netflix
WHERE type = 'Movie' AND release_year = 2020;


-- 4. Find the top 5 countries with the most content on Netflix
select * from netflix;
SET SQL_SAFE_UPDATES = 0;
UPDATE netflix
SET Country = NULL
WHERE Country = '';
WITH RECURSIVE split_string AS (
    SELECT 
		show_id,
        SUBSTRING_INDEX(country, ',', 1) AS part,
        SUBSTRING(country, LENGTH(SUBSTRING_INDEX(country, ',', 1)) + 2) AS remainder
    FROM netflix
    WHERE country IS NOT NULL
    UNION ALL
    SELECT 
		show_id,
        SUBSTRING_INDEX(remainder, ',', 1) AS part,
        SUBSTRING(remainder, LENGTH(SUBSTRING_INDEX(remainder, ',', 1)) + 2) AS remainder
    FROM split_string
    WHERE remainder != ''
)
SELECT part AS Country, COUNT(show_id) AS Ttal_shows
FROM split_string
GROUP BY part
ORDER BY COUNT(show_id) DESC;

-- 5. Identify the longest movie
select * from netflix;
SELECT * 
FROM netflix
WHERE type = 'Movie' AND duration = (SELECT 
MAX(CAST(REPLACE(duration,'min', '') AS SIGNED ) )AS movie_duration
FROM netflix
WHERE type = 'Movie' );

-- 6. Find content added in the last 5 years
SELECT *
FROM netflix
WHERE STR_TO_DATE(date_added, '%M %d,%Y') >= DATE_SUB(current_date() , interval 5 year);
DESCRIBE netflix;
-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
SELECT * FROM netflix;
SELECT * FROM
netflix
WHERE director LIKE  '%Rajiv Chilaka%';
-- 8. List all TV shows with more than 5 seasons
SELECT * FROM netflix;
SELECT *
FROM
netflix
WHERE type = 'TV Show' AND (CAST(REPLACE(duration,'Season','') AS SIGNED) >= 5 OR CAST(REPLACE(duration,'Seasons','') AS SIGNED) >= 5);

-- 9. Count the number of content items in each genre
WITH RECURSIVE Split_string AS (
	SELECT show_id,
	SUBSTRING_INDEX(listed_in,',',1) as genre,
	SUBSTRING(listed_in,LENGTH(SUBSTRING_INDEX(listed_in,',',1))+2) AS remainder
	FROM netflix
    UNION ALL
    SELECT show_id,
    SUBSTRING_INDEX(remainder,',',1) as genre,
	SUBSTRING(remainder,LENGTH(SUBSTRING_INDEX(remainder,',',1))+2) AS remainder
    FROM Split_string
    WHERE remainder != '')
SELECT genre, COUNT(show_id) AS Content_Number FROM
Split_string
GROUP BY genre
ORDER BY COUNT(show_id) DESC ;


-- 10.Find each year and the average numbers of content release in India on netflix. 
WITH table1 AS (SELECT country,EXTRACT(YEAR FROM str_to_date(date_added, '%M %d,%Y')) AS yearr, COUNT(show_id) as content_release
FROM netflix
GROUP BY country, yearr
HAVING country = 'India'
ORDER BY yearr ASC)
SELECT country , yearr,content_release, (content_release/(SELECT SUM(content_release) AS total_movies 
																	FROM table1
																	GROUP BY country)*100) AS avg_release
FROM table1;


-- 11. List all movies that are documentaries
SELECT *
FROM netflix
WHERE listed_in LIKE '%Documentaries%';
-- 12. Find all content without a director
SELECT *
FROM netflix
WHERE director = '';
-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
SELECT COUNT(title) AS total_movies
FROM netflix 
WHERE str_to_date(date_added, '%M %d,%Y') >= date_sub(current_date(),INTERVAL 10 YEAR) AND cast LIKE '%Salman Khan%'
;


-- 15.
-- Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
-- the description field. Label content containing these keywords as 'Bad' and all other 
-- content as 'Good'. Count how many items fall into each category.

WITH table1 AS(SELECT
CASE 
	WHEN LOWER(description) LIKE '%kill%' OR '%violence%' THEN 'BAD'
    ELSE 'GOOD'
END AS label
FROM netflix
)
SELECT label, COUNT(label) AS Total_count
FROM table1
GROUP BY label
;

select 
	count(*) as total
FROM netflix;