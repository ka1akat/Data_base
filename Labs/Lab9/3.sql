DROP TABLE IF EXISTS accounts CASCADE;
DROP TABLE IF EXISTS products CASCADE;
CREATE TABLE accounts (
                          id SERIAL PRIMARY KEY,
                          name VARCHAR(100) NOT NULL,
                          balance DECIMAL(10, 2) DEFAULT 0.00
);
CREATE TABLE products (
                          id SERIAL PRIMARY KEY,
                          shop VARCHAR(100) NOT NULL,
                          product VARCHAR(100) NOT NULL,
                          price DECIMAL(10, 2) NOT NULL
);
-- Insert test data
INSERT INTO accounts (name, balance) VALUES
                                         ('Alice', 1000.00),
                                         ('Bob', 500.00),
                                         ('Wally', 750.00);
INSERT INTO products (shop, product, price) VALUES
                                                ('Joe''s Shop', 'Coke', 2.50),
                                                ('Joe''s Shop', 'Pepsi', 3.00);
--Task 3.2
BEGIN;
UPDATE accounts SET balance = balance - 100.00
WHERE name = 'Alice';
UPDATE accounts SET balance = balance + 100.00
WHERE name = 'Bob';
COMMIT;
SELECT name, balance FROM accounts;
--Task 3.3
BEGIN;
UPDATE accounts SET balance = balance - 500.00
WHERE name = 'Alice';
SELECT * FROM accounts WHERE name = 'Alice';
ROLLBACK;
SELECT * FROM accounts WHERE name = 'Alice';
--Task 3.4
BEGIN;
UPDATE accounts
SET balance = balance - 100.00
WHERE name = 'Alice';

SAVEPOINT my_savepoint;

UPDATE accounts
SET balance = balance + 100.00
WHERE name = 'Bob';
ROLLBACK TO my_savepoint;
UPDATE accounts
SET balance = balance + 100.00
WHERE name = 'Wally';

COMMIT;

SELECT id, name, balance
FROM accounts
ORDER BY id;

--Task 3.5
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT * FROM products WHERE shop='Joe''s Shop';

BEGIN;
DELETE FROM products WHERE shop='Joe''s Shop';
INSERT INTO products VALUES ('Joe''s Shop', 'Fanta', 3.50);
COMMIT;




