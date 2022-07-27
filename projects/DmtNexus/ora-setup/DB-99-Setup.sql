@DB-01-dmt_tables-CreateTables.sql
@DB-02-dmt_blog_text_match_vw-CreateView.sql
@DB-02-dmt_blog_text_match_totals_vw-CreateView.sql

/* Rollback
DROP VIEW dmt_blog_text_match_totals_vw;	-- 10
DROP VIEW dmt_blog_text_match_vw;	-- 10
DROP TABLE dmt_blog_text_match;	-- 20
DROP TABLE dmt_websites;	-- 25
DROP TABLE dmt_text_lkp;	-- 25
DROP TABLE dmt_blog_posts;	-- 25
DROP SEQUENCE dmt_blog_text_match_sq;	-- 30
DROP SEQUENCE dmt_text_lkp_sq;	-- 30
DROP SEQUENCE dmt_blog_posts_sq;	-- 30
*/