-- ============================================================================
-- QUESTION 5: SLOWLY CHANGING DIMENSION (SCD TYPE 2)
-- ============================================================================

-- ==========================================
-- 1. DDL: CREATE THE SCD2 DIMENSION TABLE
-- ==========================================
-- We build a new version of DimPassenger with the required SCD2 tracking columns.
CREATE TABLE dw.DimPassenger_SCD2 (
    PassengerKey INT IDENTITY(1,1) PRIMARY KEY,
    passenger_id INT NOT NULL,          -- Stable Business Key
    passenger_name VARCHAR(255),
    home_airport_code CHAR(3),
    frequent_flyer_tier VARCHAR(50),
    signup_date DATE,
    
    -- SCD Type 2 Metadata Columns
    is_current BIT NOT NULL,
    effective_from DATE NOT NULL,
    effective_to DATE NOT NULL
);
GO

-- ==========================================
-- 2. INITIAL LOAD (Seeding from Bronze)
-- ==========================================
-- Load the current state of passengers as version 1 (is_current = 1)
INSERT INTO dw.DimPassenger_SCD2 (
    passenger_id, passenger_name, home_airport_code, frequent_flyer_tier, signup_date, 
    is_current, effective_from, effective_to
)
SELECT 
    passenger_id, 
    passenger_name, 
    home_airport_code, 
    frequent_flyer_tier, 
    signup_date, 
    1 AS is_current, 
    '1900-01-01' AS effective_from,  -- Default start of time for initial load
    '9999-12-31' AS effective_to     -- Default end of time for active records
FROM bronze_passengers;
GO

-- ==========================================
-- 3. THE TWO-STEP SCD2 PIPELINE (Processing Updates)
-- ==========================================

-- Declare a table variable to hold the records that get expired in Step 1
-- so we can insert their new active versions in Step 2.
DECLARE @ChangedRecords TABLE (
    ActionType VARCHAR(10),
    passenger_id INT,
    passenger_name VARCHAR(255),
    home_airport_code CHAR(3),
    frequent_flyer_tier VARCHAR(50)
);

-- STEP 1: Expire changed records and insert brand-new passengers
MERGE dw.DimPassenger_SCD2 AS target
USING stg_passenger_updates AS source
ON target.passenger_id = source.passenger_id

-- Condition A: The passenger exists, is currently active, but their tier or airport changed
WHEN MATCHED AND target.is_current = 1 
             AND (target.frequent_flyer_tier <> source.frequent_flyer_tier 
                  OR target.home_airport_code <> source.home_airport_code)
THEN 
    -- Expire the old record
    UPDATE SET 
        target.is_current = 0,
        target.effective_to = CAST(GETDATE() AS DATE)

-- Condition B: A brand-new passenger arrived in the staging feed
WHEN NOT MATCHED BY TARGET
THEN 
    -- Insert them immediately as a current record
    INSERT (passenger_id, passenger_name, home_airport_code, frequent_flyer_tier, is_current, effective_from, effective_to)
    VALUES (source.passenger_id, source.passenger_name, source.home_airport_code, source.frequent_flyer_tier, 1, CAST(GETDATE() AS DATE), '9999-12-31')

-- Capture the output of the MERGE to know exactly who was updated
OUTPUT $action, source.passenger_id, source.passenger_name, source.home_airport_code, source.frequent_flyer_tier
INTO @ChangedRecords (ActionType, passenger_id, passenger_name, home_airport_code, frequent_flyer_tier);

-- STEP 2: Insert the new active versions for the passengers we just expired
INSERT INTO dw.DimPassenger_SCD2 (
    passenger_id, passenger_name, home_airport_code, frequent_flyer_tier, 
    is_current, effective_from, effective_to
)
SELECT 
    passenger_id, 
    passenger_name, 
    home_airport_code, 
    frequent_flyer_tier, 
    1 AS is_current, 
    CAST(GETDATE() AS DATE) AS effective_from, 
    '9999-12-31' AS effective_to
FROM @ChangedRecords
WHERE ActionType = 'UPDATE';
GO

-- ==========================================
-- 4. ACCEPTANCE CRITERIA VALIDATION
-- ==========================================
-- Verify a passenger who changed now has two rows (one expired, one current)
SELECT passenger_id, passenger_name, frequent_flyer_tier, is_current, effective_from, effective_to
FROM dw.DimPassenger_SCD2
WHERE passenger_id IN (
    -- Find an ID that has more than one row (meaning they were upgraded/changed)
    SELECT passenger_id 
    FROM dw.DimPassenger_SCD2 
    GROUP BY passenger_id 
    HAVING COUNT(*) > 1
)
ORDER BY passenger_id, effective_from;
GO