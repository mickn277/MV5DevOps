-- LV_FIN_SECURITIES
SELECT DECODE(short_desc, null, code,code||' ('||short_desc||')') d, code r, exchange_code g
FROM fin_securities s
WHERE archive != -1;