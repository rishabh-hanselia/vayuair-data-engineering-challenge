-- ============================================================================
-- QUESTION 2: STAR SCHEMA DDL
-- ============================================================================

-- Create the data warehouse schema
CREATE SCHEMA dw;
GO

-- ==========================================
-- 1. DATE DIMENSION
-- ==========================================
CREATE TABLE dw.DimDate (
    DateKey INT PRIMARY KEY, 
    Date DATE NOT NULL,
    Year INT,
    Month INT,
    Day INT
);
GO

-- ==========================================
-- 2. AIRPORT DIMENSION 
-- ==========================================
CREATE TABLE dw.DimAirport (
    AirportKey INT IDENTITY(1,1) PRIMARY KEY,
    airport_code CHAR(3) NOT NULL,    -- Business Key
    airport_name VARCHAR(255),
    city VARCHAR(100),
    country VARCHAR(100),
    region VARCHAR(100)
);
GO

-- ==========================================
-- 3. AIRCRAFT DIMENSION
-- ==========================================
CREATE TABLE dw.DimAircraft (
    AircraftKey INT IDENTITY(1,1) PRIMARY KEY,
    aircraft_code VARCHAR(50) NOT NULL, -- Business Key
    model VARCHAR(100),
    manufacturer VARCHAR(100),
    seat_capacity INT
);
GO

-- ==========================================
-- 4. FLIGHT DIMENSION
-- ==========================================
CREATE TABLE dw.DimFlight (
    FlightKey INT IDENTITY(1,1) PRIMARY KEY,
    flight_id INT NOT NULL,             -- Business Key
    flight_number VARCHAR(50),
    flight_date DATE
);
GO

-- ==========================================
-- 5. PASSENGER DIMENSION
-- ==========================================
CREATE TABLE dw.DimPassenger (
    PassengerKey INT IDENTITY(1,1) PRIMARY KEY,
    passenger_id INT NOT NULL,          -- Business Key
    passenger_name VARCHAR(255),
    home_airport_code CHAR(3),
    frequent_flyer_tier VARCHAR(50),
    signup_date DATE
);
GO

-- ==========================================
-- 6. FACT TICKET SALES
-- ==========================================
-- Grain: One row per confirmed ticket on a specific flight.
CREATE TABLE dw.FactTicketSales (
    
    -- Surrogate Keys (The Slicing Axes)
    DateKey INT NOT NULL,
    PassengerKey INT NOT NULL,
    FlightKey INT NOT NULL,
    OriginAirportKey INT NOT NULL,
    DestAirportKey INT NOT NULL,
    AircraftKey INT NOT NULL,
    
    -- Degenerate Dimensions (Transactional Attributes)
    booking_id INT NOT NULL,
    fare_class VARCHAR(50),
    
    -- Additive Measures (Safe to SUM)
    fare_amount DECIMAL(18,2),
    tax_amount DECIMAL(18,2),
    miles_earned INT,
    
    -- Foreign Key Constraints
    CONSTRAINT FK_Fact_Date FOREIGN KEY (DateKey) 
        REFERENCES dw.DimDate(DateKey),
    
    CONSTRAINT FK_Fact_Passenger FOREIGN KEY (PassengerKey) 
        REFERENCES dw.DimPassenger(PassengerKey),
    
    CONSTRAINT FK_Fact_Flight FOREIGN KEY (FlightKey) 
        REFERENCES dw.DimFlight(FlightKey),
    
    CONSTRAINT FK_Fact_OriginAirport FOREIGN KEY (OriginAirportKey) 
        REFERENCES dw.DimAirport(AirportKey),
        
    CONSTRAINT FK_Fact_DestAirport FOREIGN KEY (DestAirportKey) 
        REFERENCES dw.DimAirport(AirportKey),
        
    CONSTRAINT FK_Fact_Aircraft FOREIGN KEY (AircraftKey) 
        REFERENCES dw.DimAircraft(AircraftKey)
);
GO