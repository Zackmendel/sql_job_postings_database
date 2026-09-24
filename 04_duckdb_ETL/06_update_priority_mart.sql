SELECT '=== Updating Roles for Priority Roles ===' AS info;

-- Update Data Engineer to priority 1
UPDATE priority_mart.priority_roles
SET priority_lvl = 1
WHERE role_name = 'Data Engineer'
;

-- Add Data Scientist as level 3
INSERT INTO priority_mart.priority_roles (role_id, role_name, priority_lvl)
VALUES
    (4, 'Data Scientist', 3)
;

-- Validation
SELECT * FROM priority_mart.priority_roles;


SELECT '=== Creating Temp Table for Merge Data ===' AS info;
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
FROM job_postings_fact jpf
LEFT JOIN company_dim cd 
    ON jpf.company_id = cd.company_id
INNER JOIN priority_mart.priority_roles r
    ON jpf.job_title_short = r.role_name;

-- Validation
SELECT *
FROM src_priority_jobs
LIMIT 2;


--MERGE INTO
SELECT '=== Batch Updating priority_jobs_snapshot for Priority Mart' AS info;

MERGE INTO priority_mart.priority_jobs_snapshot tgt 
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
FROM priority_mart.priority_jobs_snapshot
GROUP BY 1
ORDER BY job_count DESC;