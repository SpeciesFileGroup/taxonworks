require 'rails_helper'
require 'application_enumeration'

describe 'ApplicationEnumeration' do

  let(:ae) { ApplicationEnumeration }

  specify '.data_models #2' do
    expect(ae.data_models).to include(Identifier)
  end

  specify '.data_models #1' do
    expect(ae.data_models).to include(AlternateValue)
  end

  specify '.data_models #3' do
    expect(ae.data_models).to include(TypeMaterial)
  end

  specify '.citable_relations :all keys' do
    h = ae.citable_relations(Otu)
    expect(h.keys).to contain_exactly(:has_many, :has_one, :belongs_to)
  end

  specify '.citable_relations has_many' do
    h = ae.citable_relations(Otu, :has_many)
    expect(h[:has_many]).to include(:images, :confidences, :collection_objects)
    expect(h[:has_many]).not_to include(:pinboard_items)
  end

  specify '.citable_relations has_one' do
    h = ae.citable_relations(Lead, :has_one)
    expect(h[:has_one]).to include(:taxon_name) # through otu
    # TODO find a klass with a good uncitable has_one
  end

  specify '.citable_relations belongs_to' do
    h = ae.citable_relations(CollectionObject, :belongs_to)
    expect(h[:belongs_to]).to include(:collecting_event)
    expect(h[:belongs_to]).not_to include(:user)
  end
end
