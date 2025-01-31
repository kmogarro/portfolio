/*
PAYER ANALYSIS
Focus: Insurance provider patterns, coverage rates, and payer demographics
*/

-- Payer coverage rates
SELECT
    payers.name,
    ROUND(AVG(
        encounters.payer_coverage / encounters.total_claim_cost * 100
        ), 2) AS average_percent_covered
FROM payers
JOIN encounters ON payers.id=encounters.payer
GROUP BY payers.name
ORDER BY average_percent_covered DESC;

-- Top Reasons for Procedures per Provider
WITH ranked_procedures AS (
    SELECT
        payers.name AS insurance_provider,
        procedures.reasondescription,
        COUNT(*) AS total_encounters,
        DENSE_RANK() OVER (PARTITION BY payers.name ORDER BY COUNT(*) DESC) AS ranking
    FROM payers
    JOIN encounters
        ON payers.id=encounters.payer
    JOIN procedures
        ON encounters.id=procedures.encounter
    WHERE procedures.reasondescription != ''
    GROUP BY
        payers.name,
        procedures.reasondescription
    ORDER BY payers.name
)
SELECT
    ranking,
    insurance_provider,
    reasondescription,
    total_encounters,
    ROUND(100.0 * total_encounters / SUM(total_encounters) OVER (PARTITION BY insurance_provider), 2) as percentage
FROM ranked_procedures
WHERE ranking <= 2;

-- Gender distribution by payer
SELECT
    payers.name AS provider,
    ROUND(COUNT(CASE WHEN gender = 'F' THEN gender ELSE NULL END) / COUNT(*), 2) AS pct_female,
    ROUND(COUNT(CASE WHEN gender = 'M' THEN gender ELSE NULL END) / COUNT(*), 2) AS pct_male
FROM encounters
JOIN payers ON encounters.payer=payers.id
JOIN patients ON encounters.patient=patients.id
GROUP BY payers.name
ORDER BY provider;