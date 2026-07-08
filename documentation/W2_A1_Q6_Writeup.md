# Question 6: Fact Table Partitioning & Execution Plans

## 🎯 Objective
As `FactTicketSales` is the largest table in the warehouse, querying it sequentially will inevitably cause performance bottlenecks as the business scales. The objective of this task is to physically divide the table into smaller, manageable chunks (partitions) based on the date, allowing the SQL engine to skip scanning irrelevant data when querying specific timeframes—a process known as Partition Pruning.

## 🏗️ Partition Architecture
Partitioning requires two distinct architectural objects before touching the table:
1. **Partition Function (`pf_MonthlyPartition`):** This dictates *how* the data is sliced. A `RANGE RIGHT` function was created using the integer `DateKey` format (`YYYYMMDD`). Boundaries were set at the 1st of every month across 2025 and 2026. `RANGE RIGHT` ensures that a boundary value like `20250201` falls into the February partition (`>= 20250201`), rather than the end of the January partition.
2. **Partition Scheme (`ps_MonthlyPartition`):** This dictates *where* the slices live. The scheme maps the boundaries defined in the function to physical filegroups on the disk. For this challenge, all partitions were mapped to the `[PRIMARY]` filegroup.

## 🔄 Applying the Scheme
To partition the already-populated `FactTicketSales` table without dropping and recreating it, a Clustered Index was created on the `DateKey` column, explicitly specifying the `ps_MonthlyPartition` scheme in the `ON` clause. This action physically reorganizes the existing rows on disk, placing them into their respective monthly partitions.

## 📊 Execution Plan Analysis: Pruning vs. Scanning
To prove the performance gains, two queries were executed and their actual execution plans were analyzed. 

* **Query 1 (Filtering by DateKey):** When querying for flights strictly in May 2025 (`DateKey >= 20250501 AND DateKey <= 20250531`), the execution plan shows an **Actual Partition Count of 1**. By using a closed boundary (`<= 20250531`) rather than an open-ended `< 20250601`, we prevent the SQL engine from peeking at the June partition boundary. Because the engine knows exactly which partition holds May's dates, it successfully "prunes" (ignores) all other partitions, drastically reducing logical reads and I/O.
* **Query 2 (Filtering by PassengerKey):** When querying for a specific passenger without a date filter (`PassengerKey = 452`), the execution plan shows the **Actual Partition Count equals 25** (the 24 defined months plus 1 default catch-all partition). Because the table is partitioned by date, not passenger, the SQL engine is forced to scan every single monthly partition to ensure it doesn't miss a flight for that passenger.