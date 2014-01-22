require 'spec_helper'

describe Combination do

  before(:all) do
    TaxonName.delete_all
    @family = FactoryGirl.create(:relationship_family, name: 'Aidae', year_of_publication: 2000)
    @combination = FactoryGirl.create(:combination, parent: @family)
    @source = FactoryGirl.create(:valid_source_bibtex, year: 1940, author: 'Dmitriev')
  end
  after(:all) do
    TaxonName.delete_all
  end

  context 'associations' do
    context 'has_one' do
      context 'taxon_name_relationships' do
        %w{genus subgenus section subsection series subseries species subspecies variety subvariety form subform}.each do |rank|
          method = "#{rank}_taxon_name_relationship" 
          specify method do
            expect(@combination).to respond_to(method)
          end 
        end
      end

      context 'taxon_names' do
        %w{genus subgenus section subsection series subseries species subspecies variety subvariety form subform}.each do |rank|
          specify rank do
            expect(@combination).to respond_to(rank.to_sym)
          end 
        end
      end
    end
  end

  context 'validation' do
    context 'requires' do
      before do
        @combination.valid?
      end

      specify 'name to be nil' do
        expect(@combination.errors.include?(:name)).to be_false
      end

      specify 'type is Combination' do
        expect(@combination.type).to eq('Combination')
      end

      specify 'rank_class is optional' do
        expect(@combination.errors.include?(:rank_class)).to be_false
      end
    end

    context 'usage' do
      before(:all) do
        @genus = FactoryGirl.create(:iczn_genus, name: 'Aus', parent: @family)
        @subgenus = FactoryGirl.create(:iczn_subgenus, name: 'Bus', parent: @genus)
        @species = FactoryGirl.create(:iczn_species, name: 'bus', parent: @subgenus)
      end
      specify 'a genus group name used as a subgenus' do
        c = FactoryGirl.create(:combination, parent: @subgenus)
        c.genus = @genus
        c.subgenus = @subgenus
        expect(c.valid?).to be_true
        expect(c.genus.name).to eq('Aus')
        expect(c.subgenus.name).to eq('Bus')
      end
      specify 'species group names used under a different genus' do
        c = FactoryGirl.create(:combination, parent: @species)
        c.genus = @genus
        c.species = @species
        expect(c.valid?).to be_true
        expect(c.genus.name).to eq('Aus')
        expect(c.species.name).to eq('bus')
      end
    end
  end

  context 'soft validation' do

    specify 'missing source and year' do
      @combination.soft_validate(:missing_fields)
      expect(@combination.soft_validations.messages_on(:source_id).empty?).to be_false
      expect(@combination.soft_validations.messages_on(:year_of_publication).empty?).to be_false
    end

    specify 'year of combination and year of source does not match' do
      c = FactoryGirl.build(:combination, year_of_publication: 1950, parent: @family, source: @source)
      c.soft_validate(:source_older_then_description)
      expect(c.soft_validations.messages_on(:source_id).count).to eq(1)
      c.year_of_publication = 1940
      expect(c.valid?).to be_true
      c.soft_validate(:source_older_then_description)
      expect(c.soft_validations.messages_on(:source_id).empty?).to be_true
    end

    specify 'combination is older than taxon' do
      c = FactoryGirl.build(:combination, year_of_publication: 1900, parent: @family)
      @family.year_of_publication = 1940
      expect(@family.save).to be_true
      c.soft_validate(:source_older_then_description)
      expect(c.soft_validations.messages_on(:year_of_publication).count).to eq(1)
      c.year_of_publication = 1940
      expect(c.valid?).to be_true
      c.soft_validate(:source_older_then_description)
      expect(c.soft_validations.messages_on(:year_of_publication).empty?).to be_true
    end

  end
end
