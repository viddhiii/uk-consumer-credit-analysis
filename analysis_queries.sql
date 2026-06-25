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
-- 5. YEAR-OVER-YEAR % GROWTH (WINDOW FUNCTION)
-- ------------------------------------------------------------

-- Uses LAG() to compare each year's average against the previous year
-- KEY FINDING: 2021 = -6.08% (Covid lockdown debt drop)
--              2022 = +2.62%, 2023 = +5.99% (cost-of-living surge)
SELECT
    EXTRACT(YEAR FROM record_date) AS year,
    ROUND(AVG(consumer_credit_gbp_m)) AS avg_debt,
    ROUND(
        (AVG(consumer_credit_gbp_m)
            - LAG(AVG(consumer_credit_gbp_m))
                OVER (ORDER BY EXTRACT(YEAR FROM record_date)))
        / LAG(AVG(consumer_credit_gbp_m))
                OVER (ORDER BY EXTRACT(YEAR FROM record_date)) * 100,
        2
    ) AS yoy_growth_pct
FROM consumer_credit
GROUP BY EXTRACT(YEAR FROM record_date)
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
-- 7. CATEGORISING MONTHS INTO ECONOMIC ERAS (CASE)
-- ------------------------------------------------------------

-- Label each month by economic period
SELECT
    record_date,
    consumer_credit_gbp_m,
    CASE
        WHEN record_date < '2020-03-01' THEN 'Pre-Covid'
        WHEN record_date < '2021-06-01' THEN 'Covid period'
        ELSE 'Cost-of-living era'
    END AS economic_period
FROM consumer_credit
ORDER BY record_date;


-- ------------------------------------------------------------
-- 8. AVERAGE DEBT BY ECONOMIC ERA (CASE + GROUP BY)
-- ------------------------------------------------------------

-- Compare average debt across the three economic periods
-- Finding: Pre-Covid GBP 200,972m (62 months)
--          Covid period GBP 204,830m (15 months)
--          Cost-of-living era GBP 221,190m (59 months)
SELECT
    CASE
        WHEN record_date < '2020-03-01' THEN 'Pre-Covid'
        WHEN record_date < '2021-06-01' THEN 'Covid period'
        ELSE 'Cost-of-living era'
    END AS economic_period,
    ROUND(AVG(consumer_credit_gbp_m)) AS avg_debt,
    COUNT(*) AS months_count
FROM consumer_credit
GROUP BY
    CASE
        WHEN record_date < '2020-03-01' THEN 'Pre-Covid'
        WHEN record_date < '2021-06-01' THEN 'Covid period'
        ELSE 'Cost-of-living era'
    END
ORDER BY avg_debt;
