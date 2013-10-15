require 'spec_helper'

describe Protonym do

  let(:protonym) { Protonym.new }

  context 'associations' do
    before do
      # make the protonym a type of a genus
      protonym.name = 'aus'
      protonym.rank_class = Ranks.lookup(:iczn, 'species')
      protonym.save
      @genus = FactoryGirl.create(:iczn_genus)
      @family = @genus.ancestor_at_rank('family')
      @species_type_of_genus = FactoryGirl.create(:taxon_name_relationship,
                                                  subject: protonym,
                                                  object: @genus, 
                                                  type: TaxonNameRelationship::Typification::Genus::Monotypy::Original)

      @genus_type_of_family = FactoryGirl.create(:taxon_name_relationship,
                                                 subject: @genus,
                                                 object: @family, 
                                                 type: TaxonNameRelationship::Typification::Family)
    end

    context 'has_many' do
      specify 'original_description_relationships' do 
        expect(protonym).to respond_to(:original_description_relationships)
      end

      specify 'type_of_relationships' do
        expect(protonym.type_of_relationships.collect{|i| i.id}).to eq([@species_type_of_genus.id])
      end

      specify 'type_of_taxon_names' do
        expect(protonym.type_of_taxon_names).to eq([@genus])
      end
    end

    context 'has_one' do
      context 'typification' do
        specify 'type_taxon_name' do
          expect(@genus).to respond_to(:type_taxon_name)
          expect(@genus.type_taxon_name).to eq(protonym)
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
        specify 'original_description_source' do
          expect(protonym).to respond_to(:original_description_source)
        end

        %w{genus subgenus species}.each do |rank|
          method = "original_description_#{rank}_relationship" 
          specify method do
            expect(protonym).to respond_to(method)
          end 
        end

        %w{genus subgenus species}.each do |rank|
          method = "original_#{rank}" 
          specify method do
            expect(protonym).to respond_to(method)
          end 
        end
      end
    end
  end

  context 'usage' do
    before do
      @g = Protonym.new(name: 'Aus', rank_class: Ranks.lookup(:iczn, 'genus'))
      @s = Protonym.new(name: 'aus', rank_class: Ranks.lookup(:iczn, 'species'))
      @g.save
      @s.save
    end

    specify 'assign a type species to a genus' do
      expect(@g.type_taxon_name = @s).to be_true
      expect(@g.type_taxon_name.name).to eq('aus')
    end
  end

end
