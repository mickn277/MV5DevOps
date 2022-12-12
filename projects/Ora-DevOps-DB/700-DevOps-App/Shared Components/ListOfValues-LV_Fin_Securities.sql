-- LV_FIN_SECURITIES
SELECT TRIM(code||' '||DECODE(start_dt, null, null, '(')||
    DECODE(frequency, 'Y', TO_CHAR(start_dt,'YYYY'), 'M', TO_CHAR(start_dt,'MON-YYYY'), 'Q', TO_CHAR(start_dt,'MON-YYYY'), 'D', TO_CHAR(start_dt,'DD-MON-YYYY'), TO_CHAR(start_dt,'DD-MON-YYYY HH24:MI:SS'))||
    DECODE(end_dt, null, null, '~')||
    DECODE(frequency, 'Y', TO_CHAR(end_dt,'YYYY'), 'M', TO_CHAR(end_dt,'MON-YYYY'), 'Q', TO_CHAR(end_dt,'MON-YYYY'), 'D', TO_CHAR(end_dt,'DD-MON-YYYY'), TO_CHAR(end_dt,'DD-MON-YYYY HH24:MI:SS'))||
    CASE WHEN start_dt IS NOT NULL OR end_dt IS NOT NULL THEN ')' END)||':'||' '||short_desc
      d, code r
FROM fin_securities
WHERE archive != -1;