CREATE DATABASE advanced_lab;
CREATE TABLE employees (
                           emp_id SERIAL PRIMARY KEY ,
                           first_name VARCHAR(50),
                           last_name VARCHAR(50),
                           department VARCHAR(50),
                           salary INT,
                           hire_date DATE,
                           status VARCHAR(20) DEFAULT 'Active'
);
INSERT INTO employees (first_name, last_name, department)
VALUES ('John', 'Doe', 'HR');

INSERT INTO employees (first_name, last_name, department, salary, status)
VALUES ('Jane', 'Smith', 'Finance', DEFAULT, DEFAULT);

INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES ('Alice', 'Brown', 'IT', 50000 * 1.1, CURRENT_DATE);

CREATE TABLE departments (
                             dept_id SERIAL PRIMARY KEY ,
                             dept_name VARCHAR(50),
                             budget INT,
                             manager_id INT
);

INSERT INTO departments (dept_name, budget, manager_id)
VALUES
    ('HR', 200000, 1),
    ('Finance', 300000, 2),
    ('IT', 500000, 3);

CREATE TABLE projects (
                          project_id SERIAL PRIMARY KEY ,
                          project_name VARCHAR(100),
                          dept_id INT,
                          start_date DATE,
                          end_date DATE,
                          budget INT
);

CREATE TEMPORARY TABLE temp_employees AS
SELECT *
FROM employees
WHERE department = 'IT';

CREATE TEMPORARY TABLE temp_employees (LIKE employees INCLUDING ALL);

INSERT INTO temp_employees
SELECT *
FROM employees
WHERE department = 'IT';

UPDATE employees
SET salary = ROUND(salary * 1.10)::INT;
UPDATE employees
SET status = 'Senior'
WHERE salary > 60000
  AND hire_date < DATE '2020-01-01';
UPDATE employees
SET department = CASE
                     WHEN salary > 80000 THEN 'Management'
                     WHEN salary BETWEEN 50000 AND 80000 THEN 'Senior'
                     ELSE 'Junior'
    END
WHERE TRUE;

ALTER TABLE employees
    ALTER COLUMN department SET DEFAULT 'General';

UPDATE employees
SET department = DEFAULT
WHERE status = 'Inactive';

UPDATE employees
SET salary = ROUND(salary * 1.15)::INT,
    status = 'Promoted'
WHERE department = 'Sales';

DELETE FROM employees
WHERE salary < 40000
  AND hire_date > DATE '2023-01-01'
  AND department IS NULL;

DELETE FROM departments d
WHERE d.dept_name NOT IN (
    SELECT DISTINCT e.department
    FROM employees e
    WHERE e.department IS NOT NULL
);
DELETE FROM projects
WHERE end_date < DATE '2023-01-01'
RETURNING *;








