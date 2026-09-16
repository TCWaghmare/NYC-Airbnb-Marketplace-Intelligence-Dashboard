/*
===============================================================================
DDL Script: Create NYC_Airbnb_DW Database and Schemas
===============================================================================
Purpose:
    - Drops and recreates the NYC_Airbnb_DW database if it already exists.
    - Ensures a clean environment for ETL pipeline setup.
    - Creates three schemas (bronze, silver, gold) to represent the layered
      architecture of the data warehouse.

Layers:
    - Bronze: Raw ingested data (minimal processing).
    - Silver: Cleaned, typed, and standardized data.
    - Gold: Business-ready star schema (dimensions + facts).

Usage:
    Run this script before creating tables and stored procedures for each layer.
===============================================================================
*/

USE master;
GO

-- Drop and recreate the 'NYC_Airbnb_DW' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'NYC_Airbnb_DW')
BEGIN
    PRINT '>> Dropping existing NYC_Airbnb_DW database...';
    ALTER DATABASE NYC_Airbnb_DW SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE NYC_Airbnb_DW;
END;
GO

PRINT '>> Creating new NYC_Airbnb_DW database...';
CREATE DATABASE NYC_Airbnb_DW;
GO

-- Switch context to the newly created database
USE NYC_Airbnb_DW;
GO

-- Create schemas for layered architecture
PRINT '>> Creating schemas: bronze, silver, gold...';
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO

PRINT '>> Database and schemas created successfully!';

