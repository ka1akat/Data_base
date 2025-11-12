CREATE MATERIALIZED VIEW dept_summary_mv AS
SELECT
    d.dept_id,
    d.dept_name,
    COUNT(DISTINCT e.emp_id) AS total_employees,
    COALESCE(SUM(e.salary), 0) AS total_salaries,
    COUNT(DISTINCT p.project_id) AS total_projects,
    COALESCE(SUM(p.budget), 0) AS total_project_budget
FROM departments d
         LEFT JOIN employees e ON d.dept_id = e.dept_id
         LEFT JOIN projects p ON d.dept_id = p.dept_id
GROUP BY d.dept_id, d.dept_name
    WITH DATA;
SELECT *
FROM dept_summary_mv
ORDER BY total_employees DESC;

--5.2
INSERT INTO employees (emp_id, emp_name, dept_id, salary)
VALUES (8, 'Charlie Brown', 101, 54000);
SELECT * FROM dept_summary_mv;
REFRESH MATERIALIZED VIEW dept_summary_mv;
SELECT * FROM dept_summary_mv;

--5.3
CREATE UNIQUE INDEX idx_dept_summary_mv ON dept_summary_mv (dept_id);

REFRESH MATERIALIZED VIEW CONCURRENTLY dept_summary_mv;
