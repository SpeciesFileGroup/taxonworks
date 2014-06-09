require 'spec_helper'

describe 'CitationTopics', base_class: CitationTopic do

  it_behaves_like 'a_login_required_and_project_selected_controller'

  describe 'GET /citation_topics' do
    before { visit citation_topics_path }
    specify 'an index name is present' do
      expect(page).to have_content('Citation Topics')
    end
  end
end
