CREATE INDEX emp_salary_idx ON employees(salary);
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'employees';

--2
CREATE INDEX emp_dept_idx ON employees(dept_id);
SELECT * FROM employees WHERE dept_id = 101;
SELECT
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;
