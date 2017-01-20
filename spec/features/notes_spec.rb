require 'rails_helper'

describe 'Notes', :type => :feature do
  let(:index_path) { notes_path }
  let(:page_title) { 'Notes' }

  it_behaves_like 'a_login_required_and_project_selected_controller'

  context 'signed in as a user, with some records created' do
    before {
      sign_in_user_and_select_project
      o = Otu.create!(name: 'Cow', by: @user, project: @project)
      3.times { Note.create!( text: Faker::Lorem.sentence, note_object: o, by: @user, project: @project) }
    }

    describe 'GET /Notes' do
      before {
        visit notes_path }

      it_behaves_like 'a_data_model_with_annotations_index'
    end

    describe 'GET /notes/list' do
      before { visit list_notes_path }

      it_behaves_like 'a_data_model_with_standard_list_and_records_created'
    end
  end
end
