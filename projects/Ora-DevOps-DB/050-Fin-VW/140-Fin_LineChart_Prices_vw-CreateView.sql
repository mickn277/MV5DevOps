CREATE OR REPLACE VIEW Fin_LineChart_Prices_vw AS
SELECT
    s.code,
    p.security_code||': '||s.short_desc SERIES_NAME,
    TO_CHAR(dd.day_dt, 'YYYY-MM-DD') LABEL,
    p.close VALUE,
    'CUSTOM_TOOLTIP'  CUSTOM_TOOLTIP,
    'LEGEND_TOOLTIP' LEGEND_TOOLTIP,
    'LABEL_TOOLTIP' LABEL_TOOLTIP,
    'CUSTOM_COLUMN' CUSTOM_COLUMN,
    DECODE(dd.day_dt, dd.year_dt, -1, null, 0, 0) IS_YEARLY,
    DECODE(dd.day_dt, dd.month_dt, -1, null, 0, 0) IS_MONTHLY,
    DECODE(dd.day_dt, dd.week_dt, -1, null, 0, 0) IS_WEEKLY,
    dd.is_weekday
FROM
    fin_securities s
    JOIN fin_security_prices p ON (p.security_code = s.code)
    JOIN db_dates_daily_vw dd ON (DECODE(s.frequency, 'Y', dd.year_dt, 'M', dd.month_dt, 'W', dd.week_dt, 'D', dd.day_dt) = p.price_dt)
WHERE s.archive != -1
;

/*
NOTES:
Example: Joining from fin_security_prices to db_dates_daily_vw on p.price_dt = dd.year_dt when the frequency is 'Y' (Yearly) causes records to duplicate for every day of the year.
This then allows filterning by IS_YEARLY, IS_MONTHLY, etc column to get both yearly, monthly, weekly series displaying daily, or any other combination.
It allows series with different frequencies to be displayed on the same chart together, however useless this might appear to be.
*/

/*
BEGIN
    Params2_pkg.SetVarchar2('Fin_Prices_LineChart_Colour01', '#508223', 'StockChart', 'StockChart bar colour when closing up.');
END;
/

 
SELECT * FROM fin_security_hist_Prices_vw;

*/