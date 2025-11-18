CREATE INDEX emp_salary_desc_idx ON employees(salary DESC);
SELECT emp_name, salary
FROM employees
ORDER BY salary DESC;

--Task 5.2
CREATE INDEX proj_budget_nulls_first_idx ON projects(budget NULLS FIRST);
SELECT proj_name, budget
FROM projects
ORDER BY budget NULLS FIRST;