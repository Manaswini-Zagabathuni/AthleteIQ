-- ============================================================
--  AthleteIQ | Triggers: Injury Risk Auto-Flagging
--  Description: Automatically flags athletes when risk factors
--               are detected in training or recovery data
-- ============================================================

USE AthleteIQ;

DELIMITER $$

-- ------------------------------------------------------------
-- Trigger 1: Flag high injury risk after new injury is logged
-- Fires when: INSERT on injuries
-- ------------------------------------------------------------
CREATE TRIGGER trg_flag_injury_risk_on_insert
AFTER INSERT ON injuries
FOR EACH ROW
BEGIN
    DECLARE v_injury_count INT;
    DECLARE v_risk_level   VARCHAR(10);
    DECLARE v_reason       VARCHAR(255);

    -- Count total injuries for this athlete
    SELECT COUNT(*) INTO v_injury_count
    FROM injuries
    WHERE athlete_id = NEW.athlete_id;

    -- Determine risk level based on severity and history
    IF NEW.severity = 'Career-threatening' THEN
        SET v_risk_level = 'Critical';
        SET v_reason = CONCAT('Career-threatening injury logged: ', NEW.injury_type, ' (', NEW.body_part, ')');

    ELSEIF NEW.severity = 'Severe' THEN
        SET v_risk_level = 'High';
        SET v_reason = CONCAT('Severe injury logged: ', NEW.injury_type, ' — ', v_injury_count, ' total injuries');

    ELSEIF v_injury_count >= 3 THEN
        SET v_risk_level = 'High';
        SET v_reason = CONCAT('Athlete has ', v_injury_count, ' recorded injuries. Recurring risk detected.');

    ELSEIF NEW.is_recurring = TRUE THEN
        SET v_risk_level = 'Medium';
        SET v_reason = CONCAT('Recurring injury flagged: ', NEW.injury_type, ' on ', NEW.body_part);

    ELSE
        SET v_risk_level = 'Low';
        SET v_reason = CONCAT('New injury logged: ', NEW.injury_type, '. Monitoring recommended.');
    END IF;

    -- Insert risk flag
    INSERT INTO injury_risk_flags (athlete_id, reason, risk_level)
    VALUES (NEW.athlete_id, v_reason, v_risk_level);

    -- Update athlete status if severe
    IF NEW.severity IN ('Severe', 'Career-threatening') THEN
        UPDATE athletes
        SET status = 'Injured'
        WHERE athlete_id = NEW.athlete_id;
    END IF;
END$$


-- ------------------------------------------------------------
-- Trigger 2: Flag risk when recovery readiness drops critically
-- Fires when: INSERT on recovery_metrics
-- ------------------------------------------------------------
CREATE TRIGGER trg_flag_low_readiness
AFTER INSERT ON recovery_metrics
FOR EACH ROW
BEGIN
    IF NEW.readiness_score <= 3 THEN
        INSERT INTO injury_risk_flags (athlete_id, reason, risk_level)
        VALUES (
            NEW.athlete_id,
            CONCAT(
                'Critically low readiness score (', NEW.readiness_score, '/10) on ', NEW.log_date,
                '. Sleep: ', NEW.sleep_hours, 'hrs | Soreness: ', NEW.muscle_soreness, '/10'
            ),
            CASE
                WHEN NEW.readiness_score <= 2 THEN 'Critical'
                ELSE 'High'
            END
        );
    ELSEIF NEW.muscle_soreness >= 9 THEN
        INSERT INTO injury_risk_flags (athlete_id, reason, risk_level)
        VALUES (
            NEW.athlete_id,
            CONCAT('Extreme muscle soreness (', NEW.muscle_soreness, '/10) detected on ', NEW.log_date),
            'Medium'
        );
    END IF;
END$$


-- ------------------------------------------------------------
-- Trigger 3: Flag overtraining risk from high-intensity sessions
-- Fires when: INSERT on training_sessions
-- ------------------------------------------------------------
CREATE TRIGGER trg_flag_overtraining
AFTER INSERT ON training_sessions
FOR EACH ROW
BEGIN
    DECLARE v_recent_high_intensity INT;

    -- Count high-intensity sessions in last 5 days
    SELECT COUNT(*) INTO v_recent_high_intensity
    FROM training_sessions
    WHERE athlete_id     = NEW.athlete_id
      AND intensity_level >= 8
      AND session_date   BETWEEN DATE_SUB(NEW.session_date, INTERVAL 5 DAY) AND NEW.session_date;

    IF v_recent_high_intensity >= 4 THEN
        INSERT INTO injury_risk_flags (athlete_id, reason, risk_level)
        VALUES (
            NEW.athlete_id,
            CONCAT(
                v_recent_high_intensity, ' high-intensity sessions (level 8+) in the last 5 days. ',
                'Overtraining risk detected. Recovery session recommended.'
            ),
            'High'
        );
    ELSEIF NEW.intensity_level = 10 AND NEW.duration_minutes > 90 THEN
        INSERT INTO injury_risk_flags (athlete_id, reason, risk_level)
        VALUES (
            NEW.athlete_id,
            CONCAT('Max intensity (10/10) session lasting ', NEW.duration_minutes, ' minutes. Risk of overload.'),
            'Medium'
        );
    END IF;
END$$

DELIMITER ;


-- ------------------------------------------------------------
-- View: Active Risk Flags Dashboard
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW vw_active_risk_flags AS
SELECT
    irf.flag_id,
    CONCAT(a.first_name, ' ', a.last_name) AS athlete_name,
    t.team_name,
    a.position,
    a.status                               AS current_status,
    irf.risk_level,
    irf.reason,
    irf.flagged_at,
    irf.is_resolved
FROM injury_risk_flags irf
JOIN athletes a ON irf.athlete_id = a.athlete_id
LEFT JOIN teams t ON a.team_id   = t.team_id
WHERE irf.is_resolved = FALSE
ORDER BY
    FIELD(irf.risk_level, 'Critical', 'High', 'Medium', 'Low'),
    irf.flagged_at DESC;

-- Usage: SELECT * FROM vw_active_risk_flags;
