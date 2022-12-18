-- --------------------------------------------------------------------------------
-- Monthly Dates from 1st Jan 1165, the minimum date that monthly financial data is likely to exist.
-- Months fall on the 1st of the month to aligh with yearly data.
--
-- MIN_DATE_VALUE          MAX_DATE_VALUE          TOTAL_DATES
-- 01-JAN-1165 AD          01-DEC-2100 AD                11232
-- --------------------------------------------------------------------------------
--DROP VIEW db_dates_monthly_vw;
CREATE OR REPLACE VIEW db_dates_monthly_vw AS
SELECT ADD_MONTHS(to_date('01-JAN-1165 AD', 'DD-MON-YYYY AD'), LEVEL-1) AS DATE_VALUE
FROM dual
CONNECT BY LEVEL-1 <= ((2100-1165)*12)+11
;



SELECT 
    TO_CHAR(MIN(date_value), 'DD-MON-YYYY AD') MIN_DATE_VALUE,
    TO_CHAR(MAX(date_value), 'DD-MON-YYYY AD') MAX_DATE_VALUE,
    count(*) TOTAL_DATES
FROM db_dates_monthly_vw;