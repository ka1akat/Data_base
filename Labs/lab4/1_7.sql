
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

SELECT
    e.first_name || ' ' || e.last_name AS full_name,
    e.department,
    ROUND(AVG(a.hours_worked), 2) AS avg_hours_worked,
    DENSE_RANK() OVER (PARTITION BY e.department ORDER BY e.salary DESC) AS salary_rank_in_department
FROM employees e
         LEFT JOIN assignments a ON a.employee_id = e.employee_id
GROUP BY e.employee_id, e.first_name, e.last_name, e.department, e.salary
ORDER BY e.department, salary_rank_in_department, full_name;

-- Task 7.2: Projects where total hours worked > 150.
-- Show project name, total hours, and number of employees assigned.
SELECT
    p.project_name,
    COALESCE(SUM(a.hours_worked), 0) AS total_hours,
    COUNT(DISTINCT a.employee_id) AS employee_count
FROM projects p
         LEFT JOIN assignments a ON a.project_id = p.project_id
GROUP BY p.project_id, p.project_name
HAVING COALESCE(SUM(a.hours_worked), 0) > 150
ORDER BY total_hours DESC, p.project_name;

-- Task 7.3: Department report — total employees, average salary,
-- highest-paid employee name. Use GREATEST and LEAST in the output.
WITH dept_stats AS (
    SELECT
        department,
        COUNT(*) AS total_employees,
        ROUND(AVG(salary), 2) AS avg_salary,
        MAX(salary) AS max_salary,
        MIN(salary) AS min_salary
    FROM employees
    GROUP BY department
),
     top_earners AS (
         SELECT
             e.department,
             e.first_name || ' ' || e.last_name AS highest_paid_employee
         FROM employees e
                  JOIN dept_stats d
                       ON d.department = e.department
                           AND e.salary = d.max_salary
     )
SELECT
    d.department,
    d.total_employees,
    d.avg_salary,
    t.highest_paid_employee,
    GREATEST(d.max_salary, d.min_salary) AS highest_salary,
    LEAST(d.max_salary, d.min_salary) AS lowest_salary
FROM dept_stats d
         LEFT JOIN top_earners t USING (department)
ORDER BY d.department;
