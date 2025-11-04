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

SELECT emp_name, dept_name, location
FROM employees
         INNER JOIN departments USING (dept_id);

SELECT emp_name, dept_name, location
FROM employees
         NATURAL INNER JOIN departments;

SELECT e.emp_name, d.dept_name, p.project_name
FROM employees e
         INNER JOIN departments d ON e.dept_id = d.dept_id
         INNER JOIN projects p ON d.dept_id = p.dept_id;