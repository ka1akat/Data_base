--Task 3
ANALYZE;

--1) Composite B-tree index
CREATE INDEX IF NOT EXISTS idx_txn_from_created
    ON transactions (from_account_id, created_at DESC);

--2) Covering index
CREATE INDEX IF NOT EXISTS idx_txn_from_created_cover
    ON transactions (from_account_id, created_at DESC)
    INCLUDE (status, type, amount_kzt, to_account_id);

--3) Partial index:
CREATE INDEX IF NOT EXISTS idx_accounts_active_customer
    ON accounts (customer_id, currency)
    WHERE is_active = TRUE;

--4) Expression index:
CREATE INDEX IF NOT EXISTS idx_customers_email_lower
    ON customers (lower(email));

--5) Hash index:
CREATE INDEX IF NOT EXISTS idx_customers_phone_hash
    ON customers USING HASH (phone);

--6) GIN index on audit_log JSONB columns
CREATE INDEX IF NOT EXISTS idx_audit_old_values_gin
    ON audit_log USING GIN (old_values);

CREATE INDEX IF NOT EXISTS idx_audit_new_values_gin
    ON audit_log USING GIN (new_values);

--
CREATE INDEX IF NOT EXISTS idx_rates_lookup
    ON exchange_rates(from_currency, to_currency, valid_from, valid_to);
ANALYZE;

--Q1) Most common:
EXPLAIN (ANALYZE, BUFFERS)
SELECT transaction_id, created_at, status, type, amount_kzt, to_account_id
FROM transactions
WHERE from_account_id = 1
  AND created_at >= now() - interval '30 days'
ORDER BY created_at DESC
    LIMIT 50;

--Q2) Active accounts only
EXPLAIN (ANALYZE, BUFFERS)
SELECT account_id, account_number, currency, balance
FROM accounts
WHERE customer_id = 1
  AND is_active = TRUE;

--Q3) Case-insensitive email search
EXPLAIN (ANALYZE, BUFFERS)
SELECT customer_id, full_name
FROM customers
WHERE lower(email) = lower('aruzhan1@mail.com');

--Q4) JSONB search on audit_log (uses GIN)
EXPLAIN (ANALYZE, BUFFERS)
SELECT log_id, table_name, action, changed_at
FROM audit_log
WHERE new_values @> '{"status":"completed"}'::jsonb
ORDER BY changed_at DESC
    LIMIT 50;

--Q5)Equality lookup
EXPLAIN (ANALYZE, BUFFERS)
SELECT customer_id, full_name
FROM customers
WHERE phone = '+7-701-111-0001';

/*
Index strategy justification:
1) idx_txn_from_created (B-tree composite) speeds up filtering by from_account_id and sorting by created_at.
2) idx_txn_from_created_cover (covering) allows Index Only Scan for transaction history (status/type/amount_kzt/to_account_id needed often).
3) idx_accounts_active_customer (partial) optimizes queries that only work with active accounts, smaller index => faster.
4) idx_customers_email_lower (expression) supports case-insensitive email lookups without Seq Scan.
5) idx_customers_phone_hash (hash) demonstrates fast equality lookup on phone (task requirement for HASH index type).
6) idx_audit_*_gin (GIN) accelerates JSONB containment queries on audit_log columns.
*/
