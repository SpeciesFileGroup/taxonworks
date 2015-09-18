require 'rails_helper'

describe LoanItem, :type => :model do

  let(:loan_item) { LoanItem.new }
  let(:valid_loan_item) { FactoryGirl.create(:valid_loan_item) }

  context 'validation' do
    before{ loan_item.valid? }

    specify 'loan_item_object_id is required' do
      expect(loan_item.errors.include?(:loan_item_object_id) ).to be_truthy
    end 

    specify 'loan_item_object_type is required' do
      expect(loan_item.errors.include?(:loan_item_object_type) ).to be_truthy
    end
  end

  specify 'total can not be provided for Container' do
    loan_item.total = 4
    loan_item.loan_item_object_type = 'CollectionObject'
    loan_item.valid?
    expect(loan_item.errors.include?(:total)).to be_truthy
  end

  context 'as part of a loan' do
    let(:loan) { FactoryGirl.create(:valid_loan) }
    before { loan_item.loan = loan }

    specify 'a specimen can be added to loan item' do
      loan_item.loan_item_object = FactoryGirl.create(:valid_specimen)
      expect(loan_item.valid?).to be_truthy
    end

    specify 'a container can be added to loan item' do
      loan_item.loan_item_object = FactoryGirl.create(:valid_container)
      expect(loan_item.valid?).to be_truthy
    end

    specify 'an OTU alone can be added to loan item' do
      loan_item.loan_item_object = FactoryGirl.create(:valid_otu)
      expect(loan_item.valid?).to be_truthy
    end
  end


  context 'concerns' do
    it_behaves_like 'is_data'
  end

end
