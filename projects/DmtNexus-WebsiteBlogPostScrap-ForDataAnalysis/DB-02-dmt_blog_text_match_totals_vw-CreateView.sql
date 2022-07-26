CREATE OR REPLACE VIEW dmt_blog_text_match_totals_vw AS 
SELECT vw.post_id, vw.ws, vw.pg, vw.ps, 
    LISTAGG (text_id, ',') WITHIN GROUP (ORDER BY text_id) text_id_csv,
    LISTAGG (match_text_csv, ',') WITHIN GROUP (ORDER BY match_text_csv) match_text_csv, 
    SUM(match_rank) MATCH_RANK_SUM,
    bp.post_text1,
    bp.post_text2    
FROM dmt_blog_text_match_vw vw JOIN dmt_blog_posts bp ON (vw.post_id = bp.id)
GROUP BY vw.post_id, vw.ws, vw.pg, vw.ps, bp.post_text1, bp.post_text2;