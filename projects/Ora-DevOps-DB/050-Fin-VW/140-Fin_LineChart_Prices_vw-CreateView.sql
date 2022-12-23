CREATE OR REPLACE VIEW Fin_LineChart_Prices_vw AS
SELECT
    p.security_code,
    DECODE(s.frequency, 'Y', TO_CHAR(p.price_dt, 'YYYY'), 'M', TO_CHAR(p.price_dt, 'YYYY-DD'),  TO_CHAR(p.price_dt, 'YYYY-MM-DD')) PRICE_DT,
    p.close,
    --Params2_pkg.GetNumber('fin_LineChart_Val_Colour') VAL_COLOUR,
    'LABEL' LABEL,
    'CUSTOM_TOOLTIP'  CUSTOM_TOOLTIP,
    'LEGEND_TOOLTIP' LEGEND_TOOLTIP,
    'LABEL_TOOLTIP' LABEL_TOOLTIP,
    'CUSTOM_COLUMN' CUSTOM_COLUMN
FROM
    fin_securities s
    JOIN fin_security_prices p ON (p.security_code = s.code)
WHERE archive != -1
;

/*
BEGIN
    Params2_pkg.SetVarchar2('Fin_Prices_LineChart_Colour01', '#508223', 'StockChart', 'StockChart bar colour when closing up.');
END;
/

 
SELECT * FROM fin_security_hist_Prices_vw;

*/