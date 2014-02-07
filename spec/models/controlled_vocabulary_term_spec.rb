require 'spec_helper'

describe ControlledVocabularyTerm do
  let(:controlled_vocabulary_term) { FactoryGirl.build(:controlled_vocabulary_term)  }

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
    specify 'name is unique within projects per type'  do
      a = FactoryGirl.create(:valid_controlled_vocabulary_term)
      b = FactoryGirl.build(:valid_controlled_vocabulary_term, definition: 'Something else.')
      expect(b.valid?).to_not be_true
      b.name = 'Something Completely Different'
      expect(b.valid?).to be_true
    end

    specify 'definition is unique within projects' do
      a = FactoryGirl.create(:valid_controlled_vocabulary_term, definition: 'Something crazy!')
      b = FactoryGirl.build(:valid_controlled_vocabulary_term, name: 'Something else.', definition: 'Something crazy!')
      expect(b.valid?).to be_false
      expect(b.errors.include?(:definition)).to be_true
    end

    specify 'is case sensitive, i.e. bat and Bat are different' do
      a = FactoryGirl.create(:valid_controlled_vocabulary_term, name: 'blue')
      b = FactoryGirl.build(:valid_controlled_vocabulary_term, definition: 'Something else.', name: 'Blue')
      expect(b.valid?).to be_true
    end

  end

  context 'concerns' do
   it_behaves_like 'alternate_values'
  end
end
