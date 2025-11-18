CREATE INDEX emp_dept_salary_idx ON employees(dept_id, salary);
SELECT emp_name, salary
FROM employees
WHERE dept_id = 101 AND salary > 52000;

--3.2
CREATE INDEX emp_salary_dept_idx ON employees(salary, dept_id);
SELECT * FROM employees WHERE dept_id = 102 AND salary > 50000;
SELECT * FROM employees WHERE salary > 50000 AND dept_id = 102;

