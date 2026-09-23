-- https://storage.googleapis.com/sql_de
-- Inset csv content into company_dim table

SELECT '=== Loading company_dim Table ===' AS info;

INSERT INTO company_dim (company_id, name)
    SELECT 
        company_id, 
        name
    FROM read_csv("https://storage.googleapis.com/sql_de/company_dim.csv",
        AUTO_DETECT=true);


-- Inset csv content into skills_dim table

SELECT '=== Loading skills_dim Table ===' AS info;

INSERT INTO skills_dim (skill_id, skills, type)
    SELECT
        skill_id, 
        skills, 
        type
    FROM read_csv("https://storage.googleapis.com/sql_de/skills_dim.csv",
        AUTO_DETECT=true);


-- Inset csv content into job_postings_fact table

SELECT '=== Loading job_postings_fact Table ===' AS info;

INSERT INTO job_postings_fact (
    job_id,
    company_id,
    job_title_short,
    job_title,
    job_location,
    job_via,
    job_schedule_type,
    job_work_from_home,
    search_location,
    job_posted_date,
    job_no_degree_mention,
    job_health_insurance,
    job_country,
    salary_rate,
    salary_year_avg,
    salary_hour_avg
)

SELECT
    job_id,
    company_id,
    job_title_short,
    job_title,
    job_location,
    job_via,
    job_schedule_type,
    job_work_from_home,
    search_location,
    job_posted_date,
    job_no_degree_mention,
    job_health_insurance,
    job_country,
    salary_rate,
    salary_year_avg,
    salary_hour_avg
FROM read_csv("https://storage.googleapis.com/sql_de/job_postings_fact.csv",
        AUTO_DETECT=true);



-- Inset csv content into skills_job_dim table

SELECT '=== Loading skills_job_dim Table ==='  AS info;

INSERT INTO skills_job_dim (skill_id, job_id)
SELECT
    skill_id,
    job_id
FROM read_csv("https://storage.googleapis.com/sql_de/skills_job_dim.csv",
        AUTO_DETECT=true);


-- Validation: Check the resulting tables
SELECT
    'Company Dim' AS table_name,
    COUNT(*) AS record_count
FROM company_dim
UNION ALL
SELECT
    'Skills Dim' AS table_name,
    COUNT(*) AS record_count
FROM skills_dim
UNION ALL
SELECT
    'Job Postings Fact' AS table_name,
    COUNT(*) AS record_count
FROM job_postings_fact
UNION ALL 
SELECT
    'Skills Job Dim' AS table_name,
    COUNT(*) AS record_count
FROM skills_job_dim;


-- Top 5 rows of inserted data
SELECT '=== First 5 rows of company_dim Table ===' AS info;
SELECT
    *
FROM company_dim
LIMIT 5;

SELECT '=== First 5 rows of skills_dim Table ===' AS info;
SELECT
    *
FROM skills_dim
LIMIT 5;

SELECT '=== First 5 rows of job_postings_fact Table ===' AS info;
SELECT
    *
FROM job_postings_fact
LIMIT 5;

SELECT '=== First 5 rows of skills_job_dim Table ===' AS info;
SELECT
    *
FROM skills_job_dim
LIMIT 5;

