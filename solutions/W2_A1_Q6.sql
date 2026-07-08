-- ============================================================================
-- QUESTION 6: FACT TABLE PARTITIONING & EXECUTION PLANS
-- ============================================================================

/*
===============================================================================
DATA PROFILING STEP (Commented out for DDL execution)
===============================================================================
Before hardcoding the partition boundaries, I ran the following query to determine
the actual date range present in the source data. 

    SELECT 
        MIN(YEAR(travel_date)) AS MinYear, 
        MAX(YEAR(travel_date)) AS MaxYear 
    FROM bronze_bookings;

Result: The data spans from 2025 to 2026. 
Therefore, the partition function boundaries below are explicitly tailored 
to cover those years in monthly increments.
===============================================================================
*/

-- ==========================================
-- 1. CREATE PARTITION FUNCTION
-- ==========================================
CREATE PARTITION FUNCTION pf_MonthlyPartition (INT)
AS RANGE RIGHT FOR VALUES (
    20250101, 20250201, 20250301, 20250401, 20250501, 20250601,
    20250701, 20250801, 20250901, 20251001, 20251101, 20251201,
    20260101, 20260201, 20260301, 20260401, 20260501, 20260601,
    20260701, 20260801, 20260901, 20261001, 20261101, 20261201
);
GO

-- ==========================================
-- 2. CREATE PARTITION SCHEME
-- ==========================================
CREATE PARTITION SCHEME ps_MonthlyPartition
AS PARTITION pf_MonthlyPartition
ALL TO ([PRIMARY]);
GO

-- ==========================================
-- 3. APPLY PARTITIONING TO THE FACT TABLE
-- ==========================================
CREATE CLUSTERED INDEX CIX_FactTicketSales_DateKey 
ON dw.FactTicketSales(DateKey)
ON ps_MonthlyPartition(DateKey);
GO

-- ==========================================
-- 4. EXECUTION PLAN ANALYSIS (ACCEPTANCE CRITERIA)
-- ==========================================
-- Query A: Filtering on the Partition Key (DateKey)
-- Expected Result: Pruning occurs. Actual Partition Count should be 1.
SELECT 
    DateKey, PassengerKey, FlightKey, fare_amount 
FROM dw.FactTicketSales 
WHERE DateKey >= 20250501 AND DateKey <= 20250531;
GO

-- Query B: Filtering on a non-partition column (PassengerKey)
-- Expected Result: No pruning. Actual Partition Count will equal your total number of partitions + 1.
SELECT 
    DateKey, PassengerKey, FlightKey, fare_amount 
FROM dw.FactTicketSales 
WHERE PassengerKey = 452;
GO