# Question 2: Star Schema Design & DDL

## 🎯 Objective
This task focuses on physically building the foundation of the dimensional data warehouse. The SQL script creates a dedicated schema and defines the Data Definition Language (DDL) for a central fact table surrounded by its supporting dimensions, establishing a standard star schema architecture.

## 🏗️ Schema Creation
The script begins by establishing a dedicated `dw` (data warehouse) schema to logically isolate the analytical tables from the raw `bronze` source tables.

## 📐 Dimension Tables
Five dimension tables (`DimDate`, `DimAirport`, `DimAircraft`, `DimFlight`, `DimPassenger`) were created to hold the descriptive attributes for the sales data. The core design principle applied here is the strict separation of warehouse-generated identifiers from source system identifiers.

* **Surrogate Keys:** Every dimension utilizes a newly generated Surrogate Key as its Primary Key. For most tables, this is implemented as an auto-incrementing integer (`IDENTITY(1,1)`). 
* **Smart Date Key:** The `DimDate` table deviates slightly by using a deterministic, integer-based "smart key" format (`YYYYMMDD`) for its `DateKey`, which optimizes time-series querying and future table partitioning.
* **Business Keys:** The original identifiers from the source transactional system (e.g., `passenger_id`, `flight_id`, `airport_code`) are preserved in their respective tables. These act as Business Keys, allowing the data pipeline to map incoming source records to the correct dimension rows.

## 📊 Fact Table: FactTicketSales
The `FactTicketSales` table acts as the center of the star schema, built precisely at the declared grain of one confirmed ticket per flight.

* **Foreign Keys (The Slicing Axes):** The table stores only the integer Surrogate Keys (`DateKey`, `PassengerKey`, `FlightKey`, `OriginAirportKey`, `DestAirportKey`, `AircraftKey`). It enforces referential integrity through explicit `FOREIGN KEY` constraints pointing directly to the surrounding dimension tables.
* **Degenerate Dimensions:** Transactional attributes like `booking_id` and `fare_class` are stored directly within the fact table. They do not require a separate dimension table but act as filtering or identifying criteria.
* **Additive Measures:** The core quantitative metrics (`fare_amount`, `tax_amount`, `miles_earned`) are isolated in this table, ensuring they can be rapidly and safely summed across any combination of the dimensional axes.