require 'rails_helper'

describe 'Loanable', type: :model, group: :loans do
  let(:class_with_loan) {TestLoanable.new}
  let(:loan) { FactoryBot.create(:valid_loan, date_return_expected: '2016/2/14') }

  context 'associations' do
    specify 'has one loan_item' do
      expect(class_with_loan).to respond_to(:loan_item)
      expect(class_with_loan.loan_item).to eq(nil)

      expect(class_with_loan.loan_item = LoanItem.new(loan: loan)).to be_truthy
    end

    specify 'has many loan_items' do
      expect(class_with_loan).to respond_to(:loan_items)
      expect(class_with_loan.loan_items).to eq([])
    end

    specify 'has many loans' do
      expect(class_with_loan).to respond_to(:loans)
      expect(class_with_loan.loans).to eq([])
    end

    specify 'setting loan_item sets loan' do
      class_with_loan.save
      class_with_loan.build_loan_item(loan: loan)
      class_with_loan.save

      expect(class_with_loan.loan_item.id).to be_truthy
    end

    specify 'has_one loan' do
      expect(class_with_loan).to respond_to(:loan_item)
      expect(class_with_loan.loan).to eq(nil) # there are no tags yet.

      expect(class_with_loan.loan = Loan.new()).to be_truthy
    end
  end

  context 'not loaned' do
    specify '#on_loan?' do
      expect(class_with_loan.on_loan?).to be_falsey
    end

    specify '#loan_return_date' do
      expect(class_with_loan.loan_return_date).to eq(false)
    end
  end

  context 'on loan' do
    before { class_with_loan.update(loan: loan) }

    specify '#on_loan?' do
      expect(class_with_loan.on_loan?).to be_truthy
    end

    specify '#loan_return_date' do
      expect(class_with_loan.loan_return_date).to eq(loan.date_return_expected)
    end
  end

  specify 'loan item destroyed' do
    class_with_loan.save
    class_with_loan.build_loan_item(loan: loan)
    class_with_loan.save

    class_with_loan.destroy
    expect(class_with_loan.loan_items.count).to eq(0)
  end

end

class TestLoanable < ApplicationRecord
  include FakeTable
  include Shared::Loanable

  # Stubbed here, see Shared::IsData for actual method.
  def has_loans?
    true
  end
end


