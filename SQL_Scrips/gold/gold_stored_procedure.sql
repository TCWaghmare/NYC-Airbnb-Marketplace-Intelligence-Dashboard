/*
===============================================================================
DDL Script: Create Gold Views (Star Schema)
===============================================================================
Script Purpose:
    - Defines the Gold layer views for the NYC Airbnb Data Warehouse.
    - The Gold layer represents the final star schema (fact + dimension tables).
    - Each view transforms and enriches data from the Silver layer into
      business-ready structures for analytics and reporting.

Usage:
    - Query these views directly in BI tools (e.g., Power BI, Tableau).
    - Provides clean, standardized, and enriched attributes for analysis.
===============================================================================
*/

USE NYC_Airbnb_DW;

-- =============================================================================
-- Dimension: Host Information
-- =============================================================================
IF OBJECT_ID('gold.dim_host','V') IS NOT NULL
    DROP VIEW gold.dim_host;
GO

CREATE VIEW gold.dim_host AS
SELECT
    ListingKey,
    host_id   AS HostID,
    host_name AS HostName,

    -- Convert boolean (t/f) to flag (0/1) for Superhost status
    CASE WHEN host_is_superhost = 't' THEN 1
         WHEN host_is_superhost = 'f' THEN 0
         ELSE NULL END AS IsSuperhost,

    -- Convert boolean (t/f) to flag (0/1) for Identity Verification
    CASE WHEN host_identity_verified = 't' THEN 1
         WHEN host_identity_verified = 'f' THEN 0
         ELSE NULL END AS IsIdentityVerified,

    host_listings_count                  AS TotalListings,
    calculated_host_listings_count       AS ActiveListings,
    calculated_host_listings_count_entire_homes AS EntireHomeListings,
    calculated_host_listings_count_private_rooms AS PrivateRoomListings,
    calculated_host_listings_count_shared_rooms  AS SharedRoomListings,

    -- Host tenure metrics
    hosts_time_as_user_years   AS UserYears,
    hosts_time_as_user_months  AS UserMonths,
    host_as_user_total_months  AS TotalUserMonths,
    hosts_time_as_host_years   AS HostYears,
    hosts_time_as_host_months  AS HostMonths,
    host_as_host_total_months  AS TotalHostMonths
FROM silver.NYC_airbnb_listing;
GO

-- =============================================================================
-- Dimension: Location Information
-- =============================================================================
IF OBJECT_ID('gold.dim_location','V') IS NOT NULL
    DROP VIEW gold.dim_location;
GO

CREATE VIEW gold.dim_location AS
SELECT
    ListingKey,
    neighbourhood_group_cleansed AS Borough,
    neighbourhood_cleansed       AS Neighborhood,
    latitude                     AS Latitude,
    longitude                    AS Longitude
FROM silver.NYC_airbnb_listing;
GO

-- =============================================================================
-- Dimension: Room Information
-- =============================================================================
IF OBJECT_ID('gold.dim_room','V') IS NOT NULL
    DROP VIEW gold.dim_room;
GO

CREATE VIEW gold.dim_room AS
SELECT
    ListingKey,
    room_type    AS RoomType,
    accommodates AS Capacity,
    bedrooms     AS Bedrooms,
    beds         AS Beds,

    -- Estimate beds if missing or inconsistent
    CASE WHEN beds IS NULL THEN bedrooms
         WHEN beds < bedrooms THEN bedrooms
         ELSE beds END AS EstimatedBeds,

    -- Flag bed data quality (Original / Adjusted / Estimated)
    CASE WHEN beds IS NULL AND bedrooms IS NOT NULL THEN 'Estimated'
         WHEN beds < bedrooms THEN 'Adjusted'
         ELSE 'Original' END AS BedDataQuality
FROM silver.NYC_airbnb_listing;
GO

-- =============================================================================
-- Dimension: Bathroom Information
-- =============================================================================
IF OBJECT_ID('gold.dim_bathroom','V') IS NOT NULL
    DROP VIEW gold.dim_bathroom;
GO

CREATE VIEW gold.dim_bathroom AS
SELECT
    ListingKey,
    bathroomtype AS BathroomType,

    -- Use cleaned bathroom count if available
    CASE WHEN bathrooms IS NULL AND bathrooms_count IS NOT NULL 
         THEN bathrooms_count
         ELSE bathrooms END AS BathroomCount,

    -- Privacy classification
    CASE WHEN bathroomtype LIKE '%Private%' THEN 'Private'
         WHEN bathroomtype LIKE '%Shared%'  THEN 'Shared'
         ELSE 'Unknown' END AS BathroomPrivacy,

    -- Category classification (Half / Full)
    CASE WHEN bathroomtype LIKE '%Half%' THEN 'Half'
         WHEN bathroomtype LIKE '%private bath%' 
           OR bathroomtype LIKE '%Shared bath%' 
           OR bathroomtype LIKE '%shared baths%' THEN 'Full'
         ELSE 'Unknown' END AS BathroomCategory
FROM silver.NYC_airbnb_listing;
GO

-- =============================================================================
-- Dimension: Availability Information
-- =============================================================================
IF OBJECT_ID('gold.dim_availability','V') IS NOT NULL
    DROP VIEW gold.dim_availability;
GO

CREATE VIEW gold.dim_availability AS
SELECT
    ListingKey,

    -- Convert boolean (t/f) to flag (0/1) for availability
    CASE WHEN has_availability = 't' THEN 1
         WHEN has_availability = 'f' THEN 0
         ELSE NULL END AS HasAvailability,

    availability_eoy AS AvailYearEnd
FROM silver.NYC_airbnb_listing;
GO

-- =============================================================================
-- Dimension: Review Information
-- =============================================================================
IF OBJECT_ID('gold.dim_review','V') IS NOT NULL
    DROP VIEW gold.dim_review;
GO

CREATE VIEW gold.dim_review AS
SELECT
    ListingKey,
    first_review AS FirstReview,
    last_review  AS LastReview
FROM silver.NYC_airbnb_listing;
GO

-- =============================================================================
-- Dimension: Date Information
-- =============================================================================
IF OBJECT_ID('gold.dim_date','V') IS NOT NULL
    DROP VIEW gold.dim_date;
GO

CREATE VIEW gold.dim_date AS
SELECT
    ListingKey,
    price_quote_checkin_date  AS CheckInDate,
    price_quote_checkout_date AS CheckOutDate
FROM silver.NYC_airbnb_listing;
GO

-- =============================================================================
-- Fact Table: Listing Metrics
-- =============================================================================
IF OBJECT_ID('gold.fact_listing','V') IS NOT NULL
    DROP VIEW gold.fact_listing;
GO

CREATE VIEW gold.fact_listing AS
SELECT
    ListingKey,
    id          AS ListingID,
    host_id     AS HostID,

    accommodates AS Capacity,
    minimum_nights AS MinNights,
    maximum_nights AS MaxNights,
    price_doller   AS Price,

    estimated_revenue_l365d   AS EstRevenue,
    estimated_occupancy_l365d AS EstOccupancy,

    availability_30     AS Avail30Days,
    availability_next_60 AS Avail60Days,
    availability_next_90 AS Avail90Days,
    availability_next_365 AS Avail365Days,

    number_of_reviews      AS TotalReviews,
    number_of_reviews_ltm  AS ReviewsLast12Months,
    number_of_reviews_l30d AS ReviewsLast30Days,
    number_of_reviews_ly   AS ReviewsLastYear,
    reviews_per_month      AS ReviewsPerMonth,

    -- Rounded review scores for consistency
    CAST(ROUND(review_scores_rating,1)        AS DECIMAL(2,1)) AS Rating,
    CAST(ROUND(review_scores_accuracy,1)      AS DECIMAL(2,1)) AS AccuracyRating,
    CAST(ROUND(review_scores_cleanliness,1)   AS DECIMAL(2,1)) AS CleanlinessRating,
    CAST(ROUND(review_scores_checkin,1)       AS DECIMAL(2,1)) AS CheckInRating,
    CAST(ROUND(review_scores_communication,1) AS DECIMAL(2,1)) AS CommunicationRating,
    CAST(ROUND(review_scores_location,1)      AS DECIMAL(2,1)) AS LocationRating,
    CAST(ROUND(review_scores_value,1)         AS DECIMAL(2,1)) AS ValueRating
FROM silver.NYC_airbnb_listing;
GO

