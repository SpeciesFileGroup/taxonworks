require 'rails_helper'

describe Combination, :type => :model do

  before(:all) do
    TaxonName.delete_all
    @family = FactoryGirl.create(:relationship_family, name: 'Aidae', year_of_publication: 2000)
    @combination = FactoryGirl.create(:combination, parent: @family)
    @source = FactoryGirl.build(:valid_source_bibtex, year: 1940, author: 'Dmitriev')
  end
  
  after(:all) do
    TaxonName.delete_all
    Source.delete_all 
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

      context 'has_one' do
        TaxonNameRelationship.descendants.each do |d|
          if d.respond_to?(:assignment_method) and d.name.to_s =~ /TaxonNameRelationship::(Combination|SourceClassifiedAs)/
            relationship = "#{d.inverse_assignment_method}_relationship".to_sym
            relationships = "#{d.assignment_method}_relationships".to_sym
            method = d.inverse_assignment_method.to_sym
            methods = d.assignment_method.to_s.pluralize.to_sym

            specify relationship do
              expect(@combination).to respond_to(relationship)
            end
            specify relationships do
              expect(@combination).to respond_to(relationships)
            end
            specify method do
              expect(@combination).to respond_to(method)
            end
            specify methods do
              expect(@combination).to respond_to(methods)
            end
          end
        end
      end

        context 'cached name' do
        before(:all) do
          @genus = FactoryGirl.create(:relationship_genus, parent: @family)
          @species = FactoryGirl.create(:relationship_species, parent: @genus)
          @species2 = FactoryGirl.create(:relationship_species, name: 'comes', parent: @genus)
          @combination1 = FactoryGirl.create(:combination, parent: @species)
          @combination1.combination_species = @species
          expect(@combination1.save).to be_truthy
        end
        specify 'empty' do
          expect(@combination1.get_combination).to eq('<em>vitis</em>')
        end
        specify 'genus' do
          @combination1.combination_genus = @genus
          @combination1.reload
          expect(@combination1.get_combination).to eq('<em>Erythroneura vitis</em>')
          @combination1.combination_subgenus = @genus
          @combination1.reload
          expect(@combination1.get_combination).to eq('<em>Erythroneura</em> (<em>Erythroneura</em>) <em>vitis</em>')
          @combination1.combination_subspecies = @species2
          @combination1.reload
          expect(@combination1.get_combination).to eq('<em>Erythroneura</em> (<em>Erythroneura</em>) <em>vitis comes</em>')
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
        expect(@combination.errors.include?(:name)).to be_falsey
      end

      specify 'type is Combination' do
        expect(@combination.type).to eq('Combination')
      end

      specify 'rank_class is optional' do
        expect(@combination.errors.include?(:rank_class)).to be_falsey
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
        expect(c.valid?).to be_truthy
        expect(c.genus.name).to eq('Aus')
        expect(c.subgenus.name).to eq('Bus')
      end
      specify 'species group names used under a different genus' do
        c = FactoryGirl.create(:combination, parent: @species)
        c.genus = @genus
        c.species = @species
        expect(c.valid?).to be_truthy
        expect(c.genus.name).to eq('Aus')
        expect(c.species.name).to eq('bus')
      end
    end
  end

  context 'soft validation' do

    specify 'missing source and year' do
      @combination.soft_validate(:missing_fields)
      expect(@combination.soft_validations.messages_on(:source_id).empty?).to be_falsey
      expect(@combination.soft_validations.messages_on(:year_of_publication).empty?).to be_falsey
    end

    specify 'year of combination and year of source does not match' do
      c = FactoryGirl.build(:combination, year_of_publication: 1950, parent: @family, source: @source)
      c.soft_validate(:source_older_then_description)
      expect(c.soft_validations.messages_on(:source_id).count).to eq(1)
      c.year_of_publication = 1940
      expect(c.valid?).to be_truthy
      c.soft_validate(:source_older_then_description)
      expect(c.soft_validations.messages_on(:source_id).empty?).to be_truthy
    end

    specify 'combination is older than taxon' do
      c = FactoryGirl.create(:combination, year_of_publication: 1900, parent: @family)
      @family.year_of_publication = 1940
      expect(@family.save).to be_truthy
      c.soft_validate(:source_older_then_description)
      expect(c.soft_validations.messages_on(:year_of_publication).count).to eq(1)
      c.year_of_publication = 1940
      expect(c.valid?).to be_truthy
      c.soft_validate(:source_older_then_description)
      expect(c.soft_validations.messages_on(:year_of_publication).empty?).to be_truthy
    end

    specify 'duplicate combination' do
      genus = FactoryGirl.create(:iczn_genus, name: 'Aus', parent: @family)
      species = FactoryGirl.create(:iczn_species, name: 'bus', parent: genus)
      c1 = FactoryGirl.create(:combination, parent: species)
      c2 = FactoryGirl.create(:combination, parent: species)
      c1.combination_genus = genus
      c1.combination_species = species
      expect(c1.save).to be_truthy
      c1.reload
      c2.combination_genus = genus
      c2.combination_species = species
      expect(c2.save).to be_truthy
      c2.reload
      expect(c1.cached_original_combination).to eq('<em>Aus bus</em>')
      expect(c2.cached_original_combination).to eq('<em>Aus bus</em>')
      c1.soft_validate(:combination_duplicates)
      # duplicate combination
      expect(c1.soft_validations.messages_on(:base).count).to eq(1)
    end

  end
end
