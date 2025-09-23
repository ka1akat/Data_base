CREATE DATABASE university_main
    WITH OWNER = karakatzaslan
    TEMPLATE = template0
    ENCODING = 'UTF8';

CREATE DATABASE university_archive
    WITH OWNER = karakatzaslan
    TEMPLATE = template0
    CONNECTION LIMIT = 50;

CREATE DATABASE university_test
    WITH OWNER = karakatzaslan
    CONNECTION LIMIT = 10
    IS_TEMPLATE = true;


