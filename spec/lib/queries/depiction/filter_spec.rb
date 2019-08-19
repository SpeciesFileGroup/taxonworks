require 'rails_helper'

describe Queries::Depiction::Filter, type: :model, group: :depictions do

  let!(:o) { FactoryBot.create(:valid_otu) }
  let!(:s) { FactoryBot.create(:valid_specimen) }
  let!(:c) { FactoryBot.create(:valid_collecting_event) }

  let!(:d1) { FactoryBot.create(:valid_depiction, depiction_object: o) } 
  let!(:d2) { FactoryBot.create(:valid_depiction, depiction_object: s) } 

  let(:query) { Queries::Depiction::Filter.new({}) }

  specify '#depiction_object_type' do
    query.depiction_object_type = 'Otu'
    expect(query.all.map(&:id)).to contain_exactly(d1.id)
  end

  specify '#depiction_object_types' do
    query.depiction_object_types = ['Otu', 'CollectionObject']
    expect(query.all.map(&:id)).to contain_exactly(d1.id, d2.id)
  end

# specify '#depiction_object_id' do
#   query.depiction_object_id = o.id
#   expect(query.all.map(&:id)).to contain_exactly(i2.id, i3.id)
# end

# specify '#namespace_short_name #1' do
#   query.namespace_short_name = n.short_name
#   expect(query.all.map(&:id)).to contain_exactly(i2.id, i3.id)
# end

# specify '#namespace_short_name #2' do
#   query.namespace_short_name = 'zzzz'
#   expect(query.all.map(&:id)).to contain_exactly()
# end

# specify '#namespace_name #1' do
#   query.namespace_name = n.name
#   expect(query.all.map(&:id)).to contain_exactly(i2.id, i3.id)
# end

# specify '#namespace_name #2' do
#   query.namespace_name = 'asfasdf'
#   expect(query.all.map(&:id)).to contain_exactly()
# end

# specify '#depiction_object_type' do
#   query.depiction_object_type = 'Otu'
#   expect(query.all.map(&:id)).to contain_exactly(i1.id)
# end

# specify '#depiction_object_id' do
#   query.depiction_object_id = o1.id
#   expect(query.all.map(&:id)).to contain_exactly(i1.id, i2.id, i3.id) # when new objects identified, add here as necessary
# end

# specify '#depiction_object_ids' do
#   query.depiction_object_ids = [o1.id, 99]
#   expect(query.all.map(&:id)).to contain_exactly(i1.id, i2.id, i3.id) # when new objects identified, add here as necessary
# end

# specify '#type' do
#   query.type = 'Depiction::Local::CatalogNumber'
#   expect(query.all.map(&:id)).to contain_exactly( i2.id, i3.id) 
# end

# specify 'matching_polymorphic_ids #1' do
#   query.polymorphic_ids = {'otu_id' => o1.id} 
#   expect(query.all.map(&:id)).to contain_exactly(i1.id) 
# end

# specify 'matching_polymorphic_ids #1' do
#   query.polymorphic_ids = {'collecting_event_id' => o3.id} 
#   expect(query.all.map(&:id)).to contain_exactly(i3.id) 
# end

# specify 'matching_depiction_object_types[] #1' do
#   query.depiction_object_types = %w{Otu CollectionObject}
#   expect(query.all.map(&:id)).to contain_exactly(i1.id, i2.id) 
# end

end
