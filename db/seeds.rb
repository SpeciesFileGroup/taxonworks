# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

 # MySql commands to rebuild databases:

=begin
create database taxonworks_test;
create database taxonworks_development;
create database taxonworks_production;
grant all privileges on taxonworks_development.* to 'tw'@'localhost' identified by 't0ps3kr3t';
grant all privileges on taxonworks_test.* to 'tw'@'localhost' identified by 't0ps3kr3t';
grant all privileges on taxonworks_production.* to 'tw'@'localhost' identified by 't0ps3kr3t';
=end

