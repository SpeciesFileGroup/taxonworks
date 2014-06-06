require 'spec_helper'

describe "Citations" do
  describe "GET /citations" do
    before { visit citations_path }
    specify 'an index name is present' do
      expect(page).to have_content('Citations')
    end
  end
end
