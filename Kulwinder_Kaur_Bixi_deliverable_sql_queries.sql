/* SQL queries performed by Kulwinder Kaur to understand the trends on usage of Bixi Bikes
Email address: Kulwinderkaur.nit@gmail.com.
Project deliverable : Bixi Project - Part 1 - Data Analysis in SQL
*/
-- understanding data of trips and stations tables.
SELECT COUNT(*) FROM trips;
SELECT DISTINCT code FROM stations;

DESCRIBE trips;
DESC stations;

-- Q1.1 The total number of trips for the year of 2016.

SELECT COUNT(*) AS total_trips_2016
FROM trips 
WHERE YEAR(start_date)=2016; 

-- Q1.2 The total number of trips for the year of 2017.

SELECT COUNT(*) AS total_trips_2017
FROM trips 
WHERE YEAR(start_date)=2017; 

-- Q1.3 The total number of trips for the year of 2016 broken down by month.

SELECT Count(*) AS trips_per_month_2016, MONTH(start_date) AS month_2016
FROM trips
WHERE YEAR(start_date)=2016
GROUP BY month_2016 
ORDER BY month_2016;

-- Q1.4 The total number of trips for the year of 2017 broken down by month.

SELECT Count(*) AS trips_per_month_2017, MONTH(start_date) AS month_2017
FROM trips
WHERE YEAR(start_date)=2017
GROUP BY month_2017 
ORDER BY month_2017;

-- Q1.5 The average number of trips a day for each year-month combination in the dataset.

SELECT sub.trips_per_month/sub.days_in_month AS avg_per_day_per_month, sub.year_data, sub.month_of_year
FROM (SELECT  COUNT(*)  AS trips_per_month, MONTH(start_date) AS month_of_year, YEAR(start_date) AS year_data , dayofmonth(LAST_DAY(start_date)) AS days_in_month
FROM trips  
GROUP BY YEAR(start_date), month(start_date), dayofmonth(LAST_DAY(start_date))) AS sub;

-- subquery
SELECT 
	YEAR(start_date) AS year_,
	MONTH(start_date) AS month_,
	DAY(start_date) AS day_, COUNT(*) as trips_per_day
FROM trips
GROUP BY year_, month_, day_;
-- round( , 0) means no decimal point
SELECT year_, month_, ROUND(AVG(trips_per_day), 0) as avg_daily_trips
FROM (SELECT 
	YEAR(start_date) AS year_,
	MONTH(start_date) AS month_,
	DAY(start_date) AS day_, COUNT(*) as trips_per_day
FROM trips
GROUP BY year_, month_, day_) AS sub
GROUP BY year_, month_;


-- without using subquery

SELECT 
	YEAR(start_date), 
	MONTH(start_date), 
	ROUND(COUNT(*)/ COUNT(DISTINCT DAY(start_date)), 0) AS daily_average
FROM trips
GROUP BY YEAR(start_date), MONTH(start_date);


-- Q1.6 Save your query results from the previous question (Q1.5) by creating a table called working_table1.

CREATE TABLE working_table1 AS 
SELECT sub.trips_per_month/sub.days_in_month AS avg_per_day_per_month, sub.year_data, sub.month_of_year
FROM (SELECT  COUNT(*)  AS trips_per_month, MONTH(start_date) AS month_of_year, YEAR(start_date) AS year_data , dayofmonth(LAST_DAY(start_date)) AS days_in_month
FROM trips  
GROUP BY YEAR(start_date), month(start_date), dayofmonth(LAST_DAY(start_date))) AS sub;

-- Q2.1 The total number of trips in the year 2017 broken down by membership status (member/non-member).

SELECT COUNT(*) AS total_trips_in_2017, is_member
FROM trips 
WHERE YEAR(start_date)= 2017 
GROUP BY is_member;

-- Q2.2 The percentage of total trips by members for the year 2017 broken down by month.

SELECT (Count(*)/ ( SELECT COUNT(*) 
FROM trips 
WHERE YEAR(start_date) =2017 AND is_member=1 
GROUP BY YEAR(start_date))*100) as per_m_y, 
MONTH(start_date) AS month_2017
FROM trips
WHERE YEAR(start_date)=2017 AND is_member =1
GROUP BY month_2017
ORDER BY month_2017;

SELECT AVG(is_member) AS member_trips, MONTH(start_date)
FROM trips
WHERE YEAR(start_date)=2017
GROUP BY MONTH(start_date);

-- Q3.1 At which time(s) of the year is the demand for Bixi bikes at its peak?
-- for year 2017
SELECT Count(*) AS trips_per_month, MONTH(start_date) AS months, YEAR(start_date)
FROM trips
WHERE YEAR(start_date)=2017
GROUP BY MONTH(start_date), YEAR(start_date)
ORDER BY trips_per_month DESC LIMIT 1;
-- for year 2016
SELECT Count(*) AS trips_per_month, MONTH(start_date) AS months, YEAR(start_date)
FROM trips
WHERE YEAR(start_date)=2016
GROUP BY MONTH(start_date), YEAR(start_date)
ORDER BY trips_per_month DESC LIMIT 1;

-- good solution
SELECT 
	MONTH(start_date) AS month,
    SUM(IF(YEAR(start_date)=2016, 1, 0)) AS year_2016,
    SUM(IF(YEAR(start_date)=2017, 1,0)) AS year_2017
FROM trips
GROUP BY month;

-- Q3.2 If you were to offer non-members a special promotion in an attempt to convert them to members, when would you do it? 

/*The months before the summer season i.e. May and April because for both of these months the usage of bikes is less 
(for both members and non-members). If we could offer special membership discounts during these months, 
we can attract a good number before the summer and could maintain the bikes inventory for the peak season. */

-- If we were to consider location as well then, we can offer membership discounts to non-members:
-- In the peak season for less popular locations 7075,7009,5003,7062,7023
-- In off season for most popular locations 6100, 6078, 6184, 6136, 6064

-- This is the query to find out list of names of stations less popular to most popular in summer. 
SELECT a.start_station_code, b.name, COUNT(*) AS total_trips_perstartion
FROM trips as a
INNER JOIN stations as b
ON a.start_station_code= b.code
WHERE MONTH(a.start_date) IN (7,8,6,9)
GROUP BY a.start_station_code, b.name
ORDER BY total_trips_perstartion ASC;


-- Q4.1 What are the names of the 5 most popular starting stations? Determine the answer without using a subquery.

SELECT stations.name, trips.start_station_code, COUNT(*) AS total_trips
FROM trips
JOIN stations on stations.code=trips.start_station_code
GROUP BY trips.start_station_code
ORDER BY total_trips DESC
LIMIT 5;


SELECT a.start_station_code, b.name, COUNT(*) AS total_trips_perstartion
FROM trips as a
INNER JOIN stations as b
ON a.start_station_code= b.code
GROUP BY a.start_station_code, b.name
ORDER BY total_trips_perstartion DESC LIMIT 5;

-- Q4.2 Solve the same question as Q4.1, but now use a subquery. Is there a difference in query run time between 4.1 and 4.2? Why or why not?

SELECT stations.name, sub.start_station_code, sub.total_trips_perstation 
FROM stations
INNER JOIN
(SELECT COUNT(*) AS total_trips_perstation, start_station_code FROM trips GROUP BY start_station_code) AS sub
ON sub.start_station_code=stations.code
ORDER BY sub.total_trips_perstation DESC LIMIT 5;

-- Using subquery was fast in this case (only took 5.58 seconds) compared to using a single query (took 11.53 seconds) as when we are grouping the data on joined table it does an extra work because the entries are more on the new joined table.
-- When using subquery and using GROUP BY in the subquery, we are grouping the data on a single table, and it reduces the size of the resulting table and it becomes easier and fast to join it with new table and to find out results from it.

-- Q5.1 How is the number of starts and ends distributed for the station Mackay / de Maisonneuve throughout the day.
-- The station code for Mackay / de Maisonneuve is 6100.
-- We have considered time between (7-11) as morning, (12-16) as afternoon, (17-21) as evening, (22-7) as night.

SELECT COUNT(sub.time_when_ride_starts), COUNT( sub.time_when_ride_ends), sub.time_when_ride_starts, sub.time_when_ride_ends
FROM (SELECT CASE
       WHEN HOUR(start_date) BETWEEN 7 AND 11 THEN "morning"
       WHEN HOUR(start_date) BETWEEN 12 AND 16 THEN "afternoon"
       WHEN HOUR(start_date) BETWEEN 17 AND 21 THEN "evening"
       ELSE "night"
END AS time_when_ride_starts, 
CASE
       WHEN HOUR(end_date) BETWEEN 7 AND 11 THEN "morning"
       WHEN HOUR(end_date) BETWEEN 12 AND 16 THEN "afternoon"
       WHEN HOUR(end_date) BETWEEN 17 AND 21 THEN "evening"
       ELSE "night"
END AS time_when_ride_ends
FROM trips
WHERE start_station_code = 6100 AND end_station_code =6100) AS SUB
GROUP BY time_when_ride_starts, time_when_ride_ends;


############
#BEST QUERY#
############




-- Q5.2 Explain and interpret your results from above. Why do you think these patterns in Bixi usage occur for this station? Put forth a hypothesis and justify your rationale.
-- The round trips to Mackay/ de Maisonneuve are more common during afternoon and evening times probably because the station is located in the downtown and riders would find it most accessible because of availability of public transportation to reach to station and open restaurants and shops.  

-- Q6.1 First, write a query that counts the number of starting trips per station.

SELECT COUNT(*) AS total_trips, start_station_code  
FROM trips
GROUP BY start_station_code;

-- Q6.2 Second, write a query that counts, for each station, the number of round trips.

SELECT COUNT(*) AS total_round_trips , start_station_code  
FROM trips
WHERE start_station_code=end_station_code
GROUP BY start_station_code;

-- Q6.3 Combine the above queries and calculate the fraction of round trips to the total number of starting trips for each station.

SELECT COUNT(*) AS total_trips, sub.round_trips/COUNT(*) AS fract, trips.start_station_code
FROM trips
INNER JOIN 
(SELECT COUNT(*) AS round_trips , start_station_code  
FROM trips
WHERE start_station_code=end_station_code
GROUP BY start_station_code) AS sub
ON trips.start_station_code =sub.start_station_code
GROUP BY start_station_code;

-- Q6.4 Filter down to stations with at least 500 trips originating from them and having at least 10% of their trips as round trips.

SELECT COUNT(*) AS total_trips, sub.round_trips/COUNT(*) AS fract, trips.start_station_code
FROM trips
INNER JOIN 
(SELECT COUNT(*) AS round_trips , start_station_code  
FROM trips
WHERE start_station_code=end_station_code
GROUP BY start_station_code) AS sub
ON trips.start_station_code =sub.start_station_code
GROUP BY trips.start_station_code
HAVING COUNT(*)>=500 AND (fract*100)>=10;




-- Q6.5 Where would you expect to find stations with a high fraction of round trips? Describe why and justify your reasoning.

SELECT a.code, a.name, b.fract, b.total_trips 
FROM stations as a
INNER JOIN
(SELECT COUNT(*) AS total_trips, (sub.round_trips/COUNT(*)*100) AS fract, trips.start_station_code
FROM trips
INNER JOIN 
(SELECT COUNT(*) AS round_trips , start_station_code  
FROM trips
WHERE start_station_code=end_station_code
GROUP BY start_station_code) AS sub
ON trips.start_station_code =sub.start_station_code
GROUP BY trips.start_station_code
HAVING COUNT(*)>=500 AND fract>=10)  AS b
ON b.start_station_code= a.code
ORDER BY b.fract desc ;

-- Upon looking at station names of top 10 stations with maximus percentage of round trips we find the stations are one of these metro stations (like Métro Jean-Drapeau, Métro Angrignon), bus station (Berlioz / de l'Île des Soeurs), train station (Gare Canora), visitor centre (Basile-Routhier / Gouin), or tourist attractions like beach or casino. 
-- People prefer to use bixi bikes at stations where they can reach using any means of public transportation rent a bike and return to same station to go back to their respective destinations. 
-- Tourists prefer to use bixi bikes to explore the nearby area and return back to visitor centre.