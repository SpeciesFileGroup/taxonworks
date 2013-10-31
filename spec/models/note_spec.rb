require 'spec_helper'

describe Note do

  let(:note) {Note.new}

  context 'associations' do
    specify 'polymorphic note_object relationships'
  end

  context 'validations' do
    specify 'a note object is required'
    specify 'a note is required'
    specify 'a attribute is actually a attribute of the noted object'
  end

  context 'concerns' do
    specify 'isolate and create concern annotatable (see identifiable concern)' 
  end

end
