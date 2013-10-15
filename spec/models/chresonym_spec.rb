require 'spec_helper'

describe Chresonym do

  let(:chresonym) { ::Chresonym.new }

  context "associations" do
    context "has_one" do
      context "taxon_name_relationships" do
        %w{genus subgenus species subspecies}.each do |rank|
          method = "#{rank}_taxon_name_relationship" 
          specify method do
            expect(chresonym).to respond_to(method)
          end 
        end
      end

      context "taxon_names" do
        %w{genus subgenus species subspecies}.each do |rank|
          specify rank do
            expect(chresonym).to respond_to(rank.to_sym)
          end 
        end
      end
    end
  end

  context "validation" do 
    context "requires" do
      before do
        chresonym.valid?
      end

      specify "name to be nil" do
        expect(chresonym.errors.include?(:name)).to be_false
      end

      specify "type is Chresonym" do
        expect(chresonym.type).to eq('Chresonym')
      end

      specify "rank_class is optional" do
        expect(chresonym.errors.include?(:rank_class)).to be_false
      end

      specify 'specified Chresonym differs from Protonym original description for species-group names' do
        pending
      end 

    end

    context "usage" do
      context "subgeneric placement" do
        specify "a genus group name used as a subgenus" do
          c = FactoryGirl.create(:subgenus_chresonym)
          expect(c.genus.name).to eq('Aus')
          expect(c.subgenus.name).to eq('Bus')
        end
      end

      context "species group names" do
        specify "a species group named used under a different genus" do
          c = FactoryGirl.create(:species_chresonym)
          expect(c.genus.name).to eq('Aus')
          expect(c.species.name).to eq('bus')
        end
      end
    end
  end
end
