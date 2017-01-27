require 'rails_helper'

describe 'Georeferences', :type => :feature do
  let(:index_path) { georeferences_path }
  let(:page_title) { 'Georeferences' }

  it_behaves_like 'a_login_required_and_project_selected_controller'

  context 'signed in as a user, with some records created' do
    before {
      sign_in_user_and_select_project

      # We use the functionality 
      (0..2).each do |i|
        CollectingEvent.create!(
          verbatim_latitude: 100 - i,
          verbatim_longitude: i,
          with_verbatim_data_georeference: true,
          by: @user,
          project: @project
         )
      end
    }

    describe 'GET /georeferences' do
      before {
        visit georeferences_path }

      it_behaves_like 'a_data_model_with_standard_index'
    end

     describe 'GET /georeferences/list' do
       before { visit list_georeferences_path }
    
       it_behaves_like 'a_data_model_with_standard_list_and_records_created'
     end
    
     describe 'GET /georeferences/n' do
       before {
         visit georeference_path(Georeference.second)
       }
    
       it_behaves_like 'a_data_model_with_standard_show'
     end
  end
end


