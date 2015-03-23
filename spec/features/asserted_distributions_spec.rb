require 'rails_helper'

describe "AssertedDistributions", :type => :feature do
  let(:page_index_name) { 'asserted distributions' }
  let(:index_path) { asserted_distributions_path }
  let(:g) { factory_girl_create_for_user(:valid_geographic_area, @user) }
  let(:s) { factory_girl_create_for_user(:valid_source_bibtex, @user) }

  it_behaves_like 'a_login_required_and_project_selected_controller'

  context 'signed in as user, with some records created' do
    before {
      sign_in_user_and_select_project
      5.times { factory_girl_create_for_user_and_project(:valid_otu, @user, @project) }
      5.times.each_with_index { |i|
        FactoryGirl.create(:valid_asserted_distribution,
                           otu: Otu.all[i],
                           geographic_area: g,
                           source: s,
                           creator: @user,
                           updater: @user,
                           project: @project)
      }
    }

    describe 'GET /asserted_distributions' do
      before {
        visit asserted_distributions_path
      }

      it_behaves_like 'a_data_model_with_standard_index'
    end

    describe 'GET /asserted_distributions/list' do
      before {
        visit list_asserted_distributions_path
      }

      it_behaves_like 'a_data_model_with_standard_list'
    end

    describe 'GET /asserted_distributions/n' do
      before {
        visit asserted_distribution_path(AssertedDistribution.second)
      }

      it_behaves_like 'a_data_model_with_standard_show'
    end
  end
end