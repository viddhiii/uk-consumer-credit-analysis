# UK Consumer Credit & Debt Trends Analysis (2015-2026)

An end-to-end data analysis project examining how UK consumer borrowing has
evolved over the last decade, through the pre-pandemic boom, the Covid
lockdown dip, and the cost-of-living crisis. Built with **PostgreSQL** for the
analysis and **Power BI** for the dashboard, using real data from the
**Bank of England**.

---

## Why this project

Consumer borrowing in the UK has changed dramatically since 2015, and the rise
of **Buy Now, Pay Later (BNPL)** has put consumer credit back in the headlines
with the FCA bringing BNPL under formal regulation. This project steps back from
the BNPL headline to ask a broader question: **how has total UK consumer debt
actually moved over the past decade, and what do the major economic shocks look
like in the data?**

---

## Key findings

- UK outstanding consumer credit (excluding student loans) increased from approximately £171.5 billion in January 2015 to £253.5 billion in April 2026, a nominal increase of £82.0 billion (47.8%).
- Based on annual average outstanding credit, 2020 recorded a 5.21% decline compared with 2019, followed by a further 6.08% decline in 2021.
- Annual average outstanding credit increased by 2.62% in 2022 and 5.99% in 2023, showing a recovery in balances after the pandemic period.
- The figures represent outstanding credit balances, not new borrowing. They are not adjusted for inflation and do not establish the causes of changes in borrowing.

### Average outstanding consumer credit by economic period

| Economic period | Dates | Average credit (£bn) | Months |
| --- | --- | ---: | ---: |
| Pre-pandemic | Jan 2015 - Feb 2020 | 201.0 | 62 |
| Pandemic period | Mar 2020 - Dec 2021 | 202.7 | 22 |
| 2022 onwards | Jan 2022 - Apr 2026 | 224.3 | 52 |

Source: Bank of England, series LPMBI2O. Monthly, seasonally adjusted outstanding consumer credit excluding student loans.

---

## Dashboard

![Power BI Dashboard](dashboard.png)

The Power BI dashboard visualises monthly UK outstanding consumer credit between January 2015 and April 2026.

It includes:

- A KPI card showing peak outstanding consumer credit of £253.5bn.
- A line chart illustrating monthly credit trends, including the pandemic decline and subsequent recovery.
- A bar chart comparing average outstanding consumer credit across three economic periods.

The dashboard uses DAX measures to calculate and present credit balances in £ billions.

---

## Tools & skills demonstrated

| Area | Details |
|---|---|
| **SQL (PostgreSQL)** | Aggregations, `GROUP BY`, `EXTRACT`, `CASE`, and `LAG()` window functions for year-over-year growth |
| **Data cleaning** | Cleaned and reformatted the raw Bank of England CSV (date parsing, column typing) using Python |
| **Power BI** | Live PostgreSQL connection, DAX calculated column, multi-visual dashboard |
| **Data storytelling** | Translating raw figures into a clear economic narrative |

---

## Data source

- **Bank of England Interactive Database** - series **LPMBI2O**: total consumer
  credit (excluding student loans), seasonally adjusted, monthly, £ millions.
- Period: January 2015 - April 2026 (136 monthly records).

---

## Repository structure

```
uk-consumer-credit-analysis/
├── README.md
├── analysis_queries.sql
├── consumer_credit_clean.csv
├── dashboard.png
└── UK_Consumer_Credit_Dashboard.pbix
```

---

## How to reproduce

1. Clone or download this repository.
2. Create a PostgreSQL database.
3. Run the table creation statement in `analysis_queries.sql`.
4. Import `consumer_credit_clean.csv` into the `consumer_credit` table.
5. Run the remaining SQL queries to explore the trends and economic-period comparisons.
6. Open `UK_Consumer_Credit_Dashboard.pbix` in Power BI Desktop.
7. Configure the PostgreSQL connection to point to your local database and refresh the data.

---

*Built as a portfolio project to demonstrate SQL and Power BI skills applied to
real-world UK economic data.*
