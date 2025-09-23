DROP TABLESPACE IF EXISTS student_data;
CREATE TABLESPACE student_data
    LOCATION '/Users/karakatzaslan/postgres_tables/students';

DROP TABLESPACE IF EXISTS course_data;
CREATE TABLESPACE course_data
    OWNER karakatzaslan
    LOCATION '/Users/karakatzaslan/postgres_tables/courses';

DROP DATABASE IF EXISTS university_distributed;
CREATE DATABASE university_distributed
    WITH OWNER = karakatzaslan
    TABLESPACE = student_data
    TEMPLATE = template0
    ENCODING = 'LATIN9';

