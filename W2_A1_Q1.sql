-- ============================================================================
-- QUESTION 1: GRAIN & COLUMN CLASSIFICATION
-- ============================================================================

-- GRAIN STATEMENT:
-- One row represents a single confirmed ticket (booking) sold for a specific flight.

-- COLUMN CLASSIFICATION 
-- (Candidate columns from bronze_bookings joined with bronze_flights)

-- DIMENSION KEYS (The Slicing Axes - Who, What, Where, When):
-- * booking_date          (from bronze_bookings)
-- * travel_date           (from bronze_bookings)
-- * passenger_id          (from bronze_bookings)
-- * flight_id             (from bronze_bookings)
-- * origin_airport_code   (from bronze_flights)
-- * dest_airport_code     (from bronze_flights)
-- * aircraft_code         (from bronze_flights)
-- * fare_class            (from bronze_bookings)
-- * booking_id            (from bronze_bookings)

-- MEASURES (The Additive Numbers):
-- * fare_amount           (from bronze_bookings)
-- * tax_amount            (from bronze_bookings)
-- * miles_earned          (from bronze_bookings)

-- ADDITIVE VS. NON-ADDITIVE NOTE:
-- The fare_amount, tax_amount, and miles_earned are fully additive measures because they 
-- can be safely summed across any dimension (e.g., total revenue by airport or total miles 
-- by passenger); however, booking_id is a non-additive value because summing transactional 
-- IDs yields a mathematically meaningless result.
-- ============================================================================