-- ============================================================================
-- QUESTION 7: MEDALLION ARCHITECTURE & DATA CONTRACTS
-- ============================================================================

/*
===============================================================================
PART A: MEDALLION ARCHITECTURE MAPPING
===============================================================================

1. BRONZE LAYER (Raw Source Data)
Tables: bronze_airports, bronze_aircraft, bronze_passengers, bronze_flights, 
        bronze_bookings, stg_passenger_updates
Reason: These tables sit in the Bronze layer because they represent the raw, 
        unaltered data exactly as it was landed from Vayu Air's transactional 
        booking systems.

2. SILVER LAYER (Cleaned & Conformed Dimensions)
Tables: dw.DimDate, dw.DimAircraft, dw.DimFlight, dw.DimCountry, dw.DimCity, 
        dw.DimAirport_Snowflake, dw.DimPassenger_SCD2
Reason: These tables sit in the Silver layer because the raw data has been 
        cleaned, normalized (snowflaking), enriched with surrogate keys, and 
        engineered to track historical changes (SCD Type 2).

3. GOLD LAYER (Business-Ready Facts)
Tables: dw.FactTicketSales
Reason: This partitioned fact table sits in the Gold layer because it is fully 
        modeled at a specific business grain, optimized for read performance, 
        and ready to be directly consumed by BI dashboards or business analysts.

===============================================================================
PART B: DATA CONTRACT FOR bronze_bookings
===============================================================================
OWNER: Vayu Air Core Booking System Team
SLA / FRESHNESS: Daily batch delivery complete by 02:00 AM IST.

SCHEMA & DATA TYPES:
- booking_id (INT) : Primary Key
- passenger_id (INT)
- flight_id (INT)
- booking_date (DATE)
- travel_date (DATE)
- fare_class (VARCHAR)
- fare_amount (DECIMAL)
- tax_amount (DECIMAL)
- booking_status (VARCHAR)
- miles_earned (INT)

ALLOWED VALUES:
- fare_class: 'Economy', 'Premium Economy', 'Business', 'First'
- booking_status: 'Confirmed', 'Cancelled', 'NoShow'

CHANGE MANAGEMENT:
- Non-Breaking Change Example: Adding a new optional column (e.g., 'discount_code') 
  to the end of the schema. The pipeline will ignore it until mapped.
- Breaking Change Example: Renaming the 'fare_amount' column to 'base_fare', or 
  changing its data type from DECIMAL to VARCHAR. This will immediately fail 
  downstream SUM aggregations.
===============================================================================
*/