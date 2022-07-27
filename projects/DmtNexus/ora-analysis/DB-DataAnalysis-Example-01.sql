-- --------------------------------------------------------------------------------
-- Perform Search
-- --------------------------------------------------------------------------------
SELECT post_id, text_id, match_rank, vw.*
FROM dmt_blog_posts_text_match_vw vw
WHERE text_id IN (3,101);

-- --------------------------------------------------------------------------------
-- Update results table
-- --------------------------------------------------------------------------------
INSERT INTO dmt_blog_text_match (post_id, text_id, match_rank)(
    select post_id, text_id, match_rank 
    from dmt_blog_text_match_vw
    WHERE text_id IN (3)
);
COMMIT;