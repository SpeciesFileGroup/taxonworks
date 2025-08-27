require 'rails_helper'

describe 'AssertedDistributions', type: :feature do
  let(:page_title) { 'Asserted distributions' }
  let(:index_path) { asserted_distributions_path }
  it_behaves_like 'a_login_required_and_project_selected_controller'

  context 'signed in as user, with some records created' do

    let(:a) { FactoryBot.create(:valid_geographic_area_type, by: @user) }
    let(:g) { FactoryBot.create(:valid_geographic_area, geographic_area_type: a, by: @user) }
    let(:s) { factory_bot_create_for_user(:valid_source_bibtex, @user) }

    before do
      sign_in_user_and_select_project

      5.times { factory_bot_create_for_user_and_project(:valid_otu, @user, @project) }
      5.times.each_with_index { |i|
        AssertedDistribution.create!(
          asserted_distribution_object: Otu.all[i],
          asserted_distribution_shape: g,
          origin_citation_attributes: {source: s, by: @user, project: @project},
          by: @user,
          project: @project
        )
      }
    end

    after do
      click_link('Sign out')
      AssertedDistribution.delete_all
      GeographicArea.delete_all
    end

    describe 'GET /asserted_distributions' do
      before { visit asserted_distributions_path }

      it_behaves_like 'a_data_model_with_standard_index'
    end

    describe 'GET /asserted_distributions/list' do
      before { visit list_asserted_distributions_path }

      it_behaves_like 'a_data_model_with_standard_list_and_records_created'
    end

    describe 'GET /asserted_distributions/n' do
      before {
        visit asserted_distribution_path(AssertedDistribution.second)
      }

      it_behaves_like 'a_data_model_with_standard_show'
    end

  end
end
