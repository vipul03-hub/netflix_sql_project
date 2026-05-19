--NETFLIX PROJECT
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
	show_id VARCHAR(6),
	type  VARCHAR(10),
	title VARCHAR(150),
	director  VARCHAR(208),
	casts  VARCHAR(1000),
	country  VARCHAR(150),
	date_added  VARCHAR(50),
	release_year  INT,
	rating  VARCHAR(10),
	duration VARCHAR(15),
	listed_in  VARCHAR(100),
	description  VARCHAR(250)
);

SELECT * FROM netflix;


SELECT
    COUNT(*) as total_content
FROM netflix;

-- 15 business problems
--Q1. count the number of movies vs TV shows
SELECT type,count(*) AS total_content
FROM netflix
GROUP BY type

--Q2. find the most common rating for movies and tv shows
SELECT type , rating
FROM
(SELECT type, rating,count(*),RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
FROM netflix
GROUP BY 1,2
)
WHERE ranking=1

--Q3. list all movies released in a specific year (eg 2020)
SELECT *
FROM netflix
WHERE type='Movie' AND release_year=2020

--Q4. Find top 5 countries with most content on netflix
SELECT UNNEST(STRING_TO_ARRAY(country,',')) AS new_country,count(show_id) AS total_content
FROM netflix
GROUP BY new_country
ORDER BY total_content DESC
LIMIT 5

--Q5. Identify longest movie
SELECT title , duration
FROM netflix
where type='Movie' AND duration = (SELECT MAX(duration) FROM netflix) 


--Q6 Find the content added in last 5 years
SELECT * , TO_DATE(date_added,'month DD, YYYY') 
FROM netflix
WHERE
    TO_DATE(date_added,'month DD, YYYY')>=CURRENT_DATE-INTERVAL '5years'

--Q7. Find all the movies/TV shows by director rajiv chilaka
SELECT * FROM netflix
WHERE director ILIKE '%rajiv Chilaka%'


--Q8.list all TV shows with more than 5 seasons
SELECT * FROM netflix
WHERE type='TV Show' AND SPLIT_PART(duration,' ',1)::numeric>5

--Q9. Count the number of content items in each genre
SELECT UNNEST(STRING_TO_ARRAY(listed_in,',')) as genre, count(*) FROM netflix
GROUP BY UNNEST(STRING_TO_ARRAY(listed_in,','))

--Q10.Find each year and the average numbers of content release by India on netflix. return top 5 year with highest avg content release
SELECT 
   EXTRACT(YEAR FROM TO_DATE(date_added,'month DD, YYYY')) as year,
   COUNT(*) AS yearly_content,
   ROUND(
   COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country='India')::numeric*100
   ,2) as avg_content_per_year
FROM netflix
WHERE country='India'
GROUP BY 1;

--Q11. List all movies that are documentaries
SELECT * FROM NETFLIX
WHERE type='Movie' AND listed_in LIKE '%Documentaries%'


--Q12. Find all content without a director
SELECT * FROM NETFLIX
WHERE director IS NULL


--Q13. Find how many movies actor 'salman khan' appeared in last 10 years
SELECT 
    *
FROM netflix
WHERE casts ILIKE '%Salman Khan%' AND release_year>EXTRACT(YEAR FROM CURRENT_DATE)-10
    

--Q14. Find the top 10 actors who have appeared in the highest number of movies produced in India
SELECT
     UNNEST(STRING_TO_ARRAY(casts,',')) AS Actors,
	 COUNT(*)
FROM netflix
WHERE country ILIKE'%india'
GROUP BY Actors
ORDER BY COUNT(*) DESC
LIMIT 10;

--Q15. categorize the content baswd on presence of the keywords 'kill' and 'violence' in the description field. Label content containing these keywords as 'Bad' and all other content as 'Good', Count how manyitems fall into each category
WITH new_table
AS
(
SELECT 
*,
    CASE
	WHEN description ILIKE '% kill%'
	     OR
		 description ILIKE '%violence%' THEN 'BAD_FILM'
		 ELSE 'GOOD_CONTENT'
	END category
FROM netflix 
)
SELECT 
    category,
	COUNT(*) as total_content
FROM new_table
GROUP BY 1