--TASK1
CREATE OR REPLACE PROCEDURE process_transfer(
    IN  p_from_account_number TEXT,
    IN  p_to_account_number   TEXT,
    IN  p_amount              NUMERIC,
    IN  p_currency            TEXT,
    IN  p_description         TEXT,
    OUT o_code                TEXT,
    OUT o_message             TEXT,
    OUT o_transaction_id      BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
v_from_acc_id     BIGINT;
    v_to_acc_id       BIGINT;
    v_from_currency   TEXT;
    v_to_currency     TEXT;
    v_from_balance    NUMERIC;
    v_to_balance      NUMERIC;
    v_from_active     BOOLEAN;
    v_to_active       BOOLEAN;
    v_customer_id     BIGINT;
    v_customer_status TEXT;
    v_daily_limit_kzt NUMERIC;
    v_rate_to_from    NUMERIC;  -- rate p_currency -> from_currency
    v_rate_to_to      NUMERIC;  -- rate p_currency -> to_currency
    v_rate_to_kzt     NUMERIC;  -- rate p_currency -> KZT
    v_debit_amount    NUMERIC;  -- сколько списать с from (в валюте from)
    v_credit_amount   NUMERIC;  -- сколько начислить to (в валюте to)
    v_amount_kzt      NUMERIC;  -- сумма операции в KZT (для лимита)
    v_today_sum_kzt   NUMERIC;
    v_now             TIMESTAMptz := now();
    v_txn_id          BIGINT;

BEGIN
    o_code := 'OK';
    o_message := 'Transfer completed';
    o_transaction_id := NULL;

    IF p_amount IS NULL OR p_amount <= 0 THEN
        o_code := 'E000';
        o_message := 'Amount must be > 0';
INSERT INTO audit_log(table_name, record_id, action, old_values, new_values, changed_by, changed_at, ip_address)
VALUES ('process_transfer', 'N/A', 'INSERT', NULL,
        jsonb_build_object('code',o_code,'msg',o_message,'from',p_from_account_number,'to',p_to_account_number,'amount',p_amount,'currency',p_currency,'desc',p_description),
        current_user, v_now, inet_client_addr());
RETURN;
END IF;

SELECT a.account_id, a.currency, a.balance, a.is_active, a.customer_id
INTO v_from_acc_id, v_from_currency, v_from_balance, v_from_active, v_customer_id
FROM accounts a
WHERE a.account_number = p_from_account_number;

IF v_from_acc_id IS NULL THEN
        o_code := 'E001';
        o_message := 'Source account not found';
INSERT INTO audit_log(table_name, record_id, action, old_values, new_values, changed_by, changed_at, ip_address)
VALUES ('process_transfer', 'N/A', 'INSERT', NULL,
        jsonb_build_object('code',o_code,'msg',o_message,'from',p_from_account_number,'to',p_to_account_number,'amount',p_amount,'currency',p_currency),
        current_user, v_now, inet_client_addr());
RETURN;
END IF;

SELECT a.account_id, a.currency, a.balance, a.is_active
INTO v_to_acc_id, v_to_currency, v_to_balance, v_to_active
FROM accounts a
WHERE a.account_number = p_to_account_number;

IF v_to_acc_id IS NULL THEN
        o_code := 'E002';
        o_message := 'Destination account not found';
INSERT INTO audit_log(table_name, record_id, action, old_values, new_values, changed_by, changed_at, ip_address)
VALUES ('process_transfer', 'N/A', 'INSERT', NULL,
        jsonb_build_object('code',o_code,'msg',o_message,'from',p_from_account_number,'to',p_to_account_number,'amount',p_amount,'currency',p_currency),
        current_user, v_now, inet_client_addr());
RETURN;
END IF;

    IF v_from_active IS NOT TRUE THEN
        o_code := 'E003';
        o_message := 'Source account is not active';
INSERT INTO audit_log(table_name, record_id, action, old_values, new_values, changed_by, changed_at, ip_address)
VALUES ('process_transfer', v_from_acc_id::text, 'INSERT', NULL,
        jsonb_build_object('code',o_code,'msg',o_message,'from_acc_id',v_from_acc_id),
        current_user, v_now, inet_client_addr());
RETURN;
END IF;

    IF v_to_active IS NOT TRUE THEN
        o_code := 'E004';
        o_message := 'Destination account is not active';
INSERT INTO audit_log(table_name, record_id, action, old_values, new_values, changed_by, changed_at, ip_address)
VALUES ('process_transfer', v_to_acc_id::text, 'INSERT', NULL,
        jsonb_build_object('code',o_code,'msg',o_message,'to_acc_id',v_to_acc_id),
        current_user, v_now, inet_client_addr());
RETURN;
END IF;

-- 2)
SELECT c.status, c.daily_limit_kzt
INTO v_customer_status, v_daily_limit_kzt
FROM customers c
WHERE c.customer_id = v_customer_id;

IF v_customer_status IS DISTINCT FROM 'active' THEN
        o_code := 'E005';
        o_message := 'Sender customer status is not active';
INSERT INTO audit_log(table_name, record_id, action, old_values, new_values, changed_by, changed_at, ip_address)
VALUES ('process_transfer', v_customer_id::text, 'INSERT', NULL,
        jsonb_build_object('code',o_code,'msg',o_message,'customer_id',v_customer_id,'status',v_customer_status),
        current_user, v_now, inet_client_addr());
RETURN;
END IF;

-- 3)
    IF v_from_acc_id < v_to_acc_id THEN
        PERFORM 1 FROM accounts WHERE account_id = v_from_acc_id FOR UPDATE;
PERFORM 1 FROM accounts WHERE account_id = v_to_acc_id   FOR UPDATE;
ELSE
        PERFORM 1 FROM accounts WHERE account_id = v_to_acc_id   FOR UPDATE;
PERFORM 1 FROM accounts WHERE account_id = v_from_acc_id FOR UPDATE;
END IF;

SELECT balance INTO v_from_balance FROM accounts WHERE account_id = v_from_acc_id;
SELECT balance INTO v_to_balance   FROM accounts WHERE account_id = v_to_acc_id;

-- 4)
IF p_currency = v_from_currency THEN
        v_rate_to_from := 1;
ELSE
SELECT r.rate INTO v_rate_to_from
FROM exchange_rates r
WHERE r.from_currency = p_currency
  AND r.to_currency   = v_from_currency
  AND v_now >= r.valid_from
  AND v_now <  r.valid_to
ORDER BY r.valid_from DESC
    LIMIT 1;

IF v_rate_to_from IS NULL THEN
            o_code := 'E006';
            o_message := 'Exchange rate not found for amount currency -> source currency';
INSERT INTO audit_log(table_name, record_id, action, old_values, new_values, changed_by, changed_at, ip_address)
VALUES ('process_transfer', 'N/A', 'INSERT', NULL,
        jsonb_build_object('code',o_code,'msg',o_message,'from_cur',p_currency,'to_cur',v_from_currency),
        current_user, v_now, inet_client_addr());
RETURN;
END IF;
END IF;

    IF p_currency = v_to_currency THEN
        v_rate_to_to := 1;
ELSE
SELECT r.rate INTO v_rate_to_to
FROM exchange_rates r
WHERE r.from_currency = p_currency
  AND r.to_currency   = v_to_currency
  AND v_now >= r.valid_from
  AND v_now <  r.valid_to
ORDER BY r.valid_from DESC
    LIMIT 1;

IF v_rate_to_to IS NULL THEN
            o_code := 'E007';
            o_message := 'Exchange rate not found for amount currency -> destination currency';
INSERT INTO audit_log(table_name, record_id, action, old_values, new_values, changed_by, changed_at, ip_address)
VALUES ('process_transfer', 'N/A', 'INSERT', NULL,
        jsonb_build_object('code',o_code,'msg',o_message,'from_cur',p_currency,'to_cur',v_to_currency),
        current_user, v_now, inet_client_addr());
RETURN;
END IF;
END IF;

    IF p_currency = 'KZT' THEN
        v_rate_to_kzt := 1;
ELSE
SELECT r.rate INTO v_rate_to_kzt
FROM exchange_rates r
WHERE r.from_currency = p_currency
  AND r.to_currency   = 'KZT'
  AND v_now >= r.valid_from
  AND v_now <  r.valid_to
ORDER BY r.valid_from DESC
    LIMIT 1;

IF v_rate_to_kzt IS NULL THEN
            o_code := 'E008';
            o_message := 'Exchange rate not found for amount currency -> KZT';
INSERT INTO audit_log(table_name, record_id, action, old_values, new_values, changed_by, changed_at, ip_address)
VALUES ('process_transfer', 'N/A', 'INSERT', NULL,
        jsonb_build_object('code',o_code,'msg',o_message,'from_cur',p_currency,'to_cur','KZT'),
        current_user, v_now, inet_client_addr());
RETURN;
END IF;
END IF;

    v_debit_amount  := round(p_amount * v_rate_to_from, 2);
    v_credit_amount := round(p_amount * v_rate_to_to, 2);
    v_amount_kzt     := round(p_amount * v_rate_to_kzt, 2);

-- 5)
    IF v_from_balance < v_debit_amount THEN
        o_code := 'E009';
        o_message := 'Insufficient funds';
        -- можем логировать попытку + создадим failed transaction (уже есть account ids)
INSERT INTO transactions(from_account_id, to_account_id, amount, currency, exchange_rate, amount_kzt, type, status, created_at, completed_at, description)
VALUES (v_from_acc_id, v_to_acc_id, p_amount, p_currency, v_rate_to_kzt, v_amount_kzt, 'transfer', 'failed', v_now, v_now,
        COALESCE(p_description,'') || ' | FAIL: insufficient funds');
GET DIAGNOSTICS v_txn_id = RESULT_OID; -- может быть NULL в PG, поэтому отдельно:
SELECT currval(pg_get_serial_sequence('transactions','transaction_id')) INTO v_txn_id;
o_transaction_id := v_txn_id;

INSERT INTO audit_log(table_name, record_id, action, old_values, new_values, changed_by, changed_at, ip_address)
VALUES ('transactions', v_txn_id::text, 'INSERT', NULL,
        jsonb_build_object('code',o_code,'msg',o_message,'debit',v_debit_amount,'balance',v_from_balance),
        current_user, v_now, inet_client_addr());
RETURN;
END IF;

-- 6)
SELECT COALESCE(SUM(t.amount_kzt), 0)
INTO v_today_sum_kzt
FROM transactions t
         JOIN accounts a ON a.account_id = t.from_account_id
WHERE a.customer_id = v_customer_id
  AND t.type = 'transfer'
  AND t.status = 'completed'
  AND t.created_at::date = CURRENT_DATE;

IF v_today_sum_kzt + v_amount_kzt > v_daily_limit_kzt THEN
        o_code := 'E010';
        o_message := 'Daily limit exceeded';

INSERT INTO transactions(from_account_id, to_account_id, amount, currency, exchange_rate, amount_kzt, type, status, created_at, completed_at, description)
VALUES (v_from_acc_id, v_to_acc_id, p_amount, p_currency, v_rate_to_kzt, v_amount_kzt, 'transfer', 'failed', v_now, v_now,
        COALESCE(p_description,'') || ' | FAIL: daily limit exceeded');
SELECT currval(pg_get_serial_sequence('transactions','transaction_id')) INTO v_txn_id;
o_transaction_id := v_txn_id;

INSERT INTO audit_log(table_name, record_id, action, old_values, new_values, changed_by, changed_at, ip_address)
VALUES ('transactions', v_txn_id::text, 'INSERT', NULL,
        jsonb_build_object('code',o_code,'msg',o_message,'today_sum_kzt',v_today_sum_kzt,'current_kzt',v_amount_kzt,'limit_kzt',v_daily_limit_kzt),
        current_user, v_now, inet_client_addr());
RETURN;
END IF;

-- 7)
EXECUTE 'SAVEPOINT sp_transfer';

BEGIN
INSERT INTO transactions(from_account_id, to_account_id, amount, currency, exchange_rate, amount_kzt, type, status, created_at, description)
VALUES (v_from_acc_id, v_to_acc_id, p_amount, p_currency, v_rate_to_kzt, v_amount_kzt, 'transfer', 'pending', v_now, p_description)
    RETURNING transaction_id INTO v_txn_id;

--
UPDATE accounts
SET balance = balance - v_debit_amount
WHERE account_id = v_from_acc_id;

--
UPDATE accounts
SET balance = balance + v_credit_amount
WHERE account_id = v_to_acc_id;

--
UPDATE transactions
SET status = 'completed',
    completed_at = now()
WHERE transaction_id = v_txn_id;

EXECUTE 'RELEASE SAVEPOINT sp_transfer';

o_transaction_id := v_txn_id;
        o_code := 'OK';
        o_message := 'Transfer completed';

INSERT INTO audit_log(table_name, record_id, action, old_values, new_values, changed_by, changed_at, ip_address)
VALUES ('transactions', v_txn_id::text, 'INSERT', NULL,
        jsonb_build_object('code','OK','msg','completed','txn_id',v_txn_id,'debit',v_debit_amount,'credit',v_credit_amount,'amount_kzt',v_amount_kzt),
        current_user, now(), inet_client_addr());

EXCEPTION WHEN OTHERS THEN
        EXECUTE 'ROLLBACK TO SAVEPOINT sp_transfer';
EXECUTE 'RELEASE SAVEPOINT sp_transfer';

o_code := 'E999';
        o_message := 'Unexpected error during transfer: ' || SQLERRM;

        IF v_txn_id IS NOT NULL THEN
UPDATE transactions
SET status = 'failed',
    completed_at = now(),
    description = COALESCE(description,'') || ' | FAIL: ' || SQLERRM
WHERE transaction_id = v_txn_id;

o_transaction_id := v_txn_id;

INSERT INTO audit_log(table_name, record_id, action, old_values, new_values, changed_by, changed_at, ip_address)
VALUES ('transactions', v_txn_id::text, 'UPDATE', NULL,
        jsonb_build_object('code',o_code,'msg',o_message),
        current_user, now(), inet_client_addr());
ELSE
            INSERT INTO audit_log(table_name, record_id, action, old_values, new_values, changed_by, changed_at, ip_address)
            VALUES ('process_transfer', 'N/A', 'INSERT', NULL,
                    jsonb_build_object('code',o_code,'msg',o_message,'from',p_from_account_number,'to',p_to_account_number),
                    current_user, now(), inet_client_addr());
END IF;

        RETURN;
END;

EXCEPTION WHEN OTHERS THEN
    o_code := 'E998';
    o_message := 'Unhandled error: ' || SQLERRM;

INSERT INTO audit_log(table_name, record_id, action, old_values, new_values, changed_by, changed_at, ip_address)
VALUES ('process_transfer', 'N/A', 'INSERT', NULL,
        jsonb_build_object('code',o_code,'msg',o_message,'from',p_from_account_number,'to',p_to_account_number,'amount',p_amount,'currency',p_currency),
        current_user, now(), inet_client_addr());

RETURN;
END;
$$;

--CALL
CALL process_transfer(
  'KZ00TESTFROM0001',
  'KZ00TESTTO00002',
  100,
  'USD',
  'Payment for services',
  NULL, NULL, NULL
);

