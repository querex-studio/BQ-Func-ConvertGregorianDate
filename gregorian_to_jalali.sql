CREATE OR REPLACE FUNCTION `your_project.your_dataset.gregorian_to_jalali`(gregorian_date DATE) RETURNS STRUCT<year INT64, month INT64, day INT64> AS (
(
    WITH base_calc AS (
      SELECT 
        EXTRACT(YEAR FROM gregorian_date) AS gy,
        EXTRACT(MONTH FROM gregorian_date) AS gm,
        EXTRACT(DAY FROM gregorian_date) AS gd
    ),
    
    -- Prepare for calculation
    adjusted_date AS (
      SELECT
        gy,
        ARRAY[0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334][OFFSET(gm - 1)] + gd AS day_of_year,
        -- Add 1 if after February in a leap year
        CASE 
          WHEN gm > 2 AND (MOD(gy, 400) = 0 OR (MOD(gy, 4) = 0 AND MOD(gy, 100) != 0)) THEN 1 
          ELSE 0 
        END AS leap_adjustment
      FROM base_calc
    ),
    
    -- Core conversion algorithm
    conversion AS (
      SELECT
        CASE
          -- For dates from March 21 onwards
          WHEN day_of_year + leap_adjustment > 79 THEN
            STRUCT(
              CASE 
                WHEN MOD(gy, 400) = 0 OR (MOD(gy, 4) = 0 AND MOD(gy, 100) != 0) THEN gy - 1600
                ELSE gy - 1600
              END AS jy,
              day_of_year + leap_adjustment - 79 AS epy
            )
          -- For dates before March 21
          ELSE
            STRUCT(
              CASE 
                WHEN MOD(gy - 1, 400) = 0 OR (MOD(gy - 1, 4) = 0 AND MOD(gy - 1, 100) != 0) THEN gy - 1601
                ELSE gy - 1601
              END AS jy,
              365 + day_of_year + leap_adjustment - 79 + 
              CASE 
                WHEN MOD(gy - 1, 400) = 0 OR (MOD(gy - 1, 4) = 0 AND MOD(gy - 1, 100) != 0) THEN 1 
                ELSE 0 
              END AS epy
            )
        END AS result
      FROM adjusted_date
    ),
    
    -- Calculate month and day
    month_day_calc AS (
      SELECT
        result.jy + 979 AS jy,  -- Adjust to actual Jalali year
        CASE
          WHEN result.epy <= 186 THEN
            STRUCT(
              CAST(CEILING(result.epy / 31) AS INT64) AS jm,
              1 + MOD(result.epy - 1, 31) AS jd
            )
          ELSE
            STRUCT(
              CAST(CEILING((result.epy - 186) / 30) AS INT64) + 6 AS jm,
              1 + MOD(result.epy - 187, 30) AS jd
            )
        END AS month_day
      FROM conversion
    )
    
    SELECT STRUCT(
      jy AS year,
      month_day.jm AS month,
      month_day.jd AS day
    )
    FROM month_day_calc
  )
);