require 'rails_helper'

describe ControlledVocabularyTerm, :type => :model do
  let(:controlled_vocabulary_term) { FactoryGirl.build(:controlled_vocabulary_term)  }

  context 'validation' do 
    before(:each) {
      controlled_vocabulary_term.valid?
    }

    context 'required' do
      specify 'name' do
        expect(controlled_vocabulary_term.errors.include?(:name)).to be_truthy
      end

      specify 'definition' do
        expect(controlled_vocabulary_term.errors.include?(:definition)).to be_truthy
      end

      specify 'type' do
        expect(controlled_vocabulary_term.errors.include?(:type)).to be_truthy
      end
    end
  end

  specify 'definition is 4 letters long minium' do
    controlled_vocabulary_term.definition = 'abc'
    controlled_vocabulary_term.valid?
    expect(controlled_vocabulary_term.errors.include?(:definition)).to be_truthy
  end

  context 'within projects' do

    let(:uri) { 'http://purl.org/net/foo/1' }

    specify 'name is unique within projects per type'  do
      a = FactoryGirl.create(:valid_controlled_vocabulary_term)
      b = FactoryGirl.build(:valid_controlled_vocabulary_term, definition: 'Something else.', same_as_uri: uri)
      expect(b.valid?).to be_falsey
      b.name = 'Something Completely Different'
      expect(b.valid?).to be_truthy
    end

    specify 'definition is unique within projects' do
      a = FactoryGirl.create(:valid_controlled_vocabulary_term, definition: 'Something crazy!', same_as_uri: uri)
      b = FactoryGirl.build(:valid_controlled_vocabulary_term, name: 'Something else.', definition: 'Something crazy!', same_as_uri: uri)
      expect(b.valid?).to be_falsey
      expect(b.errors.include?(:definition)).to be_truthy
    end

    specify 'same_as_uri is unique within projects' do
      a = FactoryGirl.create(:valid_controlled_vocabulary_term, same_as_uri: uri)
      b = FactoryGirl.build(:valid_controlled_vocabulary_term, same_as_uri: uri )
      expect(b.valid?).to be_falsey
      expect(b.errors.include?(:same_as_uri)).to be_truthy
    end

    specify 'is case sensitive, i.e. bat and Bat are different' do
      a = FactoryGirl.create(:valid_controlled_vocabulary_term, name: 'blue')
      b = FactoryGirl.build(:valid_controlled_vocabulary_term, definition: 'Something else.', name: 'Blue', same_as_uri: :uri)
      expect(b.valid?).to be_truthy
    end

  end

  context 'concerns' do
   it_behaves_like 'alternate_values'
  end
end
