require 'rails_helper'

describe Queries::Concerns::Identifiers, type: :model, group: [:identifiers, :filter] do

  let(:query) { Queries::CollectionObject::Filter.new({}) }
  let!(:n1) { Namespace.create!(name: 'First', short_name: 'second')}
  let!(:n2) { Namespace.create!(name: 'Third', short_name: 'fourth')}
  
  let!(:co1) { Specimen.create! }
  let!(:co2) { Lot.create!(total: 2) }

  let!(:i1) { Identifier::Local::CatalogNumber.create!(namespace: n1, identifier: '123', identifier_object: co1) }
  let!(:i2) { Identifier::Local::CatalogNumber.create!(namespace: n2, identifier: '453', identifier_object: co2) }

  specify '#local_identifiers false' do
    c = FactoryBot.create(:valid_container)
    e = FactoryBot.create(:valid_specimen, contained_in: c)  # not this
    n = FactoryBot.create(:valid_specimen)

    c.identifiers << FactoryBot.create(:valid_identifier_local)
    n.identifiers << FactoryBot.create(:valid_identifier_local) # or this

    s = Specimen.create!

    query.local_identifiers = false
    expect(query.all).to contain_exactly(s)
  end

  specify '#local_identifiers true' do
    c = FactoryBot.create(:valid_container)
    e = FactoryBot.create(:valid_specimen, contained_in: c) 
    n = FactoryBot.create(:valid_specimen)

    c.identifiers << FactoryBot.create(:valid_identifier_local) # on container
    n.identifiers << FactoryBot.create(:valid_identifier_local) # on specimen

    query.local_identifiers = true 
    expect(query.all).to contain_exactly(e, n, co1, co2)
  end

  specify '#match_identifiers_delimiter' do
    expect(query.match_identifiers_delimiter).to eq(',')
  end
  
  specify '#match_identifiers' do
    query.match_identifiers = "a,b,   c, #{co1.id}, 99"
    query.match_identifiers_type = 'internal'
    expect(query.identifiers_to_match).to contain_exactly(co1.to_param, '99')
  end

  specify '#match_identifiers 1' do
    query.match_identifiers = "a,b,   c, #{co1.id}, 99"
    query.match_identifiers_type = 'internal'
    expect(query.all.pluck(:id)).to contain_exactly(co1.id)
  end

  specify '#match_identifiers 2' do
    query.match_identifiers = "a,b,  #{n1.short_name} 123 \n\n,  c, #{co1.id}, 99"
    query.match_identifiers_type = 'identifier'
    expect(query.all.pluck(:id)).to contain_exactly(co1.id)
  end

  specify '#identifiers' do
    s = FactoryBot.create(:valid_specimen)
    d = FactoryBot.create(:valid_identifier, identifier_object: s)
    query.identifiers = false
    expect(query.all.pluck(:id)).to contain_exactly()
  end

  specify '#identifiers 1' do
    t =  FactoryBot.create(:valid_specimen)

    Identifier.destroy_all # purge random dwc_occurrence based identifiers that might match
    s = FactoryBot.create(:valid_specimen)
    d = FactoryBot.create(:valid_identifier, identifier_object: s)
    query.identifiers = true
    expect(query.all.pluck(:id)).to contain_exactly(s.id)
  end

  specify '#namespace_id' do
    query.namespace_id = n1.id
    expect(query.all.pluck(:id)).to contain_exactly(co1.id)
  end

  specify 'range 1' do
    query.identifier_start = '123'
    expect(query.all.pluck(:id)).to contain_exactly(co1.id)
  end

  specify 'range 2' do
    query.identifier_start = '120'
    query.identifier_end = '200'
    expect(query.all.pluck(:id)).to contain_exactly(co1.id)
  end

  specify 'range 3' do
    query.identifier_start = '120'
    query.identifier_end = '453'
    expect(query.all.pluck(:id)).to contain_exactly(co1.id, co2.id)
  end

  specify 'range 4' do
    query.namespace_id = n2.id
    query.identifier_start = '120'
    query.identifier_end = '457'
    expect(query.all.pluck(:id)).to contain_exactly(co2.id)
  end

  specify 'range 5' do
    query.namespace_id = 999
    query.identifier_start = '120'
    query.identifier_end = '457'
    expect(query.all.pluck(:id)).to contain_exactly()
  end

  specify '#identifier_exact 1' do
    query.identifier_exact = true
    query.identifier = i2.cached
    expect(query.all.pluck(:id)).to contain_exactly(co2.id)
  end

  specify '#identifier_exact 2' do
    Identifier::Global.destroy_all # purge random dwc_occurrence based identifiers that might match
    query.identifier_exact = false
    query.identifier = '1'
    expect(query.all.pluck(:id)).to contain_exactly(co1.id)
  end
end