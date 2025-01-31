/*
PATIENT FLOW ANALYSIS
Focus: Patient movement patterns, demographics, and readmission rates
*/

-- Readmission Rate Analysis
WITH readmitted_patients AS (
    SELECT
        e1.patient,
        e1.encounter_start,
        e1.encounter_stop,
        MIN(e2.encounter_start) AS readmission_date
    FROM encounters e1
    LEFT JOIN encounters e2
        ON e1.patient = e2.patient
        AND e2.encounter_start > e1.encounter_stop
        AND e2.encounter_start <= DATE_ADD(e1.encounter_stop, INTERVAL 31 DAY)
    GROUP BY
        e1.patient,
        e1.encounter_start,
        e1.encounter_stop
)
SELECT
    COUNT(*) AS total_patients,
    SUM(CASE WHEN readmission_date IS NOT NULL THEN 1 ELSE 0 END) AS readmissions,
    ROUND(SUM(CASE WHEN readmission_date IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS rate_of_readmission_within_31_days
FROM readmitted_patients;

-- Visit Frequency Analysis
SELECT 
    yr, 
    ROUND(AVG(num_encounters), 2) AS average_encounters_per_patient
FROM 
    (SELECT 
        YEAR(encounter_start) AS yr,
        patient,
        COUNT(*) AS num_encounters
    FROM encounters
    WHERE YEAR(encounter_start) != 2022  -- Excluded due to incomplete data
    GROUP BY 
        yr, 
        patient) patient_encounters
GROUP BY yr
ORDER BY yr DESC;

-- Distribution of Encounter Types
SELECT 
    encounterclass, 
    ROUND(COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS distribution
FROM encounters
GROUP BY encounterclass
ORDER BY 2 DESC;

-- Demographics Analysis
SELECT 
    ROUND(COUNT(CASE WHEN gender = 'F' THEN 1 END) / COUNT(*), 2) AS percentage_female,
    ROUND(COUNT(CASE WHEN gender = 'M' THEN 1 END) / COUNT(*), 2) AS percentage_male
FROM encounters
JOIN patients ON encounters.patient = patients.id;

-- Average Patient Age
SELECT
    AVG(age) AS average_age
FROM (
    SELECT
        TIMESTAMPDIFF(
            YEAR,
            STR_TO_DATE(patients.birthdate, '%m/%d/%Y'),
            DATE(encounters.encounter_start)) AS age
    FROM encounters
    JOIN patients ON encounters.patient=patients.id
) ages;

-- Procedure Frequency by Racial Group
WITH reasons_by_race AS (
SELECT
    patients.race,
    procedures.reasondescription AS reason,
    COUNT(*) AS patient_count,
    DENSE_RANK() OVER (PARTITION BY race ORDER BY COUNT(*) DESC) AS ranking
FROM patients
JOIN procedures ON patients.id=procedures.patient
WHERE procedures.reasondescription NOT IN ('')
GROUP BY
    race,
    procedures.reasondescription
)
SELECT
    race,
    reason,
    patient_count
FROM reasons_by_race
WHERE ranking <= 2;