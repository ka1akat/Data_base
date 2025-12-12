--View 1
CREATE OR REPLACE VIEW customer_balance_summary AS
WITH current_rates AS (
  SELECT DISTINCT ON (from_currency, to_currency)
         from_currency,
         to_currency,
         rate
  FROM exchange_rates
  WHERE to_currency = 'KZT'
    AND now() >= valid_from
    AND now() <  valid_to
  ORDER BY from_currency, to_currency, valid_from DESC
),
acc_rows AS (
  SELECT
      c.customer_id,
      c.iin,
      c.full_name,
      c.status,
      c.daily_limit_kzt,
      a.account_id,
      a.account_number,
      a.currency,
      a.balance,
      CASE
        WHEN a.currency = 'KZT' THEN a.balance
        ELSE a.balance * cr.rate
      END AS balance_kzt
  FROM customers c
  JOIN accounts a ON a.customer_id = c.customer_id
  LEFT JOIN current_rates cr
         ON cr.from_currency = a.currency
        AND cr.to_currency   = 'KZT'
  WHERE a.is_active = TRUE
),
today_outgoing AS (
  SELECT
      a.customer_id,
      COALESCE(SUM(t.amount_kzt),0) AS today_out_kzt
  FROM transactions t
  JOIN accounts a ON a.account_id = t.from_account_id
  WHERE t.status = 'completed'
    AND t.type   = 'transfer'
    AND t.created_at::date = CURRENT_DATE
  GROUP BY a.customer_id
),
agg AS (
  SELECT
      r.customer_id,
      r.iin,
      r.full_name,
      r.status,
      r.daily_limit_kzt,
      COALESCE(o.today_out_kzt,0) AS today_out_kzt,
      SUM(r.balance_kzt) AS total_balance_kzt,
      jsonb_agg(
        jsonb_build_object(
          'account_id', r.account_id,
          'account_number', r.account_number,
          'currency', r.currency,
          'balance', r.balance
        )
        ORDER BY r.account_id
      ) AS accounts_json
  FROM acc_rows r
  LEFT JOIN today_outgoing o ON o.customer_id = r.customer_id
  GROUP BY r.customer_id, r.iin, r.full_name, r.status, r.daily_limit_kzt, o.today_out_kzt
)
SELECT
    customer_id,
    iin,
    full_name,
    status,
    daily_limit_kzt,
    today_out_kzt,
    ROUND((today_out_kzt / NULLIF(daily_limit_kzt,0)) * 100, 2) AS daily_limit_utilization_pct,
    ROUND(total_balance_kzt, 2) AS total_balance_kzt,
    accounts_json,
    DENSE_RANK() OVER (ORDER BY total_balance_kzt DESC) AS balance_rank
FROM agg;

--View 2
CREATE OR REPLACE VIEW daily_transaction_report AS
WITH base AS (
  SELECT
      created_at::date AS txn_date,
      type,
      COUNT(*) AS txn_count,
      SUM(amount_kzt) AS total_kzt,
      AVG(amount_kzt) AS avg_kzt
  FROM transactions
  WHERE status = 'completed'
  GROUP BY created_at::date, type
),
with_running AS (
  SELECT
      txn_date,
      type,
      txn_count,
      ROUND(total_kzt,2) AS total_kzt,
      ROUND(avg_kzt,2)   AS avg_kzt,

      -- running totals (әр type бөлек)
      SUM(total_kzt) OVER (PARTITION BY type ORDER BY txn_date) AS running_total_kzt,
      SUM(txn_count) OVER (PARTITION BY type ORDER BY txn_date) AS running_count,

      LAG(total_kzt) OVER (PARTITION BY type ORDER BY txn_date) AS prev_total_kzt
  FROM base
)
SELECT
    txn_date,
    type,
    txn_count,
    total_kzt,
    avg_kzt,
    ROUND(running_total_kzt,2) AS running_total_kzt,
    running_count,
    CASE
        WHEN prev_total_kzt IS NULL OR prev_total_kzt = 0 THEN NULL
        ELSE ROUND(((total_kzt - prev_total_kzt) / prev_total_kzt) * 100, 2)
        END AS day_over_day_growth_pct
FROM with_running
ORDER BY txn_date, type;

--View 3
CREATE OR REPLACE VIEW suspicious_activity_view
WITH (security_barrier = true)
AS
WITH tx AS (
  SELECT
      t.transaction_id,
      t.created_at,
      t.type,
      t.status,
      t.from_account_id,
      t.to_account_id,
      t.amount,
      t.currency,
      t.amount_kzt,
      a_from.customer_id AS sender_customer_id
  FROM transactions t
  LEFT JOIN accounts a_from ON a_from.account_id = t.from_account_id
  WHERE t.status = 'completed'
),
flag_big AS (
  SELECT
      transaction_id,
      'BIG_TXN_OVER_5M_KZT'::text AS reason,
      jsonb_build_object('amount_kzt', amount_kzt) AS details
  FROM tx
  WHERE amount_kzt > 5000000
),
flag_burst AS (
  -- customer бір сағатта > 10 транзакция
  SELECT
      MIN(transaction_id) AS transaction_id,
      'HIGH_FREQ_OVER_10_PER_HOUR'::text AS reason,
      jsonb_build_object(
        'customer_id', sender_customer_id,
        'hour_bucket', date_trunc('hour', created_at),
        'txn_count', COUNT(*)
      ) AS details
  FROM tx
  WHERE sender_customer_id IS NOT NULL
  GROUP BY sender_customer_id, date_trunc('hour', created_at)
  HAVING COUNT(*) > 10
),
flag_rapid AS (
  SELECT
      transaction_id,
      'RAPID_SEQUENTIAL_TRANSFERS_LT_1MIN'::text AS reason,
      jsonb_build_object(
        'prev_txn_id', prev_txn_id,
        'seconds_diff', seconds_diff
      ) AS details
  FROM (
    SELECT
        t.transaction_id,
        t.sender_customer_id,
        t.created_at,
        LAG(t.transaction_id) OVER (PARTITION BY t.sender_customer_id ORDER BY t.created_at) AS prev_txn_id,
        EXTRACT(EPOCH FROM (t.created_at - LAG(t.created_at) OVER (PARTITION BY t.sender_customer_id ORDER BY t.created_at))) AS seconds_diff
    FROM tx t
    WHERE t.type = 'transfer'
      AND t.sender_customer_id IS NOT NULL
  ) s
  WHERE prev_txn_id IS NOT NULL
    AND seconds_diff < 60
)
SELECT * FROM flag_big
UNION ALL
SELECT * FROM flag_burst
UNION ALL
SELECT * FROM flag_rapid;

