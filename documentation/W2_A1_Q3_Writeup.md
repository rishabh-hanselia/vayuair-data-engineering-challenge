# Question 3: Fact & Dimension Population

## 🎯 Objective
This task transitions the architecture from design to implementation. The objective is to extract data from the raw `bronze` tables, populate the `dw` dimension tables to generate Surrogate Keys, and finally perform a consolidated join to load the central `FactTicketSales` table. 

## 🔄 Dimension Loading Strategy
The descriptive dimension tables (`DimAirport`, `DimAircraft`, `DimFlight`, `DimPassenger`) were loaded using standard `INSERT INTO ... SELECT` statements. Because the Primary Keys were defined as `IDENTITY(1,1)` during the DDL phase, the database engine automatically assigned a unique integer Surrogate Key to every row as it was ingested from the bronze layer.

### The DimDate Generation
To ensure referential integrity without needing to generate a decades-long calendar table, a Common Table Expression (CTE) was utilized. 
* The CTE uses `UNION` operators to extract every distinct date currently existing across all source tables (`booking_date`, `travel_date`, `flight_date`, `signup_date`).
* The integer `DateKey` is calculated dynamically using the formula `(YEAR * 10000) + (MONTH * 100) + DAY`, resulting in an optimized, readable format (e.g., `20251108`).

## 🌉 Fact Table Loading & Key Resolution
Loading the fact table requires translating the transactional source data into the dimensional model's new architecture. 

The core query selects from `bronze_bookings` and joins it to the newly populated `dw` dimension tables. 
* **The Bridge:** The joins are performed on the original **Business Keys** (e.g., `b.passenger_id = p.passenger_id`). 
* **The Resolution:** Instead of selecting the source IDs, the `SELECT` clause grabs the newly generated **Surrogate Keys** (e.g., `p.PassengerKey`). 
* **Flight Context:** Because `bronze_bookings` only contains a `flight_id`, it was joined to `bronze_flights` as an intermediary step to access the geographical and hardware business keys (`origin_airport_code`, `aircraft_code`) required to resolve the final dimension keys.

## ✅ Acceptance Criteria Validation
To satisfy the requirement that the fact table perfectly reflects the source bookings, the load includes all rows from `bronze_bookings`. A final validation query is included in the script to prove that the `COUNT(*)` of `dw.FactTicketSales` exactly matches the `COUNT(*)` of `bronze_bookings`, ensuring no data was dropped during the key resolution joins.