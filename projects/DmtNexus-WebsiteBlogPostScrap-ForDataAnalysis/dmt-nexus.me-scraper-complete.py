#!/usr/bin/env python

# --------------------------------------------------------------------------------
# Purpose:
#   Scrape dmt-nexus.me website forum blog posts for reasearch.
#
# Requirements:
#   See README.md for python install requirements.
#   Environment variable ENC_KEY is reqiured to decrypt embeded passwords.
#   XEPDB1_Marvin5: Oracle XE database has been built using Vagrant and Virtualbox for this script to write to.
#       See: https://github.com/n2779510/MV5Servers/tree/master/Vagrant-XE18c-Apex19c
#   Database schema and tables created for this project .\emma_db-CreateTables.sql
#
# History:
#   18/07/2022 mick277@yandex.com:  Wrote Script.
# --------------------------------------------------------------------------------

import signal
import sys

import os
import aes256
from selenium import webdriver
from selenium.common import exceptions
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
#import html2text
from time import sleep
import cx_Oracle

# Environment variable on Mick's WebSvr PC to enable AES256 password decryption
enc_key = os.environ.get('ENC_KEY')

# Database connection info
db_tns="XEPDB1_Marvin5"
db_usr="devopsd"
db_enc_pwd=u"U2FsdGVkX19UeC5hv3IHtp2RMsQZaef7CoOJVYCwfys="
db_pwd=aes256.decrypt(db_enc_pwd, enc_key)

# Website forum login, not needed for scraping 
#web_user="rogernext" # physical login
#web_enc_pwd=u"U2FsdGVkX19/sEtqTw0WWpm+B21obsWIVQ5jCq+MGkE="
#web_pwd=aes256.decrypt(web_enc_pwd, enc_key)
#web_email="mick277@yandex.com"

#forum_id=3 # DMT Experiences
#db_website_id=1
forum_id=71 # DMT - Quality experience reports
db_website_id=2 # See database websites.id value
page_max=4 # Can be an estimate if not known
start_page_id=1 # Default 1.
start_post_id=1 # Default 1.

page_id=start_page_id
post_id=1 # Don't Change

URL="https://www.dmt-nexus.me/forum/default.aspx?g=topics&f={0}&p={1}".format(forum_id, start_page_id)

# Register Ctrl-C as exit script
def signal_handler(sig, frame):
    print('You pressed Ctrl+C, exiting script!')
    sys.exit(0)

# Register Ctrl-C as exit script
signal.signal(signal.SIGINT, signal_handler)

try:
    db_conn = cx_Oracle.connect(user=db_usr, password=db_pwd, dsn=db_tns, encoding="UTF-8")
except cx_Oracle.Error as ex:
    print("[ERROR] {}".format(ex))
    exit()

sql = ("INSERT INTO emma_blog_posts(website_id, page_id, post_id, post_text1, post_text2) values({0}, :page_id, :post_id, :db_post_text1, :db_post_text2)").format(db_website_id)

# Put stuff in database
def insertToDb(page_id, post_id, post_text):
    # TODO: develop some string processing for Oracle databases.  
    # Maybe in code determine the length so python string doesn't exceed Oracle VARCHAR2 length.
    db_post_text = post_text.encode('ascii', 'ignore').decode()
    #db_post_text = html2text.html2text(post_text)
    db_post_text1 = db_post_text[:3999]
    db_post_text2 = db_post_text[4000:7999]
    try:
        with db_conn.cursor() as cursor:
            # execute the insert statement
            cursor.execute(sql, [page_id, post_id, db_post_text1, db_post_text2])
            # commit work
            db_conn.commit()
    except cx_Oracle.Error as ex:
        print("[ERROR] page {0}, post {1}: {2}".format(page_id, post_id, ex))
        # Continue after exception

# Clean up a short text for command line
def TextSample(post_text):
    ret_text=post_text.replace("\r\n", " ") # Strip CRLF
    ret_text=ret_text.replace("\r", " ") # Strip any remaining CR's
    ret_text=ret_text.replace("\n", " ") # Strip any remaining LF's
    return ret_text[:50] # Just 50 Chars

driver = webdriver.Chrome()
driver.get(URL)

# Loop through all the pages, break potential infinate loops
while ((not driver.find_elements(By.CLASS_NAME, "pagelinknext") is None) and (page_id <= page_max)):
    
    if (page_id >= start_page_id):
        posts = driver.find_elements(By.CLASS_NAME, "nexus_topic_post_link")

        # Loop through all article links on the current page
        for post_idx, post in enumerate(posts):
            post_id=post_idx+1
            
            # Resume from the start page and start post, if specified
            if ((page_id > start_page_id) or (page_id == start_page_id and post_id >= start_post_id)):
                #print(post.text) # DEBUG:

                # Save the current window 
                main_window = driver.current_window_handle

                # Open link in a new tab
                post.send_keys(Keys.CONTROL + Keys.RETURN)
                
                # Wait till the tab has been rendered
                i=0 # Break potential infinate loop at 15 sec
                while ((driver.window_handles[1] is None) and (i <= 15)):
                    sleep(1)
                    i += 1
                sleep(1) # Extra second for page to load

                # Switch tab to the new tab
                chld = driver.window_handles[1]
                driver.switch_to.window(chld)

                # Attepmt to read the blog post text. If the page didn't render then this trows an error.
                try:
                    elem_1 = driver.find_element(By.CLASS_NAME, "postdiv_fixed")
                    elem_1a = elem_1.find_element(By.XPATH, "./*")
                    post_text = elem_1a.text
                    print("Page {0}, post {1}: {2}".format(page_id, post_id, TextSample(post_text)))
                    insertToDb(page_id, post_id, post_text)
                except Exception as ex:
                    print("[ERROR] page {0}, post {1}: {2}".format(page_id, post_id, ex))
                    pass # Ignore and continue

                # Close current tab
                driver.close()
                # Put focus on current window which will be the window opener. Not usually needed, but helps some error states.
                driver.switch_to.window(main_window)

    # Click on the NEXT link text to go to the next page.
    try:
        elem_2 = driver.find_element(By.CLASS_NAME, "pagelinknext")
        next_page = elem_2.find_element(By.XPATH, "./*")
        next_page.send_keys(Keys.RETURN)
        page_id += 1
    except exceptions.NoSuchElementException:
        print("Page {0}, post {1}: Next page link not found, assume complete".format(page_id, post_id))
        break

# Clost the tab and quit the browser
try:
    print("Closing browser and exiting script.")
    driver.close()
    driver.quit()
except Exception as ex:
    print("[ERROR] : {0}".format(ex))
    pass