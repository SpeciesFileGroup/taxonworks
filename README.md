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

PostgreSQL (tested on 9.3.0), postgis, GEOS
  
    # Ubuntu: 
    sudo apt-get install libgeos-dev postgresql postgis

    # Mac OS X assuming [brew][9] is installed:
    brew install postgresql 
    #(follow after install instructions)

    brew install geos
    brew install postgis
    
### OS x Troubleshooting

* If you get 'library not loaded errors' You may need to rebuild the pg gem.
* If you get 'json' related errors relinking with 'brew switch json-c 0.10' may help [see][10].

    
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


[1]: https://secure.travis-ci.org/SpeciesFileGroup/taxonworks.png?branch=postgres
[2]: http://travis-ci.org/SpeciesFileGroup/taxonworks?branch=postgres
[3]: https://coveralls.io/repos/SpeciesFileGroup/taxonworks/badge.png?branch=master
[4]: https://coveralls.io/r/SpeciesFileGroup/taxonworks?branch=postgres
[5]: https://codeclimate.com/github/SpeciesFileGroup/taxonworks.png?branch=postgres
[6]: https://codeclimate.com/github/SpeciesFileGroup/taxonworks?branch=postgres
[7]: https://gemnasium.com/SpeciesFileGroup/taxonworks.png?branch=postgres
[8]: https://gemnasium.com/SpeciesFileGroup/taxonworks?branch=postgres
[9]: http://brew.sh/
[10]: http://stackoverflow.com/questions/18071946/rails-postgis-upgrade-issues
