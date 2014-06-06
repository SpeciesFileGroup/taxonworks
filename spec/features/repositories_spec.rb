require 'spec_helper'

describe "Repositories" do
  describe "GET /repositories" do
    before { visit repositories_path }
    specify 'an index name is present' do
      expect(page).to have_content('Repositories')
    end
  end
end


