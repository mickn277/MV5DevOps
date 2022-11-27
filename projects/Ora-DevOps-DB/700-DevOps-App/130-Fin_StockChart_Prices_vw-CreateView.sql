CREATE OR REPLACE VIEW fin_StockChart_Prices_vw AS
SELECT
    security_code,
    price_dt,
    ROUND(NVL(open, close), 4) OPEN,
    ROUND(NVL(high, close+(close*hl_offset)), 4) HIGH,
    ROUND(NVL(low, close-(close*hl_offset)), 4) LOW,
    ROUND(close, 4) CLOSE,
    volume
FROM
    fin_security_prices hp
    JOIN (SELECT Params2_pkg.GetNumber('fin_StockChart_HL_Offset', 0.02, 'StockChart', 'Create larger on a StockChart bar when Open, High, Low are null to make series legible.') HL_Offset FROM dual) pr ON (1=1)
;





/* 
SELECT * FROM fin_security_hist_Prices_vw;

SELECT code d, code r
FROM fin_securities
WHERE archive != -1;

*/