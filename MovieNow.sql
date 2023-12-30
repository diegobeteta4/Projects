--1 First look at the customers table
SELECT *
FROM customers
LIMIT 5;

--2 Count of customers
SELECT COUNT(DISTINCT name) as number_of_customers
FROM customers;

-- 3 Distribution of customers by country
SELECT country, 
	COUNT(*) as number_of_customers
FROM customers
GROUP BY 1
ORDER BY 2 DESC;

--4 Gender Distribution Among Customers
SELECT gender, 
	COUNT(*) as number_of_customers 
FROM customers
GROUP by 1
ORDER BY 2 DESC;

--5 Average Age of Customers 
SELECT 
	ROUND(AVG(DATE_PART('year',(CURRENT_DATE)) -  DATE_PART('year', date_of_birth))::numeric,1) 
	AS average_age_of_customers
FROM customers;

--6 Age Standard Deviation
SELECT ROUND(stddev(DATE_PART('year',date_of_birth))::numeric,2) 
	AS standard_deviation
FROM customers;

--7 Youngest Customer
SELECT name, 
	DATE_PART('year',(CURRENT_DATE)) -  DATE_PART('year', date_of_birth) AS age
FROM customers
ORDER BY 2 
LIMIT 1;

-- 8 Oldest Customer
SELECT name, 
	DATE_PART('year',CURRENT_DATE) -  DATE_PART('year', date_of_birth) as age
FROM customers
ORDER BY 2 DESC
LIMIT 1;

--9 What customer has spent the most
SELECT c.name, SUM(m.renting_price) AS total_spent
FROM renting r
JOIN customers c ON r.customer_id = c.customer_id
JOIN movies m ON r.movie_id = m.movie_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

--10 Customer with more rentals
SELECT c.name, COUNT(r.renting_id) AS rental_count
FROM renting r
JOIN customers c ON r.customer_id = c.customer_id
GROUP BY 1
ORDER BY 2 DESC;

--11 Age Group Segmentation
SELECT 
  CASE 
    WHEN age BETWEEN 18 AND 25 THEN '18-25'
    WHEN age BETWEEN 26 AND 35 THEN '26-35'
    WHEN age BETWEEN 36 AND 45 THEN '36-45'
    WHEN age > 45 THEN '46+'
    ELSE 'Under 18'
  END AS age_group,
  COUNT(*) AS number_of_customers
FROM (
	SELECT customer_id, DATE_PART('year',CURRENT_DATE) - DATE_PART('year', date_of_birth) AS age 
	FROM customers) 
GROUP BY 1;

-- 12 Average Account Age:
SELECT 
	ROUND(AVG(DATE_PART('year', CURRENT_DATE)- DATE_PART('year',date_account_start))::numeric, 1)
	AS average_age
FROM customers;

--13 Account Longevity 
SELECT name, 
	DATE_PART('year', CURRENT_DATE)- DATE_PART('year',date_account_start) 
	AS longevity_in_years
FROM customers
ORDER BY 2;

--14 New Customer Trends Over Time
SELECT DATE_PART('year',date_account_start), 
	COUNT(*) as new_customers
FROM customers
GROUP BY 1
ORDER BY 1;


--Understanding customer preferences
--15 Preferred Genres by Country
SELECT c.country, m.genre, COUNT(*) as rental_count
FROM renting r
JOIN movies m 
ON r.movie_id = m.movie_id
JOIN customers c 
ON r.customer_id = c.customer_id
GROUP BY 1, 2
ORDER BY 1, 3 DESC;

--16 Age Group Preferences
SELECT age_group, m.genre, COUNT(*) as rental_count
FROM (
    SELECT customer_id, 
           CASE 
               WHEN DATE_PART('year',(CURRENT_DATE)) -  DATE_PART('year', date_of_birth) BETWEEN 18 AND 25 THEN '18-25'
               WHEN DATE_PART('year',(CURRENT_DATE)) -  DATE_PART('year', date_of_birth) BETWEEN 26 AND 35 THEN '26-35'
               WHEN DATE_PART('year',(CURRENT_DATE)) -  DATE_PART('year', date_of_birth) BETWEEN 36 AND 45 THEN '36-45'
               WHEN DATE_PART('year',(CURRENT_DATE)) -  DATE_PART('year', date_of_birth) > 45 THEN '46+'
               ELSE 'Under 18'
           END AS age_group
    FROM customers
) as c
JOIN renting r 
ON c.customer_id = r.customer_id
JOIN movies m 
ON r.movie_id = m.movie_id
GROUP BY 1, 2
ORDER BY 1, 3 DESC;

--17 Gender-Based Preferences
SELECT c.gender, m.genre, COUNT(*) as rental_count
FROM renting r
JOIN movies m 
ON r.movie_id = m.movie_id
JOIN customers c 
ON r.customer_id = c.customer_id
GROUP BY 1, 2
ORDER BY 1, 3 DESC;


--18 FIRST LOOK AT THE actors TABLE
SELECT *
FROM actors
LIMIT 5;

--19 Count of actors 
SELECT 
	COUNT(DISTINCT name) AS number_of_actors
FROM actors;

--20 Average Age of Actors 
SELECT 
	ROUND(AVG(DATE_PART('year',(SELECT CURRENT_DATE)) -  year_of_birth)::numeric,1)
		AS average_age
FROM actors;


--21 Youngest Actor
SELECT  name, 
	DATE_PART('year',(CURRENT_DATE)) -  year_of_birth as age
FROM actors
ORDER BY 2
LIMIT 1;

--22 Oldest Actor
SELECT  name, 
	DATE_PART('year',(CURRENT_DATE)) -  year_of_birth as age
FROM actors
WHERE year_of_birth IS NOT NULL
ORDER BY 2 DESC
LIMIT 1;


--23 Male and Female Actors
SELECT gender,
	COUNT(*) AS number_of_actors
FROM actors
GROUP BY 1;

--24 Nationalities
SELECT nationality, 
	COUNT(*) as number_of_actors
FROM actors
GROUP BY nationality
ORDER BY 2 DESC;

--25 What actors have acted in the most movies
SELECT a.name, COUNT(ai.movie_id) AS number_of_movies
FROM actors a
JOIN actsin ai ON a.actor_id = ai.actor_id
GROUP BY a.actor_id, a.name
ORDER BY number_of_movies DESC
LIMIT 10;

--26 FIRST LOOK AT THE movies TABLE
SELECT *
FROM movies
LIMIT 5;

--27 Count by genre
SELECT genre, COUNT(*)
FROM movies
GROUP BY 1
ORDER BY 2 DESC;

--28 Average hour runtime by genre
SELECT genre, ROUND(AVG(runtime/60),2) as avg_hours
FROM movies
GROUP BY 1
ORDER BY 2 DESC;

--29 Average rent price by genre
SELECT genre, 
	ROUND(AVG(renting_price),2) as avg_price
FROM movies
WHERE genre <> 'Other'
GROUP BY 1
ORDER BY 2 DESC;

--30 What are the most rented movies
SELECT m.title, 
	COUNT(r.renting_id) AS rental_count
FROM renting r
JOIN movies m 
ON r.movie_id = m.movie_id
GROUP BY m.movie_id, m.title
ORDER BY rental_count DESC
LIMIT 10;



--Key Bussines Factors
--31 Year with more rentals
SELECT DATE_PART('month',date_renting) AS rental_year, 
	COUNT(*) AS rental_count
FROM renting
GROUP BY 1
ORDER BY 2 DESC
;

--32 Income by year
SELECT DATE_PART('year', r.date_renting) AS year, 
	SUM(m.renting_price) AS total_income
FROM renting r
JOIN movies m 
ON r.movie_id = m.movie_id
GROUP BY 1
ORDER BY 2 DESC;

--33 Month with highest income
SELECT DATE_PART('month', r.date_renting) AS rental_month, 
	SUM(m.renting_price) AS total_income
FROM renting r
JOIN movies m 
ON r.movie_id = m.movie_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

--34 Rental count by genre
SELECT m.genre, 
	COUNT(r.renting_id) AS rental_count
FROM renting r
JOIN movies m 
ON r.movie_id = m.movie_id
GROUP BY 1
ORDER BY 2 DESC;

--35 Total Income by genre
SELECT genre, 
	SUM(m.renting_price) AS total_income
FROM renting r
JOIN movies m 
ON r.movie_id = m.movie_id
GROUP BY 1
ORDER BY 2 DESC;

--36 Effect of Movie Release Year on Rentals
SELECT m.year_of_release, COUNT(r.renting_id) AS rental_count
FROM renting r
JOIN movies m ON r.movie_id = m.movie_id
GROUP BY m.year_of_release
ORDER BY rental_count DESC;












