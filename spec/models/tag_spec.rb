require 'spec_helper'

describe Tag do

  let(:tag) {Tag.new}

  context 'associations' do
    specify 'polymorphic tag_object relationships'
  end

  context 'validations' do
    specify 'a tag object is required'
    specify 'a keyword is required'
    specify 'a tagged object is only tagged once per keyword'
    specify 'a attribute is actually a attribute of the tag object'
  end

  context 'concerns' do
    specify 'isolate and create concern taggable (see identifiable concern)' 
  end

end

