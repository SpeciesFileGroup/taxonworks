require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the LoansHelper. For example:
#
# describe LoansHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
describe LoansHelper, :type => :helper do
  context 'a loan needs some helpers' do
    before(:all) {
      @loan  = FactoryGirl.create(:valid_loan)
      @cvt_name = @loan.recipient_email
    }

    specify '::loan_tag' do
      expect(LoansHelper.loan_tag(@loan)).to eq(@cvt_name)
    end

    specify '#loan_tag' do
      expect(loan_tag(@loan)).to eq(@cvt_name)
    end

    specify '#loan_link' do
      expect(loan_link(@loan)).to have_link(@cvt_name)
    end

    specify "#loan_search_form" do
      expect(loans_search_form).to have_button('Show')
      expect(loans_search_form).to have_field('loan_id_for_quick_search_form')
    end

  end
end
