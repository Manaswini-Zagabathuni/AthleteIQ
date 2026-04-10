-- ============================================================
--  AthleteIQ | Schema: Injury Log
--  Description: Injury tracking, recovery timeline & impact
-- ============================================================

USE AthleteIQ;

-- ------------------------------------------------------------
-- Injuries Table
-- ------------------------------------------------------------
CREATE TABLE injuries (
    injury_id           INT AUTO_INCREMENT PRIMARY KEY,
    athlete_id          INT          NOT NULL,
    injury_date         DATE         NOT NULL,
    injury_type         VARCHAR(100) NOT NULL,   -- e.g., Hamstring Strain, ACL Tear
    body_part           VARCHAR(100) NOT NULL,   -- e.g., Left Knee, Right Shoulder
    severity            ENUM('Minor', 'Moderate', 'Severe', 'Career-threatening') NOT NULL,
    expected_return     DATE,
    actual_return       DATE,
    matches_missed      INT          DEFAULT 0,
    treatment           TEXT,
    treated_by          VARCHAR(100),            -- Doctor/Physio name
    is_recurring        BOOLEAN      DEFAULT FALSE,
    notes               TEXT,
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_injury_athlete FOREIGN KEY (athlete_id) REFERENCES athletes(athlete_id) ON DELETE CASCADE
);

-- ------------------------------------------------------------
-- Injury Risk Flags Table (auto-populated via trigger)
-- ------------------------------------------------------------
CREATE TABLE injury_risk_flags (
    flag_id             INT AUTO_INCREMENT PRIMARY KEY,
    athlete_id          INT          NOT NULL,
    flagged_at          TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    reason              VARCHAR(255) NOT NULL,
    risk_level          ENUM('Low', 'Medium', 'High', 'Critical') NOT NULL,
    is_resolved         BOOLEAN      DEFAULT FALSE,
    resolved_at         TIMESTAMP    NULL,
    CONSTRAINT fk_flag_athlete FOREIGN KEY (athlete_id) REFERENCES athletes(athlete_id) ON DELETE CASCADE
);

-- ------------------------------------------------------------
-- Indexes
-- ------------------------------------------------------------
CREATE INDEX idx_injury_athlete   ON injuries(athlete_id);
CREATE INDEX idx_injury_date      ON injuries(injury_date);
CREATE INDEX idx_injury_severity  ON injuries(severity);
CREATE INDEX idx_flag_athlete     ON injury_risk_flags(athlete_id);
CREATE INDEX idx_flag_resolved    ON injury_risk_flags(is_resolved);
