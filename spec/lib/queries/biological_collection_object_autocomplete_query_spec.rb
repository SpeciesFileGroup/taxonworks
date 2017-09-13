require 'rails_helper'

describe Queries::BiologicalCollectionObjectAutocompleteQuery, type: :model do

  let!(:namespace1) { Namespace.create!(name: 'Space1', short_name: 'Space1') }
  let!(:namespace2) { Namespace.create!(name: 'Space2', short_name: 'Space2') }

  let!(:specimen1) { Specimen.create! }
  let!(:specimen2) { Specimen.create! }
  let!(:specimen3) { Specimen.create! }

  let!(:lot1) { Lot.create!(total: 5) }
  let!(:lot2) { Lot.create!(total: 6) }
  let!(:lot3) { Lot.create!(total: 7) }

  context 'identifiers' do
    let!(:identifier1) { Identifier::Local::CatalogNumber.create!(identifier_object: specimen1, identifier: '123', namespace: namespace1) }
    let!(:identifier2) { Identifier::Local::CatalogNumber.create!(identifier_object: specimen2, identifier: '456', namespace: namespace1) }
    let!(:identifier3) { Identifier::Local::CatalogNumber.create!(identifier_object: specimen3, identifier: '789123012', namespace: namespace1) }

    let!(:identifier4) { Identifier::Local::CatalogNumber.create!(identifier_object: lot2, identifier: '321', namespace: namespace1) }
    let!(:identifier5) { Identifier::Local::CatalogNumber.create!(identifier_object: lot1, identifier: '123', namespace: namespace2) }


    context 'when a identifier matches exactly, then the record should be first in the list' do
      specify 'trial 1' do
        expect(Queries::BiologicalCollectionObjectAutocompleteQuery.new('Space1 123').autocomplete.first).to eq(specimen1)
      end

      specify 'trial 2' do
        expect(Queries::BiologicalCollectionObjectAutocompleteQuery.new('Space2 123').autocomplete.first).to eq(lot1)
      end
    end

    context 'an identifier fragment' do
      specify 'matches multiple records' do
        expect(Queries::BiologicalCollectionObjectAutocompleteQuery.new('123').autocomplete).to include(specimen1, specimen3, lot1)
      end

      specify 'matches multiple records with project_id' do
        expect(Queries::BiologicalCollectionObjectAutocompleteQuery.new('123', project_id: specimen1.project_id).autocomplete).to include(specimen1, specimen3, lot1)
      end
    end 

    specify '#all' do
      expect(Queries::BiologicalCollectionObjectAutocompleteQuery.new('123').all.to_a).to include(specimen1)
    end

  end

  context 'determinations' do
    let!(:otu) { Otu.create(name: 'Aus bus') }
    let!(:taxon_determination) { TaxonDetermination.create(biological_collection_object: specimen1, otu: otu) }


    specify 'an otu name matches a record' do
      expect(Queries::BiologicalCollectionObjectAutocompleteQuery.new('Aus bus').autocomplete).to include(specimen1)
    end
  end


end
