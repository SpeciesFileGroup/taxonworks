require 'spec_helper'

describe "LoanItems" do
  describe "GET /loan_items" do
    before { visit loan_items_path }
    specify 'an index name is present' do
      expect(page).to have_content('Loan Items')
    end
  end
end
