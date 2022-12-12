CREATE OR REPLACE VIEW fin_StockChart_Prices_vw AS
SELECT
    security_code,
    price_dt,
    ROUND(NVL(open, close), 4) OPEN,
    ROUND(NVL(high, close+(close*pr.hl_offset/2)), 4) HIGH,
    ROUND(NVL(low, close-(close*pr.hl_offset/2)), 4) LOW,
    ROUND(close, 4) CLOSE,
    volume,
    CASE 
        WHEN close > open THEN pr.up_colour
        WHEN close < open THEN pr.down_colour
        ELSE pr.default_colour
    END bar_colour,
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(custom_tooltip_text, '#DATE#', DECODE(s.price_frequency, 'Y', TO_CHAR(price_dt, 'YYYY'), 'M', TO_CHAR(price_dt, 'MON-YYYY'),  TO_CHAR(price_dt, 'DD-MON-YYYY'))), '#OPEN#', open), '#HIGH#', high), '#LOW#', low), '#CLOSE#', close), '#TEXT#', null) CUSTOM_TOOLTIP,
    'LEGEND_TOOLTIP' LEGEND_TOOLTIP,
    'LABEL_TOOLTIP' LABEL_TOOLTIP,
    'CUSTOM_COLUMN' CUSTOM_COLUMN
FROM
    fin_security_prices sp
    LEFT JOIN fin_securities s ON (sp.security_code = s.code)
    JOIN (SELECT 
        Params2_pkg.GetNumber('fin_StockChart_HL_Offset') HL_OFFSET,
        Params2_pkg.GetVARCHAR2('fin_StockChart_up_Colour') UP_COLOUR,
        Params2_pkg.GetVARCHAR2('fin_StockChart_down_Colour') DOWN_COLOUR,
        Params2_pkg.GetVARCHAR2('fin_StockChart_default_Colour') DEFAULT_COLOUR,
        Params2_pkg.GetVARCHAR2('fin_StockChart_Custom_Tooltip') CUSTOM_TOOLTIP_TEXT
        FROM dual) pr ON (1=1)
;

BEGIN
    Params2_pkg.SetNumber('fin_StockChart_HL_Offset', 0.04, 'StockChart', 'StockChart create a larger bar when Open, High, Low are null to make series legible.');
    Params2_pkg.SetVarchar2('fin_StockChart_up_Colour', '#508223', 'StockChart', 'StockChart bar colour when closing up.');
    Params2_pkg.SetVarchar2('fin_StockChart_down_Colour', '#D63B25', 'StockChart', 'StockChart bar colour when closing down.');
    Params2_pkg.SetVarchar2('fin_StockChart_default_Colour', '#FBF9F8', 'StockChart', 'StockChart bar colour default.');
    Params2_pkg.SetVarchar2('fin_StockChart_Custom_Tooltip', '<b>Date: #DATE#</b><br> Open: #OPEN#<br> High: #HIGH#<br> Low: #LOW#<br> Close: #CLOSE#', 'StockChart', 'StockChart custom_tooltip is displayed on hoverover of a bar. Fields #DATE#;  #OPEN#; #HIGH#; #LOW#; #CLOSE#; #TEXT#;');
END;
/

WITH security_prices AS (
SELECT
    sp.security_code,
    sp.price_dt,
    ROUND(NVL(sp.open, sp.close), 4) OPEN,
    ROUND(NVL(sp.high, sp.close+(sp.close*pr.hl_offset)), 4) HIGH,
    ROUND(NVL(sp.low, sp.close-(sp.close*pr.hl_offset)), 4) LOW,
    ROUND(sp.close, 4) CLOSE,
    sp.volume,
    e.short_desc
FROM
    fin_security_prices sp
    LEFT JOIN fin_securities s ON (sp.security_code = s.code)
    LEFT JOIN fin_events e ON ((s.code = e.security_code OR s.code = e.security_code_2nd OR s.code = e.security_code_3rd) AND sp.price_dt >= e.event_dt AND  sp.price_dt <= NVL(e.event_end_dt, e.event_dt))
    JOIN (SELECT 
        Params2_pkg.GetNumber('fin_StockChart_HL_Offset', 0.02, 'StockChart', 'StockChart create a larger bar when Open, High, Low are null to make series legible.') HL_OFFSET,
        Params2_pkg.GetVARCHAR2('fin_StockChart_up_Colour', '#508223', 'StockChart', 'StockChart bar colour when closing up.') UP_COLOUR,
        Params2_pkg.GetVARCHAR2('fin_StockChart_down_Colour', '#D63B25', 'StockChart', 'StockChart bar colour when closing down.') DOWN_COLOUR,
        Params2_pkg.GetVARCHAR2('fin_StockChart_default_Colour', '#FBF9F8', 'StockChart', 'StockChart bar colour default.') DEFAULT_COLOUR
        FROM dual) pr ON (1=1)
) 

SELECT 
    security_code,
    price_dt,
    open,
    high,
    low,
    close,
    volume,
    CASE 
        WHEN close > open THEN pr.up_colour
        WHEN close < open THEN pr.down_colour
        ELSE pr.default_colour
    END bar_colour,
    LISTAGG(e.short_desc, '; ') WITHIN GROUP (ORDER BY e.event_dt) CUSTOM_TOOLTIP,
    'LEGEND_TOOLTIP' LEGEND_TOOLTIP,
    'LABEL_TOOLTIP' LABEL_TOOLTIP,
    'CUSTOM_COLUMN' CUSTOM_COLUMN
FROM
    security_prices sp
    
    

;
