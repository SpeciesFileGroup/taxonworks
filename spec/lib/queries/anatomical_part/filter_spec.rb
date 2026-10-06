require 'rails_helper'

describe Queries::AnatomicalPart::Filter, type: :model do

  let(:q) { Queries::AnatomicalPart::Filter.new({}) }

  specify 'is_material == true counts as "yes, is material"' do
    FactoryBot.create(:valid_anatomical_part, is_material: true)
    q.is_material = true

    expect(q.all.count).to eq(1)
  end

  specify 'is_material == nil (on the model, not the filter) counts as "yes, is material"' do
    FactoryBot.create(:valid_anatomical_part, is_material: nil)
    q.is_material = true

    expect(q.all.count).to eq(1)
  end

  context 'origin id facets' do
    let(:field_occurrence) { FactoryBot.create(:valid_field_occurrence) }
    let!(:anatomical_part) {
      FactoryBot.create(:valid_anatomical_part, ancestor: field_occurrence)
    }

    specify 'field_occurrence_id' do
      q.field_occurrence_id = [field_occurrence.id]

      expect(q.all.pluck(:id)).to contain_exactly(anatomical_part.id)
    end

    specify 'field_occurrence_id accepts a scalar' do
      q = Queries::AnatomicalPart::Filter.new(
        field_occurrence_id: field_occurrence.id
      )

      expect(q.all.pluck(:id)).to contain_exactly(anatomical_part.id)
    end

    specify 'excludes AnatomicalParts originating from another FieldOccurrence' do
      other = FactoryBot.create(:valid_field_occurrence)
      FactoryBot.create(:valid_anatomical_part, ancestor: other)

      q.field_occurrence_id = [field_occurrence.id]

      expect(q.all.pluck(:id)).to contain_exactly(anatomical_part.id)
    end

    specify 'collection_object_id' do
      specimen = FactoryBot.create(:valid_specimen)
      part = FactoryBot.create(:valid_anatomical_part, ancestor: specimen)

      q.collection_object_id = [specimen.id]

      expect(q.all.pluck(:id)).to contain_exactly(part.id)
    end

    specify 'field_occurrence_id ignores a CollectionObject with the same id' do
      specimen = FactoryBot.create(:valid_specimen, id: field_occurrence.id)
      FactoryBot.create(:valid_anatomical_part, ancestor: specimen)

      q.field_occurrence_id = [field_occurrence.id]

      expect(q.all.pluck(:id)).to contain_exactly(anatomical_part.id)
    end
  end

  context 'origin queries' do
    let(:field_occurrence) { FactoryBot.create(:valid_field_occurrence) }
    let!(:field_occurrence_part) {
      FactoryBot.create(:valid_anatomical_part, ancestor: field_occurrence)
    }

    specify 'field_occurrence_query' do
      q = Queries::AnatomicalPart::Filter.new(
        field_occurrence_query: { field_occurrence_id: field_occurrence.id }
      )

      expect(q.all.pluck(:id)).to contain_exactly(field_occurrence_part.id)
    end

    specify 'collection_object_query' do
      specimen = FactoryBot.create(:valid_specimen)
      part = FactoryBot.create(:valid_anatomical_part, ancestor: specimen)

      q = Queries::AnatomicalPart::Filter.new(
        collection_object_query: { collection_object_id: specimen.id }
      )

      expect(q.all.pluck(:id)).to contain_exactly(part.id)
    end

    specify 'collection_object_query ignores a FieldOccurrence with the same id' do
      specimen = FactoryBot.create(:valid_specimen, id: field_occurrence.id)
      part = FactoryBot.create(:valid_anatomical_part, ancestor: specimen)

      q = Queries::AnatomicalPart::Filter.new(
        collection_object_query: { collection_object_id: specimen.id }
      )

      expect(q.all.pluck(:id)).to contain_exactly(part.id)
    end
  end

  context 'otu_query' do
    let(:otu) { FactoryBot.create(:valid_otu) }
    let(:specimen) { FactoryBot.create(:valid_specimen) }
    let!(:part) {
      FactoryBot.create(:valid_anatomical_part, ancestor: specimen, taxon_determination_otu: otu)
    }

    specify 'matches on the taxonomic origin (cached) otu, not just a direct origin relationship' do
      q = Queries::AnatomicalPart::Filter.new(otu_query: { otu_id: otu.id })

      expect(q.all.pluck(:id)).to contain_exactly(part.id)
    end

    specify 'ignores an origin CollectionObject whose id collides with the queried otu id' do
      shared_id = 91_000_001
      FactoryBot.create(:valid_otu, id: shared_id)
      colliding_specimen = FactoryBot.create(:valid_specimen, id: shared_id)
      colliding_part = FactoryBot.create(:valid_anatomical_part, ancestor: colliding_specimen)

      q = Queries::AnatomicalPart::Filter.new(otu_query: { otu_id: shared_id })

      expect(q.all.pluck(:id)).not_to include(colliding_part.id)
    end
  end

  context 'observation_query' do
    let(:specimen) { FactoryBot.create(:valid_specimen) }
    let!(:part) { FactoryBot.create(:valid_anatomical_part, ancestor: specimen) }

    specify 'matches AnatomicalParts that are the observation_object' do
      observation = FactoryBot.create(:valid_observation, observation_object: part)

      q = Queries::AnatomicalPart::Filter.new(
        observation_query: { observation_id: observation.id }
      )

      expect(q.all.pluck(:id)).to contain_exactly(part.id)
    end
  end

  context 'descendant queries' do
    let(:specimen) { FactoryBot.create(:valid_specimen) }
    let!(:part) { FactoryBot.create(:valid_anatomical_part, ancestor: specimen) }

    specify 'extract_query' do
      extract = FactoryBot.create(:valid_extract, origin: part)

      q = Queries::AnatomicalPart::Filter.new(extract_query: { extract_id: extract.id })

      expect(q.all.pluck(:id)).to contain_exactly(part.id)
    end

    specify 'sound_query' do
      sound = FactoryBot.create(:valid_sound, origin: part)

      q = Queries::AnatomicalPart::Filter.new(sound_query: { sound_id: sound.id })

      expect(q.all.pluck(:id)).to contain_exactly(part.id)
    end
  end

end
