-- LV_FIN_EVENT_EFFECT
SELECT short_desc||' ('||id||')' d, id r
FROM fin_event_effect
WHERE archive != -1
ORDER BY id;