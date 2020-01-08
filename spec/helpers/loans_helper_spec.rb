require 'rails_helper'

describe LoansHelper, type: :helper do
  context 'a loan needs some helpers' do
    let(:loan) { FactoryBot.create(:valid_loan)  }
    let(:tag_string) { "#{loan.to_param}" }

    specify '#loan_tag' do
      expect(helper.loan_tag(loan)).to match(loan.to_param)
    end

    specify '.loan_tag' do
      expect(helper.loan_tag(loan)).to match(loan.to_param)
    end

    specify '.loan_link' do
      expect(helper.loan_link(loan)).to have_link( tag_string )
    end

    specify '.loan_search_form' do
      expect(loans_search_form).to have_field('loan_id_for_quick_search_form')
    end
  end
end
