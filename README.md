# Netflix Content Analysis
![Netflix Logo](https://github.com/subh-ankar/Netflix_SQL_Project/blob/main/logo.png)

## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Objectives

- Analyze the distribution of content types (movies vs TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.

## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

```sql
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);
```

## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
SELECT type,COUNT(type) AS Movies_TV_shows
FROM netflix
GROUP BY type
```

**Objective:** Determine the distribution of content types on Netflix.

### 2. Find the Most Common Rating for Movies and TV Shows

```sql
SELECT type,ratings_count, rankk
FROM ( select type, rating,count(rating) as ratings_count,
RANK() OVER (PARTITION BY type ORDER BY count(rating) DESC) AS rankk
FROM netflix
GROUP BY type,rating) AS tablee
WHERE rankk = 1;
```

**Objective:** Identify the most frequently occurring rating for each type of content.

### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
SELECT title
from netflix
WHERE type = 'Movie' AND release_year = 2020;
```

**Objective:** Retrieve all movies released in a specific year.

### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
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
```

**Objective:** Identify the top 5 countries with the highest number of content items.

### 5. Identify the Longest Movie

```sql
SELECT * 
FROM netflix
WHERE type = 'Movie' AND duration = (SELECT 
MAX(CAST(REPLACE(duration,'min', '') AS SIGNED ) )AS movie_duration
FROM netflix
WHERE type = 'Movie' );
```

**Objective:** Find the movie with the longest duration.

### 6. Find Content Added in the Last 5 Years

```sql
SELECT *
FROM netflix
WHERE STR_TO_DATE(date_added, '%M %d,%Y') >= DATE_SUB(current_date() , interval 5 year);
DESCRIBE netflix;
```

**Objective:** Retrieve content added to Netflix in the last 5 years.

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
SELECT * FROM
netflix
WHERE director LIKE  '%Rajiv Chilaka%';
```

**Objective:** List all content directed by 'Rajiv Chilaka'.

### 8. List All TV Shows with More Than 5 Seasons

```sql
SELECT *
FROM
netflix
WHERE type = 'TV Show' AND (CAST(REPLACE(duration,'Season','') AS SIGNED) >= 5 OR CAST(REPLACE(duration,'Seasons','') AS SIGNED) >= 5);
```

**Objective:** Identify TV shows with more than 5 seasons.

### 9. Count the Number of Content Items in Each Genre

```sql
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
ORDER BY COUNT(show_id) DESC;
```

**Objective:** Count the number of content items in each genre.

### 10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!

```sql
WITH table1 AS (SELECT country,EXTRACT(YEAR FROM str_to_date(date_added, '%M %d,%Y')) AS yearr, COUNT(show_id) as content_release
FROM netflix
GROUP BY country, yearr
HAVING country = 'India'
ORDER BY yearr ASC)
SELECT country , yearr,content_release, (content_release/(SELECT SUM(content_release) AS total_movies 
																	FROM table1
																	GROUP BY country)*100) AS avg_release
FROM table1;
```

**Objective:** Calculate and rank years by the average number of content releases by India.

### 11. List All Movies that are Documentaries

```sql
SELECT *
FROM netflix
WHERE listed_in LIKE '%Documentaries%';
```

**Objective:** Retrieve all movies classified as documentaries.

### 12. Find All Content Without a Director

```sql
SELECT *
FROM netflix
WHERE director = '';
```

**Objective:** List content that does not have a director.

### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

```sql
SELECT COUNT(title) AS total_movies
FROM netflix 
WHERE str_to_date(date_added, '%M %d,%Y') >= date_sub(current_date(),INTERVAL 10 YEAR) AND cast LIKE '%Salman Khan%';
```

**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.



### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

```sql
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
```

**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.

## Findings and Conclusion

- **Content Distribution:** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
- **Common Ratings:** Insights into the most common ratings provide an understanding of the content's target audience.
- **Geographical Insights:** The top countries and the average content releases by India highlight regional content distribution.
- **Content Categorization:** Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.

This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.



## Author - Subhankar

This project is part of my portfolio, showcasing the SQL skills essential for data analyst roles. 
