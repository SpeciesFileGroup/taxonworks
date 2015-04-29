require 'rails_helper'

describe Protonym, type: :model, group: [:nomenclature, :protonym] do

  before(:all) do
    TaxonNameRelationship.delete_all
    TaxonNameClassification.delete_all
    TaxonName.delete_all
    @order = FactoryGirl.create(:iczn_order)
  end

  after(:all) do
    TaxonNameRelationship.delete_all
    TaxonNameClassification.delete_all
    TaxonName.delete_all
    Source.delete_all
  end

  let(:protonym) { Protonym.new }
  let(:root) { Protonym.where(name: 'Root').first  }

  context 'validation' do
    before { protonym.valid? }

    specify 'name' do
      expect(protonym.errors.include?(:name)).to be_truthy
    end

    context 'latinization requires' do 
      let(:error_message) {  'must be latinized, no digits or spaces allowed' } 
      specify 'no digits are present at end' do
        protonym.name = 'aus1'
        protonym.valid?
        expect(protonym.errors.messages[:name]).to include(error_message)
      end

      specify 'no digits are present at start' do
        protonym.name = '1bus'
        protonym.valid?
        expect(protonym.errors.messages[:name]).to include(error_message)
      end

      specify 'no digits are present in middle' do
        protonym.name = 'au1s'
        protonym.valid?
        expect(protonym.errors.messages[:name]).to include(error_message)
      end
        
      specify 'no spaces are present' do
        protonym.name = 'ab us'
        protonym.valid?
        expect(protonym.errors.messages[:name]).to include(error_message)
      end
    end
  end
  
  context 'usage' do
    before(:each) do
      @f = FactoryGirl.create(:relationship_family, name: 'Aidae', parent: @order)
      @g = FactoryGirl.create(:relationship_genus, name: 'Aus', parent: @f)
      @o = FactoryGirl.create(:relationship_genus, name: 'Bus', parent: @f)
      @s = FactoryGirl.create(:relationship_species, name: 'aus', parent: @g)
    end

    specify 'assign an original description genus' do
      expect(@s.original_genus = @o).to be_truthy
      expect(@s.save).to be_truthy
      expect(@s.original_genus_relationship.class).to eq(TaxonNameRelationship::OriginalCombination::OriginalGenus)
      expect(@s.original_genus_relationship.subject_taxon_name).to eq(@o)
      expect(@s.original_genus_relationship.object_taxon_name).to eq(@s)
    end

    specify 'has at most one original description genus' do
      expect(@s.original_combination_relationships.count).to eq(0)
      # Example 1) recasting
      temp_relation = FactoryGirl.build(:taxon_name_relationship,
                                                        subject_taxon_name: @o,
                                                        object_taxon_name: @s,
                                                        type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus')
      temp_relation.save
      # Recast as the subclass
      first_original_genus_relation = temp_relation.becomes(temp_relation.type_class)
      expect(@s.original_combination_relationships.count).to eq(1)

      # Example 2) just use the right subclass to start
      first_original_subgenus_relation = FactoryGirl.build(:taxon_name_relationship_original_combination,
                                                           subject_taxon_name: @g,
                                                           object_taxon_name: @s,
                                                           type: 'TaxonNameRelationship::OriginalCombination::OriginalSubgenus')
      first_original_subgenus_relation.save
      expect(@s.original_combination_relationships.count).to eq(2)
      extra_original_genus_relation = FactoryGirl.build(:taxon_name_relationship,
                                              subject_taxon_name: @g,
                                              object_taxon_name: @s,
                                              type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus')
      expect(extra_original_genus_relation.valid?).to be_falsey
      extra_original_genus_relation.save
      expect(@s.original_combination_relationships.count).to eq(2)
    end

    specify 'assign a type species to a genus' do
      expect(@g.type_species = @s).to be_truthy
      expect(@g.save).to be_truthy

      expect(@g.type_species_relationship.class).to eq(TaxonNameRelationship::Typification::Genus)
      expect(@g.type_species_relationship.subject_taxon_name).to eq(@s)
      expect(@g.type_species_relationship.object_taxon_name).to eq(@g)
      expect(@g.type_taxon_name_relationship.class).to eq(TaxonNameRelationship::Typification::Genus)
      expect(@g.type_taxon_name.name).to eq('aus')
      expect(@s.type_of_relationships.first.class).to eq(TaxonNameRelationship::Typification::Genus)
      expect(@s.type_of_relationships.first.object_taxon_name).to eq(@g)
    end

    specify 'synonym has at most one valid name' do
      genus = FactoryGirl.create(:relationship_genus, name: 'Cus', parent: @f)
      genus.iczn_set_as_subjective_synonym_of = @g
      expect(genus.save).to be_truthy
      genus.iczn_set_as_synonym_of = @o
      expect(genus.save).to be_truthy
      expect(genus.taxon_name_relationships.size).to be(1)
    end
  end
  
  context 'parallel creation of OTUs' do
    let(:p) {Protonym.new(parent: @order , name: 'Aus', rank_class: Ranks.lookup(:iczn, 'genus')) }

    specify '#also_create_otu with new creates an otu after_create' do
      expect(Otu.count).to eq(0) 
      p.also_create_otu = true
      p.save!
      expect(Otu.first.taxon_name_id).to eq(p.id)
    end

    specify '#also_create_otu does not create on save' do
      p.save!
      p.also_create_otu = true
      p.save!
      expect(Otu.count).to eq(0)
    end
  end

end
