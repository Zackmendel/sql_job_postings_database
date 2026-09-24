-- DROP TABLE IF EXISTS skill_mart.dim_skill;
DROP SCHEMA IF EXISTS skill_mart CASCADE;


CREATE SCHEMA skill_mart;

SELECT '=== Loading dim_skill Table ===' AS info;

CREATE TABLE skill_mart.dim_skill (
    skill_id    INTEGER PRIMARY KEY,
    skills      VARCHAR,
    type        VARCHAR
);

INSERT INTO skill_mart.dim_skill (skill_id, skills, type)
SELECT
    skill_id,
    skills,
    type 
FROM main.skills_dim
;


SELECT '=== Loading dim_date_month Table ===' AS info;

CREATE TABLE skill_mart.dim_date_month (
    month_start_date    DATE   PRIMARY KEY,
    year                INTEGER,
    month               INTEGER,
    quarter             INTEGER,
    quarter_name        VARCHAR,
    year_quarter        VARCHAR
);

INSERT INTO skill_mart.dim_date_month (month_start_date, year, month, quarter, quarter_name, year_quarter)
SELECT DISTINCT
    DATE_TRUNC('MONTH', job_posted_date) AS month_start_date, 
    EXTRACT(YEAR FROM job_posted_date) AS year,
    EXTRACT(MONTH FROM job_posted_date) AS month, 
    EXTRACT(QUARTER FROM job_posted_date) AS quarter,
    'Q-' || EXTRACT(QUARTER FROM job_posted_date)::VARCHAR AS quarter_name, 
    EXTRACT('YEAR' FROM job_posted_date)::VARCHAR || '-Q' || EXTRACT('QUARTER' FROM job_posted_date)::VARCHAR AS year_quarter
FROM main.job_postings_fact
ORDER BY month_start_date
;


SELECT '=== Loading fact_skill_demand_monthly Table ===' AS info;

CREATE TABLE skill_mart.fact_skill_demand_monthly (
    skill_id                        INTEGER,
    month_start_date                DATE,
    job_title_short                 VARCHAR,
    PRIMARY KEY (skill_id, month_start_date, job_title_short),
    FOREIGN KEY (skill_id) REFERENCES skill_mart.dim_skill(skill_id),
    FOREIGN KEY (month_start_date) REFERENCES skill_mart.dim_date_month(month_start_date),

    postings_count                  INTEGER,
    remote_postings_count           INTEGER,
    health_insurance_postings_count INTEGER,
    no_degree_postings_count        INTEGER
);

INSERT INTO skill_mart.fact_skill_demand_monthly (
    skill_id, 
    month_start_date,
    job_title_short, 
    postings_count, 
    remote_postings_count, 
    health_insurance_postings_count, 
    no_degree_postings_count
    )

SELECT
    sjd.skill_id, 
    DATE_TRUNC('MONTH', jpf.job_posted_date) AS month_start_date, 
    jpf.job_title_short,
    COUNT(jpf.job_id) AS postings_count,
     
    COUNT(CASE WHEN jpf.job_work_from_home = 'true' THEN jpf.job_id END) AS remote_postings_count,
    COUNT(CASE WHEN jpf.job_health_insurance = 'true' THEN jpf.job_id END) AS health_insurance_postings_count, 
    COUNT(CASE WHEN jpf.job_no_degree_mention = TRUE THEN jpf.job_id END) AS no_degree_postings_count
FROM job_postings_fact jpf 
INNER JOIN skills_job_dim sjd 
    ON jpf.job_id = sjd.job_id
GROUP BY ALL
;

-- Validation: Check the resulting tables
SELECT
    'Dim Skill' AS table_name,
    COUNT(*) AS record_count
FROM skill_mart.dim_skill
UNION ALL
SELECT
    'Dim Date Month' AS table_name,
    COUNT(*) AS record_count
FROM skill_mart.dim_date_month
UNION ALL 
SELECT
    'Fact Skill Demand Monthly' AS table_name,
    COUNT(*) AS record_count
FROM skill_mart.fact_skill_demand_monthly;



SELECT *
FROM information_schema.tables
WHERE table_schema = 'skill_mart';

SELECT '=== Displaying First 5 dim_skill Table Rows ===' AS info;
SELECT * FROM skill_mart.dim_skill LIMIT 5;

SELECT '=== Displaying First 5 dim_date_month Table Rows ===' AS info;
SELECT * FROM skill_mart.dim_date_month LIMIT 5;

SELECT '=== Displaying First 5 fact_skill_demand_monthly Table Rows ===' AS info;
SELECT * FROM skill_mart.fact_skill_demand_monthly LIMIT 5;