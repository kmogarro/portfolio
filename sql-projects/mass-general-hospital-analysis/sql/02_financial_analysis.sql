/*
FINANCIAL OPERATIONS ANALYSIS
Focus: Cost patterns, payer coverage, and financial efficiency metrics
*/

-- Average Costs by Encounter Type
SELECT
    encounterclass,
    ROUND(AVG(base_encounter_cost), 2) AS average_base_cost,
    ROUND(AVG(total_claim_cost), 2) AS average_total_cost
FROM encounters
GROUP BY encounterclass
ORDER BY average_total_cost DESC;

-- Duration vs Cost Analysis
WITH durations AS (
    SELECT
        *,
        CASE
            WHEN hour_duration BETWEEN 0 AND 4 THEN '0_4 hours'
            WHEN hour_duration BETWEEN 4 AND 24 THEN 'up_to_1_day'
            WHEN hour_duration BETWEEN 24 AND 72 THEN '1_3 days'
            WHEN hour_duration BETWEEN 72 AND 168 THEN '3_7 days'
            WHEN hour_duration BETWEEN 168 AND 720 THEN '1_4 weeks'
            WHEN hour_duration BETWEEN 720 AND 2160 THEN '1_3 months'
            WHEN hour_duration BETWEEN 2160 AND 8760 THEN '3_months_1_year'
            WHEN hour_duration > 8760 THEN '>_1_year'
            ELSE 'error'
        END AS duration
    FROM (
        SELECT
            encounterclass,
            TIMESTAMPDIFF(hour, encounter_start, encounter_stop) AS hour_duration,
            base_encounter_cost,
            total_claim_cost
        FROM
            encounters
    ) AS hours
)
SELECT
    duration,
    COUNT(*) AS encounters,
    ROUND(AVG(total_claim_cost), 2) AS average_total_cost
FROM durations
GROUP BY duration
ORDER BY average_total_cost DESC;

-- Payer Coverage Analysis
SELECT
    ROUND(
        AVG(percent_covered)
        , 2) AS average_covered
FROM (
    SELECT
        (payer_coverage / total_claim_cost) * 100  AS percent_covered
    FROM encounters
) percent_payer_covers;

-- Coverage by Payer
SELECT
    payers.name,
    ROUND(
        AVG(payer_coverage / total_claim_cost) * 100
        , 2) AS percent_covered
FROM encounters
JOIN payers ON encounters.payer=payers.id
GROUP BY payers.name
ORDER BY percent_covered DESC;

-- Coverage by encounter type
SELECT
    encounterclass,
    ROUND(
        AVG(payer_coverage / total_claim_cost) * 100
        , 2) AS percent_covered
FROM encounters
GROUP BY encounterclass
ORDER BY percent_covered DESC;