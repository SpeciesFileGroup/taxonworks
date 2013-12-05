require 'spec_helper'

describe Protonym do
  let(:protonym) { Protonym.new }

  context 'associations' do
    before(:all) do
      @order = FactoryGirl.create(:iczn_order)
      @family = FactoryGirl.create(:protonym, rank_class: Ranks.lookup(:iczn, 'family'), name: 'Aidae', parent: @order)
      @genus = FactoryGirl.create(:protonym, rank_class: Ranks.lookup(:iczn, 'genus'), name: 'Aus', parent: @family)
      @protonym = FactoryGirl.create(:protonym, rank_class: Ranks.lookup(:iczn, 'species'), name: 'aus', parent: @genus)
      @species_type_of_genus = FactoryGirl.create(:taxon_name_relationship,
                                                  subject_taxon_name: @protonym,
                                                  object_taxon_name: @genus,
                                                  type: 'TaxonNameRelationship::Typification::Genus::Monotypy::Original')

      @genus_type_of_family = FactoryGirl.create(:taxon_name_relationship,
                                                 subject_taxon_name: @genus,
                                                 object_taxon_name: @family,
                                                 type: 'TaxonNameRelationship::Typification::Family')
    end

    context 'has_many' do
      specify 'original_combination_relationships' do 
        expect(@protonym).to respond_to(:original_combination_relationships)
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
            expect(@protonym).to respond_to(relationship)
          end 

          specify d.assignment_method.to_s do
            expect(@protonym).to respond_to(d.assignment_method.to_sym)
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
          expect(@protonym).to respond_to(:type_taxon_name_relationship)
          expect(@genus.type_taxon_name_relationship.id).to eq(@species_type_of_genus.id)
          expect(@family.type_taxon_name_relationship.id).to eq(@genus_type_of_family.id)
        end 

        specify 'has at most one has_type relationship' do
          extra_type_relation = FactoryGirl.build(:taxon_name_relationship,
                                                  subject_taxon_name: @genus,
                                                  object_taxon_name: @family,
                                                  type: TaxonNameRelationship::Typification::Family)
          # Handled by TaxonNameRelationship validates_uniqueness_of :subject_taxon_name_id,  scope: [:type, :object_taxon_name_id]
          expect(extra_type_relation.valid?).to be_false
        end
      end

      context 'original description' do
        specify 'original_combination_source' do
          expect(@protonym).to respond_to(:original_combination_source)
        end

        %w{genus subgenus species}.each do |rank|
          method = "original_combination_#{rank}_relationship" 
          specify method do
            expect(@protonym).to respond_to(method)
          end 
        end

        %w{genus subgenus species}.each do |rank|
          method = "original_combination_#{rank}" 
          specify method do
            expect(@protonym).to respond_to(method)
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
    before(:all) do
      @order = FactoryGirl.create(:iczn_order)
      @f = Protonym.new(name: 'Aidae', rank_class: Ranks.lookup(:iczn, 'family'), parent: @order)
      @g = Protonym.new(name: 'Aus', rank_class: Ranks.lookup(:iczn, 'genus'), parent: @f)
      @o = Protonym.new(name: 'Bus', rank_class: Ranks.lookup(:iczn, 'genus'), parent: @f)
      @s = Protonym.new(name: 'aus', rank_class: Ranks.lookup(:iczn, 'species'), parent: @g)
      @g.save
      @s.save
      @o.save
    end

    specify 'assign an original description genus' do
      expect(@s.original_combination_genus = @o).to be_true
      expect(@s.save).to be_true
      expect(@s.original_combination_genus_relationship.class).to eq(TaxonNameRelationship::OriginalCombination::OriginalGenus)
      expect(@s.original_combination_genus_relationship.subject_taxon_name).to eq(@o)
      expect(@s.original_combination_genus_relationship.object_taxon_name).to eq(@s)
    end

    specify 'has at most one original description genus' do
      # The problem is that your variables were instances of TaxonNameRelationship, this class doesn't have the pertinent validation.
      # When you return them in the future they will be cast as the subclass, and they will have the validations. To solve, use 
      # 1) or 2) examples below (2 is preferred)
      
      expect(@s.original_combination_relationships.count).to eq(0)

      # Example 1) recasting
      temp_relation = FactoryGirl.build(:taxon_name_relationship,
                                                        subject_taxon_name: @o,
                                                        object_taxon_name: @s,
                                                        type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus')
      temp_relation.save
      # recast as the subclass
      first_original_genus_relation = temp_relation.becomes(temp_relation.type_class)
      expect(@s.original_combination_relationships.count).to eq(1)

      # Example 2) just use the right subclass to start
      first_original_subgenus_relation = FactoryGirl.build(:original_combination_relationship,
                                                           subject_taxon_name: @g,
                                                           object_taxon_name: @s,
                                                           type: 'TaxonNameRelationship::OriginalCombination::OriginalSubgenus')
      first_original_subgenus_relation.save
      expect(@s.original_combination_relationships.count).to eq(2)
      extra_original_genus_relation = FactoryGirl.build(:taxon_name_relationship,
                                              subject_taxon_name: @g,
                                              object_taxon_name: @s,
                                              type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus')
      expect(extra_original_genus_relation.valid?).to be_false
      extra_original_genus_relation.save
      expect(@s.original_combination_relationships.count).to eq(2)
    end


    specify 'assign a type species to a genus' do
      expect(@g.type_species = @s).to be_true
      expect(@g.save).to be_true

      expect(@g.type_species_relationship.class).to eq(TaxonNameRelationship::Typification::Genus)
      expect(@g.type_species_relationship.subject_taxon_name).to eq(@s)
      expect(@g.type_species_relationship.object_taxon_name).to eq(@g)
      expect(@g.type_taxon_name_relationship.class).to eq(TaxonNameRelationship::Typification::Genus)
      expect(@g.type_taxon_name.name).to eq('aus')
      expect(@s.type_of_relationships.to_a).to eq(@s.taxon_name_relationships.to_a)
      expect(@s.type_of_relationships.first.class).to eq(TaxonNameRelationship::Typification::Genus)
      expect(@s.type_of_relationships.first.object_taxon_name).to eq(@g)
    end
  end

  context 'soft_validation' do
    before(:all) do
      @s = Source.new(year: 1940, author: 'aaa')
      genus = FactoryGirl.build(:iczn_genus)
      @p = Protonym.new(name: 'aus', rank_class: Ranks.lookup(:iczn, 'species'), year_of_publication: 2000, source: @s, parent: genus)
      @s.save
    end
    specify 'A taxon had not been described at the date of the reference' do
      @p.soft_validate
      expect(@p.soft_validations.messages_on(:source_id).include?('The year of publication and the year of reference do not match')).to be_true
      @p.year_of_publication = 1940
      @p.soft_validate
      expect(@p.soft_validations.messages_on(:source_id).include?('The year of publication and the year of reference do not match')).to be_false
    end
    specify 'A combination is older than the taxon' do
      c = Combination.new(year_of_publication: 1930, parent: @p, source: @s)
      c.save
      c.soft_validate
      expect(c.soft_validations.messages_on(:source_id).include?('The year of publication and the year of reference do not match')).to be_true
      expect(c.soft_validations.messages_on(:year_of_publication).include?('The combination is older than the taxon')).to be_true
      expect(c.soft_validations.messages_on(:source_id).include?('The citation is older than the taxon')).to be_false
    end

  end

end
