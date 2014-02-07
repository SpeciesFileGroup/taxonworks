require 'spec_helper'

describe ControlledVocabularyTerm do
  let(:controlled_vocabulary_term) { FactoryGirl.build(:controlled_vocabulary_term)  }

  context 'associations' do
    context 'has_many' do
      specify 'tags'
    end
  end

  context 'validation' do 
    before(:each) {
      controlled_vocabulary_term.valid?
    }

    context 'required' do
      specify 'name' do
        expect(controlled_vocabulary_term.errors.include?(:name)).to be_true
      end

      specify 'definition' do
        expect(controlled_vocabulary_term.errors.include?(:definition)).to be_true
      end

      specify 'type' do
        expect(controlled_vocabulary_term.errors.include?(:type)).to be_true
      end
    end
  end

  specify 'definition is 4 letters long minium' do
    controlled_vocabulary_term.definition = 'abc'
    controlled_vocabulary_term.valid?
    expect(controlled_vocabulary_term.errors.include?(:definition)).to be_true
  end

  context 'within projects' do
    specify 'name is unique within projects per type'
    specify 'definition is unique within projects'
    specify 'is case sensitive, i.e. bat and Bat are different'
  end

  context 'concerns' do
   it_behaves_like 'alternate_values'
  end
end
