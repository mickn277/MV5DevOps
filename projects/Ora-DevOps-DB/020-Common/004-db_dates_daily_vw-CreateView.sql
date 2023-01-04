-- --------------------------------------------------------------------------------
-- Daily Dates from 1st Jan 0800, the minimum date that daily financial records are likely to exist.
-- Aligns with weekly data on Monday because TRUNC(date, 'IW') returns a Monday which makes algorithms simpler.
-- BugFix: Changed to start at 0800 to accommodate charting algorithms with daily, weekly, monthly, yearly data on the same chart.
--  need to monitor the performance impact.
--
-- MIN_DATE_VALUE          MAX_DATE_VALUE          TOTAL_DATES
-- 01-JAN-0800 AD	        31-DEC-2100 AD	        475177
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
    DECODE(day_dt, TRUNC(day_dt, 'IW'), -1, 0) IS_WEEKLY,
    DECODE(day_dt, TRUNC(day_dt, 'MM'), -1, 0) IS_MONTHLY,
    DECODE(day_dt, TRUNC(day_dt, 'YY'), -1, 0) IS_YEARLY
FROM (
    SELECT to_date('01-JAN-0800 AD', 'DD-MON-YYYY AD')+LEVEL-1 AS DAY_DT
    FROM dual
    CONNECT BY LEVEL-1 <= ((2101-0800)*365)+311
);

COMMENT ON TABLE db_dates_weekly_vw IS 'Daily Dates from 1st Jan 0800, the minimum date that daily financial records are likely to exist. Aligns with weekly data on Monday because TRUNC(date, ''IW'') returns a Monday which makes algorithms simpler.';

SELECT 
    TO_CHAR(MIN(day_dt), 'DD-MON-YYYY AD') MIN_DATE_VALUE,
    TO_CHAR(MAX(day_dt), 'DD-MON-YYYY AD') MAX_DATE_VALUE,
    count(*) TOTAL_DATES
FROM db_dates_daily_vw;