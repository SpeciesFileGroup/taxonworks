require 'rails_helper'

describe Queries::Loan::Filter, type: :model, group: [:geo, :collection_objects, :otus, :shared_geo] do

  let(:q) { Queries::Loan::Filter.new({}) }

  specify '#date_closed' do
    l1 = FactoryBot.create(:valid_loan)
    l2 = FactoryBot.create(:valid_loan, date_closed: '2022-12-1')

    q.with_date_closed = true
    expect(q.all).to contain_exactly(l2)
  end

  specify '#date_closed false' do
    l1 = FactoryBot.create(:valid_loan)
    l2 = FactoryBot.create(:valid_loan, date_closed: '2022-12-1')

    q.with_date_closed = false
    expect(q.all).to contain_exactly(l1)
  end

  specify '#date_received' do
    l1 = FactoryBot.create(:valid_loan)
    l2 = FactoryBot.create(:valid_loan, date_received: '2022-12-1')

    q.with_date_received = true
    expect(q.all).to contain_exactly(l2)
  end

  specify '#date_received false' do
    l1 = FactoryBot.create(:valid_loan)
    l2 = FactoryBot.create(:valid_loan, date_received: '2022-12-1')

    q.with_date_received = false
    expect(q.all).to contain_exactly(l1)
  end

  specify '#date_requested' do
    l1 = FactoryBot.create(:valid_loan)
    l2 = FactoryBot.create(:valid_loan, date_requested: '2022-12-1')

    q.with_date_requested = true
    expect(q.all).to contain_exactly(l2)
  end

  specify '#date_requested false' do
    l1 = FactoryBot.create(:valid_loan)
    l2 = FactoryBot.create(:valid_loan, date_requested: '2022-12-1')

    q.with_date_requested = false
    expect(q.all).to contain_exactly(l1)
  end

  specify '#date_return_expected' do
    l1 = FactoryBot.create(:valid_loan)
    l2 = FactoryBot.create(:valid_loan)

    q.with_date_return_expected = true
    expect(q.all).to contain_exactly(l1, l2)
  end

  specify '#date_return_expected false' do
    l1 = FactoryBot.create(:valid_loan)
    l2 = FactoryBot.create(:valid_loan) # comes with date_return_expected

    q.with_date_return_expected = false
    expect(q.all).to eq([]) # Only legacy  bad data can get past the validation here
  end

  specify '#date_sent' do
    l1 = FactoryBot.create(:valid_loan)
    l2 = FactoryBot.create(:valid_loan, date_sent: '2022-12-1')

    q.with_date_sent = true
    expect(q.all).to contain_exactly(l2)
  end

  specify '#date_sent false' do
    l1 = FactoryBot.create(:valid_loan)
    l2 = FactoryBot.create(:valid_loan, date_sent: '2022-12-1')

    q.with_date_sent = false
    expect(q.all).to contain_exactly(l1)
  end





  specify '#taxon_name_id' do
    l1 = FactoryBot.create(:valid_loan, recipient_address: 'Mars, home of chocolate bars.')
    FactoryBot.create(:valid_loan)
    s =  Specimen.create!
    l1.loan_items << FactoryBot.create(:valid_loan_item, loan_item_object: s)

    s.taxon_determinations << FactoryBot.create(:valid_taxon_determination)

    o = s.taxon_determinations.first.otu
    o.update!(taxon_name: FactoryBot.create(:valid_protonym))

    q.taxon_name_id = o.taxon_name_id

    expect(q.all).to contain_exactly(l1)
  end

  specify '#collection_object_query' do
    l1 = FactoryBot.create(:valid_loan, recipient_address: 'Mars, home of chocolate bars.')
    l2 = FactoryBot.create(:valid_loan)
    o =  Specimen.create!
    l1.loan_items << FactoryBot.create(:valid_loan_item, loan_item_object: o)

    q.collection_object_query = ::Queries::CollectionObject::Filter.new(collection_object_id: o.id)
    expect(q.all).to contain_exactly(l1)
  end

  specify '#otu_query' do
    l1 = FactoryBot.create(:valid_loan, recipient_address: 'Mars, home of chocolate bars.')
    l2 = FactoryBot.create(:valid_loan)
    o =  Otu.create(name: 'foo')
    l1.loan_items << FactoryBot.create(:valid_loan_item, loan_item_object: o)

    q.otu_query = ::Queries::Otu::Filter.new(otu_id: o.id)
    expect(q.all).to contain_exactly(l1)
  end

  specify '#otu_id' do
    l1 = FactoryBot.create(:valid_loan, recipient_address: 'Mars, home of chocolate bars.')
    l2 = FactoryBot.create(:valid_loan)
    o =  Otu.create(name: 'foo')
    l1.loan_items << FactoryBot.create(:valid_loan_item, loan_item_object: o)

    q.otu_id = o.id
    expect(q.all).to contain_exactly(l1)
  end

  specify '#date_id' do
    l1 = FactoryBot.create(:valid_loan, recipient_address: 'Mars, home of chocolate bars.')
    l2 = FactoryBot.create(:valid_loan)

    q.loan_id = l1.id
    expect(q.all).to contain_exactly(l1)
  end

  specify '#wildcard_attribute' do
    l1 = FactoryBot.create(:valid_loan, recipient_address: 'Mars, home of chocolate bars.')
    l2 = FactoryBot.create(:valid_loan)

    q.recipient_address = 'choco'
    q.wildcard_attribute = 'recipient_address'
    expect(q.all).to contain_exactly(l1)
  end

  specify '#date_item_disposition' do
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
