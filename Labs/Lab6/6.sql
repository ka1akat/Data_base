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

SELECT e.emp_name,
       e.dept_id AS emp_dept,
       d.dept_id AS dept_dept,
       d.dept_name
FROM employees e
         FULL JOIN departments d
                   ON e.dept_id = d.dept_id;

SELECT d.dept_name,
       p.project_name,
       p.budget
FROM departments d
         FULL JOIN projects p
                   ON d.dept_id = p.dept_id;

SELECT
    CASE
        WHEN e.emp_id IS NULL THEN 'Department without employees'
        WHEN d.dept_id IS NULL THEN 'Employee without department'
        ELSE 'Matched'
        END AS record_status,
    e.emp_name,
    d.dept_name
FROM employees e
         FULL JOIN departments d
                   ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL
   OR d.dept_id IS NULL;


