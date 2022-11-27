-- LV_GEO_PLACES
SELECT DECODE(p.place_name, null, p.code, p.code||' ('||p.place_name||')') d, p.code r, DECODE(p.place_type, 'COU', null, p.place_type) g
FROM geo_places p;