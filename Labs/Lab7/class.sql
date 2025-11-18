--Part A
CREATE OR REPLACE VIEW employee_directory AS
SELECT
    e.emp_name,
    d.dept_name,
    d.location,
    e.salary,
    CASE
        WHEN e.salary > 55000 THEN 'High Earner'
        ELSE 'Standard'
        END AS status
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
ORDER BY d.dept_name, e.emp_name;
SELECT * FROM employee_directory ORDER BY dept_name;

CREATE OR REPLACE VIEW project_summary AS
SELECT
    p.project_name,
    p.budget,
    d.dept_name,
    d.location,
    CASE
        WHEN p.budget > 80000 THEN 'Large'
        WHEN p.budget > 50000 THEN 'Medium'
        ELSE 'Small'
        END AS project_size
FROM projects p
         LEFT JOIN departments d ON p.dept_id = d.dept_id;
SELECT * FROM project_summary WHERE project_size = 'Large';

--Part B
CREATE OR REPLACE VIEW employee_directory AS
SELECT
    e.emp_name,
    d.dept_name,
    d.location,
    e.salary,
    CASE
        WHEN e.salary > 55000 THEN 'High Earner'
        ELSE 'Standard'
        END AS status,
    CASE
        WHEN d.dept_name ILIKE '%IT%'
        OR d.dept_name ILIKE '%Development%' THEN 'Technical'
        ELSE 'Non-Technical'
    END AS dept_catagory
FROM employees e
JOIN departments d ON  e.dept_id = d.dept_id
ORDER BY d.dept_name, e.emp_name;

ALTER VIEW project_summary RENAME TO project_overview;
DROP VIEW project_overview;

--Part C
DROP MATERIALIZED VIEW IF EXISTS dept_summary;
CREATE MATERIALIZED VIEW dept_summary AS
SELECT
    d.dept_name
    COUNT(DISTINCT e.emp_id) AS employee_count,
    COUNT(DISTINCT p.project_id) AS project_count,
    COALESCE(SUM(p.budget), 0) AS total_project_budget
FROM departments d
LEFT JOIN employees e ON e.dept_id = d.dept_id
LEFT JOIN projects  p ON p.dept_id = d.dept_id
GROUP BY d.dept_name
WITH DATA;
SELECT * FROM dept_summary ORDER BY project_count DESC;

INSERT INTO projects (project_id, project_name, budget, dept_id)
VALUES (105, 'Security Audit', 45000, 103);
SELECT * FROM dept_summary WHERE dept_name = 'Finance';
REFRESH MATERIALIZED VIEW dept_summary;
SELECT * FROM dept_summary WHERE dept_name = 'Finance';

--Part D
DROP ROLE IF EXISTS viewer_role;
CREATE ROLE iewer_role NOLOGIN;
GRANT SELECT ON employee_directory TO viewer_role;
GRANT SELECT ON departments TO viewer_role;
DROP ROLE IF EXISTS editor_role;
CREATE ROLE editor_role NOLOGIN;
GRANT SELECT ON employees, departments, projects TO editor_role;
GRANT INSERT, UPDATE ON employees TO editor_role;

DROP ROLE IF EXISTS manager_role;
CREATE ROLE manager_role NOLOGIN;
GRANT editor_role TO manager_role;
GRANT DELETE ON employees TO manager_role;
GRANT UPDATE ON projects  TO manager_role;

DROP USER IF EXISTS alice_viewer;
DROP USER IF EXISTS bob_editor;
DROP USER IF EXISTS carol_manager;

CREATE USER alice_viewer WITH PASSWORD 'view123';
CREATE USER b0b_editor WITH PASSWORD 'edit456';
CREATE USER carol_manager WITH PASSWORD 'mgr789';

GRANT viewer_role  TO alice_viewer;
GRANT editor_role TO bob_editor;
GRANT manager_role TO carol_manager;

--Checking
SELECT rolname, rolcanlogin FROM pg_roles
WHERE rolname LIKE '%_role' OR rolname LIKE '%_viewer' OR rolname LIKE '%_editor' OR rolname LIKE '%_manager'
ORDER BY rolname;




