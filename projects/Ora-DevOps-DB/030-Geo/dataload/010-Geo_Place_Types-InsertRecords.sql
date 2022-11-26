REM INSERTING into GEO_PLACE_TYPES
SET DEFINE OFF;
INSERT INTO geo_place_types (type_code,parent_code,type_name,description) VALUES ('CON',null,'Continent',null);
INSERT INTO geo_place_types (type_code,parent_code,type_name,description) VALUES ('REG','CON','Region',null);
INSERT INTO geo_place_types (type_code,parent_code,type_name,description) VALUES ('COU','REG','Country',null);
INSERT INTO geo_place_types (type_code,parent_code,type_name,description) VALUES ('TER','REG','Territory',null);
INSERT INTO geo_place_types (type_code,parent_code,type_name,description) VALUES ('STA','COU','State',null);
INSERT INTO geo_place_types (type_code,parent_code,type_name,description) VALUES ('CIT','STA','City',null);
INSERT INTO geo_place_types (type_code,parent_code,type_name,description) VALUES ('TOW','STA','Town',null);
INSERT INTO geo_place_types (type_code,parent_code,type_name,description) VALUES ('SUB','CIT','Suburb',null);
INSERT INTO geo_place_types (type_code,parent_code,type_name,description) VALUES ('ARE','CON','Ancient Region',null);
INSERT INTO geo_place_types (type_code,parent_code,type_name,description) VALUES ('ACS','ARE','Ancient City State',null);
INSERT INTO geo_place_types (type_code,parent_code,type_name,description) VALUES ('ACI','ARE','Ancient City',null);
INSERT INTO geo_place_types (type_code,parent_code,type_name,description) VALUES ('ATO','ARE','Ancient Town',null);
INSERT INTO geo_place_types (type_code,parent_code,type_name,description) VALUES ('AUR','COU','Autonomous Region','Region with some autonomy from the parent Country');
COMMIT;
