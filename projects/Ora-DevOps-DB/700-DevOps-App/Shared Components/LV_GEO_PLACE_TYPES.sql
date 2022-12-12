SELECT code||' '||type_name d, code r
FROM geo_place_types
WHERE code != 'WLD'
ORDER BY order_id, code;

--LV_GEO_PLACE_TYPES