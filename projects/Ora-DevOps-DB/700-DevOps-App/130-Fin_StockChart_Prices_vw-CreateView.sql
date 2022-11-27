CREATE OR REPLACE VIEW fin_StockChart_Prices_vw AS
SELECT
    security_code,
    price_dt,
    ROUND(NVL(open, close), 4) OPEN,
    ROUND(NVL(high, close+(close*pr.hl_offset)), 4) HIGH,
    ROUND(NVL(low, close-(close*pr.hl_offset)), 4) LOW,
    ROUND(close, 4) CLOSE,
    volume,
    CASE 
        WHEN close > open THEN pr.up_colour
        WHEN close < open THEN pr.down_colour
        ELSE pr.default_colour
    END bar_colour,
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(custom_tooltip_text, '#DATE#', price_dt), '#OPEN#', open), '#HIGH#', high), '#LOW#', low), '#CLOSE#', close), '#TEXT#', null) CUSTOM_TOOLTIP,
    'LEGEND_TOOLTIP' LEGEND_TOOLTIP,
    'LABEL_TOOLTIP' LABEL_TOOLTIP,
    'CUSTOM_COLUMN' CUSTOM_COLUMN
FROM
    fin_security_prices sp
    LEFT JOIN fin_securities s ON (sp.security_code = s.code)
    JOIN (SELECT 
        Params2_pkg.GetNumber('fin_StockChart_HL_Offset', 0.02, 'StockChart', 'StockChart create a larger bar when Open, High, Low are null to make series legible.') HL_OFFSET,
        Params2_pkg.GetVARCHAR2('fin_StockChart_up_Colour', '#508223', 'StockChart', 'StockChart bar colour when closing up.') UP_COLOUR,
        Params2_pkg.GetVARCHAR2('fin_StockChart_down_Colour', '#D63B25', 'StockChart', 'StockChart bar colour when closing down.') DOWN_COLOUR,
        Params2_pkg.GetVARCHAR2('fin_StockChart_default_Colour', '#FBF9F8', 'StockChart', 'StockChart bar colour default.') DEFAULT_COLOUR,
        Params2_pkg.GetVARCHAR2('fin_StockChart_Custom_Tooltip', 'Date: #DATE#; Open: #OPEN#; High: #HIGH#; Low: #LOW#; Close: #CLOSE#', 'StockChart', 'StockChart custom_tooltip is displayed on hoverover of a bar. Fields #DATE#;  #OPEN#; #HIGH#; #LOW#; #CLOSE#; #TEXT#;') CUSTOM_TOOLTIP_TEXT
        FROM dual) pr ON (1=1)
;

/* 
SELECT * FROM fin_security_hist_Prices_vw;

SELECT code d, code r
FROM fin_securities
WHERE archive != -1;

*/