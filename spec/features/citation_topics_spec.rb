require 'spec_helper'

describe 'CitationTopics' do

  it_behaves_like 'a_login_required_and_project_selected_controller' do 
    let(:index_path) { citation_topics_path }
    let(:page_index_name) { 'Citation Topics' }
  end

  describe 'GET /citation_topics' do
    before { 
      sign_in_valid_user_and_select_project
      visit citation_topics_path }
    specify 'an index name is present' do
      expect(page).to have_content('Citation Topics')
    end
  end
end
