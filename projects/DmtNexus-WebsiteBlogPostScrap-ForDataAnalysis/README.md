# Blog Post Scraper

Scrape dmt-nexus.me website forum blog posts for reasearch, using python and selenium webdriver into an Oracle XE database built using vagrant on virtualbox.

## Requiremetns

### Windows Installs

* python
* selenium chromedriver.exe 
* Oracle Client
* Oracle SQL Developer

### Vagrant Virtualbox Installs

* Oracle XE database - See [github.com/n2779510/MV5Servers](https://github.com/n2779510/MV5Servers)

### Python Environment Setup

* aes256.py from [github.com\aes-everywhere](https://github.com/mervick/aes-everywhere)

```powershell

# Create the new virtual environment location
 py.exe -m venv .\.env

# Activate the virtual environment
.\.env\Scripts\activate

# Pyton Installs for Chrome web scraping to Oracle database
pip install cx-oracle
pip install selenium # Already installed
pip install chromedriver-py
pip install requests # Already installed
pip install pycryptodomex
#pip install html2text
#pip install unicode

# Run scraper, output to screen and file
python.exe .\dmt-nexus.me-scraper-complete.py | tee -FilePath ".\dmt-nexus.me-scraper-complete.log"

# When finishded, deactivate the virtual environment
.\.env\Scripts\deactivate
```

### Oracle XE Setup

* Users and passwords not specified here, they are kept in a secure KeePass.
