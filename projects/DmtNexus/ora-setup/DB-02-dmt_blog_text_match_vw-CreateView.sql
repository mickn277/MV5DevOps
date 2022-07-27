CREATE OR REPLACE VIEW dmt_blog_text_match_vw AS 
  SELECT 
    b.id POST_ID,
    t.id TEXT_ID,
    website_id WS,
    page_id PG, 
    post_id PS,
    
    text_meaning_desc MATCHE_TEXT_MEANING,
    
    -- Calculate RANK
    
    CASE WHEN text01 IS NOT NULL AND (lower(post_text1) LIKE '%'||lower(text01)||'%' OR lower(post_text2) LIKE '%'||lower(text01)||'%') THEN match_rank_weight ELSE 0 END + 
    CASE WHEN text02 IS NOT NULL AND (lower(post_text1) LIKE '%'||lower(text02)||'%' OR lower(post_text2) LIKE '%'||lower(text02)||'%') THEN match_rank_weight ELSE 0 END + 
    CASE WHEN text03 IS NOT NULL AND (lower(post_text1) LIKE '%'||lower(text03)||'%' OR lower(post_text2) LIKE '%'||lower(text03)||'%') THEN match_rank_weight ELSE 0 END + 
    CASE WHEN text04 IS NOT NULL AND (lower(post_text1) LIKE '%'||lower(text04)||'%' OR lower(post_text2) LIKE '%'||lower(text04)||'%') THEN match_rank_weight ELSE 0 END + 
    CASE WHEN text05 IS NOT NULL AND (lower(post_text1) LIKE '%'||lower(text05)||'%' OR lower(post_text2) LIKE '%'||lower(text05)||'%') THEN match_rank_weight ELSE 0 END + 
    CASE WHEN text06 IS NOT NULL AND (lower(post_text1) LIKE '%'||lower(text06)||'%' OR lower(post_text2) LIKE '%'||lower(text06)||'%') THEN match_rank_weight ELSE 0 END + 
    CASE WHEN text07 IS NOT NULL AND (lower(post_text1) LIKE '%'||lower(text07)||'%' OR lower(post_text2) LIKE '%'||lower(text07)||'%') THEN match_rank_weight ELSE 0 END + 
    CASE WHEN text08 IS NOT NULL AND (lower(post_text1) LIKE '%'||lower(text08)||'%' OR lower(post_text2) LIKE '%'||lower(text08)||'%') THEN match_rank_weight ELSE 0 END + 
    CASE WHEN text09 IS NOT NULL AND (lower(post_text1) LIKE '%'||lower(text09)||'%' OR lower(post_text2) LIKE '%'||lower(text09)||'%') THEN match_rank_weight ELSE 0 END + 
    CASE WHEN text10 IS NOT NULL AND (lower(post_text1) LIKE '%'||lower(text10)||'%' OR lower(post_text2) LIKE '%'||lower(text10)||'%') THEN match_rank_weight ELSE 0 END MATCH_RANK,
    
    -- Show Text Match
    
    COLUMNAGG(
      CASE WHEN text01 IS NOT NULL AND (lower(post_text1) LIKE '%'||lower(text01)||'%' OR lower(post_text2) LIKE '%'||lower(text01)||'%') THEN text01 END,   
      CASE WHEN text02 IS NOT NULL AND (lower(post_text1) LIKE '%'||lower(text02)||'%' OR lower(post_text2) LIKE '%'||lower(text02)||'%') THEN text02 END,  
      CASE WHEN text03 IS NOT NULL AND (lower(post_text1) LIKE '%'||lower(text03)||'%' OR lower(post_text2) LIKE '%'||lower(text03)||'%') THEN text03 END,   
      CASE WHEN text04 IS NOT NULL AND (lower(post_text1) LIKE '%'||lower(text04)||'%' OR lower(post_text2) LIKE '%'||lower(text04)||'%') THEN text04 END,   
      CASE WHEN text05 IS NOT NULL AND (lower(post_text1) LIKE '%'||lower(text05)||'%' OR lower(post_text2) LIKE '%'||lower(text05)||'%') THEN text05 END,   
      CASE WHEN text06 IS NOT NULL AND (lower(post_text1) LIKE '%'||lower(text06)||'%' OR lower(post_text2) LIKE '%'||lower(text06)||'%') THEN text06 END,   
      CASE WHEN text07 IS NOT NULL AND (lower(post_text1) LIKE '%'||lower(text07)||'%' OR lower(post_text2) LIKE '%'||lower(text07)||'%') THEN text07 END,   
      CASE WHEN text08 IS NOT NULL AND (lower(post_text1) LIKE '%'||lower(text08)||'%' OR lower(post_text2) LIKE '%'||lower(text08)||'%') THEN text08 END,   
      CASE WHEN text09 IS NOT NULL AND (lower(post_text1) LIKE '%'||lower(text09)||'%' OR lower(post_text2) LIKE '%'||lower(text09)||'%') THEN text09 END,   
      CASE WHEN text10 IS NOT NULL AND (lower(post_text1) LIKE '%'||lower(text10)||'%' OR lower(post_text2) LIKE '%'||lower(text10)||'%') THEN text10 END) MATCH_TEXT_CSV,

    -- Text Match
    
    CASE WHEN text01 IS NOT NULL AND lower(post_text1) LIKE '%'||lower(text01)||'%' THEN '~'||substr(post_text1, instr(lower(post_text1), text01, 1)-30, 30-1)||' >'||substr(post_text1, instr(lower(post_text1), text01, 1), LENGTH(text01))||'< '||substr(post_text1, instr(lower(post_text1), text01, 1)+LENGTH(text01)+1, 30)||'~ ' END ||
    CASE WHEN text01 IS NOT NULL AND lower(post_text2) LIKE '%'||lower(text01)||'%' THEN '~'||substr(post_text2, instr(lower(post_text1), text01, 1)-30, 30-1)||' >'||substr(post_text2, instr(lower(post_text2), text01, 1), LENGTH(text01))||'< '||substr(post_text2, instr(lower(post_text1), text01, 1)+LENGTH(text01)+1, 30)||'~ ' END ||
    
    CASE WHEN text02 IS NOT NULL AND lower(post_text1) LIKE '%'||lower(text02)||'%' THEN '~'||substr(post_text1, instr(lower(post_text1), text02, 1)-30, 30-1)||' >'||substr(post_text1, instr(lower(post_text1), text02, 1), LENGTH(text02))||'< '||substr(post_text1, instr(lower(post_text1), text02, 1)+LENGTH(text02)+1, 30)||'~ ' END ||
    CASE WHEN text02 IS NOT NULL AND lower(post_text2) LIKE '%'||lower(text02)||'%' THEN '~'||substr(post_text2, instr(lower(post_text1), text02, 1)-30, 30-1)||' >'||substr(post_text2, instr(lower(post_text2), text02, 1), LENGTH(text02))||'< '||substr(post_text2, instr(lower(post_text1), text02, 1)+LENGTH(text02)+1, 30)||'~ ' END ||
    
    CASE WHEN text03 IS NOT NULL AND lower(post_text1) LIKE '%'||lower(text03)||'%' THEN '~'||substr(post_text1, instr(lower(post_text1), text03, 1)-30, 30-1)||' >'||substr(post_text1, instr(lower(post_text1), text03, 1), LENGTH(text03))||'< '||substr(post_text1, instr(lower(post_text1), text03, 1)+LENGTH(text03)+1, 30)||'~ ' END ||
    CASE WHEN text03 IS NOT NULL AND lower(post_text2) LIKE '%'||lower(text03)||'%' THEN '~'||substr(post_text2, instr(lower(post_text1), text03, 1)-30, 30-1)||' >'||substr(post_text2, instr(lower(post_text2), text03, 1), LENGTH(text03))||'< '||substr(post_text2, instr(lower(post_text1), text03, 1)+LENGTH(text03)+1, 30)||'~ ' END ||

    CASE WHEN text04 IS NOT NULL AND lower(post_text1) LIKE '%'||lower(text04)||'%' THEN '~'||substr(post_text1, instr(lower(post_text1), text04, 1)-30, 30-1)||' >'||substr(post_text1, instr(lower(post_text1), text04, 1), LENGTH(text04))||'< '||substr(post_text1, instr(lower(post_text1), text04, 1)+LENGTH(text04)+1, 30)||'~ ' END ||
    CASE WHEN text04 IS NOT NULL AND lower(post_text2) LIKE '%'||lower(text04)||'%' THEN '~'||substr(post_text2, instr(lower(post_text1), text04, 1)-30, 30-1)||' >'||substr(post_text2, instr(lower(post_text2), text04, 1), LENGTH(text04))||'< '||substr(post_text2, instr(lower(post_text1), text04, 1)+LENGTH(text04)+1, 30)||'~ ' END || 

    CASE WHEN text05 IS NOT NULL AND lower(post_text1) LIKE '%'||lower(text05)||'%' THEN '~'||substr(post_text1, instr(lower(post_text1), text05, 1)-30, 30-1)||' >'||substr(post_text1, instr(lower(post_text1), text05, 1), LENGTH(text05))||'< '||substr(post_text1, instr(lower(post_text1), text05, 1)+LENGTH(text05)+1, 30)||'~ ' END ||
    CASE WHEN text05 IS NOT NULL AND lower(post_text2) LIKE '%'||lower(text05)||'%' THEN '~'||substr(post_text2, instr(lower(post_text1), text05, 1)-30, 30-1)||' >'||substr(post_text2, instr(lower(post_text2), text05, 1), LENGTH(text05))||'< '||substr(post_text2, instr(lower(post_text1), text05, 1)+LENGTH(text05)+1, 30)||'~ ' END ||

    CASE WHEN text06 IS NOT NULL AND lower(post_text1) LIKE '%'||lower(text06)||'%' THEN '~'||substr(post_text1, instr(lower(post_text1), text06, 1)-30, 30-1)||' >'||substr(post_text1, instr(lower(post_text1), text06, 1), LENGTH(text06))||'< '||substr(post_text1, instr(lower(post_text1), text06, 1)+LENGTH(text06)+1, 30)||'~ ' END ||
    CASE WHEN text06 IS NOT NULL AND lower(post_text2) LIKE '%'||lower(text06)||'%' THEN '~'||substr(post_text2, instr(lower(post_text1), text06, 1)-30, 30-1)||' >'||substr(post_text2, instr(lower(post_text2), text06, 1), LENGTH(text06))||'< '||substr(post_text2, instr(lower(post_text1), text06, 1)+LENGTH(text06)+1, 30)||'~ ' END ||  

    CASE WHEN text07 IS NOT NULL AND lower(post_text1) LIKE '%'||lower(text07)||'%' THEN '~'||substr(post_text1, instr(lower(post_text1), text07, 1)-30, 30-1)||' >'||substr(post_text1, instr(lower(post_text1), text07, 1), LENGTH(text07))||'< '||substr(post_text1, instr(lower(post_text1), text07, 1)+LENGTH(text07)+1, 30)||'~ ' END ||
    CASE WHEN text07 IS NOT NULL AND lower(post_text2) LIKE '%'||lower(text07)||'%' THEN '~'||substr(post_text2, instr(lower(post_text1), text07, 1)-30, 30-1)||' >'||substr(post_text2, instr(lower(post_text2), text07, 1), LENGTH(text07))||'< '||substr(post_text2, instr(lower(post_text1), text07, 1)+LENGTH(text07)+1, 30)||'~ ' END ||

    CASE WHEN text08 IS NOT NULL AND lower(post_text1) LIKE '%'||lower(text08)||'%' THEN '~'||substr(post_text1, instr(lower(post_text1), text08, 1)-30, 30-1)||' >'||substr(post_text1, instr(lower(post_text1), text08, 1), LENGTH(text08))||'< '||substr(post_text1, instr(lower(post_text1), text08, 1)+LENGTH(text08)+1, 30)||'~ ' END ||
    CASE WHEN text08 IS NOT NULL AND lower(post_text2) LIKE '%'||lower(text08)||'%' THEN '~'||substr(post_text2, instr(lower(post_text1), text08, 1)-30, 30-1)||' >'||substr(post_text2, instr(lower(post_text2), text08, 1), LENGTH(text08))||'< '||substr(post_text2, instr(lower(post_text1), text08, 1)+LENGTH(text08)+1, 30)||'~ ' END ||

    CASE WHEN text09 IS NOT NULL AND lower(post_text1) LIKE '%'||lower(text09)||'%' THEN '~'||substr(post_text1, instr(lower(post_text1), text09, 1)-30, 30-1)||' >'||substr(post_text1, instr(lower(post_text1), text09, 1), LENGTH(text09))||'< '||substr(post_text1, instr(lower(post_text1), text09, 1)+LENGTH(text09)+1, 30)||'~ ' END ||
    CASE WHEN text09 IS NOT NULL AND lower(post_text2) LIKE '%'||lower(text09)||'%' THEN '~'||substr(post_text2, instr(lower(post_text1), text09, 1)-30, 30-1)||' >'||substr(post_text2, instr(lower(post_text2), text09, 1), LENGTH(text09))||'< '||substr(post_text2, instr(lower(post_text1), text09, 1)+LENGTH(text09)+1, 30)||'~ ' END ||

    CASE WHEN text10 IS NOT NULL AND lower(post_text1) LIKE '%'||lower(text10)||'%' THEN '~'||substr(post_text1, instr(lower(post_text1), text10, 1)-30, 30-1)||' >'||substr(post_text1, instr(lower(post_text1), text10, 1), LENGTH(text10))||'< '||substr(post_text1, instr(lower(post_text1), text10, 1)+LENGTH(text10)+1, 30)||'~ ' END ||
    CASE WHEN text10 IS NOT NULL AND lower(post_text2) LIKE '%'||lower(text10)||'%' THEN '~'||substr(post_text2, instr(lower(post_text1), text10, 1)-30, 30-1)||' >'||substr(post_text2, instr(lower(post_text2), text10, 1), LENGTH(text10))||'< '||substr(post_text2, instr(lower(post_text1), text10, 1)+LENGTH(text10)+1, 30)||'~ ' END MATCH_TEXT_POST_SAMPLES
    
FROM dmt_blog_posts b JOIN dmt_text_lkp t 
    ON ((text01 IS NOT NULL AND (lower(post_text1) LIKE '%'||lower(text01)||'%' OR post_text2 LIKE '%'||lower(text01)||'%')) OR
        (text02 IS NOT NULL AND (lower(post_text1) LIKE '%'||lower(text02)||'%' OR post_text2 LIKE '%'||lower(text02)||'%')) OR
        (text03 IS NOT NULL AND (lower(post_text1) LIKE '%'||lower(text03)||'%' OR post_text2 LIKE '%'||lower(text03)||'%')) OR
        (text04 IS NOT NULL AND (lower(post_text1) LIKE '%'||lower(text04)||'%' OR post_text2 LIKE '%'||lower(text04)||'%')) OR
        (text05 IS NOT NULL AND (lower(post_text1) LIKE '%'||lower(text05)||'%' OR post_text2 LIKE '%'||lower(text05)||'%')) OR
        (text06 IS NOT NULL AND (lower(post_text1) LIKE '%'||lower(text06)||'%' OR post_text2 LIKE '%'||lower(text06)||'%')) OR
        (text07 IS NOT NULL AND (lower(post_text1) LIKE '%'||lower(text07)||'%' OR post_text2 LIKE '%'||lower(text07)||'%')) OR
        (text08 IS NOT NULL AND (lower(post_text1) LIKE '%'||lower(text08)||'%' OR post_text2 LIKE '%'||lower(text08)||'%')) OR
        (text09 IS NOT NULL AND (lower(post_text1) LIKE '%'||lower(text09)||'%' OR post_text2 LIKE '%'||lower(text09)||'%')) OR
        (text10 IS NOT NULL AND (lower(post_text1) LIKE '%'||lower(text10)||'%' OR post_text2 LIKE '%'||lower(text10)||'%')))
WHERE t.archive = 0
;