/*
===============================================================================
Stored Procedure: silver.load_silver
===============================================================================
Database: NYC_Airbnb_DW
Schema:   silver
Purpose:
    - Perform ETL (Extract, Transform, Load) from Bronze → Silver layer.
    - Cleanse, transform, and standardize raw data from bronze.NYC_airbnb_listing.
    - Populate silver.NYC_airbnb_listing with structured, typed, and enriched data.

Key Actions:
    1. Truncate target Silver table.
    2. Insert transformed data from Bronze table.
    3. Apply data type conversions, trimming, null handling, and derived columns.
    4. Log execution duration and handle errors gracefully.

Parameters:
    None

Usage:
    EXEC silver.load_silver;
===============================================================================
*/

USE NYC_Airbnb_DW;
GO

CREATE OR ALTER PROCEDURE silver.load_silver
AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME;

    BEGIN TRY
        SET @start_time = GETDATE();

        PRINT '================================================';
        PRINT 'Loading Silver Layer';
        PRINT '================================================';

        PRINT '------------------------------------------------';
        PRINT 'Loading silver.NYC_airbnb_listing Table';
        PRINT '------------------------------------------------';

        -- Step 1: Truncate target table
        PRINT '>> Truncating Table: silver.NYC_airbnb_listing';
        TRUNCATE TABLE silver.NYC_airbnb_listing;

        -- Step 2: Insert transformed data
        PRINT '>> Inserting Data Into: silver.NYC_airbnb_listing';

        INSERT INTO silver.NYC_airbnb_listing (
            ListingKey,
            id, last_scraped, host_id, host_name,
            hosts_time_as_user_years, hosts_time_as_user_months, host_as_user_total_months,
            hosts_time_as_host_years, hosts_time_as_host_months, host_as_host_total_months,
            host_is_superhost, host_listings_count, host_identity_verified,
            neighbourhood_cleansed, neighbourhood_group_cleansed,
            latitude, longitude, room_type, accommodates,
            bathrooms, bathrooms_text, bathrooms_count, bathroomtype,
            bedrooms, beds, price_doller,
            price_quote_checkin_date, price_quote_checkout_date, price_quote_total_price,
            minimum_nights, maximum_nights, has_availability,
            availability_30, availability_next_60, availability_next_90, availability_next_365,
            number_of_reviews, number_of_reviews_ltm, number_of_reviews_l30d,
            availability_eoy, number_of_reviews_ly,
            estimated_occupancy_l365d, estimated_revenue_l365d,
            first_review, last_review,
            review_scores_rating, review_scores_accuracy, review_scores_cleanliness,
            review_scores_checkin, review_scores_communication,
            review_scores_location, review_scores_value,
            calculated_host_listings_count,
            calculated_host_listings_count_entire_homes,
            calculated_host_listings_count_private_rooms,
            calculated_host_listings_count_shared_rooms,
            reviews_per_month
        )
        SELECT
            -- Generate surrogate key
            ROW_NUMBER() OVER (ORDER BY id, host_id ) AS ListingKey,

            -- Listing Information
            TRY_CAST(NULLIF(id,'') AS BIGINT),
            TRY_CONVERT(DATE, NULLIF(last_scraped, ''), 105),

            -- Host Information
            TRY_CAST(NULLIF(host_id, '') AS BIGINT),
            TRIM(NULLIF(host_name, '')),
            TRY_CAST(NULLIF(hosts_time_as_user_years, '') AS INT),
            TRY_CAST(NULLIF(hosts_time_as_user_months, '') AS INT),

            -- Derived: Total months as user
            CASE
                WHEN TRY_CAST(NULLIF(hosts_time_as_user_years, '') AS INT) IS NULL
                     AND TRY_CAST(NULLIF(hosts_time_as_user_months, '') AS INT) IS NULL
                THEN NULL
                ELSE ISNULL(TRY_CAST(NULLIF(hosts_time_as_user_years, '') AS INT), 0) * 12
                     + ISNULL(TRY_CAST(NULLIF(hosts_time_as_user_months, '') AS INT), 0)
            END,

            TRY_CAST(NULLIF(hosts_time_as_host_years, '') AS INT),
            TRY_CAST(NULLIF(hosts_time_as_host_months, '') AS INT),

            -- Derived: Total months as host
            CASE
                WHEN TRY_CAST(NULLIF(hosts_time_as_host_years, '') AS INT) IS NULL
                     AND TRY_CAST(NULLIF(hosts_time_as_host_months, '') AS INT) IS NULL
                THEN NULL
                ELSE ISNULL(TRY_CAST(NULLIF(hosts_time_as_host_years, '') AS INT), 0) * 12
                     + ISNULL(TRY_CAST(NULLIF(hosts_time_as_host_months, '') AS INT), 0)
            END,

            NULLIF(host_is_superhost, ''),
            TRY_CAST(NULLIF(host_listings_count, '') AS INT),
            NULLIF(host_identity_verified, ''),

            -- Location
            TRIM(NULLIF(neighbourhood_cleansed, '')),
            TRIM(NULLIF(neighbourhood_group_cleansed, '')),
            ROUND(TRY_CAST(NULLIF(latitude, '') AS DECIMAL(18,10)), 6),
            ROUND(TRY_CAST(NULLIF(longitude, '') AS DECIMAL(18,10)), 6),

            -- Property
            TRIM(NULLIF(room_type, '')),
            TRY_CAST(NULLIF(accommodates, '') AS INT),
            TRY_CAST(NULLIF(bathrooms, '') AS DECIMAL(6,2)),
            TRIM(NULLIF(bathrooms_text, '')),

            -- Derived: Bathroom count
            CASE
                WHEN bathrooms_text LIKE '[0-9]%' AND CHARINDEX(' ', bathrooms_text) > 0
                THEN TRY_CAST(LEFT(bathrooms_text, CHARINDEX(' ', bathrooms_text) - 1) AS DECIMAL(4,1))
                ELSE NULL
            END,

            -- Derived: Bathroom type
            CASE
                WHEN bathrooms_text LIKE '[0-9]%' AND CHARINDEX(' ', bathrooms_text) > 0
                THEN SUBSTRING(bathrooms_text, CHARINDEX(' ', bathrooms_text) + 1, LEN(bathrooms_text))
                WHEN bathrooms_text IS NULL OR bathrooms_text = ''
                THEN 'Unknown'
                ELSE bathrooms_text
            END,

            TRY_CAST(NULLIF(bedrooms, '') AS INT),
            TRY_CAST(NULLIF(beds, '') AS INT),

            -- Pricing
            TRY_CAST(REPLACE(REPLACE(NULLIF(price, ''), '$', ''), ',', '') AS DECIMAL(15,2)),
            TRY_CONVERT(DATE, NULLIF(price_quote_checkin_date, ''), 105),
            TRY_CONVERT(DATE, NULLIF(price_quote_checkout_date, ''), 105),
            TRY_CAST(NULLIF(price_quote_total_price, '') AS DECIMAL(15,2)),

            -- Booking Rules
            TRY_CAST(NULLIF(minimum_nights, '') AS INT),
            TRY_CAST(NULLIF(maximum_nights, '') AS INT),
            NULLIF(has_availability, ''),

            -- Availability
            TRY_CAST(NULLIF(availability_30, '') AS INT),
            TRY_CAST(NULLIF(availability_next_60, '') AS INT),
            TRY_CAST(NULLIF(availability_next_90, '') AS INT),
            TRY_CAST(NULLIF(availability_next_365, '') AS INT),

            -- Reviews
            TRY_CAST(NULLIF(number_of_reviews, '') AS INT),
            TRY_CAST(NULLIF(number_of_reviews_ltm, '') AS INT),
            TRY_CAST(NULLIF(number_of_reviews_l30d, '') AS INT),
            TRY_CAST(NULLIF(availability_eoy, '') AS INT),
            TRY_CAST(NULLIF(number_of_reviews_ly, '') AS INT),

            -- Performance
            TRY_CAST(NULLIF(estimated_occupancy_l365d, '') AS INT),
            TRY_CAST(NULLIF(estimated_revenue_l365d, '') AS INT),

            -- Review Dates
            TRY_CONVERT(DATE, NULLIF(first_review, ''), 105),
            TRY_CONVERT(DATE, NULLIF(last_review, ''), 105),

            -- Ratings
            ROUND(TRY_CAST(NULLIF(review_scores_rating, '') AS DECIMAL(18,4)), 1),
            TRY_CAST(NULLIF(review_scores_accuracy, '') AS DECIMAL(18,4)),
            TRY_CAST(NULLIF(review_scores_cleanliness, '') AS DECIMAL(18,4)),
            TRY_CAST(NULLIF(review_scores_checkin, '') AS DECIMAL(18,4)),
            TRY_CAST(NULLIF(review_scores_communication, '') AS DECIMAL(18,4)),
            TRY_CAST(NULLIF(review_scores_location, '') AS DECIMAL(18,4)),
            TRY_CAST(NULLIF(review_scores_value, '') AS DECIMAL(18,4)),

            -- Host Portfolio
            TRY_CAST(NULLIF(calculated_host_listings_count, '') AS INT),
            TRY_CAST(NULLIF(calculated_host_listings_count_entire_homes, '') AS INT),
            TRY_CAST(NULLIF(calculated_host_listings_count_private_rooms, '') AS INT),
            TRY_CAST(NULLIF(calculated_host_listings_count_shared_rooms, '') AS INT),

            -- Reviews per month
            TRY_CAST(NULLIF(reviews_per_month, '') AS DECIMAL(18,4))
        FROM bronze.NYC_airbnb_listing AS b;

        -- Step 3: Log completion

             SET @end_time = GETDATE();

             PRINT '>> NYC_airbnb_listing Table loadinng completed '
 
             PRINT '>> -------------';
             PRINT '=========================================='
             PRINT 'Loading Silver Layer is Completed'
             PRINT '==========================================';
             PRINT '>> Total load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
             
             END TRY

             BEGIN CATCH
		            PRINT '=========================================='
		            PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
		            PRINT 'Error Message' + ERROR_MESSAGE();
		            PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
		            PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
		            PRINT '=========================================='
	          END CATCH

      
     END
GO

     EXEC silver.load_silver;

GO
