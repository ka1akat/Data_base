ALTER INDEX emp_salary_idx RENAME TO employees_salary_index;
SELECT indexname FROM pg_indexes WHERE tablename = 'employees';

--7.2
DROP INDEX emp_salary_dept_idx;
--task 8
SELECT e.emp_name, e.salary, d.dept_name
FROM employees e
         JOIN departments d ON e.dept_id = d.dept_id
WHERE e.salary > 50000
ORDER BY e.salary DESC;
CREATE INDEX emp_salary_filter_idx ON employees(salary) WHERE salary > 50000;

--8.2
CREATE INDEX proj_high_budget_idx ON projects(budget)
    WHERE budget > 80000;
SELECT proj_name, budget
FROM projects
WHERE budget > 80000;

--8.3
EXPLAIN SELECT * FROM employees WHERE salary > 52000;
