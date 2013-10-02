TaxonWorks
==========

[![Continuous Integration Status][1]][2]
[![Coverage Status][3]][4]
[![CodePolice][5]][6]
[![Dependency Status][7]][8]


Ruby version
------------
2.0.0 -- also see .ruby-version file

System dependencies
------------------- 

PostgreSQL, postgis, GEOS
  
    # Ubuntu: 
    sudo apt-get install libgeos-dev postgresql postgis

    # Mac OS X assuming [brew][9] is installed:
    brew install postgresql 
    #(follow after install instructions)

    brew install geos
    brew install postgis
    
Configuration
-------------

use config/database.yml.example for create and customize config/database.yml

* Database creation

* Database initialization

How to run the test suite
-------------------------
    
    rake

    spec spec/app

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...


[1]: https://secure.travis-ci.org/SpeciesFileGroup/taxonworks.png
[2]: http://travis-ci.org/SpeciesFileGroup/taxonworks
[3]: https://coveralls.io/repos/SpeciesFileGroup/taxonworks/badge.png?branch=master
[4]: https://coveralls.io/r/SpeciesFileGroup/taxonworks?branch=master
[5]: https://codeclimate.com/github/SpeciesFileGroup/taxonworks.png
[6]: https://codeclimate.com/github/SpeciesFileGroup/taxonworks
[7]: https://gemnasium.com/SpeciesFileGroup/taxonworks.png
[8]: https://gemnasium.com/SpeciesFileGroup/taxonworks
[9]: http://brew.sh/
