-- ============================================================
--  AthleteIQ | Stored Procedure: Calculate Player Rating
--  Description: Auto-calculates a composite AthleteIQ score
--               based on performance, training & recovery data
-- ============================================================

USE AthleteIQ;

DELIMITER $$

-- ------------------------------------------------------------
-- Procedure: calculate_athlete_iq_score
-- Returns a composite score (0–100) for a given athlete
-- ------------------------------------------------------------
CREATE PROCEDURE calculate_athlete_iq_score(
    IN  p_athlete_id   INT,
    OUT p_iq_score     DECIMAL(5,2),
    OUT p_grade        VARCHAR(10),
    OUT p_summary      VARCHAR(255)
)
BEGIN
    DECLARE v_avg_rating         DECIMAL(5,2) DEFAULT 0;
    DECLARE v_avg_readiness      DECIMAL(5,2) DEFAULT 0;
    DECLARE v_avg_intensity      DECIMAL(5,2) DEFAULT 0;
    DECLARE v_injury_penalty     DECIMAL(5,2) DEFAULT 0;
    DECLARE v_goal_contribution  DECIMAL(5,2) DEFAULT 0;
    DECLARE v_total_injuries     INT          DEFAULT 0;

    -- Avg match rating (weight: 35%)
    SELECT COALESCE(ROUND(AVG(rating), 2), 0)
    INTO v_avg_rating
    FROM performance_records
    WHERE athlete_id = p_athlete_id;

    -- Avg readiness score (weight: 20%)
    SELECT COALESCE(ROUND(AVG(readiness_score), 2), 0)
    INTO v_avg_readiness
    FROM recovery_metrics
    WHERE athlete_id = p_athlete_id;

    -- Avg training intensity (weight: 15%)
    SELECT COALESCE(ROUND(AVG(intensity_level), 2), 0)
    INTO v_avg_intensity
    FROM training_sessions
    WHERE athlete_id = p_athlete_id;

    -- Goal contribution rate per match (weight: 20%)
    SELECT COALESCE(ROUND(AVG(goals + assists), 2), 0)
    INTO v_goal_contribution
    FROM performance_records
    WHERE athlete_id = p_athlete_id;

    -- Injury penalty: -2 per injury, -5 for severe/career (weight: -10%)
    SELECT
        COALESCE(SUM(
            CASE
                WHEN severity IN ('Severe', 'Career-threatening') THEN 5
                ELSE 2
            END
        ), 0)
    INTO v_injury_penalty
    FROM injuries
    WHERE athlete_id = p_athlete_id;

    -- Composite AthleteIQ Score (scaled to 100)
    SET p_iq_score = ROUND(
        (v_avg_rating        * 3.5)   +   -- 35%
        (v_avg_readiness     * 2.0)   +   -- 20%
        (v_avg_intensity     * 1.5)   +   -- 15%
        (v_goal_contribution * 5.0)   -   -- 20% (scaled)
        v_injury_penalty,                  -- penalty
    2);

    -- Cap score between 0 and 100
    IF p_iq_score > 100 THEN SET p_iq_score = 100; END IF;
    IF p_iq_score < 0   THEN SET p_iq_score = 0;   END IF;

    -- Grade assignment
    SET p_grade = CASE
        WHEN p_iq_score >= 85 THEN 'S'
        WHEN p_iq_score >= 75 THEN 'A'
        WHEN p_iq_score >= 60 THEN 'B'
        WHEN p_iq_score >= 45 THEN 'C'
        WHEN p_iq_score >= 30 THEN 'D'
        ELSE 'F'
    END;

    -- Summary message
    SET p_summary = CONCAT(
        'AthleteIQ Score: ', p_iq_score,
        ' | Grade: ', p_grade,
        ' | Avg Rating: ', v_avg_rating,
        ' | Readiness: ', v_avg_readiness,
        ' | Training Load: ', v_avg_intensity,
        ' | Injury Penalty: -', v_injury_penalty
    );
END$$


-- ------------------------------------------------------------
-- Procedure: get_all_athlete_iq_scores
-- Loops through all athletes and prints their IQ scores
-- ------------------------------------------------------------
CREATE PROCEDURE get_all_athlete_iq_scores()
BEGIN
    DECLARE done      INT DEFAULT FALSE;
    DECLARE v_id      INT;
    DECLARE v_name    VARCHAR(100);
    DECLARE v_score   DECIMAL(5,2);
    DECLARE v_grade   VARCHAR(10);
    DECLARE v_summary VARCHAR(255);

    DECLARE cur CURSOR FOR
        SELECT athlete_id, CONCAT(first_name, ' ', last_name)
        FROM athletes
        WHERE status = 'Active';

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    CREATE TEMPORARY TABLE IF NOT EXISTS temp_iq_scores (
        athlete_name VARCHAR(100),
        iq_score     DECIMAL(5,2),
        grade        VARCHAR(10),
        summary      VARCHAR(255)
    );

    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_id, v_name;
        IF done THEN LEAVE read_loop; END IF;

        CALL calculate_athlete_iq_score(v_id, v_score, v_grade, v_summary);

        INSERT INTO temp_iq_scores VALUES (v_name, v_score, v_grade, v_summary);
    END LOOP;
    CLOSE cur;

    SELECT * FROM temp_iq_scores ORDER BY iq_score DESC;
    DROP TEMPORARY TABLE temp_iq_scores;
END$$

DELIMITER ;


-- ------------------------------------------------------------
-- Usage Examples:
-- ------------------------------------------------------------

-- Get IQ score for a single athlete (athlete_id = 1)
-- CALL calculate_athlete_iq_score(1, @score, @grade, @summary);
-- SELECT @score AS iq_score, @grade AS grade, @summary AS summary;

-- Get IQ scores for all active athletes
-- CALL get_all_athlete_iq_scores();
