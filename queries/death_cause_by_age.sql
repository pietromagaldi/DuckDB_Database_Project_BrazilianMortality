-- Find the most common cause of death (modal cause) for each age
WITH causes_by_age AS (
    SELECT  
        "cause_id" AS cause_id,
		ANY_VALUE("description") AS description,
        ROUND(CAST("deceased_age" AS NUMERIC), 0) AS age,
        COUNT(DISTINCT "death_id") AS death_count
    FROM "Death"
    GROUP BY age, cause_id
),

age_totals_and_max AS (
    SELECT 
        age,
        MAX(death_count) AS max_death_count,
        SUM(death_count) AS total_deaths_for_age
    FROM causes_by_age
    GROUP BY age
)

SELECT  
    cba.age,
    cba."description" AS most_common_cause,
    cba.death_count AS deaths_from_cause,
    atm.total_deaths_for_age,
    ROUND(100.0 * cba.death_count / atm.total_deaths_for_age, 4) AS cause_percentage
FROM causes_by_age cba
JOIN age_totals_and_max atm 
    ON cba.age = atm.age AND cba.death_count = atm.max_death_count
ORDER BY cba.age;