DROP TABLE IF EXISTS departments CASCADE;
CREATE TABLE departments (
                             dept_id INT PRIMARY KEY,
                             dept_name VARCHAR(50),
                             location VARCHAR(50)
);
DROP TABLE IF EXISTS employees CASCADE;
CREATE TABLE employees (
                           emp_id INT PRIMARY KEY,
                           emp_name VARCHAR(50),
                           dept_id INT,
                           salary DECIMAL(10, 2),
                           FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);
DROP TABLE IF EXISTS projects CASCADE;
CREATE TABLE projects (
                          project_id INT PRIMARY KEY,
                          project_name VARCHAR(50),
                          dept_id INT,
                          budget DECIMAL(10, 2),
                          FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);
INSERT INTO departments (dept_id, dept_name, location)
VALUES
    (101, 'IT', 'Building A'),
    (102, 'HR', 'Building B'),
    (103, 'Finance', 'Building C'),
    (104, 'Marketing', 'Building D');

INSERT INTO employees (emp_id, emp_name, dept_id, salary)
VALUES
    (1, 'John Smith', 101, 50000),
    (2, 'Jane Doe', 102, 60000),
    (3, 'Mike Johnson', 101, 55000),
    (4, 'Sarah Williams', 103, 65000),
    (5, 'Tom Brown', NULL, 45000);

INSERT INTO projects (project_id, project_name, dept_id, budget)
VALUES
    (1, 'Website Redesign', 101, 100000),
    (2, 'Employee Training', 102, 50000),
    (3, 'Budget Analysis', 103, 75000),
    (4, 'Cloud Migration', 101, 150000),
    (5, 'AI Research', NULL, 200000);

SELECT
    d.dept_name,
    e.emp_name,
    e.salary,
    p.project_name,
    p.budget
FROM departments d
         LEFT JOIN employees e ON d.dept_id = e.dept_id
         LEFT JOIN projects  p ON d.dept_id = p.dept_id
ORDER BY d.dept_name, e.emp_name;

ALTER TABLE employees ADD COLUMN manager_id INT;

UPDATE employees SET manager_id = 3 WHERE emp_id = 1;
UPDATE employees SET manager_id = 3 WHERE emp_id = 2;
UPDATE employees SET manager_id = NULL WHERE emp_id = 3;
UPDATE employees SET manager_id = 3 WHERE emp_id = 4;
UPDATE employees SET manager_id = 3 WHERE emp_id = 5;

SELECT
    e.emp_name  AS employee,
    m.emp_name  AS manager
FROM employees e
         LEFT JOIN employees m
                   ON e.manager_id = m.emp_id
ORDER BY employee;

SELECT
    d.dept_name,
    AVG(e.salary) AS avg_salary
FROM departments d
         INNER JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
HAVING AVG(e.salary) > 50000;

SELECT d.dept_name, s.avg_salary
FROM departments d
         JOIN (
    SELECT e.dept_id, AVG(e.salary) AS avg_salary
    FROM employees e
    GROUP BY e.dept_id
) s ON s.dept_id = d.dept_id
WHERE s.avg_salary > 50000;
