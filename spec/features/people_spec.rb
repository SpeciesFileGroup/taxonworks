require 'spec_helper'

describe "People" do
  describe "GET /people" do
    before { visit people_path }
    specify 'an index name is present' do
      expect(page).to have_content('People')
    end
  end
end

