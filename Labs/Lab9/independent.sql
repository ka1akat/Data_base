--Task 1
DO $$
DECLARE
bob_balance NUMERIC(10,2);
BEGIN
SELECT balance
INTO bob_balance
FROM accounts
WHERE name = 'Bob'
    FOR UPDATE;

IF bob_balance < 200 THEN
        RAISE EXCEPTION 'Insufficient funds: Bob has only %', bob_balance;
END IF;
UPDATE accounts
SET balance = balance - 200
WHERE name = 'Bob';

UPDATE accounts
SET balance = balance + 200
WHERE name = 'Wally';
END $$;
SELECT name, balance FROM accounts ORDER BY id;

--Task 2
BEGIN;
INSERT INTO products (shop, product, price)
VALUES ('Joe''s Shop', '7up', 3.20);

SAVEPOINT sp_insert;
UPDATE products
SET price = 4.00
WHERE shop = 'Joe''s Shop'
  AND product = '7up';

SAVEPOINT sp_update;

DELETE FROM products
WHERE shop = 'Joe''s Shop'
  AND product = '7up';

ROLLBACK TO sp_insert;
COMMIT;
SELECT * FROM products
WHERE shop = 'Joe''s Shop'
  AND product = '7up';
