DROP TABLE IF EXISTS restaurant_tables CASCADE;

CREATE TABLE restaurant_tables
(
    table_id         INT     NOT NULL PRIMARY KEY,
    table_number     INT     NOT NULL,
    seating_capacity INT     NOT NULL CHECK ( seating_capacity BETWEEN 2 and 12),
    location         TEXT    NOT NULL CHECK (location IN( 'indoor','outdoor','patio', 'private' )),
    is_available     BOOLEAN NOT NULL DEFAULT TRUE,
    notes            TEXT
);
INSERT INTO restaurant_tables VALUES
                                  (1, 1, 4, 'indoor', TRUE, 'Near window'),
                                  (2, 2, 6, 'outdoor', TRUE, 'Garden area'),
                                  (3, 3, 8, 'patio', FALSE, 'Reserved table'),
                                  (4, 4, 10, 'private', TRUE, 'VIP room');
--SHOULD FAIL
INSERT INTO restaurant_tables VALUES (5, 5, 15, 'indoor', TRUE, 'Too big');
INSERT INTO restaurant_tables VALUES (6,6,4,'rooftop',TRUE, 'Invalid location');
INSERT INTO restaurant_tables VALUES (7, 1, 4, 'indoor', TRUE, 'Duplicate number');
DROP TABLE IF EXISTS menu_items CASCADE;
CREATE TABLE menu_items(
    item_id INT PRIMARY KEY,
    item_name TEXT NOT NULL,
    category TEXT NOT NULL CHECK (category IN ('appetizer', 'main', 'dessert', 'beverage')),
    base_price NUMERIC NOT NULL CHECK (base_price BETWEEN 1 AND 200),
    special_price NUMERIC CHECK (special_price < base_price),
    is_available BOOLEAN NOT NULL DEFAULT TRUE,
    preparation_time INTEGER NOT NULL CHECK (preparation_time BETWEEN 5 AND 120),
    calories INTEGER CHECK (calories BETWEEN 0 AND 5000),
    CONSTRAINT unique_item_category UNIQUE (item_name, category)
);

INSERT INTO menu_items VALUES
         (1, 'Caesar Salad', 'appetizer', 25, 20, TRUE, 10, 200),
         (2, 'Grilled Salmon', 'main', 60, 50, TRUE, 25, 400),
         (3, 'Chocolate Cake', 'dessert', 30, 25, TRUE, 15, 500),
         (4, 'Lemonade', 'beverage', 15, 10, TRUE, 5, 150),
         (5, 'Steak', 'main', 80, 70, TRUE, 30, 700);

--Should fail
INSERT INTO menu_items VALUES (6, 'Soup', 'appetizer', 20, 25, TRUE, 10, 150);
INSERT INTO menu_items VALUES (7, 'Caesar Salad', 'appetizer', 30, 25, TRUE, 10, 250);

DROP TABLE IF EXISTS customers CASCADE;
CREATE TABLE customers(
    customer_id INTEGER PRIMARY KEY,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT UNIQUE,
    phone TEXT NOT NULL,
    loyalty_points   INTEGER NOT NULL DEFAULT 0 CHECK (loyalty_points >= 0),
    registration_date DATE NOT NULL DEFAULT CURRENT_DATE,
    date_of_birth    DATE,
    CHECK ( (email IS NOT NULL) OR (char_length(trim(phone)) > 0) )
);

INSERT INTO customers VALUES
    (1,'Anna','Kim','anna@ex.com','+7-700-111-11-11',10,'2025-10-01','2004-05-05'),
    (2,'John','Lee','john@ex.com','+7-700-222-22-22',0,DEFAULT,'2003-08-10'),
    (3,'Sara','Park',NULL,'+7-700-333-33-33',5,DEFAULT,'2002-12-01');

--Should fail
INSERT INTO customers VALUES (4,'Tom','Ray','tom@ex.com','+7-700-444-44-44',-1,DEFAULT,'2001-01-01');
INSERT INTO customers VALUES (5,'Kate','Moon','anna@ex.com','+7-700-555-55-55',0,DEFAULT,'2004-09-09');

DROP TABLE IF EXISTS orders CASCADE;

CREATE TABLE orders (
                        order_id       INTEGER PRIMARY KEY,
                        table_id       INTEGER NOT NULL REFERENCES restaurant_tables(table_id),
                        customer_id    INTEGER REFERENCES customers(customer_id) ON DELETE SET NULL,
                        order_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                        num_guests     INTEGER NOT NULL CHECK (num_guests BETWEEN 1 AND 20),
                        status         TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','preparing','ready','served','paid','cancelled')),
                        subtotal       NUMERIC NOT NULL DEFAULT 0 CHECK (subtotal >= 0),
                        tax            NUMERIC NOT NULL DEFAULT 0 CHECK (tax >= 0),
                        tip            NUMERIC          DEFAULT 0 CHECK (tip  >= 0),
                        total_amount   NUMERIC NOT NULL CHECK (total_amount >= 0),
                        CHECK (total_amount = subtotal + tax + tip)
);
INSERT INTO orders (order_id, table_id, customer_id, num_guests, status, subtotal, tax, tip, total_amount) VALUES
                                                                                  (1, 1, 1, 2, 'pending',   120, 12, 8, 140),
                                                                                  (2, 2, 2, 4, 'preparing', 200, 20, 0, 220),
                                                                                  (3,3,3,1,'ready',25,2,3,30);

--Should fail
INSERT INTO orders (order_id, table_id, customer_id,num_guests, status, subtotal, tax, tip, total_amount) VALUES
                    (1,1,1,2)














