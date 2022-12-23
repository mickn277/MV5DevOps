-- --------------------------------------------------------------------------------
-- Daily Dates from 1st Jan 1870, the minimum date that daily financial records are likely to exist.
-- Aligns with weekly data on Monday because TRUNC(date, 'IW') returns a Monday which makes algorithms simpler.
--
-- MIN_DATE_VALUE          MAX_DATE_VALUE          TOTAL_DATES
-- 01-JAN-1870 AD          31-DEC-2100 AD                84371
-- --------------------------------------------------------------------------------
--DROP VIEW db_dates_daily_vw;
CREATE OR REPLACE VIEW db_dates_daily_vw AS
SELECT
    date_value,
    TRUNC(date_value, 'IW') DATE_WEEK,
    to_date('01-'||to_char(date_value, 'MM-YYYY'), 'DD-MM-YYYY') DATE_MONTH,
    to_char(date_value, 'Dy') DAY_OF_WEEK,
    DECODE(to_char(date_value, 'DY'), 'SAT', 0, 'SUN', 0, -1) IS_WEEKDAY,
    DECODE(date_value, TRUNC(date_value, 'IW'), -1, 0) IS_START_OF_WORK_WEEK    
FROM (
    SELECT to_date('01-JAN-1870 AD', 'DD-MON-YYYY AD')+LEVEL-1 AS DATE_VALUE
    FROM dual
    CONNECT BY LEVEL-1 <= ((2100-1870)*365)+420
);

COMMENT ON TABLE db_dates_weekly_vw IS 'Daily Dates from 1st Jan 1870, the minimum date that daily financial records are likely to exist. Aligns with weekly data on Monday because TRUNC(date, ''IW'') returns a Monday which makes algorithms simpler.';

SELECT 
    TO_CHAR(MIN(date_value), 'DD-MON-YYYY AD') MIN_DATE_VALUE,
    TO_CHAR(MAX(date_value), 'DD-MON-YYYY AD') MAX_DATE_VALUE,
    count(*) TOTAL_DATES
FROM db_dates_daily_vw;