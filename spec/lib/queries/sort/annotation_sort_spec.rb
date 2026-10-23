require 'rails_helper'

# The annotation filters back the single Filter annotations task, one
# filter (and Sort) class per annotation type.
describe 'annotation Sort classes', type: :model do
  annotation_sorts = [
    Queries::AlternateValue::Sort,
    Queries::Attribution::Sort,
    Queries::Citation::Sort,
    Queries::Confidence::Sort,
    Queries::DataAttribute::Sort,
    Queries::Depiction::Sort,
    Queries::Documentation::Sort,
    Queries::Identifier::Sort,
    Queries::Note::Sort,
    Queries::Tag::Sort
  ]

  annotation_sorts.each do |sort_class|
    context sort_class.name do
      specify 'columns are memoized' do
        expect(sort_class.columns).to equal(sort_class.columns)
      end

      specify 'exposes created_by' do
        expect(sort_class.keys).to include('created_by')
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
      expect(Queries::Pager.new(Note.all, sort: 'created_by').ordered.to_a).to eq([note_amy, note_zed])
    end

    specify 'descending' do
      expect(Queries::Pager.new(Note.all, sort: '-created_by').ordered.to_a).to eq([note_zed, note_amy])
    end
  end
end
