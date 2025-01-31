/*
TEMPORAL ANALYSIS
Focus: Seasonal trends and workload distribution patterns
*/

-- Quarterly Volume Analysis
WITH quarterly_encounters AS (
    SELECT
        encounter_start,
        YEAR(encounter_start) AS encounter_year,
        CASE
            WHEN MONTH(encounter_start) IN (1, 2, 3) THEN 'Q1'
            WHEN MONTH(encounter_start) IN (4, 5, 6) THEN 'Q2'
            WHEN MONTH(encounter_start) IN (7, 8, 9) THEN 'Q3'
            WHEN MONTH(encounter_start) IN (10, 11, 12) THEN 'Q4'
            ELSE 'error: check logic'
        END as fiscal_quarter
    FROM encounters
    WHERE YEAR(encounter_start) != 2022  -- Excluded due to incomplete data
)
SELECT
    encounter_year,
    fiscal_quarter,
    COUNT(*) AS encounters,
    ROUND(
        COUNT(*) * 100.0 / 
        SUM(COUNT(*)) OVER (PARTITION BY encounter_year), 
        2) as pct
FROM quarterly_encounters
GROUP BY 
    encounter_year, 
    fiscal_quarter
ORDER BY 
    encounter_year DESC, 
    fiscal_quarter;


-- Daily Distribution analysis
WITH quarterly_encounters AS (
    SELECT
        encounter_start,
        YEAR(encounter_start) AS encounter_year,
        CASE
            WHEN MONTH(encounter_start) IN (1, 2, 3) THEN 'Q1'
            WHEN MONTH(encounter_start) IN (4, 5, 6) THEN 'Q2'
            WHEN MONTH(encounter_start) IN (7, 8, 9) THEN 'Q3'
            WHEN MONTH(encounter_start) IN (10, 11, 12) THEN 'Q4'
            ELSE 'error: check logic'
        END as fiscal_quarter
    FROM encounters
    WHERE YEAR(encounter_start) != 2022  -- Excluded due to incomplete data
)
SELECT
    DAYNAME(encounter_start) AS day_of_week,
    COUNT(*) AS total_encounters,
    ROUND(count(*) * 100 / SUM(COUNT(*)) OVER (), 2) AS pct_of_encounters
FROM quarterly_encounters
GROUP BY day_of_week
ORDER BY
    FIELD(day_of_week, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday');

-- Weekend vs Weekday analysis    
SELECT
    CASE 
        WHEN DAYNAME(encounter_start) IN ('Saturday', 'Sunday') THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    COUNT(*) AS total_encounters,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage_of_total,
    ROUND(COUNT(*) / COUNT(DISTINCT YEAR(encounter_start), 2)) AS avg_yearly_encounters
FROM encounters
WHERE YEAR(encounter_start) != 2022  -- Excluded due to incomplete data
GROUP BY day_type;