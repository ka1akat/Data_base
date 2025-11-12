--8.1
CREATE OR REPLACE VIEW dept_dashboard AS
SELECT
    d.dept_name,
    d.location,
    COUNT(e.emp_id)                           AS employee_count,
    ROUND(AVG(e.salary)::numeric, 2)          AS avg_salary,
    COUNT(p.project_id)                       AS active_projects,
    COALESCE(SUM(p.budget), 0)                AS total_project_budget,
    ROUND(
            COALESCE(SUM(p.budget), 0)
                / NULLIF(COUNT(e.emp_id), 0)::numeric
        , 2)                                      AS budget_per_employee
FROM departments d
         LEFT JOIN employees e ON e.dept_id = d.dept_id
         LEFT JOIN projects  p ON p.dept_id = d.dept_id
GROUP BY d.dept_name, d.location;
SELECT * FROM dept_dashboard ORDER BY employee_count DESC;

--8.2
ALTER TABLE projects
    ADD COLUMN IF NOT EXISTS created_date TIMESTAMP
        NOT NULL DEFAULT CURRENT_TIMESTAMP;
CREATE OR REPLACE VIEW high_budget_projects AS
SELECT
    p.project_name,
    p.budget,
    d.dept_name,
    p.created_date,
    CASE
        WHEN p.budget > 150000 THEN 'Critical Review Required'
        WHEN p.budget > 100000 THEN 'Management Approval Needed'
        ELSE 'Standard Process'
        END AS approval_status
FROM projects p
         LEFT JOIN departments d ON d.dept_id = p.dept_id
WHERE p.budget > 75000;

--8.3
CREATE ROLE viewer_role;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO viewer_role;
CREATE ROLE entry_role;
GRANT viewer_role TO entry_role;
GRANT INSERT ON employees, projects TO entry_role;
CREATE ROLE analyst_role;
GRANT entry_role TO analyst_role;
GRANT UPDATE ON employees, projects TO analyst_role;

CREATE USER alice   WITH PASSWORD 'alice123';
CREATE USER bob     WITH PASSWORD 'bob123';
CREATE USER charlie WITH PASSWORD 'charlie123';

GRANT viewer_role   TO alice;
GRANT analyst_role  TO bob;
GRANT manager_role  TO charlie;

