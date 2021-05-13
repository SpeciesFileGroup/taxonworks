require 'rails_helper'
describe Combination, type: :model, group: :nomenclature do

  let(:combination) { Combination.new }
  let(:source_older_than_combination) { FactoryBot.build(:valid_source_bibtex, year: 1940, author: 'Dmitriev') }
  let(:family) { FactoryBot.create(:relationship_family, name: 'Aidae', year_of_publication: 2000) }
  let(:genus ) {FactoryBot.create(:relationship_genus, parent: family, year_of_publication: 1950)}
  let(:subgenus ) {FactoryBot.create(:iczn_subgenus, parent: genus, year_of_publication: 1950)}
  let(:species) { FactoryBot.create(:relationship_species, parent: genus, year_of_publication: 1951)  }
  let(:species2) { FactoryBot.create(:relationship_species, name: 'comes', parent: genus, year_of_publication: 1952) }

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

  specify '#protonym_ids_params' do
    # Don't use update() here
    combination.genus = genus
    combination.subgenus = genus
    combination.species = species
    combination.subspecies = species
    expect(combination.protonym_ids_params).to eq(genus: genus.id, subgenus: genus.id, species: species.id, subspecies: species.id)
  end

  context 'validation' do

    before { combination.valid? }

    specify 'is invalid without at least two protonyms' do
      expect(combination.errors.include?(:base)).to be_truthy
    end

    specify 'combinations without verbatim name must be unique' do
      basic_combination.save
      c = Combination.new(genus: genus, species: species)
      expect(c.valid?).to be_falsey
      expect(c.errors.messages[:base].include?('Combination exists.')).to be_truthy
    end

    specify 'uniqueness takes into account verbatim_name 1' do
      basic_combination.save
      c = Combination.new(genus: genus, species: species, verbatim_name: "Aus zus")
      expect(c.valid?).to be_truthy
    end

    specify 'uniqueness does not include empty string' do
      basic_combination.save
      c = Combination.new(genus: genus, species: species, verbatim_name: "")
      expect(c.valid?).to be_falsey
    end

    specify 'uniqueness including original combination' do
      species.update(original_genus: genus, original_species: species)
      c = Combination.new(genus: genus, species: species)
      expect(c.valid?).to be_falsey
    end

    specify 'uniqueness including original combination different name' do
      species.update(original_genus: genus, original_species: species)
      c = Combination.new(genus: genus, species: species, verbatim_name: "Erythroneura viti")
      expect(c.valid?).to be_truthy
    end

    specify 'species combination is valid with two protonyms' do
      basic_combination.valid?
      expect(basic_combination.protonyms.last.rank_string).to eq('NomenclaturalRank::Iczn::SpeciesGroup::Species')
      expect(basic_combination.errors.include?(:base)).to be_falsey
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

    specify 'rank_class is not allowed' do
      expect(combination.errors.include?(:rank_class)).to be_falsey
    end

    specify 'scope with_cached_original_combination' do
      basic_combination.save
      expect(Combination.where(cached_html: '<i>' + genus.name + ' ' + species.name + '</i>').first).to eq(basic_combination)
    end

    specify 'scope with_protonym_at_rank' do
      basic_combination.save
      expect(Combination.with_protonym_at_rank('TaxonNameRelationship::Combination::Genus', genus).first).to eq(basic_combination)
      expect(Combination.with_protonym_at_rank('TaxonNameRelationship::Combination::Species', species).first).to eq(basic_combination)
    end
  end

  specify 'type is Combination' do
    expect(combination.type).to eq('Combination')
  end

  context 'class methods' do
    before { basic_combination.save }

    specify '.find_by_protonym_ids' do
      expect(Combination.find_by_protonym_ids(genus: genus.id, species: species.id).all).to contain_exactly(basic_combination)
    end

    specify '.match_exists? 1' do
      expect(Combination.match_exists?(genus: genus.id, species: species.id)).to eq(basic_combination)
    end

    specify '.match_exists? 1a' do
      basic_combination.update(verbatim_name: 'Aus bus')
      expect(Combination.match_exists?(genus: genus.id, species: species.id)).to eq(basic_combination)
    end

    specify '.match_exists? 1b' do
      basic_combination.update(verbatim_name: 'Aus bus')
      expect(Combination.match_exists?(genus: genus.id, subgenus: nil, species: species.id)).to eq(basic_combination)
    end

    specify '.match_exists? 2' do
      expect(Combination.match_exists?(genus: genus.id, species: species2.id)).to eq(false)
    end

    specify '.match_exists? 3' do
      expect(Combination.match_exists?(genus: genus.id)).to eq(false)
    end

    specify '.match_exists? 4' do
      expect(Combination.match_exists?(genus: genus.id, species: species.id, subspecies: species.id)).to eq(false)
    end

    specify '.match_exists? nil name' do
      expect(Combination.match_exists?(nil, genus: genus.id, species: species.id)).to eq(basic_combination)
    end

    specify '.match_exists? empty string name' do
      expect(Combination.match_exists?("", genus: genus.id, species: species.id)).to eq(basic_combination)
    end

    specify '.match_exists with name' do
      n = 'Blorf mgorf'
      basic_combination.update(verbatim_name: n)
      expect(Combination.match_exists?(n, genus: genus.id, species: species.id)).to eq(basic_combination)
    end

    specify '.matching_protonyms 1' do
      species.update(original_genus: genus, original_subgenus: genus, original_species: species)
      expect(Combination.matching_protonyms(nil, genus: genus.id, subgenus: genus.id, species: species.id).to_a).to contain_exactly(species)
    end

    specify '.matching_protonyms 2' do
      species.update(original_genus: genus, original_subgenus: genus, original_species: species)
      expect(Combination.matching_protonyms(species.cached_original_combination, genus: genus.id, subgenus: genus.id, species: species.id).to_a).to contain_exactly(species)
    end

    specify '.matching_protonyms 3' do
      species.update(original_genus: genus, original_subgenus: genus, original_species: species)
      expect(Combination.matching_protonyms("Aus bus", genus: genus.id, subgenus: genus.id, species: species.id, subspecies: nil).to_a).to contain_exactly()
    end

    specify '.matching_protonyms 4' do
      species.update(original_genus: genus, original_subgenus: genus, original_species: species)
      expect(Combination.matching_protonyms(nil, genus: genus.id, subgenus: genus.id, species: species.id, subspecies: nil).to_a).to contain_exactly(species)
    end

    specify '.matching_protonyms 5' do
      species.update(original_genus: genus, original_subgenus: genus, original_species: species)
      expect(Combination.matching_protonyms(nil, genus: genus.id, subgenus: nil, species: species.id, subspecies: nil).to_a).to contain_exactly()
    end
  end

  context 'instance methods' do
    specify '#protonym_ids_params?' do
      expect(basic_combination.protonym_ids_params).to eq({genus: genus.id, species: species.id})
    end

    specify '#is_current_placement?' do
      expect(basic_combination.is_current_placement?).to eq(true)
    end

    context '#protonyms' do
      specify 'are returned for unsaved Combinations' do
        expect(basic_combination.protonyms).to eq([genus, species])
      end

      specify 'are returned for saved Combinations' do
        basic_combination.save
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
        expect(combination.full_name_hash).to eq({'genus'=>[nil, 'Erythroneura']})
      end

      specify 'with genus and species' do
        expect(basic_combination.full_name_hash).to eq({'genus'=>[nil, 'Erythroneura'], 'species'=>[nil, 'vitis']})
      end

      specify 'with quadrinomial' do
        combination.update(genus: genus, subgenus: genus, species: species, subspecies: species2)
        expect(combination.full_name_hash).to eq({'genus'=>[nil, 'Erythroneura'], 'subgenus'=>[nil, 'Erythroneura'],  'species'=>[nil, 'vitis'], 'subspecies'=>[nil, 'comes']})
      end
    end

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

    specify 'cached_author_year on protonym author update' do
      basic_combination.save
      species.update!(verbatim_author: 'Zord')
      expect(basic_combination.reload.cached_author_year).to eq('Zord, 1951')
    end

    context 'cached_html' do
      specify 'with genus and species' do
        basic_combination.save
        expect(basic_combination.cached_html).to eq('<i>Erythroneura vitis</i>')
      end

      specify 'with a quadrinomial' do
        combination.update(genus: genus, subgenus: genus, species: species, subspecies: species2)
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
      combination.update(genus: genus, species: species, verbatim_name: 'Aus bus')
      expect(combination.cached).to eq('Aus bus')
      expect(combination.cached_html).to eq('<i>Aus bus</i>')
    end

    specify 'chached_valid_taxon_name_id for Combination' do
      combination.update(genus: genus, species: species)
      expect(species.cached_valid_taxon_name_id).to eq(species.id)
      expect(combination.cached_valid_taxon_name_id).to eq(species.id)
    end
  end

  context '#destroy' do
    before { basic_combination.save }

    specify 'works' do
      expect(basic_combination.destroy).to be_truthy
    end
  end

  context 'soft validation' do
    specify 'runs all validations without error' do
      expect(combination.soft_validate).to be_truthy
    end

    specify 'missing source and year' do
      combination.soft_validate(only_sets: :missing_fields)
      expect(combination.soft_validations.messages_on(:base).empty?).to be_falsey
      expect(combination.soft_validations.messages_on(:year_of_publication).empty?).to be_truthy
    end

    specify 'year of combination and year of source do not match' do
      combination.source = source_older_than_combination  # 1940
      combination.year_of_publication = 1950
      combination.soft_validate(only_sets: :dates)
      expect(combination.soft_validations.messages_on(:year_of_publication).count).to eq(1)
    end

    specify 'source.year_of_publication can not be older than protonym nomenclature dates' do
      combination.source = source_older_than_combination  # 1940
      combination.genus = genus    # 1950
      combination.soft_validate(only_sets: :dates)
       expect(combination.soft_validations.messages_on(:base).count).to eq(1)
    end

    specify 'year_of_publication can not be older than protonym nomenclature_dates' do
      basic_combination.update(year_of_publication: 1940)
      basic_combination.soft_validate(only_sets: :dates)
      expect(basic_combination.soft_validations.messages_on(:year_of_publication).count).to eq(1)
    end

    specify 'incomplete combination' do
      combination.update(subgenus: genus, subspecies: species)
      combination.soft_validate(only_sets: :incomplete_combination)
      expect(combination.soft_validations.messages_on(:base).count).to eq(2)
    end
  end

    specify '#cached combination' do
      combination.update(subgenus: genus, subspecies: species)
      expect(combination.cached).to eq ("[GENUS NOT SPECIFIED] (Erythroneura) [SPECIES NOT SPECIFIED] vitis")
    end

  context 'usage' do
    let(:genus) {FactoryBot.create(:iczn_genus, name: 'Aus', parent: family)}
    let(:subgenus) {FactoryBot.create(:iczn_subgenus, name: 'Bus', parent: genus) }
    let(:species) {FactoryBot.create(:iczn_species, name: 'bus', parent: subgenus) }

    specify '#parent is assigned as parent of highest ranking taxon' do
      combination.update(genus: genus, species: species)
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

      context 'combination_class_relationships' do
        before {
          combination.update(genus: genus, subgenus: genus, species: species, subspecies: species2)
        }

        let!(:stubs) { combination.combination_relationships_and_stubs(species.rank_string) }

        specify '1' do
          expect(combination.combination_class_relationships(genus.rank_string).collect{|i| i.to_s}.sort).to eq(['TaxonNameRelationship::Combination::Genus', 'TaxonNameRelationship::Combination::Subgenus'])
        end

        specify '2' do
          expect(combination.combination_class_relationships(species.rank_string).collect{|i| i.to_s}.sort).to eq(['TaxonNameRelationship::Combination::Form', 'TaxonNameRelationship::Combination::Genus', 'TaxonNameRelationship::Combination::Species', 'TaxonNameRelationship::Combination::Subgenus', 'TaxonNameRelationship::Combination::Subspecies', 'TaxonNameRelationship::Combination::Variety'])
        end

        specify '#combination_relationships_and_stubs 1' do
          expect(stubs.count).to eq(6)
        end

        specify '#combination_relationships_and_stubs 2' do
          expect(stubs[0].subject_taxon_name_id).to eq(genus.id)
        end

        specify '#combination_relationships_and_stubs 3' do
          expect(stubs[0].object_taxon_name_id).to eq(combination.id)
        end

        specify '#combination_relationships_and_stubs 4' do
          expect(stubs[0].type).to eq('TaxonNameRelationship::Combination::Genus')
        end

        specify '#combination_relationships_and_stubs 5' do
          expect(stubs[5].subject_taxon_name_id).to be_falsey
        end

        specify '#combination_relationships_and_stubs 6' do
          expect(stubs[5].object_taxon_name_id).to eq(combination.id)
        end

        specify '#combination_relationships_and_stubs 7' do
          expect(stubs[5].type).to eq('TaxonNameRelationship::Combination::Form')
        end
      end

    end
  end

  context 'concerns' do
    it_behaves_like 'citations'
  end
end
