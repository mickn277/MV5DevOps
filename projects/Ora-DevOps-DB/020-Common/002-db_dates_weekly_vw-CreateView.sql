-- --------------------------------------------------------------------------------
-- Weekly Dates from 1st 06th Jan 1800, the minimum date that weekly financial data is likely to exist.
-- Dates align with Monday of the week because TRUNC(date, 'IW') returns a Monday which makes algorithms simpler.
--
-- MIN_DATE_VALUE          MAX_DATE_VALUE          TOTAL_DATES
-- 06-JAN-1800 AD          28-DEC-2099 AD                15653
-- --------------------------------------------------------------------------------
--DROP VIEW db_dates_weekly_vw;
CREATE OR REPLACE VIEW db_dates_weekly_vw AS
SELECT
    date_value,
    to_date('01-'||to_char(date_value, 'MM-YYYY'), 'DD-MM-YYYY') DATE_MONTH,
    to_char(date_value, 'IW') ISO_WEEK_OF_YEAR
FROM (
    SELECT  TO_DATE('30-DEC-1799 AD', 'DD-MON-YYYY AD')+LEVEL*7 AS DATE_VALUE
    FROM dual
    CONNECT BY LEVEL-1 <= ((2100-1799)*52)
);

COMMENT ON TABLE db_dates_weekly_vw IS 'Weekly Dates from 1st 06th Jan 1800, the minimum date that weekly financial data is likely to exist. Dates align with Monday of the week because TRUNC(date, ''IW'') returns a Monday which makes algorithms simpler.';

SELECT
    TO_CHAR(MIN(date_value), 'DAY') DAY_OF_WEEK,
    TO_CHAR(MIN(date_value), 'DD-MON-YYYY AD') MIN_DATE_VALUE,
    TO_CHAR(MAX(date_value), 'DD-MON-YYYY AD') MAX_DATE_VALUE,
    count(*) TOTAL_DATES
FROM db_dates_weekly_vw;