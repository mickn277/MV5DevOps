INSERT INTO Geo_Continents (Code, Continent_Name) VALUES ('AF', 'Africa');
INSERT INTO Geo_Continents (Code, Continent_Name) VALUES ('AN', 'Antarctica');
INSERT INTO Geo_Continents (Code, Continent_Name) VALUES ('AS', 'Asia');
INSERT INTO Geo_Continents (Code, Continent_Name) VALUES ('EU', 'Europe');
INSERT INTO Geo_Continents (Code, Continent_Name) VALUES ('NA', 'North America');
INSERT INTO Geo_Continents (Code, Continent_Name) VALUES ('OC', 'Oceania');
INSERT INTO Geo_Continents (Code, Continent_Name) VALUES ('SA', 'South America');
COMMIT;

EXECUTE DBMS_STATS.GATHER_TABLE_STATS(ownname=>USER, tabname=>UPPER('Geo_Continents'), cascade=>TRUE, estimate_percent=>DBMS_STATS.AUTO_SAMPLE_SIZE, method_opt=>'for all columns size auto');