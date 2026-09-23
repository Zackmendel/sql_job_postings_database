-- .read 01_trials/004_priority_jobs_snapshot.sql
-- Create TEMP Table
CREATE OR REPLACE TEMP TABLE src_priority_jobs AS
SELECT
    jpf.job_id,
    jpf.job_title_short,
    cd.name AS company_name,
    jpf.job_posted_date,
    jpf.salary_year_avg,
    r.priority_lvl,
    CURRENT_TIMESTAMP AS updated_at
FROM data_jobs.job_postings_fact jpf
LEFT JOIN data_jobs.company_dim cd 
    ON jpf.company_id = cd.company_id
INNER JOIN staging.priority_roles R
    ON jpf.job_title_short = r.role_name;

SELECT *
FROM src_priority_jobs
LIMIT 2;

-- -- UPDATE statement
-- UPDATE main.priority_jobs_snapshot AS tgt
-- SET
--     priority_lvl = src.priority_lvl,
--     updated_at = src.updated_at
-- FROM src_priority_jobs src 
-- WHERE tgt.job_id = src.job_id
--     and tgt.priority_lvl IS DISTINCT FROM src.priority_lvl;

-- -- INSERT statement
-- INSERT INTO main.priority_jobs_snapshot (
--     job_id,
--     job_title_short,
--     company_name,
--     job_posted_date,
--     salary_year_avg,
--     priority_lvl,
--     updated_at
-- )

-- SELECT
--     job_id,
--     job_title_short,
--     company_name,
--     job_posted_date,
--     salary_year_avg,
--     priority_lvl,
--     updated_at
-- FROM src_priority_jobs src 
-- WHERE NOT EXISTS (
--     SELECT 1
--     FROM main.priority_jobs_snapshot tgt
--     WHERE tgt.job_id = src.job_id
-- );

-- -- DELETE statement
-- DELETE FROM main.priority_jobs_snapshot tgt 
-- WHERE NOT EXISTS (
--     SELECT 1
--     FROM src_priority_jobs src 
--     WHERE src.job_id = tgt.job_id
-- );

--MERGE INTO
MERGE INTO main.priority_jobs_snapshot tgt 
USING src_priority_jobs src 
ON tgt.job_id = src.job_id

WHEN MATCHED AND tgt.priority_lvl IS DISTINCT FROM src.priority_lvl THEN
    UPDATE SET 
        priority_lvl = src.priority_lvl,
        updated_at = src.updated_at

WHEN NOT MATCHED THEN 
    INSERT (
        job_id,
        job_title_short,
        company_name,
        job_posted_date,
        salary_year_avg,
        priority_lvl,
        updated_at
    )

    VALUES (
        job_id,
        job_title_short,
        company_name,
        job_posted_date,
        salary_year_avg,
        priority_lvl,
        updated_at
    )

WHEN NOT MATCHED BY SOURCE THEN DELETE;

-- Final Check
SELECT
    job_title_short,
    COUNT(*) AS job_count,
    MIN(priority_lvl) AS priority_lvl,
    MIN(updated_at) AS updated_at
FROM priority_jobs_snapshot
GROUP BY 1
ORDER BY job_count DESC;