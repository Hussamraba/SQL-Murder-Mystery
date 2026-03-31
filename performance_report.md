# Performance Report — SQL Murder Mystery Index Investigation

**Student Name:** ___
**Date:** ___
**Database:** `sql-murder-mystery.db` (SQLite)

---

## Summary Table

| Query | Baseline (ms) | Indexed (ms) | Improvement | Index Used? |
|-------|--------------|-------------|-------------|-------------|
| Q1 — Murders in SQL City | | | | |
| Q2 — People + license details | | | | |
| Q3 — Gym check-ins Jan 9 | | | | |
| Q4 — Gold members + income | | | | |
| Q5 — Facebook events 2018 | | | | |
| Q6 — Red-haired Tesla drivers | | | | |
| Q7 — Interview keyword search | | | | |
| Q8 — Income by car make | | | | |

---

## 1. Queries That Improved the Most

*Which queries got faster? By how much? Why did the index help for those specific queries?*

---

## 2. Queries That Did NOT Improve

*Which queries showed little or no change? Explain why — think about table size, the use of `LIKE '%...'` wildcards, or cases where a full scan is actually faster.*

---

## 3. Tradeoffs of Indexing

*Discuss:*
- How indexes speed up SELECT/WHERE/JOIN operations
- How indexes slow down INSERT, UPDATE, DELETE
- Storage overhead (each index takes extra disk space)
- Why you wouldn't index every column

---

## 4. Production Recommendation

*If this were a real police database handling thousands of queries per day, which indexes would you keep? Which would you drop? Justify your choices with evidence from your measurements.*

---

*© 2026 LevelUp Economy. All rights reserved.*
