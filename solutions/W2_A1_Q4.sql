-- ============================================================================
-- QUESTION 4: SNOWFLAKING GEOGRAPHY
-- ============================================================================

-- 1. CREATE NORMALIZED TABLES (DDL)

-- Create Country Dimension
CREATE TABLE dw.DimCountry (
    CountryKey INT IDENTITY(1,1) PRIMARY KEY,
    CountryName VARCHAR(100) NOT NULL,
    Region VARCHAR(100)
);
GO

-- Create City Dimension (Links to Country)
CREATE TABLE dw.DimCity (
    CityKey INT IDENTITY(1,1) PRIMARY KEY,
    CityName VARCHAR(100) NOT NULL,
    CountryKey INT NOT NULL,
    
    CONSTRAINT FK_DimCity_Country FOREIGN KEY (CountryKey) 
        REFERENCES dw.DimCountry(CountryKey)
);
GO

-- Create Snowflaked Airport Dimension (Links to City)
CREATE TABLE dw.DimAirport_Snowflake (
    AirportKey INT IDENTITY(1,1) PRIMARY KEY,
    airport_code CHAR(3) NOT NULL,
    airport_name VARCHAR(255),
    CityKey INT NOT NULL,
    
    CONSTRAINT FK_DimAirport_City FOREIGN KEY (CityKey) 
        REFERENCES dw.DimCity(CityKey)
);
GO

-- ==========================================
-- 2. LOAD DATA (DML) 
-- ==========================================

-- A. Load Country
INSERT INTO dw.DimCountry (CountryName, Region)
SELECT DISTINCT country, region
FROM bronze_airports
WHERE country IS NOT NULL;
GO

-- B. Load City (Joining back to DimCountry to get the CountryKey)
INSERT INTO dw.DimCity (CityName, CountryKey)
SELECT DISTINCT a.city, c.CountryKey
FROM bronze_airports a
JOIN dw.DimCountry c 
    ON a.country = c.CountryName
WHERE a.city IS NOT NULL;
GO

-- C. Load Airport (Joining back to DimCity to get the CityKey)
INSERT INTO dw.DimAirport_Snowflake (airport_code, airport_name, CityKey)
SELECT DISTINCT a.airport_code, a.airport_name, c.CityKey
FROM bronze_airports a
JOIN dw.DimCity c 
    ON a.city = c.CityName;
GO

-- ==========================================
-- 3. ACCEPTANCE CRITERIA VALIDATION
-- ==========================================
-- A query that resolves an airport all the way up to its country.
SELECT 
    a.airport_code,
    a.airport_name,
    c.CityName,
    co.CountryName,
    co.Region
FROM dw.DimAirport_Snowflake a
JOIN dw.DimCity c 
    ON a.CityKey = c.CityKey
JOIN dw.DimCountry co 
    ON c.CountryKey = co.CountryKey;
GO

-- TRADE-OFF STATEMENT:
-- The trade-off of snowflaking this dimension is that while we eliminate redundant data 
-- and save storage space (normalization), we force downstream analytical queries to perform 
-- multiple, slower joins just to retrieve the full geographical hierarchy.