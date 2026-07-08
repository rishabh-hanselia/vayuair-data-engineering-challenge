# Vayu Air Data Warehouse Challenge (Session 3)

Welcome to my submission for the **Vayu Air Challenge**, the data modeling and warehouse engineering assignment for Week 2 in the **Codebasics Live Data Engineering Bootcamp**. 

This repository contains production-grade T-SQL solutions designed to move a fast-growing airline, **Vayu Air**, away from querying a live, fragile transactional database and toward a clean, high-performance dimensional data warehouse.

---

## 📌 Project Overview & Objectives

As Vayu Air scales its domestic and international routes, its analytical reporting has suffered from slow queries and inconsistent metrics across teams. This project builds a proper data warehouse infrastructure using **T-SQL on SQL Server (SSMS)** to achieve two primary corporate goals:

1. **Single Source of Truth:** Designing a robust star schema with a precisely defined grain to ensure revenue, route, and passenger analytics are fast, accurate, and consistent across all departments.
2. **Robust Data Pipeline Engineering:** Implementing enterprise-level data warehousing techniques, including Slowly Changing Dimensions (SCD Type 2) to track passenger loyalty history, snowflaking for geography normalization, table partitioning for large facts, and data governance via Medallion architecture and data contracts.

---

## 🛠️ Data Infrastructure & Schema

The solutions inside this repository transform raw source data into a scalable dimensional model, including:
* **Bronze (Source) Tables:** `bronze_airports`, `bronze_aircraft`, `bronze_passengers`, `bronze_flights`, `bronze_bookings`, and `stg_passenger_updates`.
* **Facts:** `FactTicketSales` (Partitioned by Date).
* **Dimensions:** `DimDate`, `DimPassenger` (SCD Type 2), `DimFlight`, `DimAircraft`.
* **Snowflaked Dimensions:** `DimAirport`, `DimCity`, `DimCountry`.

---

## 🚀 Engineering Principles Applied

Across these scripts, I focus on:
* **Dimensional Modeling:** Defining clear granularity, establishing surrogate primary/foreign key relationships, and isolating additive measures from descriptive attributes.
* **Historical Accuracy (CDC):** Implementing a two-step expire-then-insert `MERGE` pattern to capture Slowly Changing Dimensions (SCD2), ensuring past flights remain tied to historical passenger tiers.
* **Optimization & Performance:** Utilizing Partition Functions and Partition Schemes to shard the massive sales fact table, proving partition pruning efficiency via execution plan analysis.
* **Data Governance:** Structuring the pipeline into Bronze, Silver, and Gold medallion layers and defining strict Data Contracts (schema, SLAs, allowed values) for source feeds.

---

## 📂 Repository Layout

* `/solutions` - Individual `.sql` scripts mapping to the 7 assignment tasks.
* `/documentation` - Individual `.md` write-ups detailing architectural decisions and data contracts.

---

## 📝 Interactive Assignment Directory

### 📅 Week 2, Assignment 1: Data Modeling & Warehouse Engineering

Click on any question to view its dedicated architectural write-up or to jump directly into its production T-SQL script.

| Question | Business Objective | Technical Documentation | T-SQL Script |
| :---: | :--- | :---: | :---: |
| **01** | Grain Definition & Column Classification | [📄 View Architecture](./documentation/W2_A1_Q1_Writeup.md) | [💻 View Script](./solutions/W2_A1_Q1.sql) |
| **02** | Star Schema Design (DDL) | [📄 View Architecture](./documentation/W2_A1_Q2_Writeup.md) | [💻 View Script](./solutions/W2_A1_Q2.sql) |
| **03** | Fact & Dimension Population | [📄 View Architecture](./documentation/W2_A1_Q3_Writeup.md) | [💻 View Script](./solutions/W2_A1_Q3.sql) |
| **04** | Snowflaking Geography Dimensions | [📄 View Architecture](./documentation/W2_A1_Q4_Writeup.md) | [💻 View Script](./solutions/W2_A1_Q4.sql) |
| **05** | Slowly Changing Dimension (SCD Type 2) | [📄 View Architecture](./documentation/W2_A1_Q5_Writeup.md) | [💻 View Script](./solutions/W2_A1_Q5.sql) |
| **06** | Fact Table Partitioning & Execution Plans | [📄 View Architecture](./documentation/W2_A1_Q6_Writeup.md) | [💻 View Script](./solutions/W2_A1_Q6.sql) |
| **07** | Medallion Architecture & Data Contracts | [📄 View Architecture](./documentation/W2_A1_Q7_Writeup.md) | [💻 View Script](./solutions/W2_A1_Q7.sql) |
