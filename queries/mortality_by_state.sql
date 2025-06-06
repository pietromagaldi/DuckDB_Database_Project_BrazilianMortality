-- Estimate population, total deaths, and mortality rate (per 1000) by state
WITH population_by_city AS (
	SELECT
		"IBGE_city_code" AS city_code,
		ANY_VALUE("IBGE_state_code") AS state_code,
		ANY_VALUE("state_name") AS state_name,
		ANY_VALUE("population_estimate_2009") AS population
	FROM "Location"
	GROUP BY city_code
),

deaths_by_city AS (
	SELECT 
		"location_code" AS city_code,
		COUNT(DISTINCT "death_id") AS total_deaths             
	FROM "Death"
	GROUP BY city_code
)

SELECT
	ANY_VALUE(pop.state_name) AS "State",
	SUM(pop.population) AS "Estimated_Population",
	SUM(dth.total_deaths) AS "Total_Deaths",
	ROUND(
		CAST((1000 * SUM(dth.total_deaths) / SUM(pop.population)) AS NUMERIC),
		4
	) AS "Mortality_Rate"
FROM population_by_city pop
JOIN deaths_by_city dth ON pop.city_code = dth.city_code
GROUP BY state_code
ORDER BY "Mortality_Rate" DESC;
