-- --------------------------------------------------------------------------------
-- Monthly Dates from 1st Jan 1165, the minimum date that monthly financial data is likely to exist.
-- Months fall on the 1st of the month to aligh with yearly data.
--
-- MIN_DATE_VALUE          MAX_DATE_VALUE          TOTAL_DATES
-- 01-JAN-0800 AD          01-DEC-2100 AD                15612
-- --------------------------------------------------------------------------------
--DROP VIEW db_dates_monthly_vw;
CREATE OR REPLACE VIEW db_dates_monthly_vw AS
SELECT
    month_dt,
    TRUNC(month_dt, 'YYYY') YEAR_DT,
    to_char(month_dt, 'MM') MONTH_OF_YEAR
FROM (
    SELECT ADD_MONTHS(to_date('01-JAN-0800 AD', 'DD-MON-YYYY AD'), LEVEL-1) AS MONTH_DT
    FROM dual
    CONNECT BY LEVEL-1 <= ((2100-0800)*12)+11
);

COMMENT ON TABLE db_dates_monthly_vw IS 'Monthly Dates from 1st Jan 0800, the minimum date that monthly financial data is likely to exist.';

SELECT 
    TO_CHAR(MIN(month_dt), 'DD-MON-YYYY AD') MIN_DATE_VALUE,
    TO_CHAR(MAX(month_dt), 'DD-MON-YYYY AD') MAX_DATE_VALUE,
    count(*) TOTAL_DATES
FROM db_dates_monthly_vw;