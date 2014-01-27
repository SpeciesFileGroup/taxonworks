require 'spec_helper'
require 'latin'

describe 'Latin' do

  context "given two names" do
    let(:name1) { 'Aera'  }
    let(:name2) { 'Aerum' }
    let(:name3) { 'Aeruma' }

    context "they are not validly_published gender variations" do
      specify "if their lengths differ by more than 1" do
        expect(Latin.same_root_name?(name1, name3)).to be_false
      end
    end

    context "names with the same root" do
      let(:name1) { 'Aer'}
      let(:name2) { 'Ara'}

      specify "it returns the root" do
        expect(Latin.root(name1)).to eq('A')
        expect(Latin.root(name2)).to eq('A')
        expect(Latin.root('absurda')).to eq('absurd')
        expect(Latin.root('absurdum')).to eq('absurd')
        expect(Latin.root(name1) == Latin.root(name2)).to be_true
      end
    end


  end 



end




