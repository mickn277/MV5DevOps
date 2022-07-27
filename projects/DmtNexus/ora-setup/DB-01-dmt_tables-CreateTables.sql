SET SCAN OFF

-- --------------------------------------------------------------------------------
-- Rollback
-- --------------------------------------------------------------------------------
/*
DROP VIEW dmt_blog_text_match_vw; 

DROP TABLE dmt_blog_text_match;
DROP SEQUENCE dmt_blog_text_match_sq;

DROP TABLE dmt_blog_posts;
DROP SEQUENCE dmt_blog_posts_sq;

DROP TABLE dmt_websites;

DROP TABLE dmt_text_lkp;
DROP SEQUENCE dmt_text_lkp_sq;
*/

-- --------------------------------------------------------------------------------
-- Websites
-- --------------------------------------------------------------------------------

CREATE TABLE dmt_websites(
  id NUMBER(5),
  website_url VARCHAR2(500)
);
CREATE UNIQUE INDEX dmt_websites_pk ON dmt_websites (id);
ALTER TABLE dmt_websites ADD CONSTRAINT dmt_websites_pk PRIMARY KEY (id) USING INDEX;

INSERT INTO dmt_websites(id, website_url) VALUES (1, 'https://www.dmt-nexus.me/forum/default.aspx?g=topics&f=3');
INSERT INTO dmt_websites(id, website_url) VALUES (2, 'https://www.dmt-nexus.me/forum/default.aspx?g=topics&f=71');
COMMIT;

-- --------------------------------------------------------------------------------
-- Blog Posts
-- --------------------------------------------------------------------------------

CREATE TABLE dmt_blog_posts(
  id NUMBER(11) NOT NULL,
  website_id NUMBER(5),
  page_id NUMBER(7),
  post_id NUMBER(7),
  post_text1 VARCHAR2(4000),
  post_text2 VARCHAR2(4000)
) COMPRESS FOR ALL OPERATIONS;

CREATE UNIQUE INDEX dmt_blog_posts_pk ON dmt_blog_posts (id);
ALTER TABLE dmt_blog_posts ADD CONSTRAINT dmt_blog_posts_pk PRIMARY KEY (id) USING INDEX;

CREATE UNIQUE INDEX dmt_blog_posts_uk1 ON dmt_blog_posts (website_id, page_id, post_id);
ALTER TABLE dmt_blog_posts ADD CONSTRAINT dmt_blog_posts_uk1 UNIQUE (website_id, page_id, post_id) USING INDEX;

ALTER TABLE dmt_blog_posts ADD CONSTRAINT dmt_blog_posts_fk1 FOREIGN KEY (website_id) REFERENCES  dmt_websites (id);

CREATE SEQUENCE  dmt_blog_posts_sq MINVALUE 1 MAXVALUE 99999999999 INCREMENT BY 1 START WITH 1 NOCACHE NOORDER  NOCYCLE  NOKEEP  NOSCALE  GLOBAL;

CREATE TRIGGER dmt_blog_posts_tr1 BEFORE INSERT OR UPDATE ON dmt_blog_posts FOR EACH ROW
BEGIN
  /* Onle set Created when INSERTING */
  IF INSERTING THEN
    IF (:NEW.id IS NULL) THEN
      SELECT dmt_blog_posts_sq.NEXTVAL INTO :NEW.id FROM dual; 
    END IF;
  END IF;
END;
/

-- --------------------------------------------------------------------------------
-- Text match
-- --------------------------------------------------------------------------------

CREATE TABLE dmt_text_lkp (
    id NUMBER(7) NOT NULL,
    text_meaning_desc VARCHAR2(255) NOT NULL,
    match_rank_weight NUMBER(1) DEFAULT 1 NOT NULL,
    text01 VARCHAR2(255),
    text02 VARCHAR2(255),
    text03 VARCHAR2(255),
    text04 VARCHAR2(255),
    text05 VARCHAR2(255),
    text06 VARCHAR2(255),
    text07 VARCHAR2(255),
    text08 VARCHAR2(255),
    text09 VARCHAR2(255),
    text10 VARCHAR2(255),
    archive NUMBER(1) DEFAULT 0 NOT NULL
);
CREATE SEQUENCE dmt_text_lkp_sq MINVALUE 1 MAXVALUE 99999999999 INCREMENT BY 1 START WITH 1 NOCACHE NOORDER  NOCYCLE  NOKEEP  NOSCALE  GLOBAL;

ALTER TABLE dmt_text_lkp ADD CONSTRAINT dmt_text_lkp_c1 CHECK (archive IN(0, -1));

CREATE TRIGGER dmt_text_lkp_tr1 BEFORE INSERT OR UPDATE ON dmt_text_lkp FOR EACH ROW
BEGIN
  /* Onle set Created when INSERTING */
  IF INSERTING THEN
    IF (:NEW.id IS NULL) THEN
      SELECT dmt_text_lkp_sq.NEXTVAL INTO :NEW.id FROM dual; 
    END IF;
  END IF;
END;
/

CREATE UNIQUE INDEX dmt_text_lkp_pk ON dmt_text_lkp (id);
ALTER TABLE dmt_text_lkp ADD CONSTRAINT dmt_text_lkp_pk PRIMARY KEY (id) USING INDEX;

-- --------------------------------------------------------------------------------
-- Text match
-- --------------------------------------------------------------------------------

CREATE TABLE dmt_blog_text_match (
    id NUMBER(11) NOT NULL,
    post_id NUMBER(11) NOT NULL,
    text_id NUMBER(7) NOT NULL,
    match_rank NUMBER(1) DEFAULT 0 NOT NULL
);

CREATE SEQUENCE  dmt_blog_text_match_sq MINVALUE 1 MAXVALUE 99999999999 INCREMENT BY 1 START WITH 1 NOCACHE NOORDER  NOCYCLE  NOKEEP  NOSCALE  GLOBAL;

CREATE TRIGGER dmt_blog_text_match_tr1 BEFORE INSERT OR UPDATE ON dmt_blog_text_match FOR EACH ROW
BEGIN
  /* Onle set Created when INSERTING */
  IF INSERTING THEN
    IF (:NEW.id IS NULL) THEN
      SELECT dmt_blog_text_match_sq.NEXTVAL INTO :NEW.id FROM dual; 
    END IF;
  END IF;
END;
/

CREATE UNIQUE INDEX dmt_blog_text_match_pk ON dmt_blog_text_match (id);
ALTER TABLE dmt_blog_text_match ADD CONSTRAINT dmt_blog_text_match_pk PRIMARY KEY (id) USING INDEX;

CREATE UNIQUE INDEX dmt_blog_text_match_uk1 ON dmt_blog_text_match (post_id, text_id);
ALTER TABLE dmt_blog_text_match ADD CONSTRAINT dmt_blog_text_match_uk1 UNIQUE (post_id, text_id) USING INDEX;

CREATE INDEX dmt_blog_text_match_ix1 ON dmt_blog_text_match (text_id);

ALTER TABLE dmt_blog_text_match ADD CONSTRAINT dmt_blog_text_match_fk1 FOREIGN KEY (post_id) REFERENCES  dmt_blog_posts (id);
ALTER TABLE dmt_blog_text_match ADD CONSTRAINT dmt_blog_text_match_fk2 FOREIGN KEY (text_id) REFERENCES  dmt_text_lkp (id);

