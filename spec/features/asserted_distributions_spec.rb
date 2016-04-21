require 'rails_helper'

describe "AssertedDistributions", :type => :feature do
  let(:page_index_name) { 'asserted distributions' }
  let(:index_path) { asserted_distributions_path }
  let(:a) { FactoryGirl.create(:valid_geographic_area_type, by: @user) }
  let(:g) { FactoryGirl.create(:valid_geographic_area, geographic_area_type: a, by: @user) }
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


    context 'testing new asserted distribution' do
      before {
        #   logged in and project selected
        visit asserted_distributions_path } #   when I visit the asserted_distributions_path

      specify 'can create a new asserted distribution', js: true do
        o = Otu.create!(user_project_attributes(@user, @project).merge(name: 'motu'))
        g = GeographicArea.first
        s = Source.first

        click_link('New') #   when I click the new link

        expect(page.has_field?('otu_id_for_asserted_distribution', :type => 'text')).to be_truthy
        expect(page.has_field?('geographic_area_id_for_asserted_distribution', :type => 'text')).to be_truthy
        expect(page.has_field?('source_id_for_asserted_distribution', :type => 'text')).to be_truthy

        # fill_autocomplete('serial_id_for_source', with: 'My Serial', select: s.id) # fill out Serial autocomplete with 'My Serial'
        fill_autocomplete('otu_id_for_asserted_distribution', with: 'motu', select: o.id)   # equivalent to o.name
        fill_autocomplete('geographic_area_id_for_asserted_distribution', with: g.name, select: g.id)
        fill_autocomplete('source_id_for_asserted_distribution', with: s.cached, select: s.id)

        click_button('Create Asserted distribution')
        expect(page).to have_content("Asserted distribution was successfully created.")
      end
    end
  end
end
