
DROP TABLE IF EXISTS order_details CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS customers CASCADE;

CREATE TABLE customers (
                           customer_id        INTEGER PRIMARY KEY,
                           name               TEXT     NOT NULL,
                           email              TEXT     NOT NULL UNIQUE,
                           phone              TEXT,
                           registration_date  DATE     NOT NULL
);

CREATE TABLE products (
                          product_id     INTEGER PRIMARY KEY,
                          name           TEXT    NOT NULL,
                          description    TEXT,
                          price          NUMERIC NOT NULL CHECK (price >= 0),
                          stock_quantity INTEGER NOT NULL CHECK (stock_quantity >= 0)
);

CREATE TABLE orders (
                        order_id     INTEGER PRIMARY KEY,
                        customer_id  INTEGER NOT NULL REFERENCES customers(customer_id) ON DELETE RESTRICT,
                        order_date   DATE    NOT NULL,
                        total_amount NUMERIC NOT NULL CHECK (total_amount >= 0),
                        status       TEXT    NOT NULL CHECK (status IN ('pending','processing','shipped','delivered','cancelled'))
);

CREATE TABLE order_details (
                               order_detail_id INTEGER PRIMARY KEY,
                               order_id        INTEGER REFERENCES orders(order_id)    ON DELETE CASCADE,
                               product_id      INTEGER REFERENCES products(product_id) ON DELETE RESTRICT,
                               quantity        INTEGER NOT NULL CHECK (quantity > 0),
                               unit_price      NUMERIC NOT NULL CHECK (unit_price >= 0)
);

-- Sample data (≥5 rows per table)
INSERT INTO customers VALUES
                          (1,'Anna','anna@example.com','+7-700-111-11-11','2025-01-10'),
                          (2,'John','john@example.com','+7-700-222-22-22','2025-02-05'),
                          (3,'Sara','sara@example.com',NULL,'2025-03-01'),
                          (4,'Tom','tom@example.com','+7-700-333-33-33','2025-03-15'),
                          (5,'Kate','kate@example.com','+7-700-444-44-44','2025-04-01');

INSERT INTO products VALUES
                         (1,'Phone','Smartphone',     1200, 30),
                         (2,'Laptop','15-inch laptop', 2200, 15),
                         (3,'Headset','BT headset',     80, 100),
                         (4,'Mouse','Wireless mouse',   25, 200),
                         (5,'Charger','USB-C charger',  18, 300);

INSERT INTO orders VALUES
                       (1,1,'2025-05-01', 1225,'pending'),
                       (2,2,'2025-05-03', 2280,'processing'),
                       (3,3,'2025-05-05',  105,'shipped'),
                       (4,1,'2025-05-08',  225,'delivered'),
                       (5,4,'2025-05-10', 2400,'pending');

INSERT INTO order_details VALUES
                              (1,1,1,1,1200),
                              (2,1,4,1,  25),
                              (3,2,2,1,2200),
                              (4,3,3,1,  80),
                              (5,4,4,3,  25);
