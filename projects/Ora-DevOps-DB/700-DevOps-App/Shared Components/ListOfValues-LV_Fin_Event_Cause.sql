-- LV_FIN_EVENT_CAUSE
SELECT short_desc d, id r
FROM fin_event_cause
WHERE archive != -1
ORDER BY order_id;