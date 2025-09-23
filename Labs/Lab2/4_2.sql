DROP TABLE IF EXISTS grade_scale CASCADE;
CREATE TABLE grade_scale (
                             grade_id      SERIAL PRIMARY KEY,
                             letter_grade  CHAR(2),
                             min_percentage DECIMAL(4,1),
                             max_percentage DECIMAL(4,1),
                             gpa_points    DECIMAL(3,2)
);

DROP TABLE IF EXISTS semester_calendar CASCADE;
CREATE TABLE semester_calendar (
                                   semester_id           SERIAL PRIMARY KEY,
                                   semester_name         VARCHAR(20),
                                   academic_year         INT,
                                   start_date            DATE,
                                   end_date              DATE,
                                   registration_deadline TIMESTAMPTZ,
                                   is_current            BOOLEAN
);