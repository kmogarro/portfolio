/*
PROCEDURE ANALYSIS
Focus: Procedure efficiency, frequency, and cost patterns
*/

-- Top 10 Most Common Procedures
SELECT
    procedure_descr,
    total_procedures
FROM (
    SELECT
        DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS ranking,
        description AS procedure_descr,
        COUNT(*) AS total_procedures
    FROM procedures
    GROUP BY procedure_descr
) ranking_procedures
WHERE ranking < 11;

-- Procedure Costs by Encounter Type
SELECT
    encounters.encounterclass,
    ROUND(
        AVG(procedures.base_cost)
        , 2) AS average_procedure_base_cost
FROM procedures
JOIN encounters ON procedures.encounter=encounters.id
GROUP BY encounters.encounterclass
ORDER BY average_procedure_base_cost DESC;

-- Average Procedure Duration Analysis
SELECT
    SEC_TO_TIME(
        AVG(
            TIMESTAMPDIFF(SECOND, procedure_start, procedure_stop)
        )
    ) AS average_duration
FROM procedures
WHERE description NOT IN ( -- removing outliers of 384 & 32 hours
    'Admission to long stay hospital', 
    'Human epidermal growth factor receptor 2 gene detection by fluorescence in situ hybridization (procedure)'
);