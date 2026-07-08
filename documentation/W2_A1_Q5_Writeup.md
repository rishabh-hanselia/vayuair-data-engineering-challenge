# Question 5: Slowly Changing Dimension (SCD Type 2)

## 🎯 Objective
As passengers fly with Vayu Air, their attributes change—they move to new home airports or earn upgrades to higher frequent flyer tiers (e.g., Silver to Gold). If we simply overwrite their old data, historical revenue reports will become skewed. The objective of this task is to rebuild the passenger dimension as an SCD Type 2 table to preserve a complete historical timeline of every passenger's status.

## 🏗️ Architecture & DDL
A new table, `DimPassenger_SCD2`, was created. Unlike a standard dimension, it relies on three critical metadata columns to track history:
* **`is_current` (BIT):** A boolean flag quickly indicating if this row is the active version.
* **`effective_from` (DATE):** The date this specific version of the passenger became true.
* **`effective_to` (DATE):** The date this version was superseded (defaulted to `9999-12-31` for current rows).

The `PassengerKey` (Surrogate Key) remains the Primary Key, meaning a single `passenger_id` (Business Key) can now legally exist on multiple rows, each uniquely identified by its Surrogate Key.

## 🔄 The Two-Step Change Data Capture (CDC) Pipeline
To process the daily `stg_passenger_updates` feed, a standard enterprise T-SQL two-step pattern was implemented to guarantee data integrity.

### Step 1: The `MERGE` and Expire 
A `MERGE` statement compares the staging feed against the target dimension.
* **Updates:** If a match is found on `passenger_id`, but the tier or airport differs, the statement updates the existing target row, setting `is_current = 0` and closing out the `effective_to` date to today.
* **Inserts:** If a completely new `passenger_id` arrives, it is seamlessly inserted as a current row.
* **The Output Clause:** As the `MERGE` executes, T-SQL's `OUTPUT` clause captures the data of the passengers that were just updated and temporarily holds them in memory via a table variable (`@ChangedRecords`).

### Step 2: The `INSERT`
A secondary `INSERT` statement selects directly from the `@ChangedRecords` table variable. It filters for records where the action type was `UPDATE`, and inserts a fresh row for those passengers. This new row reflects their new tier/airport, resets `is_current = 1`, and opens the `effective_from` date to today.

## ✅ Acceptance Criteria Validation
By running a `GROUP BY ... HAVING COUNT(*) > 1` query at the end of the pipeline, we successfully prove the pattern works: passengers who experienced a status change now possess two distinct rows—an expired historical record and a newly active current record, perfectly preserving the timeline for the fact table to join against.