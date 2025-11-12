CREATE OR REPLACE VIEW employee_details AS
SELECT
    e.emp_name,
    e.salary,
    d.dept_name,
    d.location,
    CASE
        WHEN e.salary > 60000 THEN 'High'
        WHEN e.salary > 50000 THEN 'Medium'
        ELSE 'Standard'
        END AS salary_grade
FROM employees e
         JOIN departments d
              ON e.dept_id = d.dept_id;

SELECT * FROM employee_details;
