require 'spec_helper'

describe 'PublicContents' do

  it_behaves_like 'a_login_required_and_project_selected_controller'

  describe 'GET /public_contents' do
    before { visit public_contents_path }
    specify 'an index name is present' do
      expect(page).to have_content('Public Contents')
    end
  end
end
