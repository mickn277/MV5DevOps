-- --------------------------------------------------------------------------------
-- Yearly dates from the minimum year that Oracle accepts.
-- Years fall on the 1st of Jan to align with Monthly data.
--
-- MIN_DATE_VALUE          MAX_DATE_VALUE          TOTAL_DATES
-- 01-JAN-4712 BC          01-JAN-2100 AD                 6813
-- --------------------------------------------------------------------------------

--DROP VIEW db_dates_yearly_vw;
CREATE OR REPLACE VIEW db_dates_yearly_vw AS
SELECT ADD_MONTHS(to_date('01-JAN-4712 BC', 'DD-MON-YYYY AD'), (12*LEVEL)-12) AS DATE_VALUE
FROM dual
CONNECT BY LEVEL-1 <= (4712+2100)
;

COMMENT ON TABLE db_dates_yearly_vw IS 'Yearly dates from the minimum year that Oracle accepts. Years fall on the 1st of Jan to align with Monthly data.';

SELECT 
    TO_CHAR(MIN(date_value), 'DD-MON-YYYY AD') MIN_DATE_VALUE,
    TO_CHAR(MAX(date_value), 'DD-MON-YYYY AD') MAX_DATE_VALUE, 
    count(*) TOTAL_DATES
FROM db_dates_yearly_vw;
