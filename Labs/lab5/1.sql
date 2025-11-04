DROP TABLE IF EXISTS employees CASCADE;

CREATE TABLE employees (
                           employee_id INTEGER,
                           first_name TEXT,
                           last_name TEXT,
                           age INTEGER CHECK (age BETWEEN 18 AND 65),
                           salary NUMERIC CHECK (salary > 0)
);

INSERT INTO employees VALUES (1, 'John', 'Doe', 30, 2000);
INSERT INTO employees VALUES (2, 'Anna', 'Smith', 45, 3500);


-- Task 1.2: Named CHECK Constraint

DROP TABLE IF EXISTS products_catalog CASCADE;

CREATE TABLE products_catalog (
                                  product_id INTEGER,
                                  product_name TEXT,
                                  regular_price NUMERIC,
                                  discount_price NUMERIC,
                                  CONSTRAINT valid_discount CHECK (
                                      regular_price > 0
                                          AND discount_price > 0
                                          AND discount_price < regular_price
                                      )
);
INSERT INTO products_catalog VALUES (1, 'Laptop', 2000, 1500);
INSERT INTO products_catalog VALUES (2, 'Phone', 1000, 900);

-- Task 1.3: Multiple-Column CHECK

DROP TABLE IF EXISTS bookings CASCADE;

CREATE TABLE bookings (
                          booking_id INTEGER,
                          check_in_date DATE,
                          check_out_date DATE,
                          num_guests INTEGER,
                          CHECK (num_guests BETWEEN 1 AND 10),
                          CHECK (check_out_date > check_in_date)
);

INSERT INTO bookings VALUES (1, '2025-10-01', '2025-10-05', 2);
INSERT INTO bookings VALUES (2, '2025-10-10', '2025-10-15', 5);

