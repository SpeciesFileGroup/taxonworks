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

end
