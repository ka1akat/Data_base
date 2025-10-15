DROP TABLE IF EXISTS users CASCADE;

CREATE TABLE users (
                       user_id INTEGER,
                       username TEXT UNIQUE,
                       email TEXT UNIQUE,
                       created_at TIMESTAMP
);

INSERT INTO users VALUES
                      (1, 'anna', 'anna@example.com', NOW()),
                      (2, 'john', 'john@example.com', NOW());

-- Ошибки:
INSERT INTO users VALUES
    (3, 'anna', 'anna2@example.com', NOW());
INSERT INTO users VALUES
    (4, 'kate', 'john@example.com', NOW());


DROP TABLE IF EXISTS course_enrollments CASCADE;

CREATE TABLE course_enrollments (
                                    enrollment_id INTEGER,
                                    student_id INTEGER,
                                    course_code TEXT,
                                    semester TEXT,
                                    CONSTRAINT unique_enrollment UNIQUE (student_id, course_code, semester)
);

INSERT INTO course_enrollments VALUES
                                   (1, 1001, 'CS101', 'Fall2025'),
                                   (2, 1002, 'CS102', 'Fall2025'),
                                   (3, 1001, 'CS101', 'Spring2026');

-- Ошибка:
INSERT INTO course_enrollments VALUES
    (4, 1001, 'CS101', 'Fall2025');


ALTER TABLE users
    ADD CONSTRAINT unique_username UNIQUE (username);

ALTER TABLE users
    ADD CONSTRAINT unique_email UNIQUE (email);

-- Проверка:
INSERT INTO users VALUES
    (5, 'john', 'newjohn@example.com', NOW());
INSERT INTO users VALUES
    (6, 'alex', 'john@example.com', NOW());
