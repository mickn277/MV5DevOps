-- --------------------------------------------------------------------------------
-- Example basic text search, before adding text into dmt_text_lkp
-- --------------------------------------------------------------------------------
SELECT w.website_url, b.* 
FROM dmt_blog_posts b JOIN dmt_websites w ON (b.website_id = w.id) 
WHERE (LOWER(post_text1) LIKE LOWER('%the%') OR LOWER(post_text2) LIKE LOWER('%the%'));

-- --------------------------------------------------------------------------------
-- Example insert using text above
-- --------------------------------------------------------------------------------
INSERT INTO dmt_text_lkp (text_meaning_desc, match_rank_weight, text01, text02, text03, text04, text05, text06, text07, text08, text09, text10) VALUES ('Types of drugs', 1, 'drug', 'lsd', 'psychedelic',  null, null, null, null, null, null, null);
COMMIT;

-- --------------------------------------------------------------------------------
-- Show the max page, post and total posts captured.
-- --------------------------------------------------------------------------------
SELECT ws.website_url, gr.website_id, max_page_id, max(post_id) MAX_POST_ID, total_posts FROM (
  SELECT website_id, max(page_id) MAX_PAGE_ID, count(*) TOTAL_POSTS 
  FROM dmt_blog_posts
  GROUP BY website_id
) gr JOIN dmt_blog_posts bp ON (gr.max_page_id=bp.page_id)
    JOIN dmt_websites ws ON (gr.website_id = ws.id)
GROUP BY ws.website_url, gr.website_id, max_page_id, total_posts;

-- --------------------------------------------------------------------------------
-- Show samples of text
-- --------------------------------------------------------------------------------
SELECT website_id WS, page_id PG, post_id PS, substr(post_text1, 1, 200) POST_TEXT_SAMPLE
FROM dmt_blog_posts b 
  JOIN dmt_websites w ON (b.website_id = w.id) 
ORDER BY website_id, page_id, post_id;





