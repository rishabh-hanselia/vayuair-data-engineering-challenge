# Question 4: Snowflaking Geography

## 🎯 Objective
This task focuses on dimensional normalization by converting the flat, denormalized `DimAirport` table into a "Snowflake" schema. The geographical hierarchy is broken down into three distinct, linked tables (`DimCountry`, `DimCity`, and `DimAirport_Snowflake`) to demonstrate how to handle multi-tiered dimensional relationships.

## 🏗️ Schema Normalization
Instead of storing `city`, `country`, and `region` text repeatedly on every single airport row, the data was separated into a strict hierarchy using Foreign Keys:
1. **`DimCountry`:** Holds unique countries and their regions, generating a `CountryKey`.
2. **`DimCity`:** Holds unique cities and a Foreign Key (`CountryKey`) linking it to the country table.
3. **`DimAirport_Snowflake`:** Holds the specific airport details and a Foreign Key (`CityKey`) linking it to the city table.

## 🔄 Hierarchical Data Loading
Because of the Foreign Key constraints, the data had to be inserted in a strict top-down order to ensure the parent keys existed before the child records referenced them:
* **Step 1:** Extracted distinct countries from `bronze_airports`.
* **Step 2:** Extracted distinct cities, joining them to the newly created `DimCountry` to retrieve the auto-generated `CountryKey`.
* **Step 3:** Extracted the airports, joining them to the newly created `DimCity` to retrieve the auto-generated `CityKey`.

## ⚖️ Architectural Trade-off
Snowflaking a dimension represents a direct compromise between storage efficiency and query performance. 

**The Trade-off:** By snowflaking the geography dimension, we successfully eliminate redundant string data and reduce the overall storage footprint; however, we sacrifice read performance by forcing analytical queries and reporting tools to execute multiple joins to resolve an airport up to its country level.

## ✅ Acceptance Criteria Validation
To prove the structural integrity of the snowflake model, a validation query was written. It successfully performs a double `JOIN`—starting from `DimAirport_Snowflake`, bridging through `DimCity`, and landing on `DimCountry`—to reconstruct the full geographical hierarchy for a given flight origin or destination.