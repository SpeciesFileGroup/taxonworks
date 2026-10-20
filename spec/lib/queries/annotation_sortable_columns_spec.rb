require 'rails_helper'

# The annotation filters back the single Filter annotations task, one
# filter class per annotation type.
describe 'annotation filter sortable_columns', type: :model do
  annotation_filters = [
    Queries::AlternateValue::Filter,
    Queries::Attribution::Filter,
    Queries::Citation::Filter,
    Queries::Confidence::Filter,
    Queries::DataAttribute::Filter,
    Queries::Depiction::Filter,
    Queries::Documentation::Filter,
    Queries::Identifier::Filter,
    Queries::Note::Filter,
    Queries::Tag::Filter
  ]

  annotation_filters.each do |filter_class|
    context filter_class.name do
      specify 'is memoized via sortable_columns_uncached' do
        expect(filter_class.sortable_columns).to equal(filter_class.sortable_columns)
        expect(filter_class.sortable_columns.keys).to match_array(filter_class.sortable_columns_uncached.keys)
      end

      specify 'exposes created_by' do
        expect(filter_class.sortable_columns_index).to include('created_by')
      end

      specify 'every sort key produces executable SQL' do
        filter_class.sortable_columns_index.each do |key|
          expect { filter_class.new(sort: key).all.to_a }.not_to raise_error, "sort=#{key}"
        end
      end
    end
  end

  context 'sort=created_by' do
    let(:otu) { FactoryBot.create(:valid_otu) }
    let(:zed) { FactoryBot.create(:valid_user, name: 'Zed Zulu') }
    let(:amy) { FactoryBot.create(:valid_user, name: 'Amy Alpha') }

    # Create Zed's note first so id order and name order disagree.
    let!(:note_zed) { Note.create!(text: 'z', note_object: otu, by: zed) }
    let!(:note_amy) { Note.create!(text: 'a', note_object: otu, by: amy) }

    specify 'orders by the creator name, not the user id' do
      expect(Queries::Note::Filter.new(sort: 'created_by').all.to_a).to eq([note_amy, note_zed])
    end

    specify 'descending' do
      expect(Queries::Note::Filter.new(sort: '-created_by').all.to_a).to eq([note_zed, note_amy])
    end
  end
end
