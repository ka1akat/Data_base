--7.1
CREATE ROLE read_only;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO read_only;

CREATE ROLE junior_analyst LOGIN PASSWORD 'junior123';
CREATE ROLE senior_analyst LOGIN PASSWORD 'senior123';

GRANT read_only TO junior_analyst;
GRANT read_only TO senior_analyst;

GRANT INSERT, UPDATE ON employees TO senior_analyst;

--7.2
CREATE ROLE project_manager LOGIN PASSWORD 'pm123';

ALTER VIEW dept_statistics OWNER TO project_manager;

ALTER TABLE projects OWNER TO project_manager;
SELECT tablename, tableowner
FROM pg_tables
WHERE schemaname = 'public';

--7.3
CREATE ROLE temp_owner LOGIN;

CREATE TABLE temp_table (id INT);
ALTER TABLE temp_table OWNER TO temp_owner;

REASSIGN OWNED BY temp_owner TO postgres;

DROP OWNED BY temp_owner;

DROP ROLE temp_owner;

--7.4
CREATE VIEW hr_employee_view AS
SELECT *
FROM employees
WHERE dept_id = 102;

GRANT SELECT ON hr_employee_view TO hr_team;


CREATE VIEW finance_employee_view AS
SELECT emp_id, emp_name, salary
FROM employees;

GRANT SELECT ON finance_employee_view TO finance_team;






