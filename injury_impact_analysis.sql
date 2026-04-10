-- ============================================================
--  AthleteIQ | Query: Injury Impact Analysis
--  Description: Analyze how injuries affect performance ratings
--               using CTEs, JOINs, and Window Functions
-- ============================================================

USE AthleteIQ;

-- ------------------------------------------------------------
-- 1. Injury Summary Per Athlete
-- ------------------------------------------------------------
SELECT
    CONCAT(a.first_name, ' ', a.last_name)  AS athlete_name,
    a.status,
    COUNT(i.injury_id)                       AS total_injuries,
    SUM(i.matches_missed)                    AS total_matches_missed,
    SUM(CASE WHEN i.severity = 'Minor'              THEN 1 ELSE 0 END) AS minor_injuries,
    SUM(CASE WHEN i.severity = 'Moderate'           THEN 1 ELSE 0 END) AS moderate_injuries,
    SUM(CASE WHEN i.severity = 'Severe'             THEN 1 ELSE 0 END) AS severe_injuries,
    SUM(CASE WHEN i.severity = 'Career-threatening' THEN 1 ELSE 0 END) AS career_threatening,
    SUM(CASE WHEN i.is_recurring = TRUE             THEN 1 ELSE 0 END) AS recurring_injuries,
    MIN(i.injury_date)                       AS first_injury,
    MAX(i.injury_date)                       AS latest_injury
FROM athletes a
LEFT JOIN injuries i ON a.athlete_id = i.athlete_id
GROUP BY a.athlete_id, athlete_name, a.status
ORDER BY total_matches_missed DESC;


-- ------------------------------------------------------------
-- 2. Performance Before vs After Injury
-- ------------------------------------------------------------
WITH injury_dates AS (
    SELECT
        athlete_id,
        MIN(injury_date) AS first_injury_date
    FROM injuries
    GROUP BY athlete_id
),
pre_injury_perf AS (
    SELECT
        pr.athlete_id,
        ROUND(AVG(pr.rating), 2)    AS avg_rating_before,
        ROUND(AVG(pr.goals), 2)     AS avg_goals_before,
        COUNT(*)                    AS matches_before
    FROM performance_records pr
    JOIN matches m      ON pr.match_id   = m.match_id
    JOIN injury_dates d ON pr.athlete_id = d.athlete_id
    WHERE m.match_date < d.first_injury_date
    GROUP BY pr.athlete_id
),
post_injury_perf AS (
    SELECT
        pr.athlete_id,
        ROUND(AVG(pr.rating), 2)    AS avg_rating_after,
        ROUND(AVG(pr.goals), 2)     AS avg_goals_after,
        COUNT(*)                    AS matches_after
    FROM performance_records pr
    JOIN matches m      ON pr.match_id   = m.match_id
    JOIN injury_dates d ON pr.athlete_id = d.athlete_id
    WHERE m.match_date > d.first_injury_date
    GROUP BY pr.athlete_id
)
SELECT
    CONCAT(a.first_name, ' ', a.last_name) AS athlete_name,
    pre.avg_rating_before,
    post.avg_rating_after,
    ROUND(post.avg_rating_after - pre.avg_rating_before, 2) AS rating_impact,
    pre.matches_before,
    post.matches_after
FROM athletes a
JOIN pre_injury_perf  pre  ON a.athlete_id = pre.athlete_id
LEFT JOIN post_injury_perf post ON a.athlete_id = post.athlete_id
ORDER BY rating_impact;


-- ------------------------------------------------------------
-- 3. Injury Recurrence Risk Report
-- ------------------------------------------------------------
SELECT
    CONCAT(a.first_name, ' ', a.last_name)  AS athlete_name,
    i.body_part,
    COUNT(*)                                 AS injury_count,
    MAX(i.severity)                          AS worst_severity,
    SUM(i.matches_missed)                    AS total_missed,
    MAX(i.injury_date)                       AS last_occurrence,
    CASE
        WHEN COUNT(*) >= 3 THEN 'HIGH RISK'
        WHEN COUNT(*) = 2  THEN 'MEDIUM RISK'
        ELSE 'LOW RISK'
    END AS recurrence_risk
FROM injuries i
JOIN athletes a ON i.athlete_id = a.athlete_id
GROUP BY a.athlete_id, athlete_name, i.body_part
HAVING COUNT(*) >= 1
ORDER BY injury_count DESC, total_missed DESC;


-- ------------------------------------------------------------
-- 4. Average Recovery Time By Injury Type
-- ------------------------------------------------------------
SELECT
    injury_type,
    severity,
    COUNT(*)                                                       AS total_cases,
    ROUND(AVG(DATEDIFF(actual_return, injury_date)), 1)            AS avg_actual_recovery_days,
    ROUND(AVG(DATEDIFF(expected_return, injury_date)), 1)          AS avg_expected_recovery_days,
    ROUND(AVG(DATEDIFF(actual_return, expected_return)), 1)        AS avg_delay_days
FROM injuries
WHERE actual_return IS NOT NULL
GROUP BY injury_type, severity
ORDER BY avg_actual_recovery_days DESC;
