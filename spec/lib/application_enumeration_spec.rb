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
  context '.no_related_data?', type: :model do
    let(:otu) { FactoryBot.create(:valid_otu) }

    specify 'returns true when no data' do
      note = FactoryBot.create(:valid_note)
      expect(ae.no_related_data?(note)).to be true
    end

    specify 'returns true when related data is ignored' do
      # Otus come with a UUID identifier.
      expect(ae.no_related_data?(otu, ignore: [:identifiers, :uuids])).to be true
    end

    specify 'returns false when object has related has_many data (citations)' do
      otu.citations.create!(source: FactoryBot.create(:valid_source))
      expect(ae.no_related_data?(otu)).to be false
    end

    specify 'returns false when object has related has_one data (attribution)' do
      lead = FactoryBot.create(:valid_lead)
      lead.create_attribution!(license: 'Attribution')
      expect(ae.no_related_data?(lead)).to be false
    end
  end

end
