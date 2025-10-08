DROP TABLE IF EXISTS assignments CASCADE;
DROP TABLE IF EXISTS projects CASCADE;
DROP TABLE IF EXISTS employees CASCADE;

CREATE TABLE employees (
                           employee_id SERIAL PRIMARY KEY,
                           first_name VARCHAR(50),
                           last_name VARCHAR(50),
                           department VARCHAR(50),
                           salary NUMERIC(10,2),
                           hire_date DATE,
                           manager_id INTEGER,
                           email VARCHAR(100)
);

CREATE TABLE projects (
                          project_id SERIAL PRIMARY KEY,
                          project_name VARCHAR(100),
                          budget NUMERIC(12,2),
                          start_date DATE,
                          end_date DATE,
                          status VARCHAR(20)
);

CREATE TABLE assignments (
                             assignment_id SERIAL PRIMARY KEY,
                             employee_id INTEGER REFERENCES employees(employee_id),
                             project_id INTEGER REFERENCES projects(project_id),
                             hours_worked NUMERIC(5,1),
                             assignment_date DATE
);
INSERT INTO employees (first_name, last_name, department, salary, hire_date, manager_id, email) VALUES
                                                                                                    ('John', 'Smith', 'IT', 75000, '2020-01-15', NULL, 'john.smith@company.com'),
                                                                                                    ('Sarah', 'Johnson', 'IT', 65000, '2020-03-20', 1, 'sarah.j@company.com'),
                                                                                                    ('Michael', 'Brown', 'Sales', 55000, '2019-06-10', NULL, 'mbrown@company.com'),
                                                                                                    ('Emily', 'Davis', 'HR', 60000, '2021-02-01', NULL, 'emily.davis@company.com'),
                                                                                                    ('Robert', 'Wilson', 'IT', 70000, '2020-08-15', 1, NULL),
                                                                                                    ('Lisa', 'Anderson', 'Sales', 58000, '2021-05-20', 3, 'lisa.a@company.com');

INSERT INTO projects (project_name, budget, start_date, end_date, status) VALUES
                                                                              ('Website Redesign', 150000, '2024-01-01', '2024-06-30', 'Active'),
                                                                              ('CRM Implementation', 200000, '2024-02-15', '2024-12-31', 'Active'),
                                                                              ('Marketing Campaign', 80000, '2024-03-01', '2024-05-31', 'Completed'),
                                                                              ('Database Migration', 120000, '2024-01-10', NULL, 'Active');

INSERT INTO assignments (employee_id, project_id, hours_worked, assignment_date) VALUES
                                                                                     (1, 1, 120.5, '2024-01-15'),
                                                                                     (2, 1, 95.0, '2024-01-20'),
                                                                                     (1, 4, 80.0, '2024-02-01'),
                                                                                     (3, 3, 60.0, '2024-03-05'),
                                                                                     (5, 2, 110.0, '2024-02-20'),
                                                                                     (6, 3, 75.5, '2024-03-10');

-- Task 4.1: Calculate the average salary for each department
SELECT
    department,
    ROUND(AVG(salary), 2) AS avg_salary
FROM employees
GROUP BY department
ORDER BY department;

-- Task 4.2: Find the total hours worked on each project, including the project name
SELECT
    p.project_name,
    COALESCE(SUM(a.hours_worked), 0) AS total_hours
FROM projects p
         LEFT JOIN assignments a ON a.project_id = p.project_id
GROUP BY p.project_id, p.project_name
ORDER BY p.project_name;

-- Task 4.3: Count the number of employees in each department.
SELECT
    department,
    COUNT(*) AS employee_count
FROM employees
GROUP BY department
HAVING COUNT(*) > 1
ORDER BY employee_count DESC, department;

-- Task 4.4: Find the maximum and minimum salary in the company,
SELECT
    MAX(salary) AS max_salary,
    MIN(salary) AS min_salary,
    SUM(salary) AS total_payroll
FROM employees;
