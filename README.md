# Module 3 — Stretch: SQL Performance Investigation
### 🔍 Database: SQL Murder Mystery

> **Honors Track.** This stretch assignment is not required for program completion but counts toward Honors distinction.
> Only work on this if you have completed **all core assignments** for this module and are **On Track or Advanced**.
> If you are behind on core work, focus there first.

---

## 🎯 The Challenge

A murder was committed in **SQL City** on January 15, 2018. The detective's database is full of clues — but the queries are *slow*. Your job isn't just to run queries; it's to understand **why they're slow** and **make them faster**.

You'll use `EXPLAIN QUERY PLAN` to read execution plans, add indexes, and measure the impact. This is a professional database skill — understanding why a query is slow and how to fix it is the difference between a working prototype and a production-ready system.

---

## 📚 What You'll Learn

- Reading SQLite query execution plans (`EXPLAIN QUERY PLAN`)
- Index types and when they help (B-tree for equality/range, partial indexes)
- The read/write tradeoff of indexing
- Making evidence-based optimization decisions

---

## 🗄️ The Database

The database is a SQLite file: **`sql-murder-mystery.db`**

### Tables

| Table | Rows | Description |
|-------|------|-------------|
| `person` | 10,011 | People in the city (name, address, SSN, license) |
| `drivers_license` | 10,007 | Driver's license details (age, height, eye color, car…) |
| `crime_scene_report` | 1,228 | Police reports (date, type, description, city) |
| `interview` | 4,991 | Witness and suspect interview transcripts |
| `facebook_event_checkin` | 20,011 | Event attendance records |
| `get_fit_now_member` | 184 | Gym membership records |
| `get_fit_now_check_in` | 2,703 | Gym check-in/check-out times |
| `income` | 7,514 | Annual income per person (via SSN) |

### Schema Diagram

```
person ──────────────── drivers_license        (person.license_id → drivers_license.id)
  │
  ├──────────────────── interview              (person.id → interview.person_id)
  ├──────────────────── income                 (person.ssn → income.ssn)
  ├──────────────────── facebook_event_checkin (person.id → facebook_event_checkin.person_id)
  └──────────────────── get_fit_now_member     (person.id → get_fit_now_member.person_id)
                                │
                                └──────────── get_fit_now_check_in (member.id → check_in.membership_id)
```

---

## ⚙️ Setup (2 minutes)

### Option A — SQLite CLI (recommended)
```bash
sqlite3 sql-murder-mystery.db
```

### Option B — DB Browser for SQLite (GUI, beginner-friendly)
Download from [https://sqlitebrowser.org](https://sqlitebrowser.org) and open `sql-murder-mystery.db`.

### Option C — Docker (Postgres version)
```bash
docker-compose up -d
docker exec -i murder_db psql -U postgres -d murder_mystery < setup.sql
```

### Verify the setup
```sql
SELECT name FROM sqlite_master WHERE type='table';
```

You should see 9 tables listed.

---

## ✅ Tasks

### Task 1 — Baseline Execution Plans

Run `EXPLAIN QUERY PLAN` on each of the 8 queries below. Save all output to `explain_baseline.md`.

For each query, record:
- 🔍 Scan type (`SCAN TABLE` = slow full scan, `SEARCH TABLE ... USING INDEX` = fast)
- 🔗 Join strategy shown in the plan
- ⚠️ Flag any `SCAN TABLE` on large tables — those are your targets

> **Timing tip:** Run `.timer on` in the SQLite shell before your queries to measure execution time.

---

#### The 8 Queries

**Q1 — All murders in SQL City**
```sql
EXPLAIN QUERY PLAN
SELECT date, description
FROM crime_scene_report
WHERE city = 'SQL City'
  AND type = 'murder'
ORDER BY date DESC;
```

**Q2 — People with their driver's license details**
```sql
EXPLAIN QUERY PLAN
SELECT p.name, p.address_number, p.address_street_name,
       dl.age, dl.eye_color, dl.hair_color, dl.car_make, dl.car_model
FROM person p
JOIN drivers_license dl ON p.license_id = dl.id
ORDER BY p.name;
```

**Q3 — Gym members who checked in on January 9, 2018**
```sql
EXPLAIN QUERY PLAN
SELECT m.name, m.membership_status, ci.check_in_time, ci.check_out_time
FROM get_fit_now_member m
JOIN get_fit_now_check_in ci ON m.id = ci.membership_id
WHERE ci.check_in_date = 20180109
ORDER BY ci.check_in_time;
```

**Q4 — Gold gym members and their income**
```sql
EXPLAIN QUERY PLAN
SELECT m.name, m.membership_status, i.annual_income
FROM get_fit_now_member m
JOIN person p ON m.person_id = p.id
JOIN income i ON p.ssn = i.ssn
WHERE m.membership_status = 'gold'
ORDER BY i.annual_income DESC;
```

**Q5 — People who attended Facebook events in 2018**
```sql
EXPLAIN QUERY PLAN
SELECT p.name, fe.event_name, fe.date
FROM person p
JOIN facebook_event_checkin fe ON p.id = fe.person_id
WHERE fe.date BETWEEN 20180101 AND 20181231
ORDER BY fe.date DESC;
```

**Q6 — Red-haired Tesla drivers**
```sql
EXPLAIN QUERY PLAN
SELECT p.name, dl.hair_color, dl.car_make, dl.car_model, dl.plate_number
FROM person p
JOIN drivers_license dl ON p.license_id = dl.id
WHERE dl.hair_color = 'red'
  AND dl.car_make = 'Tesla'
ORDER BY p.name;
```

**Q7 — Interview transcripts mentioning the gym or murder**
```sql
EXPLAIN QUERY PLAN
SELECT p.name, i.transcript
FROM interview i
JOIN person p ON i.person_id = p.id
WHERE i.transcript LIKE '%gym%'
   OR i.transcript LIKE '%murder%';
```

**Q8 — Average income by car make**
```sql
EXPLAIN QUERY PLAN
SELECT dl.car_make,
       COUNT(*) AS drivers,
       ROUND(AVG(i.annual_income), 0) AS avg_income,
       MIN(i.annual_income) AS min_income,
       MAX(i.annual_income) AS max_income
FROM drivers_license dl
JOIN person p ON dl.id = p.license_id
JOIN income i ON p.ssn = i.ssn
GROUP BY dl.car_make
ORDER BY avg_income DESC;
```

---

### Task 2 — Add Indexes

Based on your execution plans, identify tables that are being fully scanned unnecessarily. Edit `indexes.sql` with your indexes, then run:

```bash
# SQLite
sqlite3 sql-murder-mystery.db < indexes.sql

# Docker/Postgres
docker exec -i murder_db psql -U postgres -d murder_mystery < indexes.sql
```

Starter suggestions (add more based on your findings):

```sql
CREATE INDEX idx_crime_city_type ON crime_scene_report(city, type);
CREATE INDEX idx_person_license  ON person(license_id);
CREATE INDEX idx_checkin_date    ON get_fit_now_check_in(check_in_date);
CREATE INDEX idx_facebook_date   ON facebook_event_checkin(date);
CREATE INDEX idx_facebook_person ON facebook_event_checkin(person_id);
```

---

### Task 3 — Compare Performance

Re-run `EXPLAIN QUERY PLAN` on the same 8 queries after adding indexes. Save output to `explain_indexed.md`.

Use `.timer on` to capture actual timing and note the before/after difference for each query.

---

### Task 4 — Write a Report

Complete `performance_report.md` documenting:

- Which queries improved the most (and why the index helped)
- Which queries showed no improvement (e.g., small table, `LIKE '%...'` wildcard, full-text search)
- The tradeoffs: faster reads vs. slower writes, additional storage
- Your production recommendation: which indexes would you actually keep?

---

## 📁 Repository Structure

```
module-3-stretch-sql-performance/
├── README.md                    ← this file
├── sql-murder-mystery.db        ← the database (do not modify the data!)
├── docker-compose.yml           ← optional Postgres setup
├── setup.sql                    ← optional Postgres schema + data loader
├── indexes.sql                  ← your CREATE INDEX statements (edit this)
├── explain_baseline.md          ← Task 1 output (fill this in)
├── explain_indexed.md           ← Task 3 output (fill this in)
└── performance_report.md        ← Task 4 report (fill this in)
```

---

## 🔗 Resources

- [SQLite: EXPLAIN QUERY PLAN](https://www.sqlite.org/eqp.html)
- [SQLite: Query Planning](https://www.sqlite.org/queryplanner.html)
- [SQLite: CREATE INDEX](https://www.sqlite.org/lang_createindex.html)
- [Original SQL Murder Mystery Game](https://mystery.knightlab.com) — try solving the case too! 🕵️

---

## 📬 Submission

Push your completed repo to GitHub (include the `.db` file) and submit the link via the student portal.

---

*© 2026 LevelUp Economy. All rights reserved. Unauthorized reproduction or distribution of this material is prohibited.*
