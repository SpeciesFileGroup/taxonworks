require 'rails_helper'

describe 'Notable', type: :model do
  let(:class_with_note) { TestNotable.new } 

  context 'associations' do
    specify 'has many notes' do
      expect(class_with_note).to respond_to(:notes) # tests that the method notations exists
      expect(class_with_note.notes.count == 0).to be_truthy # currently has no notes
    end
  end

  specify 'accepts_nested_attributes_for' do
    notes = {notes_attributes: [{text: "a"}, {text: "b"}]}
    class_with_note.attributes = notes
    expect(class_with_note.save).to be_truthy
    expect(class_with_note.notes.count).to eq(2)
  end

  specify 'adding a object note works' do
    expect(class_with_note.save).to be_truthy
    expect(class_with_note.notes << FactoryGirl.build(:note, text: 'foo')).to be_truthy
    expect(class_with_note.save).to be_truthy
    expect(class_with_note.notes.count == 1).to be_truthy
    expect(class_with_note.notes[0].text).to eq('foo')
  end

  # <snip> Validity of note on a particular attribute is tested via AttributeAnnotation tests

end

class TestNotable < ActiveRecord::Base
  include FakeTable
  include Shared::Notable
end

