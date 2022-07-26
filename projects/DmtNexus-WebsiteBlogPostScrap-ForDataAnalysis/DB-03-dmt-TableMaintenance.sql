-- --------------------------------------------------------------------------------
-- Maintain all
-- --------------------------------------------------------------------------------

EXEC DBMS_STATS.GATHER_SCHEMA_STATS(ownname=>USER, cascade=>TRUE, estimate_percent=>DBMS_STATS.AUTO_SAMPLE_SIZE, options=>'GATHER AUTO' );

-- --------------------------------------------------------------------------------
-- Table maintenance
-- --------------------------------------------------------------------------------
BEGIN
  dbms_stats.gather_table_stats(ownname => USER, tabname => UPPER('dmt_websites'), estimate_percent => dbms_stats.auto_sample_size, method_opt => 'for all columns size auto');
  dbms_stats.gather_table_stats(ownname => USER, tabname => UPPER('dmt_blog_posts'), estimate_percent => dbms_stats.auto_sample_size, method_opt => 'for all columns size auto');
  dbms_stats.gather_table_stats(ownname => USER, tabname => UPPER('dmt_text_lkp'), estimate_percent => dbms_stats.auto_sample_size, method_opt => 'for all columns size auto');
  dbms_stats.gather_table_stats(ownname => USER, tabname => UPPER('dmt_blog_text_match'), estimate_percent => dbms_stats.auto_sample_size, method_opt => 'for all columns size auto');
  dbms_stats.gather_table_stats(ownname => USER, tabname => UPPER('dmt_blog_text_match'), estimate_percent => dbms_stats.auto_sample_size, method_opt => 'for all columns size auto');
END;
/
