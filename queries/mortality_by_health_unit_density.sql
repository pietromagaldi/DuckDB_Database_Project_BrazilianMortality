-- Analyze non-external mortality rates grouped by population per health unit
WITH population_per_unit AS (
    SELECT
        "IBGE_city_code" AS city_code,
        ANY_VALUE("population_estimate_2009") AS population,
        COUNT(DISTINCT basic_health_unit_CNES) AS unit_count,
        ANY_VALUE("population_estimate_2009") / COUNT(DISTINCT basic_health_unit_CNES) AS persons_per_unit
    FROM "Location"
    GROUP BY "IBGE_city_code"
),

city_bins AS (
    SELECT
        city_code,
        population,
        unit_count,
        persons_per_unit,
        CASE 
            WHEN persons_per_unit < 1500 THEN 1
            WHEN persons_per_unit < 2000 THEN 2
            WHEN persons_per_unit < 2500 THEN 3
            WHEN persons_per_unit < 3000 THEN 4
            WHEN persons_per_unit < 4000 THEN 5
            WHEN persons_per_unit < 5000 THEN 6
            ELSE 7
        END AS ppu_range
    FROM population_per_unit
),

non_external_deaths AS (
    SELECT
        "location_code" AS city_code,
        COUNT(*) AS non_external_death_count
    FROM "Death"
    WHERE NOT (
        "cause_id" LIKE 'S%' OR
        "cause_id" LIKE 'T%' OR
        "cause_id" LIKE 'V%' OR
        "cause_id" LIKE 'W%' OR
        "cause_id" LIKE 'X%' OR
        "cause_id" LIKE 'Y%'
    )
    GROUP BY "location_code"
)


SELECT
    CASE ppu_range
        WHEN 1 THEN 'Fewer than 1500'
        WHEN 2 THEN '1500-1999'
        WHEN 3 THEN '2000-2499'
        WHEN 4 THEN '2500-2999'
        WHEN 5 THEN '3000-3999'
        WHEN 6 THEN '4000-4999'
        WHEN 7 THEN '5000 or more'
    END AS individuals_per_health_unit,
    COUNT(*) AS number_of_cities,
    SUM(population) AS total_population,
    SUM(unit_count) AS total_units,
    SUM(non_external_death_count) AS total_non_external_deaths,
    ROUND(
        CAST(1000 * SUM(non_external_death_count) / SUM(population) AS NUMERIC),
        4
    ) AS mortality_rate
FROM city_bins cb JOIN
    non_external_deaths ned
    ON cb.city_code =  ned.city_code
GROUP BY ppu_range
ORDER BY ppu_range;