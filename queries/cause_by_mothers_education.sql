-- Top 3 causes of death (under age 5) by mother's education level
WITH deaths_by_mother_edu AS (
    SELECT  
        "mother_education_level" AS education_level,
		"cause_id" AS cause_id,
		ANY_VALUE("description") AS cause_description,
        ROUND(AVG(CAST("mother_age" AS NUMERIC)), 2) AS mothers_avg_age,
        COUNT(DISTINCT "death_id") AS death_count
    FROM "Death"
	WHERE 
		"deceased_age" < 5.0 AND education_level IN (0, 1, 2, 3, 4, 5)
    GROUP BY education_level, cause_id
),

ranked_causes AS (
    SELECT  
        education_level,
        cause_id,
        death_count,
        RANK() OVER (
            PARTITION BY education_level 
            ORDER BY death_count DESC
        ) AS cause_rank
    FROM deaths_by_mother_edu
),

edu_totals AS (
    SELECT  
        education_level,
        SUM(death_count) AS total_death_count
    FROM deaths_by_mother_edu
    GROUP BY education_level
)



SELECT
    CASE dme.education_level
        WHEN 0 THEN 'None'
        WHEN 1 THEN 'Elementary School'
        WHEN 2 THEN 'Middle School'
        WHEN 3 THEN 'High School'
        WHEN 4 THEN 'Incomplete Higher Education'
        WHEN 5 THEN 'Complete Higher Education'
        ELSE 'Other'
    END AS mothers_education_level,
    dme."cause_id",
    rc.cause_rank,
    dme.cause_description AS cause_of_death,
    dme.mothers_avg_age,
    rc.death_count AS cause_death_count,
    et.total_death_count,
    ROUND(100.0 * rc.death_count / et.total_death_count, 2) AS cause_percentage

FROM deaths_by_mother_edu dme
JOIN ranked_causes rc 
    ON rc.education_level = dme.education_level 
    AND rc.cause_id = dme.cause_id
JOIN edu_totals et 
    ON et.education_level = dme.education_level
WHERE
	rc.cause_rank <= 3
ORDER BY rc.education_level, rc.cause_rank;