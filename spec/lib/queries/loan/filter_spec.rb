require 'rails_helper'

describe Queries::Loan::Filter, type: :model, group: [:geo, :collection_objects, :otus, :shared_geo] do

  let(:q) { Queries::Loan::Filter.new({}) }


# let!(:l1) { FactoryBot.create(:valid_loan) }
# let!(:l2) { FactoryBot.create(:valid_loan) }


  specify '#loan_item_wildcards' do
    l1 = FactoryBot.create(:valid_loan, recipient_address: 'Mars, home of chocolate bars.') 
    l2 = FactoryBot.create(:valid_loan) 

    q.recipient_address = 'choco' 
    q.loan_wildcards = 'recipient_address'
    expect(q.all).to contain_exactly(l1)
  end

  specify '#loan_item_disposition' do
    l1 = FactoryBot.create(:valid_loan) 
    l2 = FactoryBot.create(:valid_loan) 

    l1.loan_items << FactoryBot.create(:valid_loan_item, disposition: 'Lost')

    q.loan_item_disposition = 'Lost' 
    expect(q.all).to contain_exactly(l1)
  end

  specify '#documentation (without)' do
    l1 = FactoryBot.create(:valid_loan) 
    l2 = FactoryBot.create(:valid_loan) 

    l1.documents << FactoryBot.create(:valid_document)

    q.documentation = false 
    expect(q.all).to contain_exactly(l2)
  end

  specify '#documentation' do
    l1 = FactoryBot.create(:valid_loan) 
    l2 = FactoryBot.create(:valid_loan) 

    l1.documents << FactoryBot.create(:valid_document)

    q.documentation = true
    expect(q.all).to contain_exactly(l1)
  end

  specify '#overdue' do
    l1 = FactoryBot.create(:valid_loan, date_return_expected: 2.days.ago , date_closed: nil) 
    l2 = FactoryBot.create(:valid_loan, date_return_expected: Time.current + 2.weeks, date_closed: nil) 

    q.overdue = true
    expect(q.all).to contain_exactly(l1)
  end

  specify '#overdue (not)' do
    l1 = FactoryBot.create(:valid_loan, date_return_expected: 2.days.ago , date_closed: nil) 
    l2 = FactoryBot.create(:valid_loan, date_return_expected: Time.current + 2.weeks, date_closed: nil) 

    q.overdue = false
    expect(q.all).to contain_exactly(l2)
  end



end
