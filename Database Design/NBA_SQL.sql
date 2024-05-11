USE nba;

#A. Find all players whose salary is greater than 10,000,000 and the position is PG (point guard). 
#List player, salary, and position. 

SELECT players.Player, players.Salary, players.Position
FROM players
WHERE Salary > 10000000 AND Position = "PG";

#B. For each team, find the average number of capacities of the team's stadium and the number of 
#wins. List the team’s name, average number of capacity and the number of wins. Order the 
#results by the average number of capacities in decreasing order. Show only the top 5 rows in 
#the order. 

SELECT teams.Team, avg(games.Attendance), teams.Wins
FROM teams, games
WHERE games.Home = teams.Team
GROUP BY teams.Team
ORDER BY avg(games.Attendance) DESC LIMIT 5; #LIMIT 5 = 只放五個


#C. For each player, list the player's name, team and city of the team. If the player has no salary, 
#list the total salary as 0. Sort the results by salary in increasing order. 

SELECT  players.Player, players.Team, Teams.City, COALESCE( players.Salary, 0) # NA變0
FROM players LEFT JOIN teams USING(Team) #沒有說排除沒球隊的
ORDER BY players.Salary ASC;

#D. For each team with the letter "a" in the name of each state or city, list the team name, the total 
#number of wins, and number of players. 

SELECT teams.Team, CONCAT(State, " ", City), AVG(teams.Wins), COUNT(players.Player) #CONCAT->兩個STRING加起來
FROM teams JOIN players USING(Team)
WHERE CONCAT(State, " ", City) LIKE "%a%"  #不包含: not like 字首:"a%" 限定字數:"a__"
GROUP BY teams.Team;
 

#E. Find all pairs of players with the same position. Include the player's name, team, and position 
#in each pair. Sort the results by player's name in increasing order. 

SELECT p1.Player, p1.Team, p1.Position, p2.Player, p2.Team
FROM players AS p1 JOIN players AS p2 USING(Position)
WHERE p1.Player < p2.player #才會從A開始
ORDER BY p1.Player ASC;

#F. How many teams are hockey teams? 

SELECT COUNT(teams.Team) AS Num_of_hockey_teams
FROM teams
WHERE teams.Wins IS NULL;
 

#G. Find players whose point totals are more than the average points scored by all players. In 
#addition, list those players whose salaries are higher than the average salary of PG (point guard) 
#players. List all these players in one query. List each player once. Sort the results by player 
#name in descending order. 

SELECT  players.Player
FROM players
WHERE players.Points > 
( SELECT AVG(players.Points) FROM players )
OR players.Salary >
( SELECT AVG(players.Salary) FROM players WHERE players.Position = "PG" )
ORDER BY players.Player DESC;