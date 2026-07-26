-- ==========================================================
-- Global YouTube Statistics — SQL Analysis
-- ==========================================================

-- Create Database
CREATE DATABASE YOUTUBE;

-- Use Database
USE YOUTUBE;

-- (Exploratory check only — comment out before final run)
-- SELECT * FROM cleaned_youtube_data;


-- ----------------------------------------------------------
-- TOP 10 CHANNELS BY SUBSCRIBERS
-- ----------------------------------------------------------
SELECT youtuber, subscribers
FROM cleaned_youtube_data
ORDER BY subscribers DESC
LIMIT 10;


-- ----------------------------------------------------------
-- TOP 10 CHANNELS BY VIEWS
-- ----------------------------------------------------------
SELECT youtuber, `video views`
FROM cleaned_youtube_data
ORDER BY `video views` DESC
LIMIT 10;


-- ----------------------------------------------------------
-- TOP 10 HIGHEST YEARLY EARNING CHANNELS
-- ----------------------------------------------------------
SELECT youtuber, highest_yearly_earnings
FROM cleaned_youtube_data
ORDER BY highest_yearly_earnings DESC
LIMIT 10;


-- ----------------------------------------------------------
-- TOP 10 HIGHEST MONTHLY EARNING CHANNELS
-- ----------------------------------------------------------
SELECT youtuber, highest_monthly_earnings
FROM cleaned_youtube_data
ORDER BY highest_monthly_earnings DESC
LIMIT 10;


-- ----------------------------------------------------------
-- TOP 10 CHANNELS WITH MOST UPLOADS
-- ----------------------------------------------------------
SELECT youtuber, uploads
FROM cleaned_youtube_data
ORDER BY uploads DESC
LIMIT 10;


-- ----------------------------------------------------------
-- TOTAL NUMBER OF CHANNELS IN DATASET
-- ----------------------------------------------------------
SELECT COUNT(*) AS total_channels
FROM cleaned_youtube_data;


-- ----------------------------------------------------------
-- AVERAGE SUBSCRIBERS ACROSS ALL CHANNELS
-- ----------------------------------------------------------
SELECT AVG(subscribers) AS avg_subscribers
FROM cleaned_youtube_data;


-- ----------------------------------------------------------
-- HIGHEST SUBSCRIBER COUNT (SINGLE VALUE)
-- ----------------------------------------------------------
SELECT MAX(subscribers) AS highest_subscribers
FROM cleaned_youtube_data;


-- ----------------------------------------------------------
-- CHANNELS FROM INDIA (sorted, so results are useful at a glance)
-- ----------------------------------------------------------
SELECT youtuber, subscribers
FROM cleaned_youtube_data
WHERE country = 'India'
ORDER BY subscribers DESC;


-- ----------------------------------------------------------
-- NUMBER OF CHANNELS BY COUNTRY
-- ----------------------------------------------------------
SELECT country, COUNT(*) AS total_channels
FROM cleaned_youtube_data
GROUP BY country
ORDER BY total_channels DESC;


-- ----------------------------------------------------------
-- NUMBER OF CHANNELS BY CATEGORY
-- ----------------------------------------------------------
SELECT category, COUNT(*) AS total
FROM cleaned_youtube_data
GROUP BY category
ORDER BY total DESC;


-- ----------------------------------------------------------
-- CHANNELS WITH MORE THAN 50 MILLION SUBSCRIBERS
-- ----------------------------------------------------------
SELECT youtuber, subscribers
FROM cleaned_youtube_data
WHERE subscribers > 50000000
ORDER BY subscribers DESC;


-- ----------------------------------------------------------
-- TOP EARNING CHANNEL IN EACH COUNTRY (FIXED)
-- Previous version used MAX(highest_yearly_earnings) grouped by
-- country, which returns the top earning VALUE per country but
-- not the channel name behind it (MAX() can't pull sibling
-- columns from the winning row). Fixed with a window function
-- so we get country, channel name, and earnings together.
-- ----------------------------------------------------------
SELECT country, youtuber, highest_yearly_earnings
FROM (
    SELECT
        country,
        youtuber,
        highest_yearly_earnings,
        ROW_NUMBER() OVER (
            PARTITION BY country
            ORDER BY highest_yearly_earnings DESC
        ) AS rn
    FROM cleaned_youtube_data
) ranked
WHERE rn = 1
ORDER BY highest_yearly_earnings DESC;


-- ----------------------------------------------------------
-- CHANNELS CREATED AFTER 2015
-- ----------------------------------------------------------
SELECT youtuber, created_year
FROM cleaned_youtube_data
WHERE created_year > 2015
ORDER BY created_year ASC;


-- ----------------------------------------------------------
-- FIRST (OLDEST) CHANNEL IN THE DATASET
-- ----------------------------------------------------------
SELECT youtuber, created_year, subscribers
FROM cleaned_youtube_data
ORDER BY created_year ASC
LIMIT 1;


-- ----------------------------------------------------------
-- ESTIMATED TOTAL EARNINGS TO DATE
-- Note: this is an APPROXIMATION — it assumes the channel's
-- current highest yearly earning rate has stayed constant since
-- creation, which isn't literally true (earnings fluctuate
-- year to year). Useful as a rough ranking, not an exact figure.
-- ----------------------------------------------------------
SELECT
    youtuber,
    created_year,
    highest_yearly_earnings,
    (highest_yearly_earnings * (YEAR(CURDATE()) - created_year + 1)) AS estimated_total_earnings
FROM cleaned_youtube_data
WHERE created_year IS NOT NULL
ORDER BY estimated_total_earnings DESC
LIMIT 10;


-- ----------------------------------------------------------
-- AVERAGE SUBSCRIBERS GAINED PER YEAR SINCE CHANNEL CREATION
-- Note: also an approximation — assumes linear subscriber growth
-- since the channel's creation year, which real growth rarely is.
-- ----------------------------------------------------------
SELECT
    youtuber,
    subscribers,
    created_year,
    (YEAR(CURDATE()) - created_year + 1) AS total_years,
    ROUND(subscribers / (YEAR(CURDATE()) - created_year + 1), 2) AS avg_subscribers_per_year
FROM cleaned_youtube_data
WHERE created_year IS NOT NULL
ORDER BY avg_subscribers_per_year DESC
LIMIT 10;