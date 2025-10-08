CREATE TABLE menu_items(
                            item_id            SERIAL PRIMARY KEY,
                            item_name          VARCHAR(100)      NOT NULL,
                            category           VARCHAR(50),
                            base_price         NUMERIC(10,2)     NOT NULL ,
                            is_available       BOOLEAN           NOT NULL DEFAULT true,
                            prep_time_minutes  INT
);
CREATE TABLE customer_orders(
                                 order_id       SERIAL PRIMARY KEY,
                                 customer_name  VARCHAR(100)      NOT NULL,
                                 order_date     DATE              NOT NULL,
                                 total_amount   NUMERIC(10,2),
                                 payment_status VARCHAR(20),
                                 table_number   INT
);
CREATE TABLE order_details(
                               detail_id            SERIAL PRIMARY KEY,
                               order_id             INT NOT NULL ,
                               item_id              INT NOT NULL ,
                               quantity             INT NOT NULL ,
                               special_instructions TEXT
);
INSERT INTO menu_items(item_name, category, base_price, is_available, prep_time_minutes)
VALUES ('Chef Special Burger', 'Main Course', 12.00 * 1.25, true, 20);

INSERT INTO customer_orders (customer_name, order_date, total_amount, payment_status, table_number)
VALUES
    ('John Smith',  CURRENT_DATE, 45.50, 'Paid',      5),
    ('Mary Johnson', CURRENT_DATE, 32.00, 'Pending',  8),
    ('Bob Wilson',   CURRENT_DATE, 28.75, 'Paid',     3);

INSERT INTO customer_orders(customer_name, order_date, total_amount, payment_status, table_number)
VALUES ('Walk-in Customer', CURRENT_DATE, DEFAULT, DEFAULT, NULL);

UPDATE menu_items
SET base_price = base_price*1.08
WHERE category = 'Appetizers';

UPDATE menu_items
SET category=CASE
                   WHEN base_price > 20            THEN 'Premium'
                   WHEN base_price BETWEEN 10 AND 20 THEN 'Standard'
                   ELSE 'Budget'
    END
    WHERE TRUE;

UPDATE customer_orders
SET total_amount   = total_amount * 0.90,
    payment_status = 'Discounted'
WHERE payment_status = 'Pending';

UPDATE menu_items
SET is_available = false
WHERE item_id IN (
    SELECT od.item_id
    FROM order_details od
    WHERE od.quantity > 10
);
DELETE FROM menu_items
WHERE is_available = false
  AND base_price < 5;

DELETE FROM customer_orders
WHERE order_date < DATE '2024-01-01'
  AND payment_status = 'Cancelled';

DELETE FROM order_details od
WHERE NOT EXISTS (
    SELECT 1
    FROM customer_orders co
    WHERE co.order_id = od.order_id
);

UPDATE menu_items
SET prep_time_minutes = NULL
WHERE category is NULL
RETURNING item_id, item_name;

INSERT INTO customer_orders ( customer_name, order_date , total_amount,payment_status, table_number)
VALUES ('New Customer', CURRENT_DATE, NULL, DEFAULT, NULL)
RETURNING  order_id, customer_name;




