require 'rails_helper'

describe 'Citations', :type => :feature do
  let(:index_path) { citations_path }
  let(:page_title) { 'Citations' }

  it_behaves_like 'a_login_required_and_project_selected_controller'

  context 'signed in as a user, with some records created' do
    before {
      sign_in_user_and_select_project
      5.times { factory_girl_create_for_user(:valid_source_bibtex, @user) }
      s = Source::Bibtex.all
      o = factory_girl_create_for_user_and_project(:valid_otu, @user, @project)

      5.times.each_with_index { |i|
        FactoryGirl.create(:valid_citation, user_project_attributes(@user, @project).merge(citation_object: o, source: s[i]))
      }
    }

    describe 'GET /citations' do
      before { visit citations_path }

      it_behaves_like 'a_data_model_with_annotations_index'
    end

    describe 'GET /citations/list' do
      before {
        visit list_citations_path
      }

      it_behaves_like 'a_data_model_with_standard_list_and_records_created'
    end

    context 'citations list' do
      # pending 'when a user clicks a citation record, they are taken to the cited data instance'
    end
  end
end
