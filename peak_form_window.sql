-- ============================================================
--  AthleteIQ | Query: Peak Performance Window Analysis
--  Description: Identify when athletes are in their best form
--               using Window Functions (LEAD, LAG, ROWS BETWEEN)
-- ============================================================

USE AthleteIQ;

-- ------------------------------------------------------------
-- 1. Rolling 3-Match Average Rating (Form Window)
-- ------------------------------------------------------------
WITH match_ratings AS (
    SELECT
        pr.athlete_id,
        CONCAT(a.first_name, ' ', a.last_name) AS athlete_name,
        m.match_date,
        pr.rating,
        pr.goals,
        pr.assists,
        pr.minutes_played
    FROM performance_records pr
    JOIN athletes a ON pr.athlete_id = a.athlete_id
    JOIN matches m  ON pr.match_id   = m.match_id
)
SELECT
    athlete_name,
    match_date,
    rating,
    goals,
    assists,
    ROUND(
        AVG(rating) OVER (
            PARTITION BY athlete_id
            ORDER BY match_date
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ), 2
    ) AS rolling_3match_avg,
    RANK() OVER (
        PARTITION BY athlete_id
        ORDER BY rating DESC
    ) AS personal_best_rank
FROM match_ratings
ORDER BY athlete_name, match_date;


-- ------------------------------------------------------------
-- 2. Peak Form Periods (Consecutive High-Rating Matches)
-- ------------------------------------------------------------
WITH ranked_matches AS (
    SELECT
        pr.athlete_id,
        CONCAT(a.first_name, ' ', a.last_name) AS athlete_name,
        m.match_date,
        pr.rating,
        CASE WHEN pr.rating >= 8.0 THEN 1 ELSE 0 END AS is_peak_form,
        ROW_NUMBER() OVER (PARTITION BY pr.athlete_id ORDER BY m.match_date)
        - ROW_NUMBER() OVER (PARTITION BY pr.athlete_id, CASE WHEN pr.rating >= 8.0 THEN 1 ELSE 0 END ORDER BY m.match_date)
        AS grp
    FROM performance_records pr
    JOIN athletes a ON pr.athlete_id = a.athlete_id
    JOIN matches m  ON pr.match_id   = m.match_id
)
SELECT
    athlete_name,
    MIN(match_date)     AS peak_start,
    MAX(match_date)     AS peak_end,
    COUNT(*)            AS consecutive_peak_matches,
    ROUND(AVG(rating), 2) AS avg_rating_in_peak
FROM ranked_matches
WHERE is_peak_form = 1
GROUP BY athlete_id, athlete_name, grp
HAVING COUNT(*) >= 1
ORDER BY consecutive_peak_matches DESC, avg_rating_in_peak DESC;


-- ------------------------------------------------------------
-- 3. Training Load vs Match Performance Correlation
-- ------------------------------------------------------------
WITH training_load AS (
    SELECT
        athlete_id,
        session_date,
        SUM(duration_minutes * intensity_level) AS weekly_load_score
    FROM training_sessions
    GROUP BY athlete_id, session_date
),
weekly_performance AS (
    SELECT
        pr.athlete_id,
        m.match_date,
        pr.rating,
        pr.goals,
        pr.distance_covered_km
    FROM performance_records pr
    JOIN matches m ON pr.match_id = m.match_id
)
SELECT
    CONCAT(a.first_name, ' ', a.last_name) AS athlete_name,
    wp.match_date,
    wp.rating                              AS match_rating,
    ROUND(AVG(tl.weekly_load_score), 0)   AS avg_training_load_7days,
    wp.goals,
    wp.distance_covered_km,
    CASE
        WHEN AVG(tl.weekly_load_score) > 800 AND wp.rating >= 8 THEN 'Peak Load — Peak Performance'
        WHEN AVG(tl.weekly_load_score) > 800 AND wp.rating < 6  THEN 'Overloaded — Underperforming'
        WHEN AVG(tl.weekly_load_score) < 400 AND wp.rating >= 8 THEN 'Low Load — Peak Performance'
        ELSE 'Normal'
    END AS load_performance_status
FROM weekly_performance wp
JOIN athletes a      ON wp.athlete_id = a.athlete_id
JOIN training_load tl ON (
    wp.athlete_id = tl.athlete_id
    AND tl.session_date BETWEEN DATE_SUB(wp.match_date, INTERVAL 7 DAY) AND wp.match_date
)
GROUP BY a.athlete_id, athlete_name, wp.match_date, wp.rating, wp.goals, wp.distance_covered_km
ORDER BY athlete_name, wp.match_date;


-- ------------------------------------------------------------
-- 4. Readiness Score vs Match Day Performance
-- ------------------------------------------------------------
SELECT
    CONCAT(a.first_name, ' ', a.last_name) AS athlete_name,
    m.match_date,
    rm.readiness_score                      AS pre_match_readiness,
    rm.sleep_hours,
    rm.mood_score,
    pr.rating                              AS match_rating,
    pr.goals,
    pr.minutes_played,
    LEAD(pr.rating) OVER (
        PARTITION BY a.athlete_id ORDER BY m.match_date
    )                                       AS next_match_rating
FROM recovery_metrics rm
JOIN athletes a           ON rm.athlete_id  = a.athlete_id
JOIN performance_records pr ON rm.athlete_id = pr.athlete_id
JOIN matches m            ON pr.match_id    = m.match_id
WHERE rm.log_date = DATE_SUB(m.match_date, INTERVAL 1 DAY)
ORDER BY athlete_name, m.match_date;
