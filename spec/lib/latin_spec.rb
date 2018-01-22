require 'rails_helper'
require 'utilities/latin'

describe Utilities::Latin  do

  context 'given two names' do
    let(:name1) { 'Aera'  }
    let(:name2) { 'Aerum' }
    let(:name3) { 'Aeruma' }

    context 'they are not validly_published gender variations' do
      specify 'if their lengths differ by more than 1' do
        expect(Utilities::Latin.same_root_name?(name1, name3)).to be_falsey
      end
    end

    context 'names with the same root' do
      let(:name1) { 'Aer'}
      let(:name2) { 'Ara'}

      specify 'it returns the root' do
        expect(Utilities::Latin.root(name1)).to eq('A')
        expect(Utilities::Latin.root(name2)).to eq('A')
        expect(Utilities::Latin.root('absurda')).to eq('absurd')
        expect(Utilities::Latin.root('absurdum')).to eq('absurd')
        expect(Utilities::Latin.root(name1) == Utilities::Latin.root(name2)).to be_truthy
      end
    end


  end 



end




