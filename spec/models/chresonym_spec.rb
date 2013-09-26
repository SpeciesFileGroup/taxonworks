require 'spec_helper'

describe Chresonym do

  let(:chresonym) { Chresonym.new }

  context "validation" do 
    context "requires" do
      before do
        chresonym.valid?
      end

      specify "name" do
        expect(chresonym.errors.include?(:name)).to be_false
      end

      specify "type" do
        expect(chresonym.type).to eq('Chresonym')
      end

      specify "rank_class" do
        expect(chresonym.errors.include?(:rank_class)).to be_true
      end

      specify 'at least one TaxonNameRelationship::Chresonym relationship' do
        expect(chresonym.errors.include?(:base)).to be_true 
      end
    end

    context "of formed binomial" do
      before do

        g = TaxonName.new(name: 'Aus', rank_class: ::ICZN_LOOKUP['genus'])
        s = TaxonName.new(name: 'bus', rank_class: ::ICZN_LOOKUP['species'])

        chresonym.genus = g
        chresonym.species = s

        chresonym.valid?
      end

      specify "has met taxon_name_relationship validation" do
         expect(chresonym.errors.include?("no names")).to be_false
      end
    end

  end


end
