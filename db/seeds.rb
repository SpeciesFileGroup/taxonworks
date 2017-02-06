# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


case Rails.env

  when 'development'
    FactoryGirl.create(:administrator, email: 'admin@example.com') unless User.where(is_administrator: true).first

    u = User.where(is_administrator: [false, nil]).first
    unless u
    # Creates 1,1 project/users
      u = FactoryGirl.create(:valid_user, email: 'user@example.com')
    end
   
    p = FactoryGirl.create(:valid_project, creator: u, updater: u)
    FactoryGirl.create(:project_member, project: p, user: u, creator: u, updater: u)

    # These will interfere with importing geographic_items.dmp because it creates related records
    # FactoryGirl.create(:level2_geographic_area)
    # FactoryGirl.create(:geographic_item_with_polygon)

    $user_id = u.id
    $project_id = p.id

    FactoryGirl.create(:iczn_subspecies)
    FactoryGirl.create(:icn_variety)

    20.times { FactoryGirl.create(:valid_asserted_distribution)}

  when 'production'
    # Never ever do anything.  Production should be seeded with a Rake task or deploy script if need be.

  when 'test'


end
