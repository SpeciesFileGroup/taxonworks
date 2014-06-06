require 'spec_helper'

describe "Namespaces" do
  describe "GET /Namespaces" do
    before { visit namespaces_path }
    specify 'an index name is present' do
      expect(page).to have_content('Namespaces')
    end
  end
end








