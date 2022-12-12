SELECT
    p.security_code,
    DECODE(s.frequency, 'Y', TO_CHAR(p.price_dt, 'YYYY'), 'M', TO_CHAR(p.price_dt, 'YYYY-DD'),  TO_CHAR(p.price_dt, 'YYYY-MM-DD')) LABEL,
    p.value,
    --Params2_pkg.GetNumber('fin_LineChart_Val_Colour') VAL_COLOUR,
    NULL VAL_COLOUR,
    'CUSTOM_TOOLTIP'  CUSTOM_TOOLTIP,
    'LEGEND_TOOLTIP' LEGEND_TOOLTIP,
    'LABEL_TOOLTIP' LABEL_TOOLTIP,
    'CUSTOM_COLUMN' CUSTOM_COLUMN
FROM
    fin_securities s
    JOIN fin_security_histVal p ON (p.security_code = s.code)
WHERE s.code = :P3_SECURITY_ONE