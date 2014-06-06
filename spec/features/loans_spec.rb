require 'spec_helper'

describe "Loans" do
  describe "GET /loans" do
    before { visit loans_path }
    specify 'an index name is present' do
      expect(page).to have_content('Loans')
    end
  end
end
