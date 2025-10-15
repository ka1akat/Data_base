DROP TABLE IF EXISTS employees_dept CASCADE;
DROP TABLE IF EXISTS departments CASCADE;

CREATE TABLE departments (
                             dept_id INTEGER PRIMARY KEY,
                             dept_name TEXT NOT NULL,
                             location TEXT
);

INSERT INTO departments VALUES
                            (1, 'Computer Science', 'Building A'),
                            (2, 'Mathematics', 'Building B'),
                            (3, 'Physics', 'Building C');


CREATE TABLE employees_dept (
                                emp_id INTEGER PRIMARY KEY,
                                emp_name TEXT NOT NULL,
                                dept_id INTEGER REFERENCES departments(dept_id),
                                hire_date DATE
);

INSERT INTO employees_dept VALUES
                               (1, 'Alice', 1, '2025-01-10'),
                               (2, 'Bob', 2, '2025-03-15'),
                               (3, 'Charlie', 3, '2025-05-20');


DROP TABLE IF EXISTS books CASCADE;
DROP TABLE IF EXISTS authors CASCADE;
DROP TABLE IF EXISTS publishers CASCADE;

CREATE TABLE authors (
                         author_id INTEGER PRIMARY KEY,
                         author_name TEXT NOT NULL,
                         country TEXT
);

CREATE TABLE publishers (
                            publisher_id INTEGER PRIMARY KEY,
                            publisher_name TEXT NOT NULL,
                            city TEXT
);

CREATE TABLE books (
                       book_id INTEGER PRIMARY KEY,
                       title TEXT NOT NULL,
                       author_id INTEGER REFERENCES authors(author_id),
                       publisher_id INTEGER REFERENCES publishers(publisher_id),
                       publication_year INTEGER,
                       isbn TEXT UNIQUE
);

INSERT INTO authors VALUES
                        (1, 'George Orwell', 'UK'),
                        (2, 'J.K. Rowling', 'UK'),
                        (3, 'Ernest Hemingway', 'USA');

INSERT INTO publishers VALUES
                           (1, 'Penguin Books', 'London'),
                           (2, 'HarperCollins', 'New York');

INSERT INTO books VALUES
                      (1, '1984', 1, 1, 1949, '9780451524935'),
                      (2, 'Harry Potter', 2, 1, 1997, '9780747532743'),
                      (3, 'The Old Man and the Sea', 3, 2, 1952, '9780684801223');


DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS products_fk CASCADE;
DROP TABLE IF EXISTS categories CASCADE;

CREATE TABLE categories (
                            category_id INTEGER PRIMARY KEY,
                            category_name TEXT NOT NULL
);

CREATE TABLE products_fk (
                             product_id INTEGER PRIMARY KEY,
                             product_name TEXT NOT NULL,
                             category_id INTEGER REFERENCES categories(category_id) ON DELETE RESTRICT
);

CREATE TABLE orders (
                        order_id INTEGER PRIMARY KEY,
                        order_date DATE NOT NULL
);

CREATE TABLE order_items (
                             item_id INTEGER PRIMARY KEY,
                             order_id INTEGER REFERENCES orders(order_id) ON DELETE CASCADE,
                             product_id INTEGER REFERENCES products_fk(product_id),
                             quantity INTEGER CHECK (quantity > 0)
);

INSERT INTO categories VALUES
                           (1, 'Electronics'),
                           (2, 'Books');

INSERT INTO products_fk VALUES
                            (1, 'Smartphone', 1),
                            (2, 'Laptop', 1),
                            (3, 'Novel', 2);

INSERT INTO orders VALUES
                       (1, '2025-09-01'),
                       (2, '2025-09-02');

INSERT INTO order_items VALUES
                            (1, 1, 1, 2),
                            (2, 1, 2, 1),
                            (3, 2, 3, 4);
