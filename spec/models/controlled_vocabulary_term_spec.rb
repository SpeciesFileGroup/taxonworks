require 'spec_helper'

describe ControlledVocabularyTerm do
  let(:controlled_vocabulary_term) { ControlledVocabularyTerm.new }

  context 'associations' do
    context 'has_many' do
      specify 'tags'
    end
  end

  context 'validation' do 
    specify 'it must have a name'
    specify 'it must have a definition'
    specify 'name is unique within projects per type'
    specify 'definition is unique within projects per type'
    specify 'is case sensitive, i.e. bat and Bat are different'
  end

end

