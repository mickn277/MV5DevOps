-- ================================================================================
-- Update Start_Dt, End_Dt into fin_Security table
-- ================================================================================
MERGE INTO fin_securities dst
USING (
    SELECT security_code, min(price_dt) START_DT, max(price_dt) END_DT, 'H' SERIES_TABLE
    FROM fin_security_histVal
    GROUP BY security_code
) src ON (src.security_code = dst.code)
WHEN MATCHED THEN
UPDATE SET 
    dst.start_dt = src.start_dt,
    dst.end_dt = src.end_dt,
    dst.series_table = src.series_table
;
COMMIT;

MERGE INTO fin_securities dst
USING (
    SELECT security_code, min(price_dt) START_DT, max(price_dt) END_DT, 'P' SERIES_TABLE
    FROM fin_security_prices
    GROUP BY security_code
) src ON (src.security_code = dst.code)
WHEN MATCHED THEN
UPDATE SET 
    dst.start_dt = src.start_dt,
    dst.end_dt = src.end_dt,
    dst.series_table = src.series_table
;
COMMIT;