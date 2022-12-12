SELECT TRIM(code||' '||DECODE(price_start_dt, null, null, '(')||
    DECODE(price_frequency, 'Y', TO_CHAR(price_start_dt,'YYYY'), 'M', TO_CHAR(price_start_dt,'MON-YYYY'), 'Q', TO_CHAR(price_start_dt,'MON-YYYY'), 'D', TO_CHAR(price_start_dt,'DD-MON-YYYY'), TO_CHAR(price_start_dt,'DD-MON--YYYY HH24:MI:SS'))||
    DECODE(price_end_dt, null, null, '~')||
    DECODE(price_frequency, 'Y', TO_CHAR(price_end_dt,'YYYY'), 'M', TO_CHAR(price_end_dt,'MON-YYYY'), 'Q', TO_CHAR(price_end_dt,'MON-YYYY'), 'D', TO_CHAR(price_end_dt,'DD-MON-YYYY'), TO_CHAR(price_end_dt,'DD-MON--YYYY HH24:MI:SS'))||
    DECODE(price_start_dt, null, null, ')')||': '||short_desc
    )  d, code r
FROM fin_securities
WHERE archive != -1;

UPDATE geo_currencies
set descripton = REPLACE(descripton, code, currency_name);
commit;