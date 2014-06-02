require 'spec_helper'

# :base_class is defined by us, it is accessible as example.metadata[:base_class].  It's used 
describe 'Otus', base_class: Otu do
 
  it_behaves_like 'a_login_required_and_project_selected_controller'

end
