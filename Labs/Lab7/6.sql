--1
CREATE ROLE analyst NOLOGIN;

--2
CREATE ROLE data_viewer LOGIN PASSWORD 'viewer123';

--3
CREATE USER report_user WITH PASSWORD 'report456';
SELECT rolname FROM pg_roles WHERE rolname NOT LIKE 'pg_%';
CREATE ROLE db_creator LOGIN CREATEDB PASSWORD 'creator789';
CREATE ROLE user_manager LOGIN CREATEROLE PASSWORD 'manager101';
CREATE ROLE admin_user LOGIN SUPERUSER PASSWORD 'admin999';
--6.3
GRANT SELECT ON employees, departments, projects TO analyst;

GRANT ALL PRIVILEGES ON employee_details TO data_viewer;

GRANT SELECT, INSERT ON employees TO report_user;

--6.4
-- 1. Group roles
CREATE ROLE hr_team;
CREATE ROLE finance_team;
CREATE ROLE it_team;

-- 2. Individual users
CREATE USER hr_user1 WITH PASSWORD 'hr001';
CREATE USER hr_user2 WITH PASSWORD 'hr002';
CREATE USER finance_user1 WITH PASSWORD 'fin001';

-- 3. Assign users to teams
GRANT hr_team TO hr_user1, hr_user2;
GRANT finance_team TO finance_user1;

-- 4. Grant privileges
GRANT SELECT, UPDATE ON employees TO hr_team;
GRANT SELECT ON dept_statistics TO finance_team;

--6.5
REVOKE UPDATE ON employees FROM hr_team;
REVOKE hr_team FROM hr_user2;
REVOKE ALL PRIVILEGES ON employee_details FROM data_viewer;
ALTER ROLE analyst LOGIN PASSWORD 'analyst123';
ALTER ROLE user_manager SUPERUSER;
ALTER ROLE analyst PASSWORD NULL;
ALTER ROLE data_viewer CONNECTION LIMIT 5;



