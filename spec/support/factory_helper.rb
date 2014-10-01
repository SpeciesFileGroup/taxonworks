
def strip_housekeeping_attributes(attributes)
  i = NON_ANNOTATABLE_COLUMNS
  i.delete(:type)
  attributes.delete_if { |j, k| i.map(&:to_s).include?(j) } # See config/initializers/constants/note_constants
end

def factory_girl_create_for_user(model, user)
  FactoryGirl.create(model, creator: user, updater: user)
end

def factory_girl_create_for_user_and_project(model, user, project)
  FactoryGirl.create(model, creator: user, updater: user, project: project)
end

