-- ============================================================
--  AthleteIQ | Query: Top Performers
--  Description: Rank athletes by avg rating, goals & assists
--               using Window Functions and CTEs
-- ============================================================

USE AthleteIQ;

-- ------------------------------------------------------------
-- 1. Overall Top Performers (Avg Rating + Stats)
-- ------------------------------------------------------------
WITH athlete_stats AS (
    SELECT
        a.athlete_id,
        CONCAT(a.first_name, ' ', a.last_name)  AS athlete_name,
        a.position,
        t.team_name,
        COUNT(pr.record_id)                      AS matches_played,
        SUM(pr.goals)                            AS total_goals,
        SUM(pr.assists)                          AS total_assists,
        SUM(pr.goals) + SUM(pr.assists)          AS goal_contributions,
        ROUND(AVG(pr.rating), 2)                 AS avg_rating,
        ROUND(AVG(pr.pass_accuracy), 2)          AS avg_pass_accuracy,
        ROUND(AVG(pr.distance_covered_km), 2)    AS avg_distance_km
    FROM athletes a
    JOIN performance_records pr ON a.athlete_id = pr.athlete_id
    JOIN teams t                ON a.team_id    = t.team_id
    GROUP BY a.athlete_id, athlete_name, a.position, t.team_name
)
SELECT
    RANK() OVER (ORDER BY avg_rating DESC, goal_contributions DESC) AS overall_rank,
    athlete_name,
    position,
    team_name,
    matches_played,
    total_goals,
    total_assists,
    goal_contributions,
    avg_rating,
    avg_pass_accuracy,
    avg_distance_km
FROM athlete_stats
ORDER BY overall_rank;


-- ------------------------------------------------------------
-- 2. Top Performers Per Position
-- ------------------------------------------------------------
WITH position_stats AS (
    SELECT
        a.position,
        CONCAT(a.first_name, ' ', a.last_name) AS athlete_name,
        t.team_name,
        ROUND(AVG(pr.rating), 2)               AS avg_rating,
        SUM(pr.goals)                          AS total_goals,
        SUM(pr.assists)                        AS total_assists,
        COUNT(pr.record_id)                    AS matches_played
    FROM athletes a
    JOIN performance_records pr ON a.athlete_id = pr.athlete_id
    JOIN teams t                ON a.team_id    = t.team_id
    GROUP BY a.athlete_id, a.position, athlete_name, t.team_name
)
SELECT
    position,
    athlete_name,
    team_name,
    avg_rating,
    total_goals,
    total_assists,
    matches_played,
    RANK() OVER (PARTITION BY position ORDER BY avg_rating DESC) AS position_rank
FROM position_stats
ORDER BY position, position_rank;


-- ------------------------------------------------------------
-- 3. Month-by-Month Rating Trend Per Athlete (LAG Function)
-- ------------------------------------------------------------
WITH monthly_ratings AS (
    SELECT
        a.athlete_id,
        CONCAT(a.first_name, ' ', a.last_name) AS athlete_name,
        DATE_FORMAT(m.match_date, '%Y-%m')     AS match_month,
        ROUND(AVG(pr.rating), 2)               AS avg_monthly_rating
    FROM performance_records pr
    JOIN athletes a ON pr.athlete_id = a.athlete_id
    JOIN matches m  ON pr.match_id   = m.match_id
    GROUP BY a.athlete_id, athlete_name, match_month
)
SELECT
    athlete_name,
    match_month,
    avg_monthly_rating,
    LAG(avg_monthly_rating) OVER (PARTITION BY athlete_id ORDER BY match_month) AS prev_month_rating,
    ROUND(
        avg_monthly_rating -
        LAG(avg_monthly_rating) OVER (PARTITION BY athlete_id ORDER BY match_month),
    2) AS rating_change
FROM monthly_ratings
ORDER BY athlete_name, match_month;
