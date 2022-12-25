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
    day_dt,
    TRUNC(day_dt, 'IW') WEEK_DT,
    TRUNC(day_dt, 'MM') MONTH_DT,
    TRUNC(day_dt, 'YYYY') YEAR_DT,
    to_char(day_dt, 'Dy') DAY_OF_WEEK,
    DECODE(to_char(day_dt, 'DY'), 'SAT', 0, 'SUN', 0, -1) IS_WEEKDAY,
    DECODE(day_dt, TRUNC(day_dt, 'IW'), -1, 0) IS_START_OF_WORK_WEEK    
FROM (
    SELECT to_date('01-JAN-1870 AD', 'DD-MON-YYYY AD')+LEVEL-1 AS DAY_DT
    FROM dual
    CONNECT BY LEVEL-1 <= ((2100-1870)*365)+420
);

COMMENT ON TABLE db_dates_weekly_vw IS 'Daily Dates from 1st Jan 1870, the minimum date that daily financial records are likely to exist. Aligns with weekly data on Monday because TRUNC(date, ''IW'') returns a Monday which makes algorithms simpler.';

SELECT 
    TO_CHAR(MIN(day_dt), 'DD-MON-YYYY AD') MIN_DATE_VALUE,
    TO_CHAR(MAX(day_dt), 'DD-MON-YYYY AD') MAX_DATE_VALUE,
    count(*) TOTAL_DATES
FROM db_dates_daily_vw;