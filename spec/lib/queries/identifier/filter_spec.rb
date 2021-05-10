require 'rails_helper'

describe Queries::Identifier::Filter, type: :model, group: :identifiers do

  let(:o1) { FactoryBot.create(:valid_otu) }
  let(:o2) { FactoryBot.create(:valid_specimen) }
  let(:o3) { FactoryBot.create(:valid_collecting_event) }

  let(:n) { FactoryBot.create(:valid_namespace, short_name: 'Foo') }

  let!(:i1) { Identifier::Global::Uri.create!(identifier_object: o1, identifier: 'https://uri.org/example/123') }
  let!(:i2) { Identifier::Local::CatalogNumber.create!(identifier_object: o2, namespace: n, identifier: '345') }
  let!(:i3) { Identifier::Local::CatalogNumber.create!(identifier_object: o3, namespace: n, identifier: '987') }

  let(:query) { Queries::Identifier::Filter.new({}) }

  specify 'generic query' do
    # type=&namespace_id=3&identifier=862422

    query.type = 'Identifier::Local::CatalogNumber'
    # query.identifier_object_id = i2.identifier_object.id
    query.identifier = i2.identifier

    expect(query.all.map(&:id)).to contain_exactly(i2.id)
  end

  specify '#object_global_id 1' do
    query.object_global_id = o1.to_global_id.to_s
    # "gid://taxon-works/Otu/1"
    # query.all => undefined method `type' for #<Otu:0x00007fc49d0553c0>
    expect(query.all.map(&:id)).to contain_exactly(i1.id)
  end

  specify '#object_global_id 2' do
    query.identifier_object_id = [o1.id + 99]
    expect(query.all.map(&:id)).to contain_exactly()
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
    query.identifier_object_type = 'Otu'
    expect(query.all.map(&:id)).to contain_exactly(i1.id)
  end

  specify '#identifier_object_id' do
    query.identifier_object_id = o1.id
    expect(query.all.map(&:id)).to contain_exactly(i1.id, i2.id, i3.id) # when new objects identified, add here as necessary
  end

  specify '#identifier_object_id 2' do
    query.identifier_object_id = [o1.id, 99]
    expect(query.all.map(&:id)).to contain_exactly(i1.id, i2.id, i3.id) # when new objects identified, add here as necessary
  end

  specify '#identifier_type' do
    query.type = 'Identifier::Local::CatalogNumber'
    expect(query.all.map(&:id)).to contain_exactly( i2.id, i3.id)
  end

  specify 'matching_polymorphic_ids #1' do
    query.polymorphic_ids = {'otu_id' => o1.id}
    expect(query.all.map(&:id)).to contain_exactly(i1.id)
  end

  specify 'matching_polymorphic_ids #1' do
    query.polymorphic_ids = {'collecting_event_id' => o3.id}
    expect(query.all.map(&:id)).to contain_exactly(i3.id)
  end

  specify 'matching_identifier_object_type[] #1' do
    query.identifier_object_type = %w{Otu CollectionObject}
    expect(query.all.map(&:id)).to contain_exactly(i1.id, i2.id)
  end

end
