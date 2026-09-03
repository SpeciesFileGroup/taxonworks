require 'rails_helper'

describe Queries::FieldOccurrence::Filter, type: :model, group: [:field_occurrences, :filter] do

  let(:q) { Queries::FieldOccurrence::Filter.new({}) }

  context 'anatomical_part_query' do
    let!(:field_occurrence) { FactoryBot.create(:valid_field_occurrence) }
    let!(:anatomical_part) { FactoryBot.create(:valid_anatomical_part, ancestor: field_occurrence) }

    specify 'matches the origin FieldOccurrence' do
      q.anatomical_part_query = ::Queries::AnatomicalPart::Filter.new(anatomical_part_id: anatomical_part.id)
      expect(q.all).to contain_exactly(field_occurrence)
    end

    specify 'ignores a non-AnatomicalPart descendant whose id collides with the anatomical part id' do
      shared_id = 91_000_003
      other_field_occurrence = FactoryBot.create(:valid_field_occurrence, id: shared_id)
      FactoryBot.create(:valid_extract, origin: other_field_occurrence, id: shared_id)

      ap = FactoryBot.create(:valid_anatomical_part, ancestor: field_occurrence, id: shared_id)

      q.anatomical_part_query = ::Queries::AnatomicalPart::Filter.new(anatomical_part_id: ap.id)
      expect(q.all).to contain_exactly(field_occurrence)
    end
  end

end
