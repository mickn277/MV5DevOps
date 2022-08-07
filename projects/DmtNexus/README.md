# DMT Nexus - website blog post scraper

Scrape dmt-nexus.me website forum blog posts for reasearch, using python and selenium webdriver into an Oracle XE database built using vagrant on virtualbox.

See [dmt-nexus.me](https://www.dmt-nexus.me/forum/default.aspx?g=topics&f=3) as one example blog that this script will scrape.

## Requiremetns

### Windows Installs

* powershell core 7.x
* python 3 latest release
* selenium  [chromedriver.exe](https://chromedriver.storage.googleapis.com/index.html)
* [Oracle Client 21c](https://www.oracle.com/database/technologies/oracle21c-windows-downloads.html)
* [Oracle SQL Developer ](https://www.oracle.com/database/sqldeveloper/)

### Vagrant Virtualbox Installs

* Oracle XE database - See [github.com/n2779510/MV5Servers](https://github.com/n2779510/MV5Servers)

### Python Environment Setup

* aes256.py from [github.com\aes-everywhere](https://github.com/mervick/aes-everywhere)

```powershell
# change to \DmtNexus directory

# Optionally Install Windows prerequisites including python
.\Win64-Installs.ps1

# Install pipenv
pip install pipenv

# Setup python virtual environment for this project
pipenv install

# Configure path to chromedriver
echo "PATH = 'C:\var\OneDrive\bin;$env:ORACLE_HOME\bin;$env:PATH'" > .env
echo "TNS_ADMIN = '$env:ORACLE_HOME\networks\admin'" >> .env

# Run scraper in the virtual environment, output to screen and file
pipenv run py.exe .\dmt-nexus.me-scraper.py | tee -FilePath ".\dmt-nexus.me-scraper.log"

# to create requiremetns.txt for the virtual environment
pipenv run pip freeze
```

### Oracle XE Setup

* Users and passwords not specified here, they are kept in a secure KeePass.
