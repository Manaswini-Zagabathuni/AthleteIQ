-- ============================================================
--  AthleteIQ | Seed Data
--  Description: Sample data to populate and test the database
-- ============================================================

USE AthleteIQ;

-- ------------------------------------------------------------
-- Teams
-- ------------------------------------------------------------
INSERT INTO teams (team_name, sport, city, coach_name, founded_year) VALUES
('Thunder FC',       'Football',   'New York',    'Carlos Mendez',  1998),
('Storm Athletics',  'Football',   'Los Angeles', 'David Park',     2003),
('Iron Bulls',       'Football',   'Chicago',     'Marco Rossi',    1991),
('Falcon United',    'Football',   'Houston',     'James O\'Brien', 2010),
('Apex Runners',     'Athletics',  'Seattle',     'Linda Torres',   2005);

-- ------------------------------------------------------------
-- Athletes
-- ------------------------------------------------------------
INSERT INTO athletes (first_name, last_name, date_of_birth, gender, nationality, position, team_id, height_cm, weight_kg, contract_start, contract_end, status) VALUES
('Liam',    'Carter',   '1995-03-14', 'Male',   'USA',     'Forward',    1, 181.5, 77.0, '2022-01-01', '2025-12-31', 'Active'),
('Sofia',   'Navarro',  '1998-07-22', 'Female', 'Spain',   'Midfielder', 2, 165.0, 60.5, '2021-06-01', '2024-05-31', 'Active'),
('Jamal',   'Hassan',   '1993-11-05', 'Male',   'Nigeria', 'Defender',   1, 188.0, 84.0, '2020-01-01', '2024-12-31', 'Injured'),
('Yuki',    'Tanaka',   '2000-02-18', 'Male',   'Japan',   'Goalkeeper', 3, 186.0, 81.5, '2023-01-01', '2026-12-31', 'Active'),
('Amara',   'Diallo',   '1996-09-30', 'Female', 'Senegal', 'Forward',    4, 170.0, 63.0, '2022-07-01', '2025-06-30', 'Active'),
('Carlos',  'Ruiz',     '1992-05-12', 'Male',   'Brazil',  'Midfielder', 2, 175.5, 72.0, '2019-01-01', '2024-12-31', 'Active'),
('Emily',   'Johnson',  '1999-12-01', 'Female', 'UK',      'Defender',   3, 168.0, 62.0, '2023-03-01', '2026-02-28', 'Active'),
('Noah',    'Müller',   '1997-04-25', 'Male',   'Germany', 'Forward',    4, 183.0, 79.5, '2021-01-01', '2025-12-31', 'Active');

-- ------------------------------------------------------------
-- Matches
-- ------------------------------------------------------------
INSERT INTO matches (match_date, home_team_id, away_team_id, home_score, away_score, venue, match_type) VALUES
('2024-01-15', 1, 2, 2, 1, 'MetLife Stadium',       'League'),
('2024-01-22', 3, 4, 0, 0, 'Soldier Field',          'League'),
('2024-02-05', 2, 3, 3, 2, 'SoFi Stadium',           'Cup'),
('2024-02-18', 1, 4, 1, 1, 'MetLife Stadium',        'League'),
('2024-03-10', 4, 1, 2, 3, 'NRG Stadium',            'Playoff'),
('2024-03-25', 2, 4, 1, 0, 'SoFi Stadium',           'League'),
('2024-04-08', 3, 1, 2, 2, 'Soldier Field',           'Cup'),
('2024-04-20', 1, 3, 4, 1, 'MetLife Stadium',        'League');

-- ------------------------------------------------------------
-- Performance Records
-- ------------------------------------------------------------
INSERT INTO performance_records (athlete_id, match_id, minutes_played, goals, assists, shots_on_target, pass_accuracy, distance_covered_km, sprint_count, rating, notes) VALUES
(1, 1, 90, 2, 0, 5, 88.5, 10.2, 22, 9.1, 'Outstanding game, clinical finishing'),
(1, 4, 85, 0, 1, 2, 82.0, 9.8,  18, 7.2, 'Good work rate, unlucky in front of goal'),
(1, 5, 90, 1, 1, 4, 86.0, 11.0, 25, 8.5, 'Decisive in the playoff win'),
(2, 2, 90, 0, 0, 1, 91.5, 9.5,  15, 7.0, 'Solid midfield display, dominated possession'),
(2, 3, 90, 1, 2, 3, 89.0, 10.5, 20, 9.0, 'Best performance of the season'),
(6, 3, 78, 0, 1, 0, 87.0, 8.9,  14, 7.5, 'Controlled tempo well'),
(6, 6, 90, 0, 0, 1, 85.5, 9.1,  16, 6.8, 'Average game, misplaced passes late on'),
(5, 6, 90, 1, 0, 3, 78.0, 10.8, 28, 8.2, 'Great pressing and smart run for the goal'),
(8, 4, 90, 1, 0, 4, 84.0, 10.3, 21, 8.0, 'Consistent performer'),
(8, 5, 90, 2, 1, 6, 87.5, 11.2, 27, 9.3, 'Hat-trick attempt, two goals and an assist');

-- ------------------------------------------------------------
-- Training Sessions
-- ------------------------------------------------------------
INSERT INTO training_sessions (athlete_id, session_date, session_type, duration_minutes, intensity_level, calories_burned, heart_rate_avg, heart_rate_max, rpe, coach_feedback) VALUES
(1, '2024-01-10', 'Strength',  60,  8, 520, 145, 178, 8, 'Great lifting session, pushed through fatigue'),
(1, '2024-01-12', 'Cardio',    45,  7, 480, 155, 182, 7, 'Good pace work, maintain endurance'),
(1, '2024-01-13', 'Recovery',  30,  3, 180, 100, 120, 3, 'Light stretching, ice bath post-session'),
(2, '2024-01-10', 'Agility',   50,  9, 450, 160, 185, 9, 'Sharp movements, excellent footwork'),
(2, '2024-01-14', 'Tactical',  90,  5, 350, 120, 150, 5, 'Video review + positional drills'),
(3, '2024-01-08', 'Mixed',     75,  6, 500, 140, 170, 6, 'Rehab focused — light contact only'),
(5, '2024-01-11', 'Strength',  55,  8, 490, 148, 176, 8, 'Power output improving weekly'),
(5, '2024-01-15', 'Cardio',    40,  6, 400, 150, 175, 6, 'Steady state run, good recovery rate'),
(6, '2024-01-10', 'Tactical',  80,  5, 320, 118, 145, 4, 'Focus on pressing triggers and shape'),
(8, '2024-01-12', 'Strength',  65,  9, 560, 152, 180, 9, 'Personal best on squat — excellent form');

-- ------------------------------------------------------------
-- Recovery Metrics
-- ------------------------------------------------------------
INSERT INTO recovery_metrics (athlete_id, log_date, sleep_hours, sleep_quality, muscle_soreness, hydration_level, mood_score, readiness_score, notes) VALUES
(1, '2024-01-11', 7.5, 8, 4, 8, 8, 8, 'Felt good, legs slightly tired'),
(1, '2024-01-13', 6.0, 5, 7, 6, 6, 5, 'Poor sleep, body fatigued'),
(1, '2024-01-14', 8.5, 9, 2, 9, 9, 9, 'Fully recovered, ready for match'),
(2, '2024-01-11', 7.0, 7, 3, 8, 8, 8, 'Good recovery after hard session'),
(2, '2024-01-15', 8.0, 8, 2, 9, 9, 9, 'Peak readiness before match week'),
(3, '2024-01-09', 9.0, 7, 8, 7, 5, 4, 'Injured — pain in hamstring still present'),
(5, '2024-01-12', 7.5, 8, 3, 8, 8, 8, 'Energetic, motivated for training'),
(8, '2024-01-13', 6.5, 6, 6, 7, 7, 6, 'Slightly fatigued after heavy lift');

-- ------------------------------------------------------------
-- Injuries
-- ------------------------------------------------------------
INSERT INTO injuries (athlete_id, injury_date, injury_type, body_part, severity, expected_return, actual_return, matches_missed, treatment, treated_by, is_recurring, notes) VALUES
(3, '2023-11-20', 'Hamstring Strain',  'Right Leg',     'Moderate', '2024-01-15', NULL,         4,  'Physiotherapy + rest',         'Dr. Alan Webb',    FALSE, 'Grade 2 tear, progressing well'),
(1, '2023-08-05', 'Ankle Sprain',      'Left Ankle',    'Minor',    '2023-08-20', '2023-08-18', 1,  'Ice, compression, elevation',  'Dr. Sarah Kim',    TRUE,  'Third ankle issue this year'),
(5, '2023-06-10', 'Knee Ligament',     'Left Knee',     'Severe',   '2023-12-01', '2023-11-25', 12, 'Surgery + rehabilitation',     'Dr. Marco Bianchi', FALSE, 'Full ACL reconstruction done'),
(8, '2024-02-28', 'Muscle Fatigue',    'Lower Back',    'Minor',    '2024-03-07', '2024-03-05', 0,  'Rest + massage therapy',       'Physio Jake Moore', FALSE, 'Overloaded in training week');
