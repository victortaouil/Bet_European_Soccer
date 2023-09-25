WITH 
 cte AS
 (SELECT match.home_team_api_id AS Home_id
		FROM Match
		WHERE B365H > 6.5 AND B365H )
		,
		
	cte1 AS
	
	(SELECT match.away_team_api_id AS Away_id
		FROM Match
		WHERE B365A > 6.5 AND B365A )
		,
	cte2 AS
	(SELECT 
	team_api_id,
	team_long_name
FROM Team
INNER JOIN Match 
	ON Match.home_team_api_id = Team.team_api_id )
 ,
 cte3 AS
 
(SELECT 
	DISTINCT(team_api_id),
	team_long_name
FROM cte2
INNER JOIN Match 
	ON Match.away_team_api_id = cte2.team_api_id

WHERE 
	team_api_id NOT IN
	(SELECT Home_id
		FROM cte) 
		
	AND
	
	team_api_id NOT IN
	(SELECT Away_id
		FROM cte1)
	
	AND 
	
	(B365H AND B365A NOT NULL))
	
		
SELECT 
	season AS Temporada,
	home_team_api_id,
	away_team_api_id,
	B365H,
	B365A,
	home_team_goal,
	away_team_goal,
	CASE WHEN home_team_api_id IN ( SELECT team_api_id FROM cte3)
	THEN  SUM(B365H) OVER(ORDER BY season ASC ROWS BETWEEN 0 PRECEDING AND  CURRENT ROW) 
	ELSE SUM(B365A) OVER(ORDER BY season ASC ROWS BETWEEN 0 PRECEDING AND  CURRENT ROW) 
	
	END AS odd_team_win ,
	
	CASE WHEN home_team_api_id IN (SELECT team_api_id FROM cte3)

	AND home_team_goal > away_team_goal THEN 1
	
	WHEN home_team_api_id IN ( SELECT team_api_id FROM cte3)

	AND home_team_goal <= away_team_goal THEN 0
	
	WHEN away_team_api_id  IN (SELECT team_api_id FROM cte3)

	AND away_team_goal > home_team_goal THEN 1
	
	WHEN away_team_api_id IN (SELECT team_api_id FROM cte3)

	AND away_team_goal <= home_team_goal THEN 0 
	
	END AS Team_win 
	
	FROM match
	
	WHERE 
		home_team_api_id IN (SELECT team_api_id FROM cte3)
			OR
		away_team_api_id IN (SELECT team_api_id FROM cte3);
	
	
		