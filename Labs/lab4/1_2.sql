DROP TABLE IF EXISTS assignments CASCADE;
DROP TABLE IF EXISTS projects CASCADE;
DROP TABLE IF EXISTS employees CASCADE;

CREATE TABLE employees (
                           employee_id SERIAL PRIMARY KEY,
                           first_name VARCHAR(50),
                           last_name  VARCHAR(50),
                           department VARCHAR(50),
                           salary     NUMERIC(10,2),
                           hire_date  DATE,
                           manager_id INTEGER,
                           email      VARCHAR(100)
);

CREATE TABLE projects (
                          project_id   SERIAL PRIMARY KEY,
                          project_name VARCHAR(100),
                          budget       NUMERIC(12,2),
                          start_date   DATE,
                          end_date     DATE,
                          status       VARCHAR(20)
);

CREATE TABLE assignments (
                             assignment_id  SERIAL PRIMARY KEY,
                             employee_id    INTEGER REFERENCES employees(employee_id),
                             project_id     INTEGER REFERENCES projects(project_id),
                             hours_worked   NUMERIC(5,1),
                             assignment_date DATE
);

INSERT INTO employees
(first_name, last_name, department, salary, hire_date, manager_id, email)
VALUES
    ('John',   'Smith',   'IT',    75000, '2020-01-15', NULL, 'john.smith@company.com'),
    ('Sarah',  'Johnson', 'IT',    65000, '2020-03-20', 1,    'sarah.j@company.com'),
    ('Michael','Brown',   'Sales', 55000, '2019-06-10', NULL, 'mbrown@company.com'),
    ('Emily',  'Davis',   'HR',    60000, '2021-02-01', NULL, 'emily.davis@company.com'),
    ('Robert', 'Wilson',  'IT',    70000, '2020-08-15', 1,    NULL),
    ('Lisa',   'Anderson','Sales', 58000, '2021-05-20', 3,    'lisa.a@company.com');

INSERT INTO projects
(project_name, budget, start_date, end_date, status)
VALUES
    ('Website Redesign',    150000, '2024-01-01', '2024-06-30', 'Active'),
    ('CRM Implementation',  200000, '2024-02-15', '2024-12-31', 'Active'),
    ('Marketing Campaign',   80000, '2024-03-01', '2024-05-31', 'Completed'),
    ('Database Migration',  120000, '2024-01-10', NULL,         'Active');

INSERT INTO assignments
(employee_id, project_id, hours_worked, assignment_date)
VALUES
    (1, 1, 120.5, '2024-01-15'),
    (2, 1,  95.0, '2024-01-20'),
    (1, 4,  80.0, '2024-02-01'),
    (3, 3,  60.0, '2024-03-05'),
    (5, 2, 110.0, '2024-02-20'),
    (6, 3,  75.5, '2024-03-10');

-- Task 2.1: Find all employees hired after January 1, 2020
SELECT
    first_name,
    last_name,
    department,
    hire_date
FROM employees
WHERE hire_date > '2020-01-01'
ORDER BY hire_date;

-- Task 2.2: Find all employees whose salary is between 60000 and 70000
SELECT
    first_name,
    last_name,
    department,
    salary
FROM employees
WHERE salary BETWEEN 60000 AND 70000
ORDER BY salary;

-- Task 2.3: Find all employees whose last name starts with 'S' or 'J'
SELECT
    first_name,
    last_name,
    department
FROM employees
WHERE last_name LIKE 'S%' OR last_name LIKE 'J%'
ORDER BY last_name;

-- Task 2.4: Find all employees who have a manager and work in the IT department
SELECT
    first_name,
    last_name,
    department,
    manager_id
FROM employees
WHERE manager_id IS NOT NULL
  AND department = 'IT'
ORDER BY last_name;
