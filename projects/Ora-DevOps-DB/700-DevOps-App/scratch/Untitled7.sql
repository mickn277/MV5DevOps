SELECT
    security_code,
    price_dt,
    open,
    high,
    low,
    close,
    volume,
    bar_colour,
    custom_tooltip,
    legend_tooltip,
    label_tooltip,
    custom_column
FROM fin_stockchart_prices_vw
WHERE security_code = :P1004_SECURITY_ONE