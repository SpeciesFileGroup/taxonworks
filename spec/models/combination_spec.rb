require 'spec_helper'

describe Combination do

  before(:all) do
    @family = FactoryGirl.create(:relationship_family, name: 'Aidae')
    @combination = FactoryGirl.create(:combination, parent: @family)
  end

  context "associations" do
    context "has_one" do
      context "taxon_name_relationships" do
        %w{genus subgenus section subsection series subseries species subspecies variety subvariety form subform}.each do |rank|
          method = "#{rank}_taxon_name_relationship" 
          specify method do
            expect(@combination).to respond_to(method)
          end 
        end
      end

      context "taxon_names" do
        %w{genus subgenus section subsection series subseries species subspecies variety subvariety form subform}.each do |rank|
          specify rank do
            expect(@combination).to respond_to(rank.to_sym)
          end 
        end
      end
    end
  end

  context "validation" do 
    context "requires" do
      before do
        @combination.valid?
      end

      specify "name to be nil" do
        expect(@combination.errors.include?(:name)).to be_false
      end

      specify "type is Combination" do
        expect(@combination.type).to eq('Combination')
      end

      specify "rank_class is optional" do
        expect(@combination.errors.include?(:rank_class)).to be_false
      end

      specify 'specified Combination differs from Protonym original description for species-group names' do
        pending
      end
    end

    context "usage" do
      before(:all) do
        @genus = FactoryGirl.create(:iczn_genus, name: 'Aus', parent: @family)
        @subgenus = FactoryGirl.create(:iczn_subgenus, name: 'Bus', parent: @genus)
        @species = FactoryGirl.create(:iczn_species, name: 'bus', parent: @subgenus)
      end
      specify "a genus group name used as a subgenus" do
        c = FactoryGirl.create(:combination, parent: @subgenus)
        c.genus = @genus
        c.subgenus = @subgenus
        expect(c.valid?).to be_true
        expect(c.genus.name).to eq('Aus')
        expect(c.subgenus.name).to eq('Bus')
      end
      specify "species group names used under a different genus" do
        c = FactoryGirl.create(:combination, parent: @species)
        c.genus = @genus
        c.species = @species
        expect(c.valid?).to be_true
        expect(c.genus.name).to eq('Aus')
        expect(c.species.name).to eq('bus')
      end
    end
  end
end
