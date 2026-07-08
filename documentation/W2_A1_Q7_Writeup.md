# Question 7: Medallion Architecture & Data Contracts

## 🎯 Objective
A modern data warehouse requires strict governance to remain reliable. The objective of this final task is to logically organize the Vayu Air pipeline into Medallion architecture layers (Bronze, Silver, Gold) and define a strict Data Contract for the most critical source feed to prevent upstream engineering changes from breaking downstream BI reports.

## 🏅 Part A: Medallion Layer Mapping

Organizing tables into progression layers ensures data quality and clear dependency mapping.

### 🥉 Bronze Layer (Raw)
* **Tables:** `bronze_airports`, `bronze_aircraft`, `bronze_passengers`, `bronze_flights`, `bronze_bookings`, `stg_passenger_updates`.
* **Reason:** These tables sit in the Bronze layer because they act as the immutable landing zone. They represent the raw, unaltered data exactly as it was extracted from Vayu Air's transactional systems.

### 🥈 Silver Layer (Conformed & Cleansed)
* **Tables:** `dw.DimDate`, `dw.DimAircraft`, `dw.DimFlight`, `dw.DimCountry`, `dw.DimCity`, `dw.DimAirport_Snowflake`, `dw.DimPassenger_SCD2`.
* **Reason:** These tables sit in the Silver layer because they represent our conformed dimensions. The raw data has been transformed: surrogate keys generated, geography normalized (snowflaked), and complex business logic applied to track history (SCD Type 2). 

### 🥇 Gold Layer (Business-Ready)
* **Tables:** `dw.FactTicketSales`.
* **Reason:** This table sits in the Gold layer because it is built entirely for business consumption. It is modeled at a precise grain, contains only purely additive measures, and is partitioned for high-performance querying by BI tools and executive dashboards.

---

## 📜 Part B: Data Contract for `bronze_bookings`

To protect the Gold layer, the data engineering team and the upstream software engineers must agree on a strict contract for the core sales feed.

* **Data Owner:** Vayu Air Core Booking System Team
* **Freshness SLA:** Daily incremental batch must be landed in the Bronze zone no later than 02:00 AM IST.

### 🧱 Schema & Data Types
The downstream pipeline strictly expects the following structure:
* `booking_id` *(INT)*
* `passenger_id` *(INT)*
* `flight_id` *(INT)*
* `booking_date` *(DATE)*
* `travel_date` *(DATE)*
* `fare_class` *(VARCHAR)*
* `fare_amount` *(DECIMAL)*
* `tax_amount` *(DECIMAL)*
* `booking_status` *(VARCHAR)*
* `miles_earned` *(INT)*

### ✅ Allowed Values (Data Quality Constraints)
If categorical columns deviate from these exact string values, the rows will be quarantined.
* **`fare_class`:** Must be exactly one of: `'Economy'`, `'Premium Economy'`, `'Business'`, `'First'`.
* **`booking_status`:** Must be exactly one of: `'Confirmed'`, `'Cancelled'`, `'NoShow'`. *(Note: Revenue logic strictly depends on 'Confirmed').*

### ⚠️ Change Management Protocols
* **Example of a Non-Breaking Change:** The source team adds a new, optional column (e.g., `promo_code_applied`) to the very end of the file feed. The pipeline will safely ignore this new column until the analytics team decides to map it into the warehouse.
* **Example of a Breaking Change:** The source team renames `fare_amount` to `base_ticket_price` or changes its data type from `DECIMAL` to a string with currency symbols (e.g., `"₹5000"`). This breaks the contract and will immediately crash the downstream `FactTicketSales` load.