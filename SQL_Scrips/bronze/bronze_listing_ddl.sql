/*
===============================================================================
DDL Script: Create Bronze Table
===============================================================================
Purpose:
    - Defines the Bronze layer table for raw Airbnb listings.
    - The Bronze layer stores ingested data in its raw form (minimal processing).
    - All columns are stored as NVARCHAR(100) to preserve original values
      without enforcing strict typing at this stage.

Usage:
    - This table is populated by the stored procedure [bronze.load_bronze].
    - Serves as the foundation for Silver layer transformations.
===============================================================================
*/

USE NYC_Airbnb_DW;   -- Connect to the NYC_Airbnb_DW database
GO

-- Drop existing Bronze table if it already exists
IF OBJECT_ID('bronze.nyc_airbnb_listing', 'U') IS NOT NULL
    DROP TABLE bronze.nyc_airbnb_listing;
GO

-- Create Bronze table with raw schema
CREATE TABLE bronze.nyc_airbnb_listing (
    -- Core identifiers
    id NVARCHAR(100),
    last_scraped NVARCHAR(100),
    host_id NVARCHAR(100),
    host_name NVARCHAR(100),

    -- Host tenure information
    hosts_time_as_user_years NVARCHAR(100),
    hosts_time_as_user_months NVARCHAR(100),
    hosts_time_as_host_years NVARCHAR(100),
    hosts_time_as_host_months NVARCHAR(100),

    -- Host attributes
    host_is_superhost NVARCHAR(100),
    host_listings_count NVARCHAR(100),
    host_identity_verified NVARCHAR(100),

    -- Location attributes
    neighbourhood_cleansed NVARCHAR(100),
    neighbourhood_group_cleansed NVARCHAR(100),
    latitude NVARCHAR(100),
    longitude NVARCHAR(100),

    -- Room attributes
    room_type NVARCHAR(100),
    accommodates NVARCHAR(100),
    bathrooms NVARCHAR(100),
    bathrooms_text NVARCHAR(100),
    bedrooms NVARCHAR(100),
    beds NVARCHAR(100),

    -- Pricing attributes
    price NVARCHAR(100),
    price_quote_checkin_date NVARCHAR(100),
    price_quote_checkout_date NVARCHAR(100),
    price_quote_total_price NVARCHAR(100),
    price_quote_price_per_night NVARCHAR(100),

    -- Availability attributes
    minimum_nights NVARCHAR(100),
    maximum_nights NVARCHAR(100),
    has_availability NVARCHAR(100),
    availability_30 NVARCHAR(100),
    availability_next_60 NVARCHAR(100),
    availability_next_90 NVARCHAR(100),
    availability_next_365 NVARCHAR(100),
    availability_eoy NVARCHAR(100),

    -- Review metrics
    number_of_reviews NVARCHAR(100),
    number_of_reviews_ltm NVARCHAR(100),
    number_of_reviews_l30d NVARCHAR(100),
    number_of_reviews_ly NVARCHAR(100),
    reviews_per_month NVARCHAR(100),

    -- Estimated metrics
    estimated_occupancy_l365d NVARCHAR(100),
    estimated_revenue_l365d NVARCHAR(100),

    -- Review dates
    first_review NVARCHAR(100),
    last_review NVARCHAR(100),

    -- Review scores
    review_scores_rating NVARCHAR(100),
    review_scores_accuracy NVARCHAR(100),
    review_scores_cleanliness NVARCHAR(100),
    review_scores_checkin NVARCHAR(100),
    review_scores_communication NVARCHAR(100),
    review_scores_location NVARCHAR(100),
    review_scores_value NVARCHAR(100),

    -- Calculated host listing counts
    calculated_host_listings_count NVARCHAR(100),
    calculated_host_listings_count_entire_homes NVARCHAR(100),
    calculated_host_listings_count_private_rooms NVARCHAR(100),
    calculated_host_listings_count_shared_rooms NVARCHAR(100)
);
GO

