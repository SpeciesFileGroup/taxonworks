
def strip_housekeeping_attributes(attributes)
  i = RESERVED_ATTRIBUTES.dup
  i.delete(:type)
  attributes.delete_if {|j, k| i.map(&:to_s).include?(j) } 
end

def factory_girl_create_for_user(model, user)
  FactoryGirl.create(model, creator: user, updater: user)
end

def factory_girl_create_for_user_and_project(model, user, project)
  FactoryGirl.create(model, creator: user, updater: user, project: project)
end

