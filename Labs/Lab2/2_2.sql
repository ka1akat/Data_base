DROP TABLE IF EXISTS class_schedule CASCADE;
DROP TABLE IF EXISTS student_records CASCADE;

CREATE TABLE class_schedule (
                                schedule_id SERIAL PRIMARY KEY,
                                course_id INT,
                                professor_id INT,
                                classroom VARCHAR(20),
                                class_date DATE,
                                start_time TIME WITHOUT TIME ZONE,
                                end_time TIME WITHOUT TIME ZONE,
                                duration INTERVAL
);
ALTER TABLE class_schedule
    ADD COLUMN room_capacity INT,
    DROP COLUMN duration,
    ADD COLUMN session_type VARCHAR(15),
    ALTER COLUMN classroom TYPE VARCHAR(30),
    ADD COLUMN equipment_needed TEXT;


CREATE TABLE student_records (
                                 record_id SERIAL PRIMARY KEY,
                                 student_id INT,
                                 course_id INT,
                                 semester VARCHAR(20),
                                 year INT,
                                 grade CHAR(2),
                                 attendance_percentage DECIMAL(4,1),
                                 submission_timestamp TIMESTAMPTZ,
                                 last_updated TIMESTAMPTZ
);
ALTER TABLE student_records
    ADD COLUMN extra_credit_points DECIMAL(4,1),
    ALTER COLUMN grade TYPE VARCHAR(5),
    ALTER COLUMN extra_credit_points SET DEFAULT 0.0,
    ADD COLUMN final_exam_date DATE,
    DROP COLUMN last_updated;

