--Task 4

CREATE OR REPLACE PROCEDURE process_salary_batch(
    IN  p_company_account_number TEXT,
    IN  p_payments JSONB,
    OUT successful_count INT,
    OUT failed_count INT,
    OUT failed_details JSONB
)
LANGUAGE plpgsql
AS $$
DECLARE
v_company_acc_id   BIGINT;
    v_company_balance  NUMERIC;
    v_total_amount     NUMERIC := 0;

    v_item        JSONB;
    v_iin         TEXT;
    v_amount      NUMERIC;
    v_desc        TEXT;

    v_emp_customer_id BIGINT;
    v_emp_account_id  BIGINT;

    v_success INT := 0;
    v_failed  INT := 0;
    v_failed_details JSONB := '[]'::jsonb;

BEGIN
--1)
    PERFORM pg_advisory_lock(hashtext(p_company_account_number));

--2)
SELECT account_id, balance
INTO v_company_acc_id, v_company_balance
FROM accounts
WHERE account_number = p_company_account_number
    FOR UPDATE;

IF v_company_acc_id IS NULL THEN
        RAISE EXCEPTION 'Company account not found'
        USING ERRCODE = 'B001';
END IF;

--3)
SELECT SUM((elem->>'amount')::numeric)
INTO v_total_amount
FROM jsonb_array_elements(p_payments) elem;

IF v_total_amount > v_company_balance THEN
        RAISE EXCEPTION 'Insufficient company balance for batch'
        USING ERRCODE = 'B002';
END IF;

--4)
FOR v_item IN SELECT * FROM jsonb_array_elements(p_payments)
                                LOOP
    v_iin    := v_item->>'iin';
v_amount := (v_item->>'amount')::numeric;
        v_desc   := v_item->>'description';

SAVEPOINT sp_salary;

BEGIN

SELECT customer_id
INTO v_emp_customer_id
FROM customers
WHERE iin = v_iin
  AND status = 'active';

IF v_emp_customer_id IS NULL THEN
                RAISE EXCEPTION 'Employee not found or inactive';
END IF;

SELECT account_id
INTO v_emp_account_id
FROM accounts
WHERE customer_id = v_emp_customer_id
  AND currency = 'KZT'
  AND is_active = TRUE
    LIMIT 1;

IF v_emp_account_id IS NULL THEN
                RAISE EXCEPTION 'Employee has no active KZT account';
END IF;

INSERT INTO transactions(
    from_account_id, to_account_id,
    amount, currency, exchange_rate, amount_kzt,
    type, status, created_at, completed_at, description
)
VALUES (
           v_company_acc_id, v_emp_account_id,
           v_amount, 'KZT', 1, v_amount,
           'transfer', 'completed', now(), now(),
           COALESCE(v_desc,'Salary payment')
       );

v_success := v_success + 1;

EXCEPTION WHEN OTHERS THEN
            ROLLBACK TO SAVEPOINT sp_salary;

            v_failed := v_failed + 1;
            v_failed_details := v_failed_details || jsonb_build_object(
                'iin', v_iin,
                'amount', v_amount,
                'error', SQLERRM
            );
END;
END LOOP;

--5)
UPDATE accounts
SET balance = balance - v_total_amount
WHERE account_id = v_company_acc_id;

UPDATE accounts a
SET balance = balance + t.amount
    FROM transactions t
WHERE t.to_account_id = a.account_id
  AND t.from_account_id = v_company_acc_id
  AND t.created_at::date = CURRENT_DATE;

successful_count := v_success;
    failed_count     := v_failed;
    failed_details   := v_failed_details;

    PERFORM pg_advisory_unlock(hashtext(p_company_account_number));
END;
$$;

--Materialized View
CREATE MATERIALIZED VIEW salary_batch_summary AS
SELECT
    t.created_at::date AS batch_date,
    a_from.account_number AS company_account,
    COUNT(*) AS total_payments,
    SUM(t.amount_kzt) AS total_paid_kzt
FROM transactions t
         JOIN accounts a_from ON a_from.account_id = t.from_account_id
WHERE t.description ILIKE '%salary%'
GROUP BY t.created_at::date, a_from.account_number;

REFRESH MATERIALIZED VIEW salary_batch_summary;

--Test case
CALL process_salary_batch(
  'ACC_KZ_0001',
  '[
     {"iin":"000000000002","amount":100000,"description":"June salary"},
     {"iin":"000000000003","amount":120000,"description":"June salary"},
     {"iin":"000000000999","amount":90000,"description":"Invalid employee"}
   ]'::jsonb,
  NULL, NULL, NULL
);

