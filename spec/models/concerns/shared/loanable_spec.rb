require 'rails_helper'

describe 'Loanable', type: :model, group: :loans do
  let(:class_with_loan) {TestLoanable.new}
  let(:loan) { FactoryBot.create(:valid_loan, date_return_expected: '2016/2/14') }

  context 'containers' do
    let(:a) { FactoryBot.create(:valid_container) }
    let(:b) { FactoryBot.create(:valid_container, contained_in: a) }

    specify '#on_loan?' do
      s = Specimen.create!(contained_in: b)
      loan.loan_items << LoanItem.new(loan_item_object: a)

      expect(s.on_loan?).to be_truthy
    end

    specify '#container_loaned?' do
      s = Specimen.create!(contained_in: b)
      loan.loan_items << LoanItem.new(loan_item_object: a)

      expect(s.container_loaned?).to be_truthy
    end

    specify '#loaned_in_container?' do
      s = Specimen.create!(contained_in: b)
      loan.loan_items << LoanItem.new(loan_item_object: a)

      expect(s.loaned_in_container.id).to eq(a.id)
    end

    specify '#current_loan' do
      s = Specimen.create!(contained_in: b)
      loan.loan_items << LoanItem.new(loan_item_object: a)

      expect(s.current_loan).to eq(loan)
    end

    specify 'times_loaned (nested)' do
      s = Specimen.create!(contained_in: b)
      loan.loan_items << LoanItem.new(loan_item_object: a)

      expect(s.times_loaned).to eq(1)
    end

    specify 'times_loaned (nested container)' do
      s = Specimen.create!(contained_in: b)
      loan.loan_items << LoanItem.new(loan_item_object: b)

      46

      expect(s.times_loaned).to eq(1)
    end

    specify 'times_loaned (immediate container)' do
      s = Specimen.create!(contained_in: b)
      loan.loan_items << LoanItem.new(loan_item_object: b)

      loan.send(:return!)

      l2 = FactoryBot.create(:valid_loan)
      l2.loan_items << LoanItem.new(loan_item_object: s)

      expect(s.times_loaned).to eq(2)
    end

    specify 'times_loaned (immediate container)' do
      s = Specimen.create!(contained_in: b)
      loan.loan_items << LoanItem.new(loan_item_object: b)

      loan.send(:return!)

      l2 = FactoryBot.create(:valid_loan)
      l2.loan_items << LoanItem.new(loan_item_object: s)

      expect(s.all_loans).to contain_exactly(loan, l2)
    end

  end

  context 'associations' do
    specify 'has one loan_item' do
      expect(class_with_loan).to respond_to(:loan_item)
      expect(class_with_loan.loan_item).to eq(nil)

      expect(class_with_loan.loan_item = LoanItem.new(loan:)).to be_truthy
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
      class_with_loan.save!
      class_with_loan.build_loan_item(loan:)
      class_with_loan.save!

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
    before { class_with_loan.update(loan:) }

    specify '#on_loan?' do
      expect(class_with_loan.on_loan?).to be_truthy
    end

    specify '#loan_return_date' do
      expect(class_with_loan.loan_return_date).to eq(loan.date_return_expected)
    end
  end

  specify 'loan item destroyed' do
    class_with_loan.save!
    class_with_loan.build_loan_item(loan:)
    class_with_loan.save!

    class_with_loan.destroy!
    expect(class_with_loan.loan_items.count).to eq(0)
  end

end

class TestLoanable < ApplicationRecord
  include FakeTable
  include Shared::Loanable

  # Stubbed here, see Shared::IsData for actual methods

  def has_loans?
    true
  end

  def self.is_containable?
    true
  end

  def contained?
    false
  end

end
