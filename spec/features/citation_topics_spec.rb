require 'spec_helper'

describe "CitationTopics" do
  describe "GET /citation_topics" do
    before { visit citation_topics_path }
    specify 'an index name is present' do
      expect(page).to have_content('Citation Topics')
    end
  end
end
