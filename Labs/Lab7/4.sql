CREATE VIEW employee_salaries AS
SELECT
    emp_id,
    emp_name,
    dept_id,
    salary
FROM employees;

--4.2
UPDATE employee_salaries
SET salary = 52000
WHERE emp_name = 'John Smith';
SELECT * FROM employees WHERE emp_name = 'John Smith';
--4.3
INSERT INTO employee_salaries (emp_id, emp_name, dept_id, salary)
VALUES (6, 'Alice Johnson', 102, 58000);
SELECT * FROM employees;
--4.4
CREATE VIEW it_employees AS
SELECT
    emp_id,
    emp_name,
    dept_id,
    salary
FROM employees
WHERE dept_id = 101
        WITH LOCAL CHECK OPTION;




