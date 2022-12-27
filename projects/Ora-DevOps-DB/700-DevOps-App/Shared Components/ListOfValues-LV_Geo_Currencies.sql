-- LV_GEO_Currencies
SELECT c.code||' ('||c.description||')' d, c.code r
FROM geo_currencies c
ORDER BY c.code, c.description;