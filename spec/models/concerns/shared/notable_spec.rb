require 'rails_helper'
describe 'Notable', :type => :model do
  let(:class_with_note) { TestNotable.new } 
 
  context 'foo', a: :b do
    it "has access to methods defined in shared context" do
      expect(shared_method).to eq("it works")
    end

    it "has access to methods defined with let in shared context" do
      expect(shared_let['arbitrary']).to eq('object')
    end

    it "runs the before hooks defined in the shared context" do
      expect(@some_var).to be(:some_value)
    end

    it "accesses the subject defined in the shared context" do
      expect(subject).to eq('this is the subject')
    end 
  end 

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

  specify 'adding a attribute (column) note works' do
    expect(class_with_note.save).to be_truthy
    expect(class_with_note.notes << FactoryGirl.build(
      :note, 
      text: 'foo', 
      note_object_attribute: TestNotable.columns[4].name)).to be_truthy # column 4 is 'string', others are on restricted list
   
    expect(class_with_note.save).to be_truthy
    expect(class_with_note.notes.size == 1).to be_truthy
    expect(class_with_note.notes[0].text).to eq('foo')
    expect(class_with_note.notes[0].note_object_attribute).to eq(TestNotable.columns[4].name)
  end

  context 'attaching a note to column that is not notable' do
    let(:bad_note) { FactoryGirl.build(:note, text: 'foo') }
    let(:error_message) { 'can not add a note to this attribute (column)'}
    before(:each) { class_with_note.save! }

    # for each column in ::NON_ANNOTATABLE_COLUMNS test that you can't add a note to it.
    NON_ANNOTATABLE_COLUMNS.each do |attr|
      specify "#{attr.to_s} is a housekeeping or related column and can not be annotated" do
        expect(class_with_note.notes.count == 0).to eq(true)

        bad_note.note_object_attribute = attr
        bad_note.text                  = "note to #{attr.to_s}"
        expect(class_with_note.notes << bad_note).to be_falsey

        expect(class_with_note.notes.count == 0).to eq(true) #be_truthy # <---
        expect(bad_note.errors.messages[:note_object_attribute].include?(error_message)).to be_truthy
  
        # now add note to a real column
        bad_note.note_object_attribute = :string 
        expect(bad_note.errors.full_messages.include?(error_message)).to be_falsey
      end
    end

    specify 'can not add a note to a non-existent attribute (column)' do
      expect(class_with_note.notes.count == 0).to eq(true)
 
      not_a_column = 'nonexistentColumn'
      bad_note.note_object_attribute = not_a_column 

      expect(class_with_note.notes << bad_note).to be_falsey
      expect(class_with_note.notes.count == 0).to be_truthy
      expect(bad_note.errors.messages[:note_object_attribute].include?("#{not_a_column} is not an attribute (column) of #{class_with_note.class}")).to be_truthy

      # now add note to a real column
      bad_note.note_object_attribute = :string 
      expect(bad_note.errors.full_messages.include?(error_message)).to be_falsey
    end
  end

  context 'methods' do
    # has_notes has changed to mean that the class is notable (see is_data.rb)
    # specify 'has_notes? with no notes' do
    #   expect(class_with_note.has_notes?).to eq(true)
    # end
    #
    # specify 'has_notes? with some notes' do
    #   class_with_note.notes << Note.new(text: "Foo")
    #   expect(class_with_note.has_notes?).to eq(true)
    # end
  end
end

class TestNotable < ActiveRecord::Base
  include FakeTable
  include Shared::Notable
end

