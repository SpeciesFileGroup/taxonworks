require 'rails_helper'

describe Note, type: :model, group: :annotator do

  let(:note) {FactoryBot.build(:note)}

  context 'associations' do
    context 'belongs_to' do
      specify 'note_object' do
        expect(note.note_object = Specimen.new).to be_truthy
      end
    end
  end

  # sanity check for Housekeeping, which is also tested elsewhere
    context 'sets housekeeping' do
      let(:specimen1) {FactoryBot.create(:valid_specimen)}

      before {note.valid?}
      specify 'creator' do
        expect(note.errors.include?(:creator)).to be_falsey
      end

      specify 'updater' do
        expect(note.errors.include?(:updater)).to be_falsey
      end

      specify 'with <<' do
        expect(specimen1.notes.count).to eq(0)
        specimen1.notes << Note.new(text: 'Yay!')
        expect(specimen1.save).to be_truthy
        expect(specimen1.notes.first.creator.nil?).to be_falsey
        expect(specimen1.notes.first.updater.nil?).to be_falsey
        expect(specimen1.notes.first.project.nil?).to be_falsey
      end

      specify 'with .build' do
        expect(specimen1.notes.count).to eq(0)
        specimen1.notes.build(text: 'Nay!')
        expect(specimen1.save).to be_truthy
        expect(specimen1.notes.first.creator.nil?).to be_falsey
        expect(specimen1.notes.first.updater.nil?).to be_falsey
        expect(specimen1.notes.first.project.nil?).to be_falsey
      end

      specify 'with new objects and <<' do
        s = FactoryBot.build(:valid_specimen)
        s.notes << Note.new(text: 'Whooopee!')
        expect(s.save).to be_truthy
        expect(s.notes.count).to eq(1)
        expect(s.notes.first.creator.nil?).to be_falsey
        expect(s.notes.first.updater.nil?).to be_falsey
        expect(s.notes.first.project.nil?).to be_falsey
      end

      specify 'with new objects and build' do
        s = FactoryBot.build(:valid_specimen)
        s.notes.build(text: 'Yabbadabbadoo.')
        expect(s.save).to be_truthy
        expect(s.notes.count).to eq(1)
        expect(s.notes.first.creator.nil?).to be_falsey
        expect(s.notes.first.updater.nil?).to be_falsey
        expect(s.notes.first.project.nil?).to be_falsey
      end

      specify 'as nested_attributes' do
        s = FactoryBot.build(:valid_specimen)
        s.notes_attributes = [{text: 'foo'}, {text: 'bar'}]
        expect(s.save).to be_truthy
      end
    end

  context 'validations' do
    before(:each) { note.valid? }

    context 'required' do
      specify 'note_object (the thing that has the note)' do
        expect(note.errors.include?(:note_object)).to be_truthy
      end

      specify 'text' do
        expect(note.errors.include?(:text)).to be_truthy
      end

    end
  end

  specify '#text is not trimmed' do
    s = " asdf sd  \n  asdfd \r\n"
    note.text = s
    note.valid?
    expect(note.text).to eq(s)
  end

  context 'concerns' do
    it_behaves_like 'is_data'
  end

end
