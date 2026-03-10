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

  # See https://github.com/CatalogueOfLife/testing/issues/322
  context 'nominotypical autonym synonymy' do
    let!(:species) { FactoryBot.create(:iczn_species) }

    specify 'nominotypical subspecies is not exported as synonym of its parent species' do
      subspecies = Protonym.create!(
        name: species.name,
        rank_class: Ranks.lookup(:iczn, :subspecies),
        parent: species,
        verbatim_author: species.verbatim_author,
        year_of_publication: species.year_of_publication
      )

      TaxonNameRelationship::Iczn::Invalidating.create!(
        subject_taxon_name: subspecies,
        object_taxon_name: species
      )

      species_otu = Otu.create!(taxon_name: species)
      otus = Export::Coldp.otus(species_otu.id)

      tsv = Export::Coldp::Files::Synonym.generate(species_otu, otus, {})
      rows = CSV.parse(tsv, col_sep: "\t", headers: true)
      name_ids = rows.map { |r| r['nameID'] }

      expect(name_ids).not_to include(subspecies.id.to_s)
    end

    specify 'species is not exported as synonym of its nominotypical subspecies' do
      subspecies = Protonym.create!(
        name: species.name,
        rank_class: Ranks.lookup(:iczn, :subspecies),
        parent: species,
        verbatim_author: species.verbatim_author,
        year_of_publication: species.year_of_publication
      )

      TaxonNameRelationship::Iczn::Invalidating.create!(
        subject_taxon_name: species,
        object_taxon_name: subspecies
      )

      subspecies_otu = Otu.create!(taxon_name: subspecies)
      otus = Export::Coldp.otus(subspecies_otu.id)

      tsv = Export::Coldp::Files::Synonym.generate(subspecies_otu, otus, {})
      rows = CSV.parse(tsv, col_sep: "\t", headers: true)
      name_ids = rows.map { |r| r['nameID'] }

      expect(name_ids).not_to include(species.id.to_s)
    end

    specify 'species with different original combination is not exported as reified synonym of its nominotypical subspecies' do
      # Create a different genus for the original combination
      other_genus = Protonym.create!(
        name: 'Xus',
        rank_class: Ranks.lookup(:iczn, :genus),
        parent: species.ancestor_at_rank('tribe'),
        verbatim_author: 'Author',
        year_of_publication: 1800
      )

      # Set original genus so cached_original_combination differs from cached
      species.original_genus = other_genus
      species.save!
      species.reload

      subspecies = Protonym.create!(
        name: species.name,
        rank_class: Ranks.lookup(:iczn, :subspecies),
        parent: species,
        verbatim_author: species.verbatim_author,
        year_of_publication: species.year_of_publication
      )

      TaxonNameRelationship::Iczn::Invalidating.create!(
        subject_taxon_name: species,
        object_taxon_name: subspecies
      )

      subspecies_otu = Otu.create!(taxon_name: subspecies)
      otus = Export::Coldp.otus(subspecies_otu.id)

      tsv = Export::Coldp::Files::Synonym.generate(subspecies_otu, otus, {})
      rows = CSV.parse(tsv, col_sep: "\t", headers: true)
      name_ids = rows.map { |r| r['nameID'] }

      # The reified ID should not appear as a synonym
      species.reload
      reified_id = Utilities::Nomenclature.reified_id(species.id, species.cached_original_combination)
      expect(name_ids).not_to include(reified_id.to_s)
    end

    specify 'valid autonym subspecies with different original combination does not export its binomial OC as synonym' do
      # The subspecies was originally described at species rank (binomial OC),
      # then later moved to subspecies. The reified OC "Aus bus" should not
      # be listed as a synonym of the subspecies "Aus bus bus" because it
      # collides with the accepted parent species.
      other_genus = Protonym.create!(
        name: 'Xus',
        rank_class: Ranks.lookup(:iczn, :genus),
        parent: species.ancestor_at_rank('tribe'),
        verbatim_author: 'Author',
        year_of_publication: 1800
      )

      subspecies = Protonym.create!(
        name: species.name,
        rank_class: Ranks.lookup(:iczn, :subspecies),
        parent: species,
        verbatim_author: species.verbatim_author,
        year_of_publication: species.year_of_publication
      )

      # Set original genus on the subspecies so its OC is a binomial in a different genus
      subspecies.original_genus = other_genus
      subspecies.save!
      subspecies.reload

      species_otu = Otu.create!(taxon_name: species)
      subspecies_otu = Otu.create!(taxon_name: subspecies)
      otus = Export::Coldp.otus(species_otu.id)

      tsv = Export::Coldp::Files::Synonym.generate(species_otu, otus, {})
      rows = CSV.parse(tsv, col_sep: "\t", headers: true)
      name_ids = rows.map { |r| r['nameID'] }

      reified_id = Utilities::Nomenclature.reified_id(subspecies.id, subspecies.cached_original_combination)
      expect(name_ids).not_to include(reified_id.to_s)
    end
  end

  # See https://github.com/catalogueoflife/testing/issues/322
  specify 'invalid_core_names excludes misapplications' do
    species = FactoryBot.create(:iczn_species)
    otu = Otu.create!(taxon_name: species)

    misapplied = Protonym.create!(
      name: 'misapplicatus',
      rank_class: Ranks.lookup(:iczn, :species),
      parent: species.parent,
      verbatim_author: 'Smith',
      year_of_publication: 1900
    )

    TaxonNameRelationship::Iczn::Invalidating::Misapplication.create!(
      subject_taxon_name: misapplied,
      object_taxon_name: species
    )

    scope = Export::Coldp::Files::Name.invalid_core_names(otu)
    expect(scope.where(id: misapplied.id).count).to eq(0)
  end
end
