require 'rails_helper'

describe 'RangedLotCategories', :type => :feature do
  let(:page_title) { 'Ranged lot categories' }
  let(:index_path) { ranged_lot_categories_path }

  it_behaves_like 'a_login_required_and_project_selected_controller'

  context 'signed in as a user, with some records created' do
    before {
      sign_in_user_and_select_project
      %w{small medium large jumbo ginormous}.each do |w|
        FactoryGirl.create(:valid_ranged_lot_category,  user_project_attributes(@user, @project).merge(name: w))
      end 
    }

    describe 'GET /ranged_lot_categories' do
      before {
        visit ranged_lot_categories_path }

      it_behaves_like 'a_data_model_with_standard_index'
    end

    describe 'GET /ranged_lot_categories/list' do
      before { visit list_ranged_lot_categories_path }

      it_behaves_like 'a_data_model_with_standard_list_and_records_created'
    end

    describe 'GET /ranged_lot_categories/n' do
      before {
        visit ranged_lot_category_path(RangedLotCategory.second)
      }

      it_behaves_like 'a_data_model_with_standard_show'
    end
  end
end


