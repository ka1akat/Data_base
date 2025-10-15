
-- Task 2.1: NOT NULL Implementation

DROP TABLE IF EXISTS customers CASCADE;

CREATE TABLE customers (
                           customer_id      INTEGER       NOT NULL,
                           email            TEXT          NOT NULL,
                           phone            TEXT,                 -- может быть NULL
                           registration_date DATE         NOT NULL
);

INSERT INTO customers VALUES
                          (1, 'anna@example.com',  '+7-777-111-22-33', '2025-10-01'),
                          (2, 'john@example.com',  NULL,              '2025-10-10');
-- Task 2.2: Combining Constraints

DROP TABLE IF EXISTS inventory CASCADE;

CREATE TABLE inventory (
                           item_id      INTEGER    NOT NULL,
                           item_name    TEXT       NOT NULL,
                           quantity     INTEGER    NOT NULL CHECK (quantity >= 0),
                           unit_price   NUMERIC    NOT NULL CHECK (unit_price > 0),
                           last_updated TIMESTAMP  NOT NULL
);

INSERT INTO inventory VALUES
                          (101, 'USB Cable',  50,  3.99,  NOW()),
                          (102, 'Keyboard',   10, 25.50,  NOW());



