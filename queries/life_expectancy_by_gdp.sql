-- Analyze death statistics by GDP per capita decile
WITH city_deciles AS (
    SELECT 
        "IBGE_city_code" AS city_code,
		ANY_VALUE("GDP_per_capita") AS gdp_per_capita,
		ANY_VALUE("population_estimate_2009") AS population,
        NTILE(10) OVER (ORDER BY ANY_VALUE("GDP_per_capita")) AS decile
    FROM "Location"
	GROUP BY city_code
),

city_stats_by_decile AS (
    SELECT 
        decile,
        COUNT(*) AS number_of_cities,
        MIN(gdp_per_capita) AS lowest_gdp_per_capita,
        MAX(gdp_per_capita) AS highest_gdp_per_capita,
        SUM(population) AS total_population
    FROM city_deciles
    GROUP BY decile
),

death_stats_by_decile AS (
    SELECT 
        d.decile,
        COUNT(DISTINCT "death_id") AS total_deaths,
        ROUND(CAST(AVG("deceased_age") AS NUMERIC), 4) AS mean_age_of_death,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY "deceased_age") AS median_age_of_death
    FROM "Death" dt
    JOIN city_deciles d ON dt."location_code" = d.city_code
    GROUP BY d.decile
)

SELECT 
    cs.decile AS decile,
    cs.number_of_cities,
    cs.lowest_gdp_per_capita,
    cs.highest_gdp_per_capita,
	--CAST(lowest_gdp_per_capita AS VARCHAR(20)) + ' - ' CAST(highest_gdp_per_capita AS VARCHAR(20))
		--AS gdp_per_capita,
    cs.total_population,
    ds.total_deaths,
    ds.mean_age_of_death,
    ds.median_age_of_death
FROM city_stats_by_decile cs
JOIN death_stats_by_decile ds ON cs.decile = ds.decile
ORDER BY cs.decile;