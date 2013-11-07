require 'spec_helper'

describe Protonym do
  let(:protonym) { Protonym.new }

  context 'associations' do
    before(:all) do
      @protonym = FactoryGirl.create(:protonym, rank_class: Ranks.lookup(:iczn, 'species'), name: 'aus' )
      @genus = FactoryGirl.create(:protonym, rank_class: Ranks.lookup(:iczn, 'genus'), name: 'Aus' )
      @family = FactoryGirl.create(:protonym, rank_class: Ranks.lookup(:iczn, 'family'), name: 'Aidae') 
      @species_type_of_genus = FactoryGirl.create(:taxon_name_relationship,
                                                  subject: @protonym,
                                                  object: @genus, 
                                                  type: 'TaxonNameRelationship::Typification::Genus::Monotypy::Original')

      @genus_type_of_family = FactoryGirl.create(:taxon_name_relationship,
                                                 subject: @genus,
                                                 object: @family, 
                                                 type: 'TaxonNameRelationship::Typification::Family')
    end

    context 'has_many' do
      specify 'original_combination_relationships' do 
        expect(protonym).to respond_to(:original_combination_relationships)
      end

      specify 'type_of_relationships' do
        expect(@protonym.type_of_relationships.collect{|i| i.id}).to eq([@species_type_of_genus.id])
      end

      specify 'type_of_taxon_names' do
        expect(@protonym.type_of_taxon_names).to eq([@genus])
      end
    end

    context 'has_one' do
      TaxonNameRelationship.descendants.each do |d|
        if d.respond_to?(:assignment_method) 
          relationship = "#{d.assignment_method}_relationship".to_sym
          specify relationship do
            expect(protonym).to respond_to(relationship)
          end 

          specify d.assignment_method.to_s do
            expect(protonym).to respond_to(d.assignment_method.to_sym)
          end
        end
      end

      context 'typification' do
        specify 'type_taxon_name' do
          expect(@genus).to respond_to(:type_taxon_name)
          expect(@genus.type_taxon_name).to eq(@protonym)
          expect(@family.type_taxon_name).to eq(@genus)
        end 

        specify 'type_taxon_name_relationship' do
          expect(protonym).to respond_to(:type_taxon_name_relationship)
          expect(@genus.type_taxon_name_relationship.id).to eq(@species_type_of_genus.id)
          expect(@family.type_taxon_name_relationship.id).to eq(@genus_type_of_family.id)
        end 

        specify 'has at most one has_type relationship' do
          extra_type_relation = FactoryGirl.build(:taxon_name_relationship,
                                                  subject: @genus,
                                                  object: @family, 
                                                  type: TaxonNameRelationship::Typification::Family)
          # Handled by TaxonNameRelationship validates_uniqueness_of :subject_taxon_name_id,  scope: [:type, :object_taxon_name_id]
          expect(extra_type_relation.valid?).to be_false
        end
      end

      context 'original description' do
        specify 'original_combination_source' do
          expect(protonym).to respond_to(:original_combination_source)
        end

        %w{genus subgenus species}.each do |rank|
          method = "original_combination_#{rank}_relationship" 
          specify method do
            expect(protonym).to respond_to(method)
          end 
        end

        %w{genus subgenus species}.each do |rank|
          method = "original_combination_#{rank}" 
          specify method do
            expect(protonym).to respond_to(method)
          end 
        end
      end
    end
  end

  context 'validation' do
    before do
      protonym.valid?
    end

    specify 'name' do
      expect(protonym.errors.include?(:name)).to be_true
    end
  end

  context 'usage' do
    before do
      @g = Protonym.new(name: 'Aus', rank_class: Ranks.lookup(:iczn, 'genus'))
      @s = Protonym.new(name: 'aus', rank_class: Ranks.lookup(:iczn, 'species'))
      @o = Protonym.new(name: 'Bus', rank_class: Ranks.lookup(:iczn, 'genus'))
      @f = Protonym.new(name: 'Aidae', rank_class: Ranks.lookup(:iczn, 'family'))
      @g.save
      @s.save
      @o.save
    end

    specify 'assign an original description genus' do
      expect(@s.original_combination_genus = @o).to be_true
      expect(@s.save).to be_true 
      expect(@s.original_combination_genus_relationship.class).to eq(TaxonNameRelationship::OriginalCombination::OriginalGenus)
      expect(@s.original_combination_genus_relationship.subject).to eq(@o)
      expect(@s.original_combination_genus_relationship.object).to eq(@s)
    end

    specify 'assign a type species to a genus' do
      expect(@g.type_species = @s).to be_true
      expect(@g.save).to be_true

      expect(@g.type_species_relationship.class).to eq(TaxonNameRelationship::Typification::Genus)
      expect(@g.type_species_relationship.subject).to eq(@s)
      expect(@g.type_species_relationship.object).to eq(@g)
      expect(@g.type_taxon_name_relationship.class).to eq(TaxonNameRelationship::Typification::Genus)
      expect(@g.type_taxon_name.name).to eq('aus')
      expect(@s.type_of_relationships.to_a).to eq(@s.taxon_name_relationships.to_a)
      expect(@s.type_of_relationships.first.class).to eq(TaxonNameRelationship::Typification::Genus)
      expect(@s.type_of_relationships.first.object).to eq(@g)
    end
  end

end
