
CREATE TABLE departments (
                             department_id SERIAL PRIMARY KEY,
                             department_name VARCHAR(100),
                             department_code CHAR(5),
                             building VARCHAR(50),
                             phone VARCHAR(15),
                             budget NUMERIC(15,2),
                             established_year INT
);

CREATE TABLE library_books (
                               book_id SERIAL PRIMARY KEY,
                               isbn CHAR(13),
                               title VARCHAR(200),
                               author VARCHAR(100),
                               publisher VARCHAR(100),
                               publication_date DATE,
                               price DECIMAL(10,2),
                               is_available BOOLEAN,
                               acquisition_timestamp TIMESTAMP
);

CREATE TABLE student_book_loans (
                                    loan_id SERIAL PRIMARY KEY,
                                    student_id INT,
                                    book_id INT,
                                    loan_date DATE,
                                    due_date DATE,
                                    return_date DATE,
                                    fine_amount DECIMAL(10,2),
                                    loan_status VARCHAR(20)
);
