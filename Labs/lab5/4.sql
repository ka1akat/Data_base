DROP TABLE IF EXISTS departments CASCADE;

CREATE TABLE departments (
                             dept_id INTEGER PRIMARY KEY,
                             dept_name TEXT NOT NULL,
                             location TEXT
);

INSERT INTO departments VALUES
                            (1, 'Computer Science', 'Building A'),
                            (2, 'Mathematics', 'Building B'),
                            (3, 'Physics', 'Building C');

-- Ошибка: дубликат dept_id
INSERT INTO departments VALUES (1, 'Chemistry', 'Building D');

-- Ошибка: NULL dept_id
INSERT INTO departments VALUES (NULL, 'Biology', 'Building E');


DROP TABLE IF EXISTS student_courses CASCADE;

CREATE TABLE student_courses (
                                 student_id INTEGER,
                                 course_id INTEGER,
                                 enrollment_date DATE,
                                 grade TEXT,
                                 PRIMARY KEY (student_id, course_id)
);

INSERT INTO student_courses VALUES
                                (101, 1, '2025-09-01', 'A'),
                                (102, 2, '2025-09-02', 'B'),
                                (103, 3, '2025-09-03', 'A');

-- Ошибка: комбинация student_id+course_id уже существует
INSERT INTO student_courses VALUES (101, 1, '2025-09-10', 'B');
