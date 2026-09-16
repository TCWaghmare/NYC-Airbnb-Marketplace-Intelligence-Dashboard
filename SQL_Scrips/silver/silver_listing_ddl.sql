/*
===============================================================================
DDL Script: Create Silver Table
===============================================================================
Purpose:
    - Defines the Silver layer table for Airbnb listings.
    - The Silver layer applies type casting, cleaning, and enrichment
      to raw Bronze data, preparing it for the Gold layer (star schema).
    - Columns are strongly typed (INT, DECIMAL, DATE, NVARCHAR) to ensure
      consistency and enable accurate transformations.

Usage:
    - This table is populated from the Bronze layer via ETL transformations.
    - Serves as the source for Gold layer dimension and fact views.
===============================================================================
*/

USE NYC_Airbnb_DW;
GO

-- Drop existing Silver table if it already exists
IF OBJECT_ID('silver.NYC_airbnb_listing', 'U') IS NOT NULL
    DROP TABLE silver.NYC_airbnb_listing;
GO

-- Create Silver table with cleaned schema
CREATE TABLE silver.NYC_airbnb_listing (

    ListingKey     INT,   -- Surrogate key for each listing

    -- Listing Information
    id                 BIGINT,
    last_scraped       DATE,

    -- Host Information
    host_id            BIGINT,
    host_name          NVARCHAR(255),
    hosts_time_as_user_years   INT,
    hosts_time_as_user_months  INT,
    host_as_user_total_months  INT,
    hosts_time_as_host_years   INT,
    hosts_time_as_host_months  INT,
    host_as_host_total_months  INT,
    host_is_superhost          NVARCHAR(10),   -- Boolean flag (t/f)
    host_listings_count        INT,
    host_identity_verified     NVARCHAR(10),   -- Boolean flag (t/f)

    -- Location
    neighbourhood_cleansed        NVARCHAR(50),
    neighbourhood_group_cleansed  NVARCHAR(50),
    latitude                      DECIMAL(18,10),
    longitude                     DECIMAL(18,10),

    -- Property
    room_type              NVARCHAR(100),
    accommodates           INT,
    bathrooms              DECIMAL(6,2),
    bathrooms_text         NVARCHAR(100),
    bathrooms_count        DECIMAL(6,2),
    bathroomtype           NVARCHAR(50),
    bathrooms_cleaned_count DECIMAL(6,2),
    bedrooms               INT,
    beds                   INT,

    -- Pricing
    price_doller              DECIMAL(18,2),
    price_quote_checkin_date  DATE,
    price_quote_checkout_date DATE,
    price_quote_total_price   DECIMAL(18,2),

    -- Booking Rules
    minimum_nights     INT,
    maximum_nights     INT,
    has_availability   NVARCHAR(10),   -- Boolean flag (t/f)

    -- Availability
    availability_30       INT,
    availability_next_60  INT,
    availability_next_90  INT,
    availability_next_365 INT,
    availability_eoy      INT,

    -- Reviews
    number_of_reviews      INT,
    number_of_reviews_ltm  INT,
    number_of_reviews_l30d INT,
    number_of_reviews_ly   INT,
    reviews_per_month      DECIMAL(6,2),

    -- Performance
    estimated_occupancy_l365d INT,
    estimated_revenue_l365d   INT,

    -- Review Dates
    first_review DATE,
    last_review  DATE,

    -- Ratings
    review_scores_rating        DECIMAL(6,2),
    review_scores_accuracy      DECIMAL(6,2),
    review_scores_cleanliness   DECIMAL(6,2),
    review_scores_checkin       DECIMAL(6,2),
    review_scores_communication DECIMAL(6,2),
    review_scores_location      DECIMAL(6,2),
    review_scores_value         DECIMAL(6,2),

    -- Host Portfolio
    calculated_host_listings_count              INT,
    calculated_host_listings_count_entire_homes INT,
    calculated_host_listings_count_private_rooms INT,
    calculated_host_listings_count_shared_rooms  INT
);
GO

