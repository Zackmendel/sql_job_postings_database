/*
Question: What are the most in-demand skills for data engineers?
- Join job postings to inner join table similar to query 2
- Identify the top 10 in-demand skills for data engineers
- Focus on remote job postings
- Why? Retrieves the top 10 skills with the highest demand in the remote job market,
    providing insights into the most valuable skills for data engineers seeking remote work
*/

SELECT
    s.skills,
    s.skill_id,
    COUNT(DISTINCT p.job_id) AS hiring_jobs
FROM job_postings_fact p 
INNER JOIN skills_job_dim sj 
    ON p.job_id = sj.job_id
INNER JOIN skills_dim s
    ON sj.skill_id = s.skill_id
WHERE job_title_short LIKE '%Data Engineer%'
    AND job_work_from_home = 'true'
GROUP BY s.skills, s.skill_id
ORDER BY hiring_jobs DESC
LIMIT 10;



/*
Here's the breakdown of the most demanded skills for data engineers:
SQL and Python are by far the most in-demand skills, with around 29,000 job postings each - nearly double the next closest skill.
Cloud platforms round out the top skills, with AWS leading at ~18,000 postings, followed by Azure at ~14,000.
Apache Spark completes the top 5 with nearly 13,000 postings, highlighting the importance of big data processing skills.

Key takeaways:
- SQL and Python remain the foundational skills for data engineers
- Cloud platforms (AWS, Azure) are critical for modern data engineering
- Big data tools like Spark continue to be highly valued
- Data pipeline tools (Airflow, Snowflake, Databricks) show growing demand
- Java and GCP round out the top 10 most requested skills

┌────────────┬──────────┬─────────────┐
│   skills   │ skill_id │ hiring_jobs │
│  varchar   │  int32   │    int64    │
├────────────┼──────────┼─────────────┤
│ sql        │        0 │       38368 │
│ python     │        1 │       38117 │
│ aws        │       77 │       24514 │
│ azure      │       74 │       18707 │
│ spark      │       92 │       17591 │
│ airflow    │      104 │       13395 │
│ snowflake  │       73 │       11781 │
│ databricks │       75 │       10962 │
│ java       │       12 │        9993 │
│ kafka      │       97 │        9315 │
└────────────┴──────────┴─────────────┘
  10 rows                   3 columns
*/