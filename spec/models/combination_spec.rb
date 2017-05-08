require 'rails_helper'
describe Combination, type: :model, group: :nomenclature do

  let(:combination) { Combination.new }
  let(:source_older_than_combination) { FactoryGirl.build(:valid_source_bibtex, year: 1940, author: 'Dmitriev') }
  let(:family) { FactoryGirl.create(:relationship_family, name: 'Aidae', year_of_publication: 2000) }
  let(:genus ) {FactoryGirl.create(:relationship_genus, parent: family, year_of_publication: 1950)}
  let(:subgenus ) {FactoryGirl.create(:iczn_subgenus, parent: genus, year_of_publication: 1950)}
  let(:species) { FactoryGirl.create(:relationship_species, parent: genus, year_of_publication: 1951)  }
  let(:species2) { FactoryGirl.create(:relationship_species, name: 'comes', parent: genus, year_of_publication: 1952) }

  let(:basic_combination) {Combination.new(genus: genus, species: species) }

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
    specify 'is invalid without at least two protonyms' do
      expect(combination.errors.include?(:base)).to be_truthy
    end

    specify 'species combination is valid with two protonyms' do
      c = Combination.new(genus: genus, species: species)
      c.valid?
      expect(c.protonyms.last.rank_string).to eq('NomenclaturalRank::Iczn::SpeciesGroup::Species')
      expect(c.errors.include?(:base)).to be_falsey
    end

    specify 'species combination is invalid with one protonym' do
      c = Combination.new(species: species)
      c.valid?
      expect(c.errors.include?(:base)).to be_truthy
    end

    specify 'genus combination is valid with two protonyms' do
      c = Combination.new(genus: genus, subgenus: subgenus)
      c.valid?
      expect(c.protonyms.last).to eq(subgenus)
      expect(c.errors.include?(:base)).to be_falsey
    end

    specify 'genus combination is valid with one protonym' do
      c = Combination.new(genus: genus)
      c.valid?
      expect(c.protonyms.last.rank_string).to eq('NomenclaturalRank::Iczn::GenusGroup::Genus')
      expect(c.errors.include?(:base)).to be_falsey
    end


    specify 'name must be nil' do
      expect(combination.errors.include?(:name)).to be_falsey
    end

    #TODO: Double check?!
    specify 'rank_class is optional' do
      expect(combination.errors.include?(:rank_class)).to be_falsey
    end

    specify 'scope with_cached_original_combination' do
      c = Combination.new(genus: genus, species: species)
      c.save
      expect(Combination.with_cached_html('<i>' + genus.name + ' ' + species.name + '</i>').first).to eq(c)
    end

    specify 'scope with_protonym_at_rank' do
      c = Combination.new(genus: genus, species: species)
      c.save
      expect(Combination.with_protonym_at_rank('TaxonNameRelationship::Combination::Genus', genus).first).to eq(c)
      expect(Combination.with_protonym_at_rank('TaxonNameRelationship::Combination::Species', species).first).to eq(c)
    end
  end

  specify 'type is Combination' do
    expect(combination.type).to eq('Combination')
  end

  context 'instance methods' do
    context '#protonyms' do
      specify 'are returned for unsaved Combinations' do
        expect(basic_combination.protonyms).to eq([genus, species])
      end

      specify 'are returned for saved Combinations' do
        expect(basic_combination.save).to be_truthy
        expect(basic_combination.protonyms).to eq([genus, species])
      end
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
        expect(basic_combination.full_name_hash).to eq({"genus"=>[nil, "Erythroneura"], "species"=>[nil, "vitis"]})
      end

      specify 'with quadrinomial' do
        combination.genus = genus
        combination.subgenus = genus
        combination.species = species
        combination.subspecies = species2 
        expect(combination.full_name_hash).to eq({"genus"=>[nil, "Erythroneura"], "subgenus"=>[nil, "Erythroneura"],  "species"=>[nil, "vitis"], "subspecies"=>[nil, "comes"]})
      end
    end

#    specify '#source_classified_as' do
#      basic_combination.source_classified_as = family
#      expect(basic_combination.save).to be_truthy
#      expect(basic_combination.all_taxon_name_relationships.count).to be > 0
#      expect(basic_combination.reload.cached_classified_as).to eq(' (as Aidae)')
#    end

    specify '#earliest_protonym_year' do
      basic_combination.subspecies = species2 # 1952 ( with genus 1950, species 1951)
      expect(basic_combination.earliest_protonym_year).to eq(1950)
    end

    specify '#publication_years' do
      basic_combination.subspecies = species2 # 1952 ( with genus 1950, species 1951)
      expect(basic_combination.publication_years).to eq([1950, 1951, 1952])
    end
  end

  context 'cached values' do
    specify 'cached' do
      basic_combination.save
      expect(basic_combination.cached).to eq('Erythroneura vitis')
    end

    context 'cached_html' do
      specify 'with genus and species' do
        basic_combination.save
        expect(basic_combination.cached_html).to eq('<i>Erythroneura vitis</i>')
      end

      specify 'with a quadrinomial' do
        combination.genus = genus
        combination.subgenus = genus 
        combination.species = species
        combination.subspecies = species2 
        combination.save
        expect(combination.cached_html).to eq('<i>Erythroneura</i> (<i>Erythroneura</i>) <i>vitis comes</i>')
      end
    end

    specify 'cached values update on changed relationship' do
      basic_combination.save
      expect(basic_combination.cached).to eq('Erythroneura vitis')
      basic_combination.species = species2
      expect(basic_combination.save).to be_truthy
      expect(basic_combination.cached).to eq('Erythroneura comes')
    end

    specify 'with verbatim_name' do
      combination.genus = genus
      combination.species = species
      combination.verbatim_name = 'Aus bus'
      combination.save
      expect(combination.cached).to eq('Aus bus')
      expect(combination.cached_html).to eq('<i>Aus bus</i>')
    end

    specify 'chached_valid_taxon_name_id for Combination' do
      combination.genus = genus
      combination.species = species
      combination.save
      expect(species.cached_valid_taxon_name_id).to eq(species.id)
      expect(combination.cached_valid_taxon_name_id).to eq(species.id)
    end


  end

  context 'soft validation' do
    specify 'runs all validations without error' do
      expect(combination.soft_validate).to be_truthy
    end

    specify 'missing source and year' do
      combination.soft_validate(:missing_fields)

      # expect(combination.soft_validations.messages_on(:source_id).empty?).to be_falsey
      expect(combination.soft_validations.messages_on(:base).empty?).to be_falsey
      
      expect(combination.soft_validations.messages_on(:year_of_publication).empty?).to be_falsey
    end

    specify 'year of combination and year of source do not match' do
      combination.source = source_older_than_combination  # 1940
      combination.year_of_publication = 1950
      combination.soft_validate(:dates)
      expect(combination.soft_validations.messages_on(:year_of_publication).count).to eq(1)
    end

    specify 'source.year_of_publication can not be older than protonym nomenclature dates' do
      combination.source = source_older_than_combination  # 1940
      combination.genus = genus    # 1950
      combination.soft_validate(:dates)
      
      # expect(combination.soft_validations.messages_on(:source_id).count).to eq(1)
       expect(combination.soft_validations.messages_on(:base).count).to eq(1)
    end

    specify 'year_of_publication can not be older than protonym nomenclature_dates' do
      basic_combination.year_of_publication = 1940
      expect(basic_combination.save).to be_truthy
      basic_combination.soft_validate(:dates)
      expect(basic_combination.soft_validations.messages_on(:year_of_publication).count).to eq(1)
    end

    specify 'duplicate combinations are detected' do
      c1 = Combination.new
      c1.genus = genus
      c1.species = species
      expect(c1.save).to be_truthy
      c2 = Combination.new
      c2.genus = genus
      c2.species = species
      expect(c2.save).to be_truthy
      c1.soft_validate(:combination_duplicates)
      expect(c1.soft_validations.messages_on(:base).count).to eq(1)
    end
  end

  context 'usage' do
    let(:genus) {FactoryGirl.create(:iczn_genus, name: 'Aus', parent: family)}
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
        expect(basic_combination.save).to be_truthy
        expect(basic_combination.related_taxon_name_relationships.size).to eq(2)
        expect(basic_combination.taxon_name_relationships.size).to eq(0) # Combination is on the right side, not left
      end

      specify '#combination_taxon_names' do
        expect(basic_combination.save).to be_truthy
        expect(basic_combination.combination_taxon_names.to_a).to include(genus, species) 
      end

      specify '#combination_relationships' do
        expect(basic_combination.save).to be_truthy
        expect(basic_combination.combination_relationships.count).to eq(2) 
      end

      specify 'generated taxon name relationships are the right type' do
        expect(basic_combination.save).to be_truthy
        expect(basic_combination.related_taxon_name_relationships.pluck('type')).to include('TaxonNameRelationship::Combination::Species', 'TaxonNameRelationship::Combination::Genus') 
      end

      specify 'combination_class_relationships' do
        combination.genus = genus
        combination.subgenus = genus
        combination.species = species
        combination.subspecies = species2

        expect(combination.valid?).to be_truthy
        combination.save

        expect(combination.combination_class_relationships(genus.rank_string).collect{|i| i.to_s}.sort).to eq(['TaxonNameRelationship::Combination::Genus', 'TaxonNameRelationship::Combination::Subgenus'])
        expect(combination.combination_class_relationships(species.rank_string).collect{|i| i.to_s}.sort).to eq(["TaxonNameRelationship::Combination::Form", "TaxonNameRelationship::Combination::Genus", "TaxonNameRelationship::Combination::Species", "TaxonNameRelationship::Combination::Subgenus", "TaxonNameRelationship::Combination::Subspecies", "TaxonNameRelationship::Combination::Variety"])

        stubs = combination.combination_relationships_and_stubs(species.rank_string)

        expect(stubs.count).to eq(6)
        expect(stubs[0].subject_taxon_name_id).to eq(genus.id)
        expect(stubs[0].object_taxon_name_id).to eq(combination.id)
        expect(stubs[0].type).to eq('TaxonNameRelationship::Combination::Genus')
        expect(stubs[5].subject_taxon_name_id).to be_falsey
        expect(stubs[5].object_taxon_name_id).to eq(combination.id)
        expect(stubs[5].type).to eq('TaxonNameRelationship::Combination::Form')
      end

    end
  end

  context 'concerns' do
    it_behaves_like 'citable'
  end
end
