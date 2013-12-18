FactoryGirl.define do

 trait :creator_and_updater do
   creator {
     # build_stubbed(:valid_user)
     u = User.where( FactoryGirl.attributes_for(:test_user) )
     if u.blank? 
       user = FactoryGirl.create(:valid_user, id: 1)
     else
       user = u.first
     end
     user
   }
   updater { creator }
 end

 trait :projects do
   project {
     user = User.where( FactoryGirl.attributes_for(:test_user))
     if user.blank? 
       u = FactoryGirl.create(:valid_user, id: 1)
     else
       u = user.first
     end

     p = Project.where( FactoryGirl.attributes_for(:valid_project).merge(created_by_id: u.id, updated_by_id: u.id)  ) 
     if p.blank? 
       FactoryGirl.create(:valid_project, id: 1)
     elsif !p.map(&:id).include?(1)
       FactoryGirl.create(:valid_project, id: 1)
     else
       p.first
     end
   }
 end 

 trait :housekeeping  do
   creator_and_updater
   projects 
 end

end
