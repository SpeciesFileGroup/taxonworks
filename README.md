TaxonWorks
==========

[![Continuous Integration Status][1]][2]
[![Coverage Status][3]][4]
[![CodePolice][5]][6]
[![Dependency Status][7]][8]

Overview
--------

TaxonWorks is Ruby on Rails application that facilitates biodiversity informatics research.  More information is available at [taxonworks.org][13].  The codebase is in active development.  At present only models are available (i.e. all interactions are through a command-line interface).

Installation
------------

TaxonWorks is a Rails 4 (4.1.1) application using Ruby 2.0 (2.1.1) and rubygems.  It requires PostgreSQL with the postgis extension.  It uses ImageMagick.  The core development team is using [rvm][16] and [brew][9] to configure their environment on OS X.  

Minimally, the following steps are required.  If you have postgres/postgis installed skip to 3. 

1. Install Postgres, postgis, and image magick.
  
   ``` 
   brew install postgres
   brew install postgis 
   brew install imagemagick
   ```

2. To start postgres follow the instructions via 'brew info postgres'. The following sets postgres to start at logon, and then starts postgres for this session.

   ```  
   mkdir -p ~/Library/LaunchAgents    # This may already exist.   
   ln -sfv /usr/local/opt/postgresql/*.plist ~/Library/LaunchAgents
   launchctl load ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist
   ```
 
3. Clone the source code.

   ```
   git clone git@github.com:SpeciesFileGroup/taxonworks.git
   ```

4. Copy the config/database.yml.example file to config/database.yml.  

5. Given no modifications to database.yml, you can proceed by creating a postgres role (user).

   ```
   psql -d postgres
   create role taxonworks_development login createdb superuser; 
   \q
   ```

6. Install the gems dependencies. Ensure you are using the Ruby version you intend to develop under (check with 'ruby -v'). Install the pg gem with some flags first, then the rest of the gems.

  ```
  env ARCHFLAGS="-arch x86_64" gem install pg -- --with-pg-config=/usr/local/bin/pg_config
  bundle update
  ```

7. Setup the databases.
 
  ``` 
  rake db:create
  rake db:migrate RAILS_ENV=test
  rake db:migrate RAILS_ENV=development
  ```

8. Test your setup.

  ```
  rspec
  ```

If the tests run, then the installation has been a success.  You'll likely want to go back and further secure your postgres installation and roles at this point.

Other resources
---------------

TaxonWorks has a [wiki][11] for conceptual discussion and aggregating long term help. It also includes a basic roadmap. There is a [developers list][14] for technical discussion. Code is documented inline using [Yard tags][12], see [rdoc][10].  Tweets come from [@TaxonWorks][15].  A stub homepage is at [taxonworks.org][13].

License
-------

TaxonWorks is open source, a decision on the licence to be used is pending, it will likely be MIT or nearly identical. 

 
[1]: https://secure.travis-ci.org/SpeciesFileGroup/taxonworks.png?branch=master
[2]: http://travis-ci.org/SpeciesFileGroup/taxonworks?branch=master
[3]: https://coveralls.io/repos/SpeciesFileGroup/taxonworks/badge.png?branch=master
[4]: https://coveralls.io/r/SpeciesFileGroup/taxonworks?branch=master
[5]: https://codeclimate.com/github/SpeciesFileGroup/taxonworks.png?branch=master
[6]: https://codeclimate.com/github/SpeciesFileGroup/taxonworks?branch=master
[7]: https://gemnasium.com/SpeciesFileGroup/taxonworks.png?branch=master
[8]: https://gemnasium.com/SpeciesFileGroup/taxonworks?branch=master
[9]: http://brew.sh/
[10]: http://rubydoc.info/github/SpeciesFileGroup/taxonworks/frames
[11]: http://wiki.taxonworks.org/
[12]: http://rdoc.info/gems/yard/file/docs/Tags.md
[13]: http://taxonworks.org
[14]: https://groups.google.com/forum/?hl=en#!forum/taxonworks-developers
[15]: https://twitter.com/taxonworks
[16]: http://rvm.io
