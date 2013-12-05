# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


case Rails.env

when 'development'

  # Experimenting with some dummy data for a 'hello world' stack.
  root =  FactoryGirl.create(:root_taxon_name)
  %w{Aidae Bidae Cidae}.each do |family|
    FactoryGirl.create(:iczn_family, parent: root, name: family)
  end

when 'production'
  # Never ever do anything.  Production should be seeded with a Rake task or deploy script if need be.
when 'test'

  # Never ever do anything. Test with FactoryGirl or inline..... 

end
