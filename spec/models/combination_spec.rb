require 'rails_helper'
describe Combination, :type => :model do

  let(:combination) { Combination.new }
  let(:source) { FactoryGirl.build(:valid_source_bibtex, year: 1940, author: 'Dmitriev') }
  let(:root) { FactoryGirl.create(:root_taxon_name) }
  let(:family) { FactoryGirl.create(:relationship_family, name: 'Aidae', year_of_publication: 2000) }
  
  let(:genus ) {FactoryGirl.create(:relationship_genus, parent: family)}
  let(:species) { FactoryGirl.create(:relationship_species, parent: genus)  }
  let(:species2) { FactoryGirl.create(:relationship_species, name: 'comes', parent: genus) }

  context 'associations' do
    context 'has_one' do
      context 'taxon_name_relationship' do
        Combination::APPLICABLE_RANKS.each do |rank|
          method = "#{rank}_taxon_name_relationship" 
          specify method do
            expect(combination.send("#{method}=", TaxonNameRelationship.new)).to be_truthy
          end 
        end
      end

      context 'taxon_name' do
        Combination::APPLICABLE_RANKS.each do |rank|
          specify rank do
            expect(combination.send("#{rank}=", Protonym.new)).to be_truthy
          end
        end
      end
    end
  end

  context 'validation' do
    before{combination.valid?}

    specify 'is invalid without at least one protonym' do
      expect(combination.errors.include?(:base)).to be_truthy
    end

    specify 'is valid with at least one protonym' do
      c = Combination.new(genus: genus) 
      expect(c.errors.include?(:base)).to be_falsey
    end

    specify 'name must be nil' do
      expect(combination.errors.include?(:name)).to be_falsey
    end

    # Double check?!
    specify 'rank_class is optional' do
      expect(combination.errors.include?(:rank_class)).to be_falsey
    end
  end

  specify 'type is Combination' do
    expect(combination.type).to eq('Combination')
  end

  context '#protonyms_by_rank' do
    specify 'for a quadrinomial' do
      combination.genus = genus
      combination.subgenus = genus
      combination.species = species
      combination.subspecies = species2 
      expect(combination.protonyms_by_rank).to eq(
        'genus' => genus,
        'subgenus' => genus,
        'species' => species,
        'subspecies' => species2
      )
    end
  end

  context '#full_name_hash (overrides @taxon_name.full_name_hash)' do
    specify 'with genus' do
      combination.genus = genus
      expect(combination.full_name_hash).to eq({"genus"=>[nil, "Erythroneura"]})
    end

    specify 'with genus and species' do
      combination.genus = genus
      combination.species = species
      expect(combination.full_name_hash).to eq({"genus"=>[nil, "Erythroneura"], "species"=>[nil, "vitis"]})
    end

    specify 'with quadrinomial' do
      combination.genus = genus
      combination.subgenus = genus
      combination.species = species
      combination.subspecies = species2 
      expect(combination.full_name_hash).to eq({"genus"=>[nil, "Erythroneura"], "subgenus"=>[nil, "Erythroneura"],  "species"=>[nil, "vitis"], "subspecies"=>[nil, "comes"]})
    end
  end

  context 'cached values' do
    specify 'cached' do
      combination.genus = genus
      combination.species = species
      combination.save
      expect(combination.cached).to eq('Erythroneura vitis')
    end

    context 'cached_html' do
      specify 'with genus and species' do
        combination.genus = genus
        combination.species = species
        combination.save
        expect(combination.cached_html).to eq('<em>Erythroneura vitis</em>')
      end

      specify 'with a quadrinomial' do
        combination.genus = genus
        combination.subgenus = genus 
        combination.species = species
        combination.subspecies = species2 
        combination.save
        expect(combination.cached_html).to eq('<em>Erythroneura</em> (<em>Erythroneura</em>) <em>vitis comes</em>')
      end
    end
  end

  context 'soft validation' do
    specify 'missing source and year' do
      combination.soft_validate(:missing_fields)
      expect(combination.soft_validations.messages_on(:source_id).empty?).to be_falsey
      expect(combination.soft_validations.messages_on(:year_of_publication).empty?).to be_falsey
    end

    specify 'year of combination and year of source does not match' do
      c = Combination.new(year_of_publication: 1950, genus: genus, source: source)
      c.soft_validate(:source_older_then_description)
      expect(c.soft_validations.messages_on(:source_id).count).to eq(1)
      c.year_of_publication = 1940
      expect(c.valid?).to be_truthy
      c.soft_validate(:source_older_then_description)
      expect(c.soft_validations.messages_on(:source_id).empty?).to be_truthy
    end

    specify 'combination is older than taxon' do
      c = FactoryGirl.create(:combination, year_of_publication: 1900, parent: family)
      family.year_of_publication = 1940
      expect(family.save).to be_truthy
      c.soft_validate(:source_older_then_description)
      expect(c.soft_validations.messages_on(:year_of_publication).count).to eq(1)
      c.year_of_publication = 1940
      expect(c.valid?).to be_truthy
      c.soft_validate(:source_older_then_description)
      expect(c.soft_validations.messages_on(:year_of_publication).empty?).to be_truthy
    end

    specify 'duplicate combination' do
      genus = FactoryGirl.create(:iczn_genus, name: 'Aus', parent: family)
      species = FactoryGirl.create(:iczn_species, name: 'bus', parent: genus)
      c1 = FactoryGirl.create(:combination, parent: species)
      c2 = FactoryGirl.create(:combination, parent: species)
      #c1.combination_genus = genus
      #c1.combination_species = species
      FactoryGirl.create(:taxon_name_relationship, subject_taxon_name: genus, object_taxon_name: c1, type: 'TaxonNameRelationship::Combination::Genus')
      FactoryGirl.create(:taxon_name_relationship, subject_taxon_name: species, object_taxon_name: c1, type: 'TaxonNameRelationship::Combination::Species')
      expect(c1.save).to be_truthy
      c1.reload
      #c2.combination_genus = genus
      #c2.combination_species = species
      FactoryGirl.create(:taxon_name_relationship, subject_taxon_name: genus, object_taxon_name: c2, type: 'TaxonNameRelationship::Combination::Genus')
      FactoryGirl.create(:taxon_name_relationship, subject_taxon_name: species, object_taxon_name: c2, type: 'TaxonNameRelationship::Combination::Species')
      expect(c2.save).to be_truthy
      c2.reload
      expect(c1.cached_original_combination).to eq('<em>Aus bus</em>')
      expect(c2.cached_original_combination).to eq('<em>Aus bus</em>')
      c1.soft_validate(:combination_duplicates)
      # duplicate combination
      expect(c1.soft_validations.messages_on(:base).count).to eq(1)
    end
  end

  specify '#source_classified_as' do
    combination.genus = genus
    combination.source_classified_as = family
    expect(combination.save).to be_truthy
    expect(combination.all_taxon_name_relationships.count).to be > 0
    expect(combination.cached_classified_as).to eq(' (as Aidae)')
  end

  context 'usage' do
    let(:genus) { FactoryGirl.create(:iczn_genus, name: 'Aus', parent: family)}
    let(:subgenus) {FactoryGirl.create(:iczn_subgenus, name: 'Bus', parent: genus) }
    let(:species) {FactoryGirl.create(:iczn_species, name: 'bus', parent: subgenus) }

    specify 'parent is assigned as parent of highest ranking taxon' do
      combination.genus = genus
      combination.species = species
      expect(combination.save).to be_truthy
      expect(combination.parent).to eq(family)
    end

    context 'with .new() relationships are created' do
      specify '#related_taxon_name_relationships are created by assignment to taxon name' do
        combination.genus = genus
        combination.species = species
        expect(combination.save).to be_truthy
        combination.reload
        expect(combination.related_taxon_name_relationships.size).to eq(2)
        expect(combination.taxon_name_relationships.size).to eq(0) # Combination is on the right side, not left
      end

      specify '#combination_taxon_names' do
        combination.genus = genus
        expect(combination.save).to be_truthy
        expect(combination.combination_taxon_names.to_a).to eq([genus]) 
      end

      specify '#combination_relationships' do
        combination.genus = genus
        expect(combination.save).to be_truthy
        expect(combination.combination_relationships.count).to eq(1) 
      end
 

    end

 #  specify 'a genus group name used as a subgenus' do
 #    c = FactoryGirl.create(:combination, parent: subgenus)
 #    c.genus = genus
 #    c.subgenus = subgenus
 #    expect(c.valid?).to be_truthy
 #    expect(c.genus.name).to eq('Aus')
 #    expect(c.subgenus.name).to eq('Bus')
 #  end

 #  specify 'species group names used under a different genus' do
 #    c = FactoryGirl.create(:combination, parent: species)
 #    c.genus = genus
 #    c.species = species
 #    expect(c.valid?).to be_truthy
 #    expect(c.genus.name).to eq('Aus')
 #    expect(c.species.name).to eq('bus')
 #  end
  end
end
