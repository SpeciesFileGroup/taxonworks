require 'rails_helper'

describe Queries::Identifier::Filter, type: :model, group: :identifiers do

  let(:o1) { FactoryBot.create(:valid_specimen) }
  let(:o2) { FactoryBot.create(:valid_specimen) }
  let(:o3) { FactoryBot.create(:valid_specimen) }

  let(:n) { FactoryBot.create(:valid_namespace, short_name: 'Foo') }

  let!(:i1) { Identifier::Global::Uri.create!(identifier_object: o1, identifier: 'https://uri.org/example/123') }
  let!(:i2) { Identifier::Local::CatalogNumber.create!(identifier_object: o2, namespace: n, identifier: '345') }
  let!(:i3) { Identifier::Local::CatalogNumber.create!(identifier_object: o3, namespace: n, identifier: '987') }

  let(:query) { Queries::Identifier::Filter.new({}) }

  specify '#annotated_class Person' do
    query.identifier_object_type = 'Person'
    expect(query.annotated_class).to eq(['Person'])
  end

  specify '#ignores_project? Person' do
    query.identifier_object_type = 'Person'
    expect(query.ignores_project?).to be_truthy
  end

  specify '#ignores_project Source' do
    query.identifier_object_type = 'Source'
    expect(query.ignores_project?).to be_truthy
  end

  specify 'Source and Identifier::Global' do
    s = FactoryBot.create(:valid_source_bibtex)
    i = Identifier::Global::Uri.create!(identifier_object: s, identifier: 'https://uri.org/example/123')

    query.identifier_object_type = 'Source'
    query.identifier_object_id = s.id

    expect(query.all).to contain_exactly(i)
  end

  specify '#set_polymorphic_params id' do
    query.set_polymorphic_params({person_id: 1})
    expect(query.polymorphic_type).to eq('Person')
  end

  specify '#set_polymorphic_params type' do
    query.set_polymorphic_params({person_id: 1})
    expect(query.polymorphic_id).to eq(1)
  end

  specify 'Person (person_id) and Identifier::Global' do
    p = FactoryBot.create(:valid_person)
    i = Identifier::Global::Uri.create!(identifier_object: p, identifier: 'https://uri.org/example/123')

    query.set_polymorphic_params({person_id: p.id})

    expect(query.all).to contain_exactly(i)
  end

  specify 'Person and Identifier::Global' do
    p = FactoryBot.create(:valid_person)
    i = Identifier::Global::Uri.create!(identifier_object: p, identifier: 'https://uri.org/example/123')

    query.identifier_object_type = 'Person'
    query.identifier_object_id = p.id

    expect(query.all).to contain_exactly(i)
  end

  specify 'generic query' do
    # type=&namespace_id=3&identifier=862422

    query.type = 'Identifier::Local::CatalogNumber'
    query.identifier_object_id = i2.identifier_object.id
    query.identifier = i2.identifier

    expect(query.all.map(&:id)).to contain_exactly(i2.id)
  end

  specify '#object_global_id'  do
    query.object_global_id = i1.to_global_id.to_s
    expect(query.all.map(&:id)).to contain_exactly(i1.id)
  end

  specify '#query_string' do
    query.query_string = 'Foo 345'
    expect(query.all.map(&:id)).to contain_exactly(i2.id)
  end

  specify '#identifier' do
    query.identifier = '345'
    expect(query.all.map(&:id)).to contain_exactly(i2.id)
  end

  specify '#namespace_id' do
    query.namespace_id = n.id
    expect(query.all.map(&:id)).to contain_exactly(i2.id, i3.id)
  end

  specify '#namespace_short_name #1' do
    query.namespace_short_name = n.short_name
    expect(query.all.map(&:id)).to contain_exactly(i2.id, i3.id)
  end

  specify '#namespace_short_name #2' do
    query.namespace_short_name = 'zzzz'
    expect(query.all.map(&:id)).to contain_exactly()
  end

  specify '#namespace_name #1' do
    query.namespace_name = n.name
    expect(query.all.map(&:id)).to contain_exactly(i2.id, i3.id)
  end

  specify '#namespace_name #2' do
    query.namespace_name = 'asfasdf'
    expect(query.all.map(&:id)).to contain_exactly()
  end

  specify '#identifier_object_type' do
    query.identifier_object_type = 'CollectionObject'
    expect(query.all.map(&:id)).to include(i1.id)
  end

  specify '#identifier_object_id' do
    query.identifier_object_id = o1.id
    expect(query.all.map(&:id)).to include(i1.id) # when new objects identified, add here as necessary
  end

  specify '#identifier_object_id 2' do
    query.identifier_object_id = [o1.id, 99]
    expect(query.all.map(&:id)).to include(i1.id) # when new objects identified, add here as necessary
  end

  specify '#identifier_type' do
    query.type = 'Identifier::Local::CatalogNumber'
    expect(query.all.map(&:id)).to contain_exactly( i2.id, i3.id)
  end


  specify 'matching_identifier_object_type[] #1' do
    query.identifier_object_type = %w{Otu CollectionObject}
    expect(query.all.map(&:id)).to include(i1.id, i2.id)
  end

end
