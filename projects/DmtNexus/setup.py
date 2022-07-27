"""Package configuration."""
from setuptools import setup

setup(
    name='DmtNexus',
    description="Dmt Nexus Blog Text Scraper",
    long_description="",
    author='Mick 277',
    author_email='mick277@yandex.com',
    url='https://github.com/n2779510',
    version='0.1',
    install_requires=[         
        'cx-oracle',         
        'selenium',
        'chromedriver-py'
    ],
)