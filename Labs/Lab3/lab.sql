DROP DATABASE IF EXISTS university_main WITH (FORCE);
CREATE DATABASE university_main
    WITH OWNER = karakatzaslan
    ENCODING = 'UTF8';

DROP DATABASE IF EXISTS university_archive WITH (FORCE);
CREATE DATABASE university_archive
    WITH OWNER = karakatzaslan
    CONNECTION LIMIT = 50;

CREATE TABLESPACE student_data
    LOCATION '/Users/karakatzaslan/postgres_tables/students';

DROP TABLESPACE IF EXISTS course_data;
CREATE TABLESPACE course_data
    OWNER karakatzaslan
    LOCATION '/Users/karakatzaslan/postgres_tables/courses';

DROP TABLE IF EXISTS students CASCADE;
CREATE TABLE students (
                          student_id SERIAL PRIMARY KEY,
                          first_name VARCHAR(50),
                          last_name VARCHAR(50),
                          email VARCHAR(100),
                          phone CHAR(15),
                          date_of_birth DATE,
                          enrollment_date DATE,
                          gpa DECIMAL(3,2),
                          is_active BOOLEAN,
                          graduation_year SMALLINT
);
ALTER TABLE students
    ADD COLUMN middle_name VARCHAR(30),
    ADD COLUMN student_status VARCHAR(20) DEFAULT 'ACTIVE',
    ALTER COLUMN phone TYPE VARCHAR(20),
    ALTER COLUMN gpa SET DEFAULT 0.00;


DROP TABLE IF EXISTS professors CASCADE;
CREATE TABLE professors (
                            professor_id SERIAL PRIMARY KEY,
                            first_name VARCHAR(50),
                            last_name VARCHAR(50),
                            email VARCHAR(100),
                            office_number VARCHAR(20),
                            hire_date DATE,
                            salary NUMERIC(12,2),
                            is_tenured BOOLEAN,
                            years_experience INT
);
ALTER TABLE professors
    ADD COLUMN department_code CHAR(5),
    ADD COLUMN research_area TEXT,
    ALTER COLUMN years_experience TYPE SMALLINT,
    ALTER COLUMN is_tenured SET DEFAULT FALSE,
    ADD COLUMN last_promotion_date DATE;


DROP TABLE IF EXISTS courses CASCADE;
CREATE TABLE courses (
                         course_id SERIAL PRIMARY KEY,
                         course_code CHAR(8),
                         course_title VARCHAR(100),
                         description TEXT,
                         credits SMALLINT,
                         max_enrollment INT,
                         course_fee DECIMAL(10,2),
                         is_online BOOLEAN,
                         created_at TIMESTAMP
);

ALTER TABLE courses
    ADD COLUMN prerequisite_course_id INT,
    ADD COLUMN difficulty_level SMALLINT,
    ALTER COLUMN course_code TYPE VARCHAR(10),
    ALTER COLUMN credits SET DEFAULT 3,
    ADD COLUMN lab_required BOOLEAN DEFAULT FALSE;


ALTER TABLE professors
    ADD COLUMN IF NOT EXISTS department_id INT;

ALTER TABLE students
    ADD COLUMN IF NOT EXISTS advisor_id INT;

ALTER TABLE courses
    ADD COLUMN IF NOT EXISTS department_id INT;
