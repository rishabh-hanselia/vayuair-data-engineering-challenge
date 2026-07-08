-- ============================================================================
-- QUESTION 3: FACT & DIMENSION POPULATION
-- ============================================================================

-- 1. LOAD DIMENSIONS (Identity columns will auto-generate Surrogate Keys)

-- Load DimAirport
INSERT INTO dw.DimAirport (airport_code, airport_name, city, country, region)
SELECT airport_code, airport_name, city, country, region 
FROM bronze_airports;

-- Load DimAircraft
INSERT INTO dw.DimAircraft (aircraft_code, model, manufacturer, seat_capacity)
SELECT aircraft_code, model, manufacturer, seat_capacity 
FROM bronze_aircraft;

-- Load DimFlight
INSERT INTO dw.DimFlight (flight_id, flight_number, flight_date)
SELECT flight_id, flight_number, flight_date 
FROM bronze_flights;

-- Load DimPassenger
INSERT INTO dw.DimPassenger (passenger_id, passenger_name, home_airport_code, frequent_flyer_tier, signup_date)
SELECT passenger_id, passenger_name, home_airport_code, frequent_flyer_tier, signup_date 
FROM bronze_passengers;

-- Load DimDate (Extracting all unique dates from the source data)
WITH AllDates AS (
    SELECT CAST(booking_date AS DATE) AS d FROM bronze_bookings
    UNION 
    SELECT CAST(travel_date AS DATE) FROM bronze_bookings
    UNION 
    SELECT CAST(flight_date AS DATE) FROM bronze_flights
    UNION 
    SELECT CAST(signup_date AS DATE) FROM bronze_passengers
)
INSERT INTO dw.DimDate (DateKey, Date, Year, Month, Day)
SELECT 
    (YEAR(d) * 10000) + (MONTH(d) * 100) + DAY(d) AS DateKey,
    d AS Date,
    YEAR(d) AS Year,
    MONTH(d) AS Month,
    DAY(d) AS Day
FROM AllDates
WHERE d IS NOT NULL;
GO

-- 2. LOAD FACT TABLE 
-- Join raw bookings to the dimensions on Business Keys to retrieve Surrogate Keys
INSERT INTO dw.FactTicketSales (
    DateKey, 
    PassengerKey, 
    FlightKey, 
    OriginAirportKey, 
    DestAirportKey, 
    AircraftKey,
    booking_id, 
    fare_class, 
    fare_amount, 
    tax_amount, 
    miles_earned
)
SELECT 
    -- Compute DateKey for the travel date
    (YEAR(b.travel_date) * 10000) + (MONTH(b.travel_date) * 100) + DAY(b.travel_date) AS DateKey,
    p.PassengerKey,
    f.FlightKey,
    oa.AirportKey AS OriginAirportKey,
    da.AirportKey AS DestAirportKey,
    a.AircraftKey,
    b.booking_id,
    b.fare_class,
    b.fare_amount,
    b.tax_amount,
    b.miles_earned
FROM bronze_bookings b
-- Join to DimPassenger for PassengerKey
JOIN dw.DimPassenger p 
    ON b.passenger_id = p.passenger_id
-- Join to DimFlight for FlightKey
JOIN dw.DimFlight f 
    ON b.flight_id = f.flight_id
-- We need bronze_flights to get the aircraft/airport codes for the specific flight
JOIN bronze_flights bf 
    ON b.flight_id = bf.flight_id
-- Join to DimAirport for Origin and Destination Keys
JOIN dw.DimAirport oa 
    ON bf.origin_airport_code = oa.airport_code
JOIN dw.DimAirport da 
    ON bf.dest_airport_code = da.airport_code
-- Join to DimAircraft for AircraftKey
JOIN dw.DimAircraft a 
    ON bf.aircraft_code = a.aircraft_code;
GO

-- 3. VALIDATION CHECK (Acceptance Criteria: fact row count matches bronze_bookings)
SELECT 
    (SELECT COUNT(*) FROM bronze_bookings) AS Bronze_Count,
    (SELECT COUNT(*) FROM dw.FactTicketSales) AS Fact_Count;
GO