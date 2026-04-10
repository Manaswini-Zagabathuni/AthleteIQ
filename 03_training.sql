-- ============================================================
--  AthleteIQ | Schema: Training Load Manager
--  Description: Tracks workout sessions, intensity & recovery
-- ============================================================

USE AthleteIQ;

-- ------------------------------------------------------------
-- Training Sessions Table
-- ------------------------------------------------------------
CREATE TABLE training_sessions (
    session_id          INT AUTO_INCREMENT PRIMARY KEY,
    athlete_id          INT          NOT NULL,
    session_date        DATE         NOT NULL,
    session_type        ENUM('Strength', 'Cardio', 'Agility', 'Recovery', 'Tactical', 'Mixed') NOT NULL,
    duration_minutes    INT          NOT NULL,
    intensity_level     TINYINT      NOT NULL CHECK (intensity_level BETWEEN 1 AND 10),
    calories_burned     INT          DEFAULT 0,
    heart_rate_avg      INT,         -- bpm
    heart_rate_max      INT,         -- bpm
    rpe                 TINYINT      CHECK (rpe BETWEEN 1 AND 10),  -- Rate of Perceived Exertion
    coach_feedback      TEXT,
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_training_athlete FOREIGN KEY (athlete_id) REFERENCES athletes(athlete_id) ON DELETE CASCADE
);

-- ------------------------------------------------------------
-- Recovery Metrics Table
-- ------------------------------------------------------------
CREATE TABLE recovery_metrics (
    recovery_id         INT AUTO_INCREMENT PRIMARY KEY,
    athlete_id          INT          NOT NULL,
    log_date            DATE         NOT NULL,
    sleep_hours         DECIMAL(4,2),
    sleep_quality       TINYINT      CHECK (sleep_quality BETWEEN 1 AND 10),
    muscle_soreness     TINYINT      CHECK (muscle_soreness BETWEEN 1 AND 10),
    hydration_level     TINYINT      CHECK (hydration_level BETWEEN 1 AND 10),
    mood_score          TINYINT      CHECK (mood_score BETWEEN 1 AND 10),
    readiness_score     TINYINT      CHECK (readiness_score BETWEEN 1 AND 10),  -- Overall readiness
    notes               TEXT,
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_recovery_athlete FOREIGN KEY (athlete_id) REFERENCES athletes(athlete_id) ON DELETE CASCADE,
    CONSTRAINT uq_recovery_daily   UNIQUE (athlete_id, log_date)
);

-- ------------------------------------------------------------
-- Indexes
-- ------------------------------------------------------------
CREATE INDEX idx_training_athlete ON training_sessions(athlete_id);
CREATE INDEX idx_training_date    ON training_sessions(session_date);
CREATE INDEX idx_recovery_athlete ON recovery_metrics(athlete_id);
CREATE INDEX idx_recovery_date    ON recovery_metrics(log_date);
