require 'rails_helper'

describe Export::Dwca::ChecklistData, type: :model, group: :darwin_core do

  # Create OTUs with taxon determinations for testing
  let!(:otu1) { FactoryBot.create(:valid_otu) }
  let!(:otu2) { FactoryBot.create(:valid_otu) }
  let!(:otu3) { FactoryBot.create(:valid_otu) }

  let(:otu_scope) { { otu_id: [otu1.id, otu2.id, otu3.id] } }

  context 'when initialized with a scope' do
    let(:data) { Export::Dwca::ChecklistData.new(core_scope: otu_scope) }

    specify '#csv returns csv String' do
      expect(data.csv).to be_kind_of(String)
    end

    context 'with some occurrence records created' do
      # Create taxon names with full classification including class for testing
      let!(:root) { FactoryBot.create(:root_taxon_name) }
      let!(:kingdom) { Protonym.create!(name: 'Animalia', rank_class: Ranks.lookup(:iczn, :kingdom), parent: root) }
      let!(:phylum) { Protonym.create!(name: 'Arthropoda', rank_class: Ranks.lookup(:iczn, :phylum), parent: kingdom) }
      let!(:tn_class) { Protonym.create!(name: 'Insecta', rank_class: Ranks.lookup(:iczn, :class), parent: phylum) }
      let!(:order) { Protonym.create!(name: 'Lepidoptera', rank_class: Ranks.lookup(:iczn, :order), parent: tn_class) }
      let!(:family) { Protonym.create!(name: 'Noctuidae', rank_class: Ranks.lookup(:iczn, :family), parent: order) }
      let!(:genus) { Protonym.create!(name: 'Aus', rank_class: Ranks.lookup(:iczn, :genus), parent: family) }
      let!(:taxon_name1) { Protonym.create!(name: 'bus', rank_class: Ranks.lookup(:iczn, :species), parent: genus) }
      let!(:taxon_name2) { Protonym.create!(name: 'cus', rank_class: Ranks.lookup(:iczn, :species), parent: genus) }
      let!(:taxon_name3) { Protonym.create!(name: 'dus', rank_class: Ranks.lookup(:iczn, :species), parent: genus) }

      before do
        # Link OTUs to taxon names
        otu1.update!(taxon_name: taxon_name1)
        otu2.update!(taxon_name: taxon_name2)
        otu3.update!(taxon_name: taxon_name3)

        # Create specimens with taxon determinations to our OTUs
        3.times do |i|
          otu = [otu1, otu2, otu3][i]
          specimen = FactoryBot.create(:valid_specimen)
          FactoryBot.create(:valid_taxon_determination,
            otu: otu,
            taxon_determination_object: specimen)
          specimen.get_dwc_occurrence
        end
      end

      after { data.cleanup }

      let(:csv) { CSV.parse(data.csv, headers: true, col_sep: "\t") }

      # Expected DwC Taxon core fields
      let(:taxon_headers) {
        %w{taxonID scientificName kingdom phylum class order family genus specificEpithet
           taxonRank scientificNameAuthorship nomenclaturalCode}
      }

      specify '#total returns count of DwcOccurrences' do
        expect(data.total).to eq(3)
      end

      specify '#no_records? returns false when records exist' do
        expect(data.no_records?).to be_falsey
      end

      specify '#csv returns normalized taxonomy (more rows than occurrences)' do
        # With 3 species from same genus/family/etc., we expect:
        # kingdom, phylum, class, order, family, genus, and 3 species = 9 unique taxa
        expect(csv.count).to be > data.total
        expect(csv.count).to eq(9)
      end

      context 'CSV headers and column conversions' do
        specify 'taxonID is the first column' do
          expect(csv.headers.first).to eq('taxonID')
        end

        specify 'headers include scientificName' do
          expect(csv.headers).to include('scientificName')
        end

        specify 'dwcClass column is converted to "class" in header' do
          expect(csv.headers).to include('class')
          expect(csv.headers).not_to include('dwcClass')
        end

        specify 'occurrenceID is excluded from headers' do
          expect(csv.headers).not_to include('occurrenceID')
        end

        specify 'TW housekeeping columns are not present' do
          expect(csv.headers).not_to include('project_id', 'created_by_id', 'updated_by_id',
            'dwc_occurrence_object_id', 'dwc_occurrence_object_type')
        end

        specify 'generated headers contain expected taxon fields' do
          # taxonID should be present, plus at least some of the taxon fields
          expect(csv.headers).to include('taxonID', 'scientificName', 'taxonRank')
        end
      end

      context 'normalized taxonomy structure' do
        specify 'all original scientificNames are preserved in output' do
          # Get all scientificNames from the source DwcOccurrence records
          source_names = data.core_occurrence_scope.pluck(:scientificName).uniq.compact
          output_names = csv.map { |row| row['scientificName'] }.compact

          # Every source scientificName should appear in the output
          source_names.each do |name|
            expect(output_names).to include(name), "Expected to find '#{name}' in output but it was missing"
          end
        end

        specify 'all rank column values are preserved as taxa' do
          # Collect all unique rank values from source data
          rank_columns = %w[kingdom phylum class order family genus]
          source_rank_values = {}

          data.core_occurrence_scope.each do |dwc|
            rank_columns.each do |rank|
              col = rank == 'class' ? 'dwcClass' : rank
              value = dwc.send(col)
              if value.present?
                source_rank_values[rank] ||= Set.new
                source_rank_values[rank] << value
              end
            end
          end

          # Check that all rank values appear in output
          source_rank_values.each do |rank, values|
            output_at_rank = csv.select { |row| row['taxonRank'] == rank }
                                .map { |row| row['scientificName'] }
            values.each do |value|
              expect(output_at_rank).to include(value),
                "Expected to find #{rank} '#{value}' in output but it was missing"
            end
          end
        end

        specify 'no duplicate taxa in output' do
          # Each unique "rank:name" combination should appear exactly once
          taxa_keys = csv.map { |row| "#{row['taxonRank']}:#{row['scientificName']}" }
          expect(taxa_keys.uniq.count).to eq(taxa_keys.count)
        end

        specify 'taxonID values are sequential integers starting from 1' do
          taxon_ids = csv.map { |row| row['taxonID'].to_i }
          expect(taxon_ids.first).to eq(1)
          expect(taxon_ids.last).to eq(csv.count)
          expect(taxon_ids).to eq((1..csv.count).to_a)
        end

        specify 'all taxonID values are unique' do
          taxon_ids = csv.map { |row| row['taxonID'] }
          expect(taxon_ids.uniq.count).to eq(taxon_ids.count)
        end

        specify 'parentNameUsageID header is present' do
          expect(csv.headers).to include('parentNameUsageID')
          # Should be second column after taxonID
          expect(csv.headers[1]).to eq('parentNameUsageID')
        end

        specify 'root taxon (kingdom) has no parent' do
          kingdom = csv.find { |row| row['taxonRank'] == 'kingdom' }
          expect(kingdom).to be_present
          expect(kingdom['parentNameUsageID']).to be_nil.or be_empty
        end

        specify 'child taxa have parentNameUsageID linking to parent taxonID' do
          # Find a species and its genus
          species = csv.find { |row| row['taxonRank'] == 'species' }
          expect(species).to be_present
          expect(species['parentNameUsageID']).to be_present

          # The parent should be the genus with matching genus name
          parent_id = species['parentNameUsageID'].to_i
          genus = csv.find { |row| row['taxonID'].to_i == parent_id }
          expect(genus).to be_present
          expect(genus['taxonRank']).to eq('genus')
          expect(genus['scientificName']).to eq(species['genus'])
        end

        specify 'taxa are exported in rank order' do
          # Check that kingdom comes before phylum, phylum before class, etc.
          rank_order = %w[kingdom phylum class order family genus species]

          # Find index of first occurrence of each rank
          rank_indices = rank_order.map do |rank|
            csv.each_with_index.find { |row, idx| row['taxonRank'] == rank }&.last
          end.compact

          # Each rank should appear before the next rank (if both exist)
          rank_indices.each_cons(2) do |earlier, later|
            expect(earlier).to be < later
          end
        end
      end

      specify '#meta_fields returns headers without id column' do
        meta_fields = data.meta_fields
        expect(meta_fields).not_to include('id')
        expect(meta_fields).to include('scientificName')
        # taxonID is the renamed id column in the CSV, but meta_fields returns the pre-header-conversion names
      end

      context 'files' do
        specify '#data_file is a tempfile' do
          expect(data.data_file).to be_kind_of(Tempfile)
        end

        specify '#eml is a tempfile' do
          expect(data.eml).to be_kind_of(Tempfile)
        end

        specify '#meta is a tempfile' do
          expect(data.meta).to be_kind_of(Tempfile)
        end

        specify '#zipfile is a Tempfile' do
          expect(data.zipfile).to be_kind_of(Tempfile)
        end

        specify '#package_download packages' do
          d = FactoryBot.build(:valid_download)
          expect(data.package_download(d)).to be_truthy
        end

        specify '#package_download creates file at path' do
          d = FactoryBot.build(:valid_download)
          data.package_download(d)
          expect(File.exist?(d.file_path)).to be_truthy
        end
      end

      specify '#cleanup returns truthy' do
        expect(data.cleanup).to be_truthy
      end
    end

    context 'with no matching records' do
      let(:empty_scope) { { otu_id: [999999] } }
      let(:empty_data) { Export::Dwca::ChecklistData.new(core_scope: empty_scope) }

      after { empty_data.cleanup }

      specify '#no_records? returns true' do
        expect(empty_data.no_records?).to be_truthy
      end

      specify '#total returns 0' do
        expect(empty_data.total).to eq(0)
      end

      specify '#csv returns minimal content for empty dataset' do
        expect(empty_data.csv).to be_kind_of(String)
      end

      specify '#meta_fields returns empty array' do
        expect(empty_data.meta_fields).to eq([])
      end
    end

    context 'with various OTU query scopes' do
      before do
        # Create one specimen with determination to otu1
        specimen = FactoryBot.create(:valid_specimen)
        FactoryBot.create(:valid_taxon_determination,
          otu: otu1,
          taxon_determination_object: specimen)
        specimen.get_dwc_occurrence
      end

      specify 'with single OTU ID' do
        single_scope = { otu_id: otu1.id }
        d = Export::Dwca::ChecklistData.new(core_scope: single_scope)
        expect(d.total).to eq(1)
        d.cleanup
      end

      specify 'with array of OTU IDs' do
        array_scope = { otu_id: [otu1.id] }
        d = Export::Dwca::ChecklistData.new(core_scope: array_scope)
        expect(d.total).to eq(1)
        d.cleanup
      end

      specify 'with range of OTU IDs converted to array' do
        # Ranges must be converted to arrays for proper querying
        range_scope = { otu_id: (otu1.id..otu1.id).to_a }
        d = Export::Dwca::ChecklistData.new(core_scope: range_scope)
        expect(d.total).to eq(1)
        d.cleanup
      end
    end

    context 'with infraspecific taxa at different ranks' do
      # Test case: same infraspecific epithet at different ranks should create distinct taxa
      # e.g., "Aus bus subsp. cus" and "Aus bus var. cus" are different taxa
      let!(:root) { FactoryBot.create(:root_taxon_name) }
      let!(:kingdom) { Protonym.create!(name: 'Plantae', rank_class: Ranks.lookup(:icn, :kingdom), parent: root) }
      let!(:family) { Protonym.create!(name: 'Rosaceae', rank_class: Ranks.lookup(:icn, :family), parent: kingdom) }
      let!(:genus) { Protonym.create!(name: 'Rosa', rank_class: Ranks.lookup(:icn, :genus), parent: family) }
      let!(:species) { Protonym.create!(name: 'alba', rank_class: Ranks.lookup(:icn, :species), parent: genus) }
      let!(:subspecies) { Protonym.create!(name: 'rubra', rank_class: Ranks.lookup(:icn, :subspecies), parent: species) }
      let!(:variety) { Protonym.create!(name: 'rubra', rank_class: Ranks.lookup(:icn, :variety), parent: species) }

      let!(:otu_species) { FactoryBot.create(:valid_otu, taxon_name: species) }
      let!(:otu_subspecies) { FactoryBot.create(:valid_otu, taxon_name: subspecies) }
      let!(:otu_variety) { FactoryBot.create(:valid_otu, taxon_name: variety) }

      before do
        # Create specimens for each OTU
        [otu_species, otu_subspecies, otu_variety].each do |otu|
          specimen = FactoryBot.create(:valid_specimen)
          FactoryBot.create(:valid_taxon_determination, otu: otu, taxon_determination_object: specimen)
          specimen.get_dwc_occurrence
        end
      end

      let(:infra_scope) { { otu_id: [otu_species.id, otu_subspecies.id, otu_variety.id] } }
      let(:infra_data) { Export::Dwca::ChecklistData.new(core_scope: infra_scope) }
      let(:infra_csv) { CSV.parse(infra_data.csv, headers: true, col_sep: "\t") }

      after { infra_data.cleanup }

      specify 'subspecies and variety with same epithet create distinct taxa' do
        # Find the subspecies and variety taxa
        subspecies_taxon = infra_csv.find { |row| row['taxonRank'] == 'subspecies' }
        variety_taxon = infra_csv.find { |row| row['taxonRank'] == 'variety' }

        # Both should exist
        expect(subspecies_taxon).to be_present
        expect(variety_taxon).to be_present

        # They should have different taxonIDs
        expect(subspecies_taxon['taxonID']).not_to eq(variety_taxon['taxonID'])

        # They should have different scientificNames (one with "subsp.", one with "var.")
        expect(subspecies_taxon['scientificName']).not_to eq(variety_taxon['scientificName'])

        # Both should have same infraspecificEpithet
        expect(subspecies_taxon['infraspecificEpithet']).to eq('rubra')
        expect(variety_taxon['infraspecificEpithet']).to eq('rubra')
      end

      specify 'subspecies and variety both have species as parent' do
        # Find species taxon
        species_taxon = infra_csv.find { |row| row['taxonRank'] == 'species' && row['scientificName'].include?('alba') }
        species_id = species_taxon['taxonID']

        # Find subspecies and variety
        subspecies_taxon = infra_csv.find { |row| row['taxonRank'] == 'subspecies' }
        variety_taxon = infra_csv.find { |row| row['taxonRank'] == 'variety' }

        # Both should have species as parent
        expect(subspecies_taxon['parentNameUsageID']).to eq(species_id)
        expect(variety_taxon['parentNameUsageID']).to eq(species_id)
      end

      specify 'total unique taxa includes both infraspecific ranks' do
        # Should have at least: kingdom, family, genus, species, subspecies, variety
        expect(infra_csv.count).to be >= 6

        # Should have exactly one subspecies and one variety
        subspecies_count = infra_csv.count { |row| row['taxonRank'] == 'subspecies' }
        variety_count = infra_csv.count { |row| row['taxonRank'] == 'variety' }

        expect(subspecies_count).to eq(1)
        expect(variety_count).to eq(1)
      end

      specify 'epithet fields are correctly populated by rank' do
        # Species: should have specificEpithet but NOT infraspecificEpithet
        species_taxon = infra_csv.find { |row| row['taxonRank'] == 'species' && row['scientificName'].include?('alba') }
        expect(species_taxon).to be_present
        expect(species_taxon['specificEpithet']).to eq('alba')
        expect(species_taxon['infraspecificEpithet']).to be_nil.or be_empty

        # Subspecies: should have BOTH specificEpithet and infraspecificEpithet
        subspecies_taxon = infra_csv.find { |row| row['taxonRank'] == 'subspecies' }
        expect(subspecies_taxon).to be_present
        expect(subspecies_taxon['specificEpithet']).to eq('alba')
        expect(subspecies_taxon['infraspecificEpithet']).to eq('rubra')

        # Variety: should have BOTH specificEpithet and infraspecificEpithet
        variety_taxon = infra_csv.find { |row| row['taxonRank'] == 'variety' }
        expect(variety_taxon).to be_present
        expect(variety_taxon['specificEpithet']).to eq('alba')
        expect(variety_taxon['infraspecificEpithet']).to eq('rubra')

        # Genus: should have NEITHER specificEpithet nor infraspecificEpithet
        genus_taxon = infra_csv.find { |row| row['taxonRank'] == 'genus' && row['scientificName'] == 'Rosa' }
        expect(genus_taxon).to be_present
        expect(genus_taxon['specificEpithet']).to be_nil.or be_empty
        expect(genus_taxon['infraspecificEpithet']).to be_nil.or be_empty

        # Family: should have NEITHER specificEpithet nor infraspecificEpithet
        family_taxon = infra_csv.find { |row| row['taxonRank'] == 'family' }
        expect(family_taxon).to be_present
        expect(family_taxon['specificEpithet']).to be_nil.or be_empty
        expect(family_taxon['infraspecificEpithet']).to be_nil.or be_empty
      end
    end
  end
end