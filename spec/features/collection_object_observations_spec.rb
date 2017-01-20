require 'rails_helper'

RSpec.describe "CollectionObjectObservations", type: :feature do
  let(:index_path) { collection_object_observations_path }
  let(:page_title) { 'Collection object observation' }

  it_behaves_like 'a_login_required_and_project_selected_controller'

  context 'signed in as a user' do
    before { sign_in_user_and_select_project }

    context 'with some records created' do
      
      before {
        10.times { factory_girl_create_for_user_and_project(:valid_collection_object_observation, @user, @project) }
      }

      context 'GET /collection_object_observations' do
        before {
          visit index_path
        }

        specify 'that it has an AJAX autocomplete box', js: true do
          select_text = 'Select a collection object observation'
          expect(page).to have_button('Show')
          expect(page).to have_field(select_text) # TODO: inflect
          fill_in(select_text, :with => 'a')
        end

       it_behaves_like 'a_data_model_with_standard_index'
      end

      describe 'GET /collection_object_observations/list' do
        before do
          visit list_collection_object_observations_path
        end

        it_behaves_like 'a_data_model_with_standard_list_and_records_created'
      end

      describe 'GET /collection_object_observations/n' do
        before {
          visit collection_object_observation_path(CollectionObjectObservation.second)
        }

        it_behaves_like 'a_data_model_with_standard_show'
      end
    end
  end
end
