# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


case Rails.env

when 'development'

  # Creates 1,1 project/users  
  FactoryGirl.create(:valid_user)
  FactoryGirl.create(:valid_project)
  FactoryGirl.create(:project_member, project_id: 1, user_id: 1)
 
  # These will interfere with importing geographic_items.dmp because it creates related records 
  # FactoryGirl.create(:level2_geographic_area)
  # FactoryGirl.create(:geographic_item_with_polygon)
  
  FactoryGirl.create(:iczn_subspecies)
  FactoryGirl.create(:icn_variety)

when 'production'
  # Never ever do anything.  Production should be seeded with a Rake task or deploy script if need be.

when 'test'

  # Never ever do anything. Test with FactoryGirl or inline..... 

end
