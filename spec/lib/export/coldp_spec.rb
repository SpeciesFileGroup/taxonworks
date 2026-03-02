require 'rails_helper'
require 'export/coldp'

describe Export::Coldp, type: :model, group: :col do
  include ActiveJob::TestHelper

  specify 'otus' do
    p = FactoryBot.create(:valid_protonym)
    o = Otu.create!(taxon_name: p)
    expect(::Export::Coldp.otus(o.id).count).to eq(1)
  end

  context 'download packaging' do
    before { include ActiveJob::TestHelper }

    # We want the minimum data to have at least one, and hopefully as few as possible, lines in each export file.
    #
    # TODO:
    # * Add gender missmatch spec
    #     For combination
    #     For misspelled original protonym differening from current parent
    # Add original combination data
    # 
    let!(:species) { FactoryBot.create(:iczn_species) }
    let(:otu) { Otu.create(taxon_name: species) }
    let(:specimen) { Specimen.create! }
    let!(:citation) { Citation.create!(citation_object: otu, source: FactoryBot.create(:valid_source_bibtex), is_original: true) }
    let!(:invalid_species) { Protonym.create(name: 'bus', rank_class: Ranks.lookup(:iczn, :species), parent: species.parent) }
    let!(:synonym) { TaxonNameRelationship::Iczn::Invalidating.create!(subject_taxon_name: invalid_species, object_taxon_name: species) }    
    let!(:common_name) { FactoryBot.create(:valid_common_name, otu: otu) }
    let!(:type_material) { FactoryBot.create(:valid_type_material, collection_object: specimen, protonym: species) }
    let!(:asserted_distribution) { FactoryBot.create(:valid_geographic_area_asserted_distribution, asserted_distribution_object: otu) }
    let!(:homonym_species) { Protonym.create(name: 'hus', rank_class: Ranks.lookup(:iczn, :species), parent: species.root) }
    let!(:homonym) { TaxonNameRelationship::Iczn::Invalidating::Homonym.create!(subject_taxon_name: homonym_species, object_taxon_name: species )  }
    let!(:biological_association) { FactoryBot.create(:valid_biological_association, biological_association_subject: otu, biological_association_object: Otu.create!(name: 'ba'))  }
    let!(:otu_relationship) { FactoryBot.create(:valid_otu_relationship, subject_otu: otu, object_otu:  Otu.create!(name: 'or'))  }

    let!(:d) {
      ::Export::Coldp.download_async(
        otu, 'https://example.org/some_url',
        prefer_unlabelled_otus: true
      )
    }

    specify '#download_async creates Download' do
      expect(Download.count).to eq(1)
    end

    specify '#download_async creates Zip after worker' do
      perform_enqueued_jobs
      expect(File.exist?(d.file_path)).to be_truthy
    end

    context 'when performed' do
      before { perform_enqueued_jobs }

      let!(:download) { Download.first }
      let!(:z) { Zip::File.open(download.file_path) }

      specify 'includes tsv' do
        ::Export::Coldp::FILETYPES.each do |t|
          expect(z.find_entry("#{t}.tsv")).to be_truthy
        end
      end

      specify 'writes to tsv' do
        ::Export::Coldp::FILETYPES.each do |t|
          c = z.find_entry("#{t}.tsv").get_input_stream.read.lines.count
          expect(c > 1).to be_truthy,  "Can't find #{t}.tsv"
        end
      end
    end
  end

  context 'authorship brackets for invalid species with changed genus' do
    # Scenario: An invalid species originally described in genus Originalus,
    # now placed under genus Erythroneura (via synonym relationship).
    # The original combination row in Name.tsv should preserve the
    # parenthesized authorship from cached_author_year.
    #
    # See https://github.com/catalogueoflife/testing/issues/322

    let!(:species) { FactoryBot.create(:iczn_species) }
    let(:otu) { Otu.create!(taxon_name: species) }

    let!(:original_genus) {
      Protonym.create!(
        name: 'Originalus',
        rank_class: Ranks.lookup(:iczn, :genus),
        parent: species.ancestor_at_rank('subtribe'),
        verbatim_author: 'Jones',
        year_of_publication: 1850
      )
    }

    let!(:moved_species) {
      Protonym.create!(
        name: 'transferus',
        rank_class: Ranks.lookup(:iczn, :species),
        parent: species.parent,
        verbatim_author: 'Smith',
        year_of_publication: 1900
      )
    }

    let!(:original_genus_relationship) {
      TaxonNameRelationship::OriginalCombination::OriginalGenus.create!(
        subject_taxon_name: original_genus,
        object_taxon_name: moved_species
      )
    }

    let!(:original_species_relationship) {
      TaxonNameRelationship::OriginalCombination::OriginalSpecies.create!(
        subject_taxon_name: moved_species,
        object_taxon_name: moved_species
      )
    }

    let!(:synonym_relationship) {
      TaxonNameRelationship::Iczn::Invalidating.create!(
        subject_taxon_name: moved_species,
        object_taxon_name: species
      )
    }

    # Recompute cached_author_year after all relationships are established.
    # The OriginalCombination callback only updates cached_original_combination,
    # not cached_author_year (which depends on original vs current genus).
    before do
      moved_species.update_column(:cached_author_year, moved_species.get_author_and_year)
    end

    let(:project_members) { Export::Coldp.project_members(otu.project_id) }

    let(:name_tsv) {
      moved_species.reload
      Export::Coldp::Files::Name.generate(otu, project_members)
    }

    let(:name_rows) { CSV.parse(name_tsv, col_sep: "\t", headers: true) }

    specify 'test data has expected cached values' do
      moved_species.reload
      expect(moved_species.cached_is_valid).to be false
      expect(moved_species.cached_original_combination).to include('Originalus')
      expect(moved_species.cached).not_to include('Originalus')
      expect(moved_species.cached_author_year).to start_with('(')
    end

    specify 'invalid original combination row preserves parenthesized authorship in Name.tsv' do
      original_combination_row = name_rows.find { |r|
        r['scientificName']&.include?('Originalus') &&
          r['scientificName']&.include?('transferus')
      }

      expect(original_combination_row).not_to be_nil,
        "Expected a Name.tsv row for the original combination (Originalus transferus)"
      expect(original_combination_row['authorship']).to start_with('('),
        "Expected parenthesized authorship to be preserved for invalid species with changed genus"
    end
  end
end
