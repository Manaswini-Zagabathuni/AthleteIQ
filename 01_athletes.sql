-- ============================================================
--  AthleteIQ | Schema: Athletes & Teams
--  Description: Core tables for athlete and team management
-- ============================================================

CREATE DATABASE IF NOT EXISTS AthleteIQ;
USE AthleteIQ;

-- ------------------------------------------------------------
-- Teams Table
-- ------------------------------------------------------------
CREATE TABLE teams (
    team_id       INT AUTO_INCREMENT PRIMARY KEY,
    team_name     VARCHAR(100) NOT NULL,
    sport         VARCHAR(50)  NOT NULL,
    city          VARCHAR(100),
    coach_name    VARCHAR(100),
    founded_year  YEAR,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ------------------------------------------------------------
-- Athletes Table
-- ------------------------------------------------------------
CREATE TABLE athletes (
    athlete_id      INT AUTO_INCREMENT PRIMARY KEY,
    first_name      VARCHAR(50)  NOT NULL,
    last_name       VARCHAR(50)  NOT NULL,
    date_of_birth   DATE         NOT NULL,
    gender          ENUM('Male', 'Female', 'Other') NOT NULL,
    nationality     VARCHAR(100),
    position        VARCHAR(50),
    team_id         INT,
    height_cm       DECIMAL(5,2),
    weight_kg       DECIMAL(5,2),
    contract_start  DATE,
    contract_end    DATE,
    status          ENUM('Active', 'Injured', 'Retired', 'Suspended') DEFAULT 'Active',
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_athlete_team FOREIGN KEY (team_id) REFERENCES teams(team_id) ON DELETE SET NULL
);

-- ------------------------------------------------------------
-- Indexes
-- ------------------------------------------------------------
CREATE INDEX idx_athlete_team   ON athletes(team_id);
CREATE INDEX idx_athlete_status ON athletes(status);
CREATE INDEX idx_athlete_name   ON athletes(last_name, first_name);
