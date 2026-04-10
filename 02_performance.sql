-- ============================================================
--  AthleteIQ | Schema: Performance Tracking
--  Description: Match stats and performance records per athlete
-- ============================================================

USE AthleteIQ;

-- ------------------------------------------------------------
-- Matches Table
-- ------------------------------------------------------------
CREATE TABLE matches (
    match_id        INT AUTO_INCREMENT PRIMARY KEY,
    match_date      DATE         NOT NULL,
    home_team_id    INT          NOT NULL,
    away_team_id    INT          NOT NULL,
    home_score      INT          DEFAULT 0,
    away_score      INT          DEFAULT 0,
    venue           VARCHAR(150),
    match_type      ENUM('Friendly', 'League', 'Cup', 'Playoff', 'Final') DEFAULT 'League',
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_home_team FOREIGN KEY (home_team_id) REFERENCES teams(team_id),
    CONSTRAINT fk_away_team FOREIGN KEY (away_team_id) REFERENCES teams(team_id)
);

-- ------------------------------------------------------------
-- Performance Records Table
-- ------------------------------------------------------------
CREATE TABLE performance_records (
    record_id           INT AUTO_INCREMENT PRIMARY KEY,
    athlete_id          INT          NOT NULL,
    match_id            INT          NOT NULL,
    minutes_played      INT          DEFAULT 0,
    goals               INT          DEFAULT 0,
    assists             INT          DEFAULT 0,
    shots_on_target     INT          DEFAULT 0,
    pass_accuracy       DECIMAL(5,2) DEFAULT 0.00,   -- percentage
    distance_covered_km DECIMAL(5,2) DEFAULT 0.00,
    sprint_count        INT          DEFAULT 0,
    rating              DECIMAL(3,1) DEFAULT 0.0,    -- 0.0 to 10.0
    notes               TEXT,
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_perf_athlete FOREIGN KEY (athlete_id) REFERENCES athletes(athlete_id) ON DELETE CASCADE,
    CONSTRAINT fk_perf_match   FOREIGN KEY (match_id)   REFERENCES matches(match_id)   ON DELETE CASCADE,
    CONSTRAINT uq_athlete_match UNIQUE (athlete_id, match_id)
);

-- ------------------------------------------------------------
-- Indexes
-- ------------------------------------------------------------
CREATE INDEX idx_perf_athlete   ON performance_records(athlete_id);
CREATE INDEX idx_perf_match     ON performance_records(match_id);
CREATE INDEX idx_perf_rating    ON performance_records(rating);
CREATE INDEX idx_match_date     ON matches(match_date);
