USE lyft;

#1 FIND THE NUMBER OF REQUESTS PER GENDER PER YEAR, ARE MEN MORE INTERESTED TO NEWER CARS?
SELECT Gender, Year, count(requestID)
FROM customers, drivers, requests
WHERE drivers.DriverName = requests.DriverName AND customers.CustomerName = requests.CustomerName
GROUP BY Gender, Year
ORDER BY Gender, Year;

#2 FIND THE OLDEST CUSTOMER. LIST NAME, AGE
SELECT CustomerName, Age
FROM customers
WHERE Age = ( SELECT MAX(Age) FROM customers );

#3 Among the customers who requested a ride to the Park, how many of them have names starting with the character ‘S’?
SELECT COUNT(customers.CustomerName)
FROM customers, requests
WHERE customers.CustomerName = requests.CustomerName
AND customers.CustomerName LIKE "S%" AND Destination = "Park";

#4 List all customers, except the youngest one. Try this with the ANY operator.
SELECT CustomerName, Age
FROM customers
WHERE Age > ANY( SELECT Age FROM customers );

#5 Find the drivers whose average distance driven is larger than the average distance of all rides taken by Clayton residents.
#Sort the results by the average distance.

SELECT DriverName, AVG(Distance)
FROM requests
GROUP BY DriverName
HAVING AVG( Distance ) > 
	( SELECT AVG( Distance ) 
	  FROM requests, customers
	  WHERE customers.CustomerName = requests.CustomerName AND Address = "Clayton");
      
#6 Find the number of requests per gender per destination. Select only destinations that have the
#  character ‘t’ in them. Sort results by destination then gender.

SELECT Destination, Gender, count( RequestID )
FROM requests JOIN customers USING( CustomerName )
WHERE LOWER( Destination ) LIKE "%t%"
GROUP BY Destination, Gender;

#7 List the customers who had a ride to WashU in a silver car. Among these customers, who is
#  the youngest? Use a subquery in the WHERE clause in your answer. Sort the results by age.
SELECT customers.CustomerName, Age
FROM customers
WHERE customers.CustomerName IN			#IN = INTERSECT
(SELECT customers.CustomerName FROM customers, drivers, requests
WHERE customers.CustomerName = requests.CustomerName AND drivers.DriverName = requests.DriverName 
AND destination = "WashU" AND drivers.Color = "Silver" )
ORDER BY AGE;

#8 List the customers who are younger than the average age. Also, list those customers that all
#  their rides are shorter than the average distance of all trips in any individual ride. Show all
#  of these customers in one query. Sort the results by customer name is increasing order.
(SELECT customers.CustomerName
FROM customers
WHERE Age < ( SELECT AVG(Age) FROM customers)
)
UNION
(SELECT CustomerName
FROM Requests
GROUP BY CustomerName
HAVING MAX(Distance)  <
( SELECT AVG(Distance) FROM Requests )
)
ORDER BY CustomerName;

#9 Find the customers who have more than the average number of requests in the current week.
# List their names and number of trips in the current week. Sort by the number of trips.
SELECT requests.CustomerName, COUNT(requests.CustomerName) AS Num_of_trips
FROM requests
GROUP BY requests.CustomerName
HAVING COUNT(requests.CustomerName) > 
	(SELECT AVG(Trips)
	 FROM ( SELECT COUNT(requests.CustomerName) AS Trips
			FROM requests
			GROUP BY requests.CustomerName) AS Average)  # ALIAS超重要
ORDER BY COUNT(requests.CustomerName);

#10 Among the customers in the previous query, which ones do not live in ‘St. Louis’? (Hint:
#Use NOT IN)
SELECT requests.CustomerName, COUNT(requests.CustomerName) AS Num_of_trips
FROM requests
WHERE CustomerName NOT IN ( SELECT CustomerName FROM customers WHERE Address = "St. Louis" )
GROUP BY requests.CustomerName
HAVING COUNT(requests.CustomerName) > 
	(SELECT AVG(Trips)
	 FROM ( SELECT COUNT(requests.CustomerName) AS Trips
			FROM requests
			GROUP BY requests.CustomerName) AS Average) 
ORDER BY COUNT(requests.CustomerName);

#11 Please add a new column to the requests table in order to identify the distance of rides and
#   call it Trip. Please tag rides based on the following condition:
#   If the distance is larger than 20, tag it as “Long”.
# 	If the distance is between and including 15 and 20, tag it as “Upper Medium”.
# 	If the distance is between and including 10 and 14, tag it as “Medium”.
# 	If the distance is between and including 5 and 9, tag it as “Lower Medium”.
# 	If the distance is less than 5 tag it as “Short”.
# 	If no information is available for distance, please tag it as “No Information”
ALTER TABLE requests ADD Trip VARCHAR(30);

UPDATE requests JOIN
	( SELECT Distance,
    CASE
		WHEN Distance > 20 THEN "Long"
        WHEN Distance >= 15 AND Distance <= 20 THEN "Upper Median"
        WHEN Distance >= 10 AND Distance <= 14 THEN "Median"
        WHEN Distance >= 9  AND Distance <= 5 THEN "Lower Median"
        WHEN Distance < 5 THEN "Short"
        ELSE "No Information"
	END AS Trip
    FROM requests)
	AS temp_table
USING(Distance)
SET requests.Trip = temp_table.Trip;

SELECT * FROM requests;

# 12) Please remove the column that you added recently (Trip).
ALTER TABLE requests DROP COLUMN Trip;

# 13)List once each car model for cars that were requested on Tuesdays.
#  Try this with the EXIST operator
SELECT DISTINCT Model
FROM drivers
WHERE EXISTS
		( SELECT DriverName
          FROM requests
          WHERE drivers.DriverName = requests.DriverName  # EXIST外面裡面要用WHERE不能直接JOIN
          AND DayOfWeek = "Tuesday" );
          

#7) Are certain car colors more popular? For each car color calculate: the number of rides, the number of 
#cars, and the average number of rides per car. Include all cars in this query.  Optional: calculate the 
#average distance per car of that color.

SELECT Color, count(RequestID) as rides, count(DISTINCT requests.DriverName) as car_numbers,
(count(RequestID)/count(DISTINCT requests.DriverName)) AS Avg_Drives
FROM drivers JOIN requests USING(DriverName)
GROUP BY Color;

 

#8) For each customer find the total number of rides they had, both in the past and in the current week. Is 
#there any relationship between the number of rides a customer had in the past, and the number of rides 
#in the current week? Sort you results by the total number of rides, and return only the 12 customers 
#with the fewest rides, in total. 
SELECT customers.CustomerName, PastTrips, count(requestID),
( IF(PastTrips IS NULL, 0, PastTrips) + count(requestID) ) AS total
FROM customers LEFT JOIN requests USING(CustomerName)
GROUP BY customers.CustomerName 
ORDER BY total LIMIT 12;

#9) Convert the previous question (Question #8) into a subquery to find the average total number of trips 
#for each address. Remember that the address is the city the customer lives in. Sort results in increasing 
#order of average number of trips.
SELECT Address, AVG(total)
FROM (SELECT customers.CustomerName, PastTrips, count(requestID), Address,
( IF(PastTrips IS NULL, 0, PastTrips) + count(requestID) ) AS total
FROM customers LEFT JOIN requests USING(CustomerName) 
GROUP BY customers.CustomerName ) AS temp
GROUP BY Address
ORDER BY AVG(total);

#11) What is the average age of travelers to each destination? Order the destinations from oldest 
#travelers to youngest.

SELECT Destination, AVG(Age)
FROM customers JOIN requests USING(CuSTOMERName)
GROUP BY  Destination
order by avg(age) desc;