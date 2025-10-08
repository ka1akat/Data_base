CREATE TABLE menu_items (
                            item_id            SERIAL PRIMARY KEY,
                            item_name          VARCHAR(100)      NOT NULL,
                            category           VARCHAR(50),
                            base_price         NUMERIC(10,2)     NOT NULL CHECK (base_price >= 0),
                            is_available       BOOLEAN           NOT NULL DEFAULT true,
                            prep_time_minutes  INT                          CHECK (prep_time_minutes IS NULL OR prep_time_minutes >= 0)
);
CREATE TABLE customer_orders (
                                 order_id       SERIAL PRIMARY KEY,
                                 customer_name  VARCHAR(100)      NOT NULL,
                                 order_date     DATE              NOT NULL DEFAULT CURRENT_DATE,
                                 total_amount   NUMERIC(10,2),
                                 payment_status VARCHAR(20)       DEFAULT 'Pending'
                                     CHECK (payment_status IN ('Pending','Paid','Discounted','Cancelled')),
                                 table_number   INT
);
CREATE TABLE order_details (
                               detail_id            SERIAL PRIMARY KEY,
                               order_id             INT NOT NULL ,
                               item_id              INT NOT NULL ,
                               quantity             INT NOT NULL CHECK (quantity > 0),
                               special_instructions TEXT
);
CREATE INDEX IF NOT EXISTS idx_order_details_order_id ON order_details(order_id);
CREATE INDEX IF NOT EXISTS idx_order_details_item_id  ON order_details(item_id);

INSERT INTO menu_items (item_name, category, base_price, is_available, prep_time_minutes)
VALUES ('Chef Special Burger', 'Main Course', 12.00 * 1.25, true, 20);

INSERT INTO customer_orders (customer_name, order_date, total_amount, payment_status, table_number)
VALUES
    ('John Smith',  CURRENT_DATE, 45.50, 'Paid',      5),
    ('Mary Johnson', CURRENT_DATE, 32.00, 'Pending',  8),
    ('Bob Wilson',   CURRENT_DATE, 28.75, 'Paid',     3);

INSERT INTO customer_orders (customer_name, order_date, total_amount, payment_status, table_number)
VALUES ('Walk-in Customer', CURRENT_DATE, DEFAULT, DEFAULT, NULL);

UPDATE menu_items
SET base_price = base_price*1.08
WHERE category = 'Appetizers';

UPDATE menu_items
SET prep_time_minutes = NULL
WHERE category IS NULL
    RETURNING item_id, item_name;


INSERT INTO customer_orders (customer_name, order_date, total_amount, payment_status, table_number)
VALUES ('New Customer', CURRENT_DATE, NULL, DEFAULT, NULL)
    RETURNING order_id, customer_name;