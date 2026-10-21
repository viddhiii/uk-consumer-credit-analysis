-- ============================================================
-- UK Consumer Credit & Debt Trends Analysis (2015-2026)
-- Data source: Bank of England Interactive Database
-- Series: LPMBI2O - Total consumer credit (excl. student loans),
--         seasonally adjusted, monthly, GBP millions
-- Database: PostgreSQL 16
-- ============================================================


-- ------------------------------------------------------------
-- 1. TABLE SETUP
-- ------------------------------------------------------------

-- Create the table to hold the monthly consumer credit data
CREATE TABLE consumer_credit (
    record_date DATE,
    consumer_credit_gbp_m NUMERIC
);

-- (Data was then imported from consumer_credit_clean.csv - 136 rows)


-- ------------------------------------------------------------
-- 2. INITIAL EXPLORATION
-- ------------------------------------------------------------

-- View all records, oldest first
SELECT *
FROM consumer_credit
ORDER BY record_date;


-- ------------------------------------------------------------
-- 3. HEADLINE SUMMARY STATISTICS
-- ------------------------------------------------------------

-- Lowest, highest, and average consumer debt across the whole period
-- Finding: lowest GBP 171,157m | highest GBP 253,512m | average GBP 210,169m
-- That is roughly GBP 82 billion (48%) growth over 11 years.
SELECT
    MIN(consumer_credit_gbp_m) AS lowest_debt,
    MAX(consumer_credit_gbp_m) AS highest_debt,
    ROUND(AVG(consumer_credit_gbp_m)) AS average_debt
FROM consumer_credit;


-- ------------------------------------------------------------
-- 4. YEAR-BY-YEAR AVERAGE DEBT
-- ------------------------------------------------------------

-- Average debt grouped by calendar year
-- Reveals the trend: steady growth -> Covid stall -> cost-of-living surge
SELECT
    EXTRACT(YEAR FROM record_date) AS year,
    ROUND(AVG(consumer_credit_gbp_m)) AS avg_debt
FROM consumer_credit
GROUP BY EXTRACT(YEAR FROM record_date)
ORDER BY year;



-- ------------------------------------------------------------
-- 5. YEAR-OVER-YEAR % GROWTH (FULL YEARS ONLY)
-- ------------------------------------------------------------

-- Calculate annual averages using complete calendar years.
-- Exclude 2026 because only Jan-Apr data is available.

WITH annual_averages AS (
    SELECT
        EXTRACT(YEAR FROM record_date)::INT AS year,
        AVG(consumer_credit_gbp_m) AS avg_credit_gbp_m
    FROM consumer_credit
    GROUP BY EXTRACT(YEAR FROM record_date)
    HAVING COUNT(*) = 12
),
annual_growth AS (
    SELECT
        year,
        avg_credit_gbp_m,
        LAG(avg_credit_gbp_m) OVER (
            ORDER BY year
        ) AS previous_year_avg
    FROM annual_averages
)
SELECT
    year,
    ROUND(avg_credit_gbp_m, 0) AS avg_credit_gbp_m,
    ROUND(
        (avg_credit_gbp_m - previous_year_avg)
        / NULLIF(previous_year_avg, 0) * 100,
        2
    ) AS yoy_growth_pct
FROM annual_growth
ORDER BY year;


-- ------------------------------------------------------------
-- 6. FILTERING: COST-OF-LIVING PERIOD ONLY
-- ------------------------------------------------------------

-- Isolate the months from Jan 2022 onwards (52 rows)
SELECT
    record_date,
    consumer_credit_gbp_m
FROM consumer_credit
WHERE record_date >= '2022-01-01'
ORDER BY record_date;



-- ------------------------------------------------------------
-- 7. CATEGORISING MONTHS INTO ECONOMIC PERIODS
-- ------------------------------------------------------------

SELECT
    record_date,
    consumer_credit_gbp_m,
    CASE
        WHEN record_date < '2020-03-01'
            THEN 'Pre-pandemic'
        WHEN record_date < '2022-01-01'
            THEN 'Pandemic period'
        ELSE '2022 onwards'
    END AS economic_period
FROM consumer_credit
ORDER BY record_date;


-- ------------------------------------------------------------
-- 8. AVERAGE CREDIT BY ECONOMIC PERIOD
-- ------------------------------------------------------------

WITH classified_credit AS (
    SELECT
        record_date,
        consumer_credit_gbp_m,
        CASE
            WHEN record_date < '2020-03-01'
                THEN 'Pre-pandemic'
            WHEN record_date < '2022-01-01'
                THEN 'Pandemic period'
            ELSE '2022 onwards'
        END AS economic_period
    FROM consumer_credit
)

SELECT
    economic_period,
    ROUND(
        AVG(consumer_credit_gbp_m) / 1000, 1
    ) AS avg_credit_gbp_bn,
    COUNT(*) AS months_count
FROM classified_credit
GROUP BY economic_period
ORDER BY MIN(record_date);

