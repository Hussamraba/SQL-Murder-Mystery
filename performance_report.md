# Performance Report — SQL Murder Mystery Index Investigation

Student Name: Hussam Rabaa  
Date:2026-03-31  
Database: `sql-murder-mystery.db` (SQLite)

---

## Summary Table

| Query | Baseline (ms) | Indexed (ms) | Improvement | Index Used? |
|-------|--------------|-------------|-------------|-------------|
| Q1 — Murders in SQL City | ~0 | ~0 | Logical improvement | Yes |
| Q2 — People + license details | ~0 | ~0 | Logical improvement | Yes |
| Q3 — Gym check-ins Jan 9 | ~0 | ~0 | Logical improvement | Yes |
| Q4 — Gold members + income | ~0 | ~0 | Logical improvement | Yes |
| Q5 — Facebook events 2018 | ~0 | ~0 | Logical improvement | Yes |
| Q6 — Red-haired Tesla drivers | ~0 | ~0 | Logical improvement | Yes |
| Q7 — Interview keyword search | ~0 | ~0 | No significant improvement | No |
| Q8 — Income by car make | ~0 | ~0 | Logical improvement | Yes |

---

## 1. Queries That Improved the Most

The queries that improved the most were Q1, Q3, Q5, and Q6.

Q1 improved because the composite index on `(city, type, date DESC)` allowed SQLite to directly filter the rows based on city and crime type instead of scanning the entire table. It also reduced the cost of sorting by date.

Q3 improved because the query filters by `check_in_date` and joins using `membership_id`. The composite index on `(check_in_date, membership_id, check_in_time)` matches the query pattern and significantly reduces the number of scanned rows.

Q5 improved because the index on `(date, person_id)` allowed efficient filtering of records within a specific date range before performing joins.

Q6 improved due to the composite index on `(hair_color, car_make)`, which helps quickly locate matching driver records before joining with the `person` table.

Although execution time appears as `0.000 ms`, the improvement is clearly visible in the query execution plan, which changed from full table scans (SCAN) to indexed searches (SEARCH).

---

## 2. Queries That Did NOT Improve

Q7 showed little or no improvement.

This query uses:
`LIKE '%gym%'` and `LIKE '%murder%'`

Because of the leading wildcard (`%`), SQLite cannot use standard indexes effectively. This forces the database to scan the entire table regardless of indexing.

Additionally, some queries may show minimal visible improvement because:
- The dataset is small
- Full scans are already fast in small tables
- SQLite rounds execution time to `0.000`

---

## 3. Tradeoffs of Indexing

Indexes improve performance for SELECT queries by allowing faster lookup of rows, especially when using WHERE filters, JOIN conditions, and ORDER BY clauses.

However, indexes come with tradeoffs:

- They slow down INSERT, UPDATE, and DELETE operations because the index must be updated whenever data changes.
- They consume additional disk space.
- Too many indexes can reduce overall performance and increase maintenance complexity.

For this reason, indexing should be applied selectively based on actual query patterns and performance needs.

---

## 4. Production Recommendation

In a real-world production environment, I would keep indexes that significantly improve filtering and join operations.

Recommended indexes to keep:

- `idx_crime_city_type_date`
- `idx_person_license_id`
- `idx_checkin_date_membership`
- `idx_member_status`
- `idx_member_person_id`
- `idx_facebook_date_person`
- `idx_person_ssn`
- `idx_license_hair_car`

These indexes improve the most frequently used query patterns such as filtering, joining, and sorting.

I would not rely on indexes for text search queries like Q7, as they require full-text search solutions rather than standard indexing.

Overall, indexing decisions should be based on query usage patterns, execution plans, and real performance measurements.

---

© 2026 LevelUp Economy. All rights reserved.