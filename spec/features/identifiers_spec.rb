require 'rails_helper'

describe 'Identifiers', :type => :feature do
  let(:page_index_name) { 'identifiers' }
  let(:index_path) { identifiers_path }

  it_behaves_like 'a_login_required_and_project_selected_controller'

  context 'signed in as a user, with some records created' do
    before {
      sign_in_user_and_select_project

      namespace = Namespace.create!(name: 'Matt Ids', short_name: "MID", by: @user)


      (1..3).each do |n|
        o = Otu.create(name: "O", by: @user, project: @project)
       Identifier::Local::CatalogNumber.create!(namespace: namespace, identifier_object: o, identifier: n, by: @user, project: @project)
      end
    }

    describe 'GET /identifiers' do
      before {
        visit identifiers_path
      }

      it_behaves_like 'a_data_model_with_annotations_index'
    end

    describe 'GET /identifiers/list' do
      before { visit list_identifiers_path }

      it_behaves_like 'a_data_model_with_standard_list'
    end
  end
end







