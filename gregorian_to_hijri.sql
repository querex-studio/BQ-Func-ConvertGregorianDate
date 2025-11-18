CREATE OR REPLACE FUNCTION `your_project.your_dataset.gregorian_to_hijri`(gregorian_date DATE) RETURNS STRUCT<year INT64, month INT64, day INT64> AS (
(
    WITH base_calc AS (
      SELECT 
        EXTRACT(YEAR FROM gregorian_date) AS gy,
        EXTRACT(MONTH FROM gregorian_date) AS gm,
        EXTRACT(DAY FROM gregorian_date) AS gd
    ),
    
    -- Calculate absolute day number from Gregorian epoch
    absolute_day AS (
      SELECT
        -- Calculate total days from year 1
        (gy - 1) * 365 +
        CAST(FLOOR((gy - 1) / 4) AS INT64) -
        CAST(FLOOR((gy - 1) / 100) AS INT64) +
        CAST(FLOOR((gy - 1) / 400) AS INT64) +
        -- Add days from months
        CASE 
          WHEN gm = 1 THEN 0
          WHEN gm = 2 THEN 31
          WHEN gm = 3 THEN 59
          WHEN gm = 4 THEN 90
          WHEN gm = 5 THEN 120
          WHEN gm = 6 THEN 151
          WHEN gm = 7 THEN 181
          WHEN gm = 8 THEN 212
          WHEN gm = 9 THEN 243
          WHEN gm = 10 THEN 273
          WHEN gm = 11 THEN 304
          WHEN gm = 12 THEN 334
        END +
        -- Add leap day if applicable
        CASE 
          WHEN gm > 2 AND (MOD(gy, 400) = 0 OR (MOD(gy, 4) = 0 AND MOD(gy, 100) != 0)) THEN 1
          ELSE 0
        END +
        gd AS abs_day
      FROM base_calc
    ),
    
    -- Islamic calendar epoch: July 16, 622 CE (Gregorian)
    -- This corresponds to absolute day 227015
    islamic_days AS (
      SELECT
        abs_day - 227015 AS days_since_hijri_epoch
      FROM absolute_day
    ),
    
    -- Calculate Islamic year
    -- Using more accurate cycle calculation
    year_calculation AS (
      SELECT
        days_since_hijri_epoch,
        -- Islamic calendar has 30-year cycles
        -- Each cycle = 10631 days (19 * 354 + 11 * 355)
        CAST(FLOOR(days_since_hijri_epoch / 10631) AS INT64) AS cycles,
        MOD(days_since_hijri_epoch, 10631) AS days_in_cycle
      FROM islamic_days
    ),
    
    -- Find year within current cycle
    year_in_cycle AS (
      SELECT
        cycles,
        days_in_cycle,
        -- Calculate which year in the 30-year cycle
        CASE
          WHEN days_in_cycle < 354 THEN 0
          WHEN days_in_cycle < 709 THEN 1   -- 354 + 355
          WHEN days_in_cycle < 1063 THEN 2  -- 709 + 354
          WHEN days_in_cycle < 1417 THEN 3  -- 1063 + 354
          WHEN days_in_cycle < 1772 THEN 4  -- 1417 + 355
          WHEN days_in_cycle < 2126 THEN 5  -- 1772 + 354
          WHEN days_in_cycle < 2481 THEN 6  -- 2126 + 355
          WHEN days_in_cycle < 2835 THEN 7  -- 2481 + 354
          WHEN days_in_cycle < 3189 THEN 8  -- 2835 + 354
          WHEN days_in_cycle < 3544 THEN 9  -- 3189 + 355
          WHEN days_in_cycle < 3898 THEN 10 -- 3544 + 354
          WHEN days_in_cycle < 4252 THEN 11 -- 3898 + 354
          WHEN days_in_cycle < 4607 THEN 12 -- 4252 + 355
          WHEN days_in_cycle < 4961 THEN 13 -- 4607 + 354
          WHEN days_in_cycle < 5315 THEN 14 -- 4961 + 354
          WHEN days_in_cycle < 5670 THEN 15 -- 5315 + 355
          WHEN days_in_cycle < 6024 THEN 16 -- 5670 + 354
          WHEN days_in_cycle < 6379 THEN 17 -- 6024 + 355
          WHEN days_in_cycle < 6733 THEN 18 -- 6379 + 354
          WHEN days_in_cycle < 7087 THEN 19 -- 6733 + 354
          WHEN days_in_cycle < 7442 THEN 20 -- 7087 + 355
          WHEN days_in_cycle < 7796 THEN 21 -- 7442 + 354
          WHEN days_in_cycle < 8150 THEN 22 -- 7796 + 354
          WHEN days_in_cycle < 8505 THEN 23 -- 8150 + 355
          WHEN days_in_cycle < 8859 THEN 24 -- 8505 + 354
          WHEN days_in_cycle < 9214 THEN 25 -- 8859 + 355
          WHEN days_in_cycle < 9568 THEN 26 -- 9214 + 354
          WHEN days_in_cycle < 9922 THEN 27 -- 9568 + 354
          WHEN days_in_cycle < 10277 THEN 28 -- 9922 + 355
          ELSE 29 -- 10277 + 354
        END AS year_index,
        -- Days at start of each year in cycle
        CASE
          WHEN days_in_cycle < 354 THEN 0
          WHEN days_in_cycle < 709 THEN 354
          WHEN days_in_cycle < 1063 THEN 709
          WHEN days_in_cycle < 1417 THEN 1063
          WHEN days_in_cycle < 1772 THEN 1417
          WHEN days_in_cycle < 2126 THEN 1772
          WHEN days_in_cycle < 2481 THEN 2126
          WHEN days_in_cycle < 2835 THEN 2481
          WHEN days_in_cycle < 3189 THEN 2835
          WHEN days_in_cycle < 3544 THEN 3189
          WHEN days_in_cycle < 3898 THEN 3544
          WHEN days_in_cycle < 4252 THEN 3898
          WHEN days_in_cycle < 4607 THEN 4252
          WHEN days_in_cycle < 4961 THEN 4607
          WHEN days_in_cycle < 5315 THEN 4961
          WHEN days_in_cycle < 5670 THEN 5315
          WHEN days_in_cycle < 6024 THEN 5670
          WHEN days_in_cycle < 6379 THEN 6024
          WHEN days_in_cycle < 6733 THEN 6379
          WHEN days_in_cycle < 7087 THEN 6733
          WHEN days_in_cycle < 7442 THEN 7087
          WHEN days_in_cycle < 7796 THEN 7442
          WHEN days_in_cycle < 8150 THEN 7796
          WHEN days_in_cycle < 8505 THEN 8150
          WHEN days_in_cycle < 8859 THEN 8505
          WHEN days_in_cycle < 9214 THEN 8859
          WHEN days_in_cycle < 9568 THEN 9214
          WHEN days_in_cycle < 9922 THEN 9568
          WHEN days_in_cycle < 10277 THEN 9922
          ELSE 10277
        END AS year_start_day
      FROM year_calculation
    ),
    
    -- Calculate final year and day of year
    hijri_year_day AS (
      SELECT
        cycles * 30 + year_index + 1 AS hy,
        days_in_cycle - year_start_day + 1 AS day_of_year
      FROM year_in_cycle
    ),
    
    -- Calculate month and day
    month_day AS (
      SELECT
        hy,
        CASE
          WHEN day_of_year <= 30 THEN 1
          WHEN day_of_year <= 59 THEN 2
          WHEN day_of_year <= 89 THEN 3
          WHEN day_of_year <= 118 THEN 4
          WHEN day_of_year <= 148 THEN 5
          WHEN day_of_year <= 177 THEN 6
          WHEN day_of_year <= 207 THEN 7
          WHEN day_of_year <= 236 THEN 8
          WHEN day_of_year <= 266 THEN 9
          WHEN day_of_year <= 295 THEN 10
          WHEN day_of_year <= 325 THEN 11
          ELSE 12
        END AS hm,
        CASE
          WHEN day_of_year <= 30 THEN day_of_year
          WHEN day_of_year <= 59 THEN day_of_year - 30
          WHEN day_of_year <= 89 THEN day_of_year - 59
          WHEN day_of_year <= 118 THEN day_of_year - 89
          WHEN day_of_year <= 148 THEN day_of_year - 118
          WHEN day_of_year <= 177 THEN day_of_year - 148
          WHEN day_of_year <= 207 THEN day_of_year - 177
          WHEN day_of_year <= 236 THEN day_of_year - 207
          WHEN day_of_year <= 266 THEN day_of_year - 236
          WHEN day_of_year <= 295 THEN day_of_year - 266
          WHEN day_of_year <= 325 THEN day_of_year - 295
          ELSE day_of_year - 325
        END AS hd
      FROM hijri_year_day
    )
    
    SELECT STRUCT(
      hy AS year,
      hm AS month,
      hd AS day
    )
    FROM month_day
  )
);