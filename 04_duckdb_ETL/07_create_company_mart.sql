-- Create and drop schema
DROP SCHEMA IF EXISTS company_mart CASCADE;

CREATE SCHEMA company_mart;

-- Create, Insert into Tables & Validate per table

-- ==========================================================================
-- dim_job_title_short
-- ==========================================================================
SELECT '=== Loading dim_job_title_short Table ===' AS info;
CREATE TABLE company_mart.dim_job_title_short (
    job_title_short_id      INTEGER     PRIMARY KEY,
    job_title_short         VARCHAR
);

INSERT INTO company_mart.dim_job_title_short (job_title_short_id, job_title_short)
WITH unique_job_titles AS (
    SELECT DISTINCT
        job_title_short
    FROM job_postings_fact
)

SELECT
    ROW_NUMBER() OVER (ORDER BY job_title_short) AS job_title_short_id,
    job_title_short
FROM unique_job_titles
;

-- Validate 
SELECT '=== Validating dim_job_title_short Table ===' AS info;
SELECT * FROM company_mart.dim_job_title_short;



-- ==========================================================================
-- dim_job_title
-- ==========================================================================
SELECT '=== Loading dim_job_title Table ===' AS info;
CREATE TABLE company_mart.dim_job_title (
    job_title_id      INTEGER     PRIMARY KEY,
    job_title         VARCHAR
);

INSERT INTO company_mart.dim_job_title (job_title_id, job_title)
WITH unique_job_titles AS (
    SELECT DISTINCT
        job_title
    FROM job_postings_fact
)

SELECT
    ROW_NUMBER() OVER (ORDER BY job_title) AS job_title_id,
    job_title
FROM unique_job_titles
;

-- Validate 
SELECT '=== Validating dim_job_title Table ===' AS info;
SELECT * FROM company_mart.dim_job_title LIMIT 10;


-- ==========================================================================
-- bridge_job_title
-- ==========================================================================
SELECT '=== Loading bridge_job_title Table ===' AS info;
CREATE TABLE company_mart.bridge_job_title (
    job_title_short_id   INTEGER,
    job_title_id         INTEGER,
    PRIMARY KEY (job_title_short_id, job_title_id),
    FOREIGN KEY (job_title_short_id) REFERENCES company_mart.dim_job_title_short(job_title_short_id),
    FOREIGN KEY (job_title_id) REFERENCES company_mart.dim_job_title(job_title_id)
);

INSERT INTO company_mart.bridge_job_title (job_title_short_id, job_title_id)
SELECT DISTINCT
    job_title_short_id,
    job_title_id
FROM job_postings_fact jpf 
INNER JOIN company_mart.dim_job_title_short jts
    ON jpf.job_title_short = jts.job_title_short
INNER JOIN company_mart.dim_job_title djt 
    ON jpf.job_title = djt.job_title
ORDER BY job_title_id
;

-- Validate 
SELECT '=== Validating bridge_job_title Table ===' AS info;
SELECT * FROM company_mart.bridge_job_title LIMIT 10;


-- ==========================================================================
-- dim_company
-- ==========================================================================
SELECT '=== Loading dim_company Table ===' AS info;
CREATE TABLE company_mart.dim_company (
    company_id      INTEGER PRIMARY KEY,
    company_name    VARCHAR
);

INSERT INTO company_mart.dim_company
SELECT
    company_id,
    name AS company_name
FROM company_dim
ORDER BY company_id
;

-- Validate 
SELECT '=== Validating dim_company Table ===' AS info;
SELECT * FROM company_mart.dim_company LIMIT 10;


-- ==========================================================================
-- dim_location
-- ==========================================================================
SELECT '=== Loading dim_location Table ===' AS info;
CREATE TABLE company_mart.dim_location (
    location_id         INTEGER     PRIMARY KEY,
    job_country         VARCHAR,
    job_location        VARCHAR
);

INSERT INTO company_mart.dim_location (location_id, job_country, job_location)
WITH unique_locations AS (
    SELECT DISTINCT
        job_country,
        job_location
    FROM job_postings_fact
    WHERE job_country IS NOT NULL OR job_location IS NOT NULL
)
SELECT
    ROW_NUMBER() OVER (ORDER BY job_country, job_location) AS location_id,
    job_country,
    job_location
FROM unique_locations;


-- Validate 
SELECT '=== Validating dim_location Table ===' AS info;
SELECT * FROM company_mart.dim_location LIMIT 10;


-- ==========================================================================
-- bridge_company_location
-- ==========================================================================
SELECT '=== Loading bridge_company_location Table ===' AS info;
CREATE TABLE company_mart.bridge_company_location (
    company_id      INTEGER,
    location_id     INTEGER,
    PRIMARY KEY (company_id, location_id),
    FOREIGN KEY (company_id) REFERENCES company_mart.dim_company(company_id),
    FOREIGN KEY (location_id) REFERENCES company_mart.dim_location(location_id)
);

INSERT INTO company_mart.bridge_company_location (company_id, location_id)
SELECT DISTINCT
    dc.company_id,
    dl.location_id
FROM job_postings_fact jpf 
INNER JOIN company_mart.dim_company dc 
    ON jpf.company_id = dc.company_id
INNER JOIN company_mart.dim_location dl 
    ON jpf.job_country = dl.job_country
    AND jpf.job_location = dl.job_location
ORDER BY dc.company_id
;


-- Validate 
SELECT '=== Validating bridge_company_location Table ===' AS info;
SELECT * FROM company_mart.bridge_company_location LIMIT 10;


-- ==========================================================================
-- dim_date_month
-- ==========================================================================
SELECT '=== Loading dim_date_month Table ===' AS info;
CREATE TABLE company_mart.dim_date_month (
    month_start_date    DATE    PRIMARY KEY,
    year                INTEGER,
    month               INTEGER
);

INSERT INTO company_mart.dim_date_month (month_start_date, year, month)
SELECT DISTINCT
    DATE_TRUNC('MONTH', job_posted_date) AS month_start_date,
    EXTRACT(YEAR FROM job_posted_date) AS year,
    EXTRACT(MONTH FROM job_posted_date) AS month
FROM job_postings_fact
;


-- Validate 
SELECT '=== Validating dim_date_month Table ===' AS info;
SELECT * FROM company_mart.dim_date_month LIMIT 10;

-- ==========================================================================
-- fact_company_hiring_monthly
-- ==========================================================================
SELECT '=== Loading fact_company_hiring_monthly Table ===' AS info;
CREATE TABLE company_mart.fact_company_hiring_monthly (
    company_id                  INTEGER,
    job_title_short_id          INTEGER,
    month_start_date            DATE,
    job_country                 VARCHAR,
    postings_count              INTEGER,
    median_salary_year          INTEGER,
    min_salary_year             INTEGER,
    max_salary_year             INTEGER,
    remote_share                DOUBLE,
    health_insurance_share      DOUBLE,
    no_degree_mention_share     DOUBLE,
    PRIMARY KEY (company_id, job_title_short_id, month_start_date, job_country),
    FOREIGN KEY (company_id)            REFERENCES company_mart.dim_company(company_id),
    FOREIGN KEY (job_title_short_id)    REFERENCES company_mart.dim_job_title_short(job_title_short_id),
    FOREIGN KEY (month_start_date)      REFERENCES company_mart.dim_date_month(month_start_date)
);

INSERT INTO company_mart.fact_company_hiring_monthly (
    company_id,
    job_title_short_id,
    month_start_date,
    job_country,
    postings_count,
    median_salary_year,
    min_salary_year,
    max_salary_year,
    remote_share,
    health_insurance_share,
    no_degree_mention_share
)

SELECT
    jpf.company_id,
    jts.job_title_short_id,
    ddm.month_start_date,
    jpf.job_country,
    COUNT(*) AS postings_count,
    MEDIAN(salary_year_avg) AS median_salary_year,
    MIN(salary_year_avg) AS min_salary_year,
    MAX(salary_year_avg) AS max_salary_year,
    (COUNT(CASE WHEN job_work_from_home = TRUE THEN 1 END) * 100) / NULLIF(COUNT(*), 0) AS remote_share,
    (COUNT(CASE WHEN job_health_insurance = TRUE THEN 1 END) * 100) / NULLIF(COUNT(*), 0) AS health_insurance_share,
    (COUNT(CASE WHEN job_no_degree_mention = TRUE THEN 1 END) * 100) / NULLIF(COUNT(*), 0) AS no_degree_mention_share
FROM job_postings_fact jpf
LEFT JOIN company_mart.dim_company dc 
    ON jpf.company_id = dc.company_id
LEFT JOIN company_mart.dim_job_title_short jts
    ON jpf.job_title_short = jts.job_title_short
LEFT JOIN company_mart.dim_date_month ddm 
    ON DATE_TRUNC('MONTH', jpf.job_posted_date) = ddm.month_start_date
WHERE jpf.job_country IS NOT NULL
GROUP BY ALL
ORDER BY RANDOM()
;


-- Validate 
SELECT '=== Validating fact_company_hiring_monthly Table ===' AS info;
SELECT * FROM company_mart.fact_company_hiring_monthly LIMIT 10;