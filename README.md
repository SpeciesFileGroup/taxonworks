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

1. PostgreSQL, postgis, GEOS (Ultimate target, postgres branch)
  
# Ubuntu: 
    sudo apt-get install libgeos-dev postgresql postgis

# Mac OS X assuming [brew][9] is installed:
    brew install postgresql 

# (follow after install instructions)

    brew install geos
    brew install postgis

2. MySQL (paralell development at present, master branch)
 
Configuration
-------------

Use config/database.yml.example for create and customize config/database.yml

* Database permissions (MySQL)

Something like this should work:  

    grant all privileges on taxonworks_development.* to 'tw'@'localhost' identified by 't0ps3kr3t';
    grant all privileges on taxonworks_test.* to 'tw'@'localhost' identified by 't0ps3kr3t';
    grant all privileges on taxonworks_production.* to 'tw'@'localhost' identified by 't0ps3kr3t';

* Database creation

If your database.yml is setup and reflects the uptodate permissions just use 

    rake db:create

* Database initialization

If you want to seed some dummy development data (very minimal at present) do

    rake db:seed RAILS_ENV=development

How to run the test suite
-------------------------
    
    rake

or

    rspec 

Documentation
-------------

See the [wiki][11] for conceptual and general discussion.  Code is documented inline using [Yard tags][12], see [rdoc][10].

[1]: https://secure.travis-ci.org/SpeciesFileGroup/taxonworks.png?branch=postgres
[2]: http://travis-ci.org/SpeciesFileGroup/taxonworks?branch=postgres
[3]: https://coveralls.io/repos/SpeciesFileGroup/taxonworks/badge.png?branch=postgres
[4]: https://coveralls.io/r/SpeciesFileGroup/taxonworks?branch=postgres
[5]: https://codeclimate.com/github/SpeciesFileGroup/taxonworks.png?branch=postgres
[6]: https://codeclimate.com/github/SpeciesFileGroup/taxonworks?branch=postgres
[7]: https://gemnasium.com/SpeciesFileGroup/taxonworks.png?branch=postgres
[8]: https://gemnasium.com/SpeciesFileGroup/taxonworks?branch=postgres
[9]: http://brew.sh/
[10]: http://rubydoc.info/github/SpeciesFileGroup/taxonworks/frames
[11]: http://wiki.taxonworks.org/
[12]: http://rdoc.info/gems/yard/file/docs/Tags.md
