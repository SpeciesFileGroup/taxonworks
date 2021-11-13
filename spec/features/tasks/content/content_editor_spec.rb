require 'rails_helper'

describe 'Content editor' do
  let(:index_path) { '/tasks/content/editor/index' }
  it_behaves_like 'a_login_required_controller'

  context 'Test new topic' do
    before {
      sign_in_user_and_select_project
    }

    context 'create new topic', js: true do
      before {
        visit index_editor_task_path
      }
      specify 'can create new topic' do
        click_button('Topic')
        click_button('Create new')
        expect(page).to have_content('New topic')
        fill_in 'Name', with: 'Testing topic'
        fill_in 'Definition', with: 'Testing, making sure this is long enough'
        click_button('Create')
        expect(page).to have_content('Testing topic was successfully created.')
      end
    end
  end
end


