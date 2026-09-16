/*
===============================================================================
Stored Procedure: bronze.load_bronze
===============================================================================
Purpose:
    - Loads raw Airbnb listing data from the staging table (dbo.nyc_airbnb_listing)
      into the Bronze layer (bronze.NYC_airbnb_listing).
    - Applies basic type casting and ensures all values are stored as NVARCHAR(100).
    - Serves as the ingestion step before Silver and Gold transformations.

Usage:
    EXEC bronze.load_bronze;
===============================================================================
*/

USE NYC_Airbnb_DW;
GO

CREATE OR ALTER PROCEDURE bronze.load_bronze
AS
BEGIN
    ---------------------------------------------------------------------------
    -- Insert into Bronze Table
    -- All columns are cast to NVARCHAR(100) for raw storage consistency.
    ---------------------------------------------------------------------------
    INSERT INTO bronze.NYC_airbnb_listing ( 
        id, last_scraped, host_id, host_name,
        hosts_time_as_user_years, hosts_time_as_user_months,
        hosts_time_as_host_years, hosts_time_as_host_months,
        host_is_superhost, 
        host_listings_count, 
        host_identity_verified,
        neighbourhood_cleansed, neighbourhood_group_cleansed,
        latitude, longitude, room_type, accommodates,
        bathrooms, bathrooms_text, bedrooms, beds, price,
        price_quote_checkin_date, price_quote_checkout_date,
        price_quote_total_price, price_quote_price_per_night,
        minimum_nights, maximum_nights, has_availability,
        availability_30, availability_next_60, availability_next_90,
        availability_next_365, number_of_reviews, number_of_reviews_ltm,
        number_of_reviews_l30d, availability_eoy, number_of_reviews_ly,
        estimated_occupancy_l365d, estimated_revenue_l365d,
        first_review, last_review, review_scores_rating,
        review_scores_accuracy, review_scores_cleanliness,
        review_scores_checkin, review_scores_communication,
        review_scores_location, review_scores_value,
        calculated_host_listings_count,
        calculated_host_listings_count_entire_homes,
        calculated_host_listings_count_private_rooms,
        calculated_host_listings_count_shared_rooms,
        reviews_per_month
    )
    SELECT
        TRY_CAST(id AS NVARCHAR(100))                          AS id,
        TRY_CAST(last_scraped AS NVARCHAR(100))                AS last_scraped,
        TRY_CAST(host_id AS NVARCHAR(100))                     AS host_id,
        TRY_CAST(host_name AS NVARCHAR(100))                   AS host_name,
        TRY_CAST(hosts_time_as_user_years AS NVARCHAR(100))    AS hosts_time_as_user_years,
        TRY_CAST(hosts_time_as_user_months AS NVARCHAR(100))   AS hosts_time_as_user_months,
        TRY_CAST(hosts_time_as_host_years AS NVARCHAR(100))    AS hosts_time_as_host_years,
        TRY_CAST(hosts_time_as_host_months AS NVARCHAR(100))   AS hosts_time_as_host_months,
        TRY_CAST(host_is_superhost AS NVARCHAR(100))           AS host_is_superhost,
        TRY_CAST(host_listings_count AS NVARCHAR(100))         AS host_listings_count,
        TRY_CAST(host_identity_verified AS NVARCHAR(100))      AS host_identity_verified,
        TRY_CAST(neighbourhood_cleansed AS NVARCHAR(100))      AS neighbourhood_cleansed,
        TRY_CAST(neighbourhood_group_cleansed AS NVARCHAR(100))AS neighbourhood_group_cleansed,
        TRY_CAST(latitude AS NVARCHAR(100))                    AS latitude,
        TRY_CAST(longitude AS NVARCHAR(100))                   AS longitude,
        TRY_CAST(room_type AS NVARCHAR(100))                   AS room_type,
        TRY_CAST(accommodates AS NVARCHAR(100))                AS accommodates,
        TRY_CAST(bathrooms AS NVARCHAR(100))                   AS bathrooms,
        TRY_CAST(bathrooms_text AS NVARCHAR(100))              AS bathrooms_text,
        TRY_CAST(bedrooms AS NVARCHAR(100))                    AS bedrooms,
        TRY_CAST(beds AS NVARCHAR(100))                        AS beds,
        TRY_CAST(price AS NVARCHAR(100))                       AS price,
        TRY_CAST(price_quote_checkin_date AS NVARCHAR(100))    AS price_quote_checkin_date,
        TRY_CAST(price_quote_checkout_date AS NVARCHAR(100))   AS price_quote_checkout_date,
        TRY_CAST(price_quote_total_price AS NVARCHAR(100))     AS price_quote_total_price,
        TRY_CAST(price_quote_price_per_night AS NVARCHAR(100)) AS price_quote_price_per_night,
        TRY_CAST(minimum_nights AS NVARCHAR(100))              AS minimum_nights,
        TRY_CAST(maximum_nights AS NVARCHAR(100))              AS maximum_nights,
        TRY_CAST(has_availability AS NVARCHAR(100))            AS has_availability,
        TRY_CAST(availability_30 AS NVARCHAR(100))             AS availability_30,
        TRY_CAST(availability_next_60 AS NVARCHAR(100))        AS availability_next_60,
        TRY_CAST(availability_next_90 AS NVARCHAR(100))        AS availability_next_90,
        TRY_CAST(availability_next_365 AS NVARCHAR(100))       AS availability_next_365,
        TRY_CAST(number_of_reviews AS NVARCHAR(100))           AS number_of_reviews,
        TRY_CAST(number_of_reviews_ltm AS NVARCHAR(100))       AS number_of_reviews_ltm,
        TRY_CAST(number_of_reviews_l30d AS NVARCHAR(100))      AS number_of_reviews_l30d,
        TRY_CAST(availability_eoy AS NVARCHAR(100))            AS availability_eoy,
        TRY_CAST(number_of_reviews_ly AS NVARCHAR(100))        AS number_of_reviews_ly,
        TRY_CAST(estimated_occupancy_l365d AS NVARCHAR(100))   AS estimated_occupancy_l365d,
        TRY_CAST(estimated_revenue_l365d AS NVARCHAR(100))     AS estimated_revenue_l365d,
        TRY_CAST(first_review AS NVARCHAR(100))                AS first_review,
        TRY_CAST(last_review AS NVARCHAR(100))                 AS last_review,
        TRY_CAST(review_scores_rating AS NVARCHAR(100))        AS review_scores_rating,
        TRY_CAST(review_scores_accuracy AS NVARCHAR(100))      AS review_scores_accuracy,
        TRY_CAST(review_scores_cleanliness AS NVARCHAR(100))   AS review_scores_cleanliness,
        TRY_CAST(review_scores_checkin AS NVARCHAR(100))       AS review_scores_checkin,
        TRY_CAST(review_scores_communication AS NVARCHAR(100)) AS review_scores_communication,
        TRY_CAST(review_scores_location AS NVARCHAR(100))      AS review_scores_location,
        TRY_CAST(review_scores_value AS NVARCHAR(100))         AS review_scores_value,
        TRY_CAST(calculated_host_listings_count AS NVARCHAR(100)) AS calculated_host_listings_count,
        TRY_CAST(calculated_host_listings_count_entire_homes AS NVARCHAR(100)) AS calculated_host_listings_count_entire_homes,
        TRY_CAST(calculated_host_listings_count_private_rooms AS NVARCHAR(100)) AS calculated_host_listings_count_private_rooms,
        TRY_CAST(calculated_host_listings_count_shared_rooms AS NVARCHAR(100))  AS calculated_host_listings_count_shared_rooms,
        TRY_CAST(reviews_per_month AS NVARCHAR(100))           AS reviews_per_month
    FROM dbo.nyc_airbnb_listing;
END;
GO

-- Execute the procedure to load Bronze data
EXEC bronze.load_bronze;
