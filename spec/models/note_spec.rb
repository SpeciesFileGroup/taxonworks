require 'spec_helper'

describe Note do

  let(:note) {FactoryGirl.build(:note)} 

  context 'associations' do
    context 'belongs_to' do
      specify 'note_object' do
        expect(note).to respond_to(:note_object) 
      end
    end
  end

  context 'validations' do
    before(:each) {
      note.valid?
    }

    context 'required' do
      specify 'note_object (the thing that has the note)' do 
        expect(note.errors.include?(:note_object)).to be_truthy
      end

      specify 'text' do
        expect(note.errors.include?(:text)).to be_truthy
      end
    end
  end
end
