-- --------------------------------------------------------------------------------
-- 
-- --------------------------------------------------------------------------------
CREATE OR REPLACE VIEW fin_security_gics_vw AS
SELECT g.code, g.short_desc, g.gics_group, g.gics_group_level, g.description, g.notes,
    DECODE(3, g.gics_group_level, g.code, ind.gics_group_level, ind.code, NULL) INDUSTRY_CODE, 
    DECODE(3, g.gics_group_level, g.short_desc, ind.gics_group_level, ind.short_desc, NULL) INDUSTRY_SHORT_DESC, 
    DECODE(2, g.gics_group_level, g.code, ind.gics_group_level, ind.code, ig.gics_group_level, ig.code, NULL) IND_GROUP_CODE, 
    DECODE(2, g.gics_group_level, g.short_desc, ind.gics_group_level, ind.short_desc, ig.gics_group_level, ig.short_desc, NULL) IND_GROUP_SHORT_DESC, 
    DECODE(1, g.gics_group_level, g.code, ind.gics_group_level, ind.code, ig.gics_group_level, ig.code, s.gics_group_level, s.code, 'ERROR') SECTOR_CODE, 
    DECODE(1, g.gics_group_level, g.short_desc, ind.gics_group_level, ind.short_desc, ig.gics_group_level, ig.short_desc, s.gics_group_level, s.short_desc, 'ERROR') SECTOR_SHORT_DESC
FROM fin_security_gics g
    LEFT JOIN fin_security_gics ind ON (ind.code = g.parent_code)
    LEFT JOIN fin_security_gics ig ON (ig.code = ind.parent_code)
    LEFT JOIN fin_security_gics s ON (s.code = ig.parent_code)
;

/*
SELECT g.code, g.short_desc, g.gics_group, g.gics_group_level, g.description, g.notes,
    ind.code INDUSTRY_CODE, ind.short_desc INDUSTRY_SHORT_DESC,
    ig.code IND_GROUP_CODE, ig.short_desc IND_GROUP_SHORT_DESC,
    s.code SECTOR_CODE, s.short_desc SECTOR_SHORT_DESC
FROM fin_security_gics g
    LEFT JOIN fin_security_gics ind ON ((ind.code = g.parent_code AND g.gics_group_level = 4) OR (ind.code = g.code AND g.gics_group_level = 3))
    LEFT JOIN fin_security_gics ig ON ((ig.code = ind.parent_code AND ind.gics_group_level = 3) OR (ig.code = g.parent_code AND g.gics_group_level = 3) OR (ig.code = g.code AND g.gics_group_level = 2))
    LEFT JOIN fin_security_gics s ON ((s.code = ig.parent_code AND ig.gics_group_level = 2) OR (s.code = ind.parent_code AND ind.gics_group_level = 2) OR (s.code = g.parent_code AND g.gics_group_level = 2) OR (s.code = g.code AND g.gics_group_level = 1))
--ORDER BY g.gics_group_level DESC, g.code
;
*/
 