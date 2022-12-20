-- --------------------------------------------------------------------------------
-- Daily Dates from 1st Jan 1875, the minimum date that daily financial records are likely to exist.
--
-- MIN_DATE_VALUE          MAX_DATE_VALUE          TOTAL_DATES
-- 01-JAN-1875 AD          31-DEC-2100 AD                82545
-- --------------------------------------------------------------------------------
--DROP VIEW db_dates_daily_vw;
CREATE OR REPLACE VIEW db_dates_daily_vw AS
SELECT to_date('01-JAN-1875 AD', 'DD-MON-YYYY AD')+LEVEL-1 AS DATE_VALUE
FROM dual
CONNECT BY LEVEL-1 <= ((2100-1875)*365)+419
;

SELECT 
    TO_CHAR(MIN(date_value), 'DD-MON-YYYY AD') MIN_DATE_VALUE,
    TO_CHAR(MAX(date_value), 'DD-MON-YYYY AD') MAX_DATE_VALUE,
    count(*) TOTAL_DATES
FROM db_dates_daily_vw;