require 'rails_helper'

describe Export::Dwca::ChecklistData, type: :model, group: :darwin_core do

  let!(:otu1) { FactoryBot.create(:valid_otu) }
  let!(:otu2) { FactoryBot.create(:valid_otu) }
  let!(:otu3) { FactoryBot.create(:valid_otu) }
  let!(:otu4) { FactoryBot.create(:valid_otu) } # Not this one

  let(:otu_scope) { { otu_id: [otu1.id, otu2.id, otu3.id] } }

  context 'when initialized with a scope' do
    let(:data) { Export::Dwca::ChecklistData.new(core_otu_scope_params: otu_scope) }

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
      let!(:family2) { Protonym.create!(name: 'Gracillariidae', rank_class: Ranks.lookup(:iczn, :family), parent: order) }
      let!(:genus) { Protonym.create!(name: 'Aus', rank_class: Ranks.lookup(:iczn, :genus), parent: family) }
      let!(:genus2) { Protonym.create!(name: 'Fus', rank_class: Ranks.lookup(:iczn, :genus), parent: family) }
      let!(:taxon_name1) { Protonym.create!(name: 'bus', rank_class: Ranks.lookup(:iczn, :species), parent: genus) }
      let!(:taxon_name2) { Protonym.create!(name: 'cus', rank_class: Ranks.lookup(:iczn, :species), parent: genus) }
      let!(:taxon_name3) { Protonym.create!(name: 'dus', rank_class: Ranks.lookup(:iczn, :species), parent: genus) }

      before do
        otu1.update!(taxon_name: taxon_name1)
        otu2.update!(taxon_name: taxon_name2)
        otu3.update!(taxon_name: taxon_name3)

        3.times do |i|
          otu = [otu1, otu2, otu3][i]
          specimen = FactoryBot.create(:valid_specimen)
          FactoryBot.create(:valid_taxon_determination,
            otu: otu,
            taxon_determination_object: specimen)
          specimen.get_dwc_occurrence
        end
      end

      let(:csv) { CSV.parse(data.csv, headers: true, col_sep: "\t") }

      specify '#total returns count of DwcOccurrences' do
        expect(data.total).to eq(3)
      end

      specify '#no_records? returns false when records exist' do
        expect(data.no_records?).to be_falsey
      end

      specify '#csv returns normalized taxonomy (more rows than occurrences)' do
        # With 3 species from same genus/family/etc., we expect:
        # kingdom, phylum, class, order, family, genus, and 3 species = 9 unique taxa
        expect(csv.count).to eq(9)
      end

      context 'CSV headers and column conversions' do
        specify 'id is the first column (for DwC-A star joins)' do
          expect(csv.headers.first).to eq('id')
        end

        specify 'taxonID is the second column' do
          expect(csv.headers[1]).to eq('taxonID')
        end

        specify 'id and taxonID have the same values' do
          csv.each do |row|
            expect(row['id']).to eq(row['taxonID'])
          end
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

        specify 'empty columns are removed from output' do
          csv.headers.each do |header|
            # Required columns are allowed to be empty
            next if ['id', 'taxonID', 'scientificName', 'taxonRank'].include?(header)

            # Check that this column has at least one non-empty value
            has_value = csv.any? { |row| row[header].present? }
            expect(has_value).to be(true),
              "Column '#{header}' is completely empty and should have been removed"
          end
        end
      end

      context 'normalized taxonomy structure' do
        specify 'all original scientificNames are preserved in output' do
          # Get all scientificNames from the source DwcOccurrence records
          source_names = data.core_occurrence_scope.pluck(:scientificName).uniq.compact
          output_names = csv.map { |row| row['scientificName'] }.compact

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

        specify 'parentNameUsageID header is present' do
          expect(csv.headers).to include('parentNameUsageID')
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

          # The parent should be the genus with matching genus name
          parent_id = species['parentNameUsageID'].to_i
          genus = csv.find { |row| row['taxonID'].to_i == parent_id }
          expect(genus['taxonRank']).to eq('genus')
          expect(genus['scientificName']).to eq(species['genus'])
        end

        specify 'intermediate ranks not in DwC are skipped when assigning parents' do
          # Test that taxa with intermediate parent ranks get correct
          # parentNameUsageID pointing to the next available ancestor, even with
          # multiple consecutive intermediate ranks.

          # Create hierarchy with TWO consecutive intermediate ranks:
          # Animalia > Arthropoda (phylum) > Hexapoda (subphylum) >
          # Pancrustacea (superclass) > Insecta (class) > Hemiptera (order)
          phylum_hex = Protonym.create!(name: 'Arthropodasubphylum', rank_class: Ranks.lookup(:iczn, :phylum), parent: kingdom)
          subphylum = Protonym.create!(name: 'Hexapoda', rank_class: Ranks.lookup(:iczn, :subphylum), parent: phylum_hex)
          superclass = Protonym.create!(name: 'Pancrustacea', rank_class: Ranks.lookup(:iczn, :superclass), parent: subphylum)
          class_hex = Protonym.create!(name: 'Insectasubphylum', rank_class: Ranks.lookup(:iczn, :class), parent: superclass)
          order_hex = Protonym.create!(name: 'Hemiptera', rank_class: Ranks.lookup(:iczn, :order), parent: class_hex)
          family_hex = Protonym.create!(name: 'Cercopidae', rank_class: Ranks.lookup(:iczn, :family), parent: order_hex)
          genus_hex = Protonym.create!(name: 'Cercopis', rank_class: Ranks.lookup(:iczn, :genus), parent: family_hex)
          species_hex = Protonym.create!(name: 'testus', rank_class: Ranks.lookup(:iczn, :species), parent: genus_hex)

          otu_hex = FactoryBot.create(:valid_otu, taxon_name: species_hex)
          specimen = FactoryBot.create(:valid_specimen)
          FactoryBot.create(:valid_taxon_determination, otu: otu_hex, taxon_determination_object: specimen)
          specimen.get_dwc_occurrence

          # Export with this new OTU included
          data_hex = Export::Dwca::ChecklistData.new(core_otu_scope_params: { otu_id: [otu_hex.id] })
          csv_hex = CSV.parse(data_hex.csv, headers: true, col_sep: "\t")

          # Find the class in the export
          class_row = csv_hex.find { |row| row['scientificName'] == 'Insectasubphylum' && row['taxonRank'] == 'class' }
          expect(class_row).to be_present

          # Find the phylum in the export
          phylum_row = csv_hex.find { |row| row['scientificName'] == 'Arthropodasubphylum' && row['taxonRank'] == 'phylum' }
          expect(phylum_row).to be_present

          # Neither intermediate rank should be in export
          hexapoda = csv_hex.find { |row| row['scientificName'] == 'Hexapoda' }
          expect(hexapoda).to be_nil
          pancrustacea = csv_hex.find { |row| row['scientificName'] == 'Pancrustacea' }
          expect(pancrustacea).to be_nil

          # Class's parent should be phylum (skipping over BOTH subphylum and superclass)
          expect(class_row['parentNameUsageID']).to eq(phylum_row['taxonID'])
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

      context 'extracted higher taxa field clearing' do
        # Add some taxon-specific data to the DwcOccurrences to test field clearing.
        before do
          data.core_occurrence_scope.each do |dwc|
            dwc.update!(
              scientificNameAuthorship: 'Smith, 1850',
              namePublishedIn: 'Journal of Taxonomy',
              namePublishedInYear: '1850',
              taxonomicStatus: 'accepted',
              nomenclaturalStatus: 'valid',
              taxonRemarks: 'Common species',
              vernacularName: 'Common Name'
            )
          end
        end

        specify 'extracted higher taxon clears taxon-specific fields from terminal taxon' do
          # Find an extracted genus (higher than the terminal species)
          genus = csv.find { |row| row['taxonRank'] == 'genus' }

          # These fields should be cleared (came from terminal species)
          expect(genus['scientificNameAuthorship']).to be_nil.or be_empty
          expect(genus['namePublishedIn']).to be_nil.or be_empty
          expect(genus['namePublishedInYear']).to be_nil.or be_empty
          expect(genus['taxonomicStatus']).to be_nil.or be_empty
          expect(genus['nomenclaturalStatus']).to be_nil.or be_empty
          expect(genus['taxonRemarks']).to be_nil.or be_empty
          expect(genus['vernacularName']).to be_nil.or be_empty
        end

        specify 'terminal taxon retains all its taxon-specific fields' do
          # Find a terminal species taxon (not extracted, original).
          species = csv.find { |row| row['taxonRank'] == 'species' }

          # These fields should be retained for the terminal taxon.
          expect(species['scientificNameAuthorship']).to eq('Smith, 1850')
          expect(species['namePublishedIn']).to eq('Journal of Taxonomy')
          expect(species['namePublishedInYear']).to eq('1850')
          expect(species['taxonomicStatus']).to eq('accepted')
        end

        specify 'extracted higher taxon has recomputed higherClassification' do
          genus = csv.find { |row| row['taxonRank'] == 'genus' }

          # higherClassification should be recomputed from rank columns above genus
          # Should include kingdom, phylum, class, order, family (in that order)
          expected_parts = [
            genus['kingdom'],
            genus['phylum'],
            genus['class'],
            genus['order'],
            genus['family']
          ].compact.reject(&:empty?)

          expect(genus['higherClassification']).to eq(expected_parts.join(Export::Dwca::DELIMITER))
        end

        specify 'terminal taxon keeps original higherClassification' do
          # Get the original higherClassification from a DwcOccurrence
          original = data.core_occurrence_scope.first
          original_classification = original.higherClassification

          # Find the corresponding species in output
          species = csv.find { |row|
            row['scientificName'] == original.scientificName &&
            row['taxonRank'] == original.taxonRank&.downcase
          }

          expect(species['higherClassification']).to eq(original_classification)
        end

        specify 'extracted higher taxon clears epithet fields for non-species ranks' do
          genus = csv.find { |row| row['taxonRank'] == 'genus' }
          expect(genus['specificEpithet']).to be_nil.or be_empty
          expect(genus['infraspecificEpithet']).to be_nil.or be_empty
        end

        specify 'extracted higher taxon clears rank columns below its rank' do
          family = csv.find { |row| row['taxonRank'] == 'family' }

          expect(family['genus']).to be_nil.or be_empty
          expect(family['subgenus']).to be_nil.or be_empty
        end

        specify 'extracted higher taxon retains rank columns at and above its rank' do
          genus = csv.find { |row| row['taxonRank'] == 'genus' }

          expect(genus['kingdom']).to eq('Animalia')
          expect(genus['phylum']).to eq('Arthropoda')
          expect(genus['class']).to eq('Insecta')
          expect(genus['order']).to eq('Lepidoptera')
          expect(genus['family']).to eq('Noctuidae')
          expect(genus['genus']).to eq('Aus')
        end
      end

      specify '#meta_fields returns headers without id column' do
        meta_fields = data.meta_fields
        # taxonID is the renamed id column in the CSV, but meta_fields returns
        # the pre-header-conversion names.
        expect(meta_fields).not_to include('id')
        expect(meta_fields).to include('scientificName')
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

      context 'with distribution extension' do
        # Create asserted distributions for testing
        let!(:asserted_distribution1) { FactoryBot.create(:valid_asserted_distribution, asserted_distribution_object: otu1) }
        let!(:asserted_distribution2) { FactoryBot.create(:valid_asserted_distribution, asserted_distribution_object: otu2) }

        before do
          asserted_distribution1.get_dwc_occurrence
          asserted_distribution2.get_dwc_occurrence
        end

        let(:data_with_extension) { Export::Dwca::ChecklistData.new(core_otu_scope_params: otu_scope, extensions: [Export::Dwca::ChecklistData::DISTRIBUTION_EXTENSION]) }
        let(:data_without_extension) { Export::Dwca::ChecklistData.new(core_otu_scope_params: otu_scope, extensions: []) }

        specify 'distribution_extension flag is set when extension is requested' do
          expect(data_with_extension.species_distribution_extension).to be true
          expect(data_without_extension.species_distribution_extension).to be false
        end

        specify 'distribution_extension_tmp returns nil when extension not requested' do
          expect(data_without_extension.species_distribution_extension_tmp).to be_nil
        end

        specify 'distribution_extension_tmp returns Tempfile when extension requested' do
          expect(data_with_extension.species_distribution_extension_tmp).to be_a(Tempfile)
        end

        specify 'distribution extension CSV has correct headers' do
          # Generate core CSV first to populate taxon_name_to_id mapping.
          data_with_extension.csv

          csv_content = data_with_extension.species_distribution_extension_tmp.read
          csv = CSV.parse(csv_content, headers: true, col_sep: "\t")

          expect(csv.headers).to eq(['id', 'locality', 'occurrenceStatus', 'source'])
        end

        specify 'distribution extension includes AssertedDistribution records' do
          # Generate core CSV first to populate taxon_name_to_id mapping.
          data_with_extension.csv

          csv_content = data_with_extension.species_distribution_extension_tmp.read
          csv = CSV.parse(csv_content, headers: true, col_sep: "\t")

          # Should have 2 records (one for each asserted distribution)
          expect(csv.length).to eq 2
        end

        specify 'distribution extension uses taxonID from normalized taxonomy' do
          # Generate core CSV first to populate taxon_name_to_id mapping.
          data_with_extension.csv

          csv_content = data_with_extension.species_distribution_extension_tmp.read
          dist_csv = CSV.parse(csv_content, headers: true, col_sep: "\t")

          # All id values should be present (not nil)
          dist_csv.each do |row|
            expect(row['id']).to be_present
            expect(row['id'].to_i).to be > 0
          end
        end

        specify 'distribution extension includes occurrenceStatus' do
          # Generate core CSV first to populate taxon_name_to_id mapping.
          data_with_extension.csv

          csv_content = data_with_extension.species_distribution_extension_tmp.read
          dist_csv = CSV.parse(csv_content, headers: true, col_sep: "\t")

          dist_csv.each do |row|
            expect(['present', 'absent']).to include(row['occurrenceStatus'])
          end
        end

        specify 'zipfile includes distribution.tsv when extension enabled' do
          zipfile = data_with_extension.zipfile
          Zip::File.open(zipfile.path) do |zip|
            expect(zip.find_entry('species_distribution.tsv')).to be_present
          end
        end

        specify 'zipfile does not include distribution.tsv when extension disabled' do
          zipfile = data_without_extension.zipfile
          Zip::File.open(zipfile.path) do |zip|
            expect(zip.find_entry('species_distribution.tsv')).to be_nil
          end
        end

        specify 'meta.xml includes distribution extension when enabled' do
          meta_content = data_with_extension.meta.read

          expect(meta_content).to include('species_distribution.tsv')
          expect(meta_content).to include('http://rs.gbif.org/terms/1.0/Distribution')
        end

        specify 'meta.xml does not include distribution extension when disabled' do
          meta_content = data_without_extension.meta.read

          expect(meta_content).not_to include('species_distribution.tsv')
          expect(meta_content).not_to include('http://rs.gbif.org/terms/1.0/Distribution')
        end

        specify 'distribution extension rows star-join to correct core taxa with matching occurrence data' do
          core_content = data_with_extension.csv
          extension_content = data_with_extension.species_distribution_extension_tmp.read

          core_csv = CSV.parse(core_content, headers: true, col_sep: "\t")
          extension_csv = CSV.parse(extension_content, headers: true, col_sep: "\t")

          ext_row = extension_csv.first

          data_row = core_csv.find { |row| row['taxonID'] == ext_row['id'] }

          # Match data row's scientificName to one of our two occurrences.
          scientific_name = data_row['scientificName']
          dwc_occ = if otu1.taxon_name.cached == scientific_name
                      asserted_distribution1.dwc_occurrence
                    elsif otu2.taxon_name.cached == scientific_name
                      asserted_distribution2.dwc_occurrence
                    end

          expected_locality = dwc_occ.locality.presence || [
            dwc_occ.country,
            dwc_occ.stateProvince,
            dwc_occ.county
          ].compact.reject(&:empty?).join(', ').presence

          expect(ext_row['locality']).to eq(expected_locality) if expected_locality
          expect(ext_row['occurrenceStatus']).to eq(dwc_occ.occurrenceStatus)
        end

        specify 'locality is populated for regional GeographicArea that does not map to country/state/county' do
          # Create a regional area.
          regional_area = FactoryBot.create(:valid_geographic_area,
            name: 'West Tropical Africa')

          regional_otu = FactoryBot.create(:valid_otu, taxon_name: taxon_name1)

          regional_ad = FactoryBot.create(:valid_asserted_distribution,
            asserted_distribution_object: regional_otu,
            asserted_distribution_shape: regional_area)

          # Mock geographic_names to return empty hash (simulating a TDWG area that
          # doesn't map to country/state/county).
          allow(regional_ad).to receive(:geographic_names).and_return({})

          regional_ad.get_dwc_occurrence

          regional_data = Export::Dwca::ChecklistData.new(
            core_otu_scope_params: { otu_id: [regional_otu.id] },
            extensions: [Export::Dwca::ChecklistData::DISTRIBUTION_EXTENSION]
          )

          # Generate core CSV to populate taxon mapping.
          regional_data.csv

          csv_content = regional_data.species_distribution_extension_tmp.read
          dist_csv = CSV.parse(csv_content, headers: true, col_sep: "\t")

          expect(dist_csv.length).to eq 1

          row = dist_csv.first
          expect(row['locality']).to eq('West Tropical Africa')
        end

        specify 'locality is populated for Gazetteer' do
          gazetteer = FactoryBot.create(:valid_gazetteer, name: 'Custom Region XYZ')

          gaz_otu = FactoryBot.create(:valid_otu, taxon_name: taxon_name2)

          gaz_ad = FactoryBot.create(:valid_gazetteer_asserted_distribution,
            asserted_distribution_object: gaz_otu,
            asserted_distribution_shape: gazetteer)
          gaz_ad.get_dwc_occurrence

          gaz_data = Export::Dwca::ChecklistData.new(
            core_otu_scope_params: { otu_id: [gaz_otu.id] },
            extensions: [Export::Dwca::ChecklistData::DISTRIBUTION_EXTENSION]
          )

          # Generate core CSV to populate taxon mapping.
          gaz_data.csv

          csv_content = gaz_data.species_distribution_extension_tmp.read
          dist_csv = CSV.parse(csv_content, headers: true, col_sep: "\t")

          expect(dist_csv.length).to eq 1

          row = dist_csv.first
          expect(row['locality']).to eq('Custom Region XYZ')
        end
      end

      context 'with references extension' do
        let!(:source1) { FactoryBot.create(:valid_source) }
        let!(:source2) { FactoryBot.create(:valid_source) }

        let!(:ad_with_refs1) { FactoryBot.create(:valid_asserted_distribution, asserted_distribution_object: otu1) }
        let!(:ad_with_refs2) { FactoryBot.create(:valid_asserted_distribution, asserted_distribution_object: otu2) }

        before do
          FactoryBot.create(:valid_citation, citation_object: ad_with_refs1, source: source1)
          FactoryBot.create(:valid_citation, citation_object: ad_with_refs1, source: source2)
          FactoryBot.create(:valid_citation, citation_object: ad_with_refs2, source: source1)

          ad_with_refs1.get_dwc_occurrence
          ad_with_refs2.get_dwc_occurrence
        end

        let(:data_with_extension) { Export::Dwca::ChecklistData.new(core_otu_scope_params: otu_scope, extensions: [Export::Dwca::ChecklistData::REFERENCES_EXTENSION]) }
        let(:data_without_extension) { Export::Dwca::ChecklistData.new(core_otu_scope_params: otu_scope, extensions: []) }

        specify 'references_extension flag is set when extension is requested' do
          expect(data_with_extension.references_extension).to be true
          expect(data_without_extension.references_extension).to be false
        end

        specify 'references_extension_tmp returns nil when extension not requested' do
          expect(data_without_extension.references_extension_tmp).to be_nil
        end

        specify 'references_extension_tmp returns Tempfile when extension requested' do
          expect(data_with_extension.references_extension_tmp).to be_a(Tempfile)
        end

        specify 'references extension CSV has correct headers' do
          # Generate core CSV first to populate taxon_name_to_id mapping
          data_with_extension.csv

          csv_content = data_with_extension.references_extension_tmp.read
          csv = CSV.parse(csv_content, headers: true, col_sep: "\t")

          expect(csv.headers).to eq(['id', 'bibliographicCitation'])
        end

        specify 'references extension splits multiple citations into separate rows' do
          # Generate core CSV first to populate taxon_name_to_id mapping
          data_with_extension.csv

          csv_content = data_with_extension.references_extension_tmp.read
          csv = CSV.parse(csv_content, headers: true, col_sep: "\t")

          expect(csv.length).to eq 2
        end

        specify 'references extension uses taxonID from normalized taxonomy' do
          # Generate core CSV first to populate taxon_name_to_id mapping
          data_with_extension.csv

          csv_content = data_with_extension.references_extension_tmp.read
          refs_csv = CSV.parse(csv_content, headers: true, col_sep: "\t")

          refs_csv.each do |row|
            expect(row['id']).to be_present
            expect(row['id'].to_i).to be > 0
          end
        end

        specify 'references extension includes bibliographicCitation' do
          # Generate core CSV first to populate taxon_name_to_id mapping
          data_with_extension.csv

          csv_content = data_with_extension.references_extension_tmp.read
          refs_csv = CSV.parse(csv_content, headers: true, col_sep: "\t")

          refs_csv.each do |row|
            expect(row['bibliographicCitation']).to be_present
          end
        end

        specify 'zipfile includes references.tsv when extension enabled' do
          zipfile = data_with_extension.zipfile
          Zip::File.open(zipfile.path) do |zip|
            expect(zip.find_entry('references.tsv')).to be_present
          end
        end

        specify 'zipfile does not include references.tsv when extension disabled' do
          zipfile = data_without_extension.zipfile
          Zip::File.open(zipfile.path) do |zip|
            expect(zip.find_entry('references.tsv')).to be_nil
          end
        end

        specify 'meta.xml includes references extension when enabled' do
          meta_content = data_with_extension.meta.read
          data_with_extension.meta.rewind

          expect(meta_content).to include('references.tsv')
          expect(meta_content).to include('http://rs.gbif.org/terms/1.0/Reference')
        end

        specify 'meta.xml does not include references extension when disabled' do
          meta_content = data_without_extension.meta.read
          data_without_extension.meta.rewind

          expect(meta_content).not_to include('references.tsv')
          expect(meta_content).not_to include('http://rs.gbif.org/terms/1.0/Reference')
        end

        specify 'references extension rows star-join to correct core taxa with matching citation data' do
          core_content = data_with_extension.csv
          extension_content = data_with_extension.references_extension_tmp.read

          core_csv = CSV.parse(core_content, headers: true, col_sep: "\t")
          extension_csv = CSV.parse(extension_content, headers: true, col_sep: "\t")

          ext_row = extension_csv.first

          # Find matching data.tsv row by taxonID (star schema join).
          data_row = core_csv.find { |row| row['taxonID'] == ext_row['id'] }

          # Match data row's scientificName to one of our two OTUs.
          scientific_name = data_row['scientificName']
          dwc_occ = if otu1.taxon_name.cached == scientific_name
                      ad_with_refs1.dwc_occurrence
                    elsif otu2.taxon_name.cached == scientific_name
                      ad_with_refs2.dwc_occurrence
                    end

          expect(ext_row['bibliographicCitation']).to be_present
          expect(dwc_occ.associatedReferences).to include(ext_row['bibliographicCitation'])
        end
      end

      context 'with types and specimen extension' do
        let!(:holotype_specimen) { FactoryBot.create(:valid_specimen) }
        let!(:paratype_specimen) { FactoryBot.create(:valid_specimen) }

        before do
          FactoryBot.create(:valid_taxon_determination, otu: otu1, taxon_determination_object: holotype_specimen)
          FactoryBot.create(:valid_taxon_determination, otu: otu2, taxon_determination_object: paratype_specimen)

          FactoryBot.create(:valid_type_material, protonym: taxon_name1, collection_object: holotype_specimen, type_type: 'holotype')
          FactoryBot.create(:valid_type_material, protonym: taxon_name2, collection_object: paratype_specimen, type_type: 'paratype')

          holotype_specimen.get_dwc_occurrence
          paratype_specimen.get_dwc_occurrence
        end

        let(:data_with_extension) { Export::Dwca::ChecklistData.new(core_otu_scope_params: otu_scope, extensions: [Export::Dwca::ChecklistData::TYPES_AND_SPECIMEN_EXTENSION]) }
        let(:data_without_extension) { Export::Dwca::ChecklistData.new(core_otu_scope_params: otu_scope, extensions: []) }

        specify 'types_and_specimen_extension flag is set when extension is requested' do
          expect(data_with_extension.types_and_specimen_extension).to be true
          expect(data_without_extension.types_and_specimen_extension).to be false
        end

        specify 'types_and_specimen_extension_tmp returns nil when extension not requested' do
          expect(data_without_extension.types_and_specimen_extension_tmp).to be_nil
        end

        specify 'types_and_specimen_extension_tmp returns Tempfile when extension requested' do
          expect(data_with_extension.types_and_specimen_extension_tmp).to be_a(Tempfile)
        end

        specify 'types and specimen extension CSV has correct headers' do
          # Generate core CSV first to populate taxon_name_to_id mapping
          data_with_extension.csv

          csv_content = data_with_extension.types_and_specimen_extension_tmp.read
          csv = CSV.parse(csv_content, headers: true, col_sep: "\t")

          expected_headers = ['id', 'typeStatus', 'scientificName', 'taxonRank', 'occurrenceID',
                            'institutionCode', 'collectionCode', 'catalogNumber', 'locality',
                            'sex', 'recordedBy', 'verbatimEventDate']
          expect(csv.headers).to eq(expected_headers)
        end

        specify 'types and specimen extension only includes CollectionObject records' do
          # Generate core CSV first to populate taxon_name_to_id mapping
          data_with_extension.csv

          csv_content = data_with_extension.types_and_specimen_extension_tmp.read
          csv = CSV.parse(csv_content, headers: true, col_sep: "\t")

          expect(csv.length).to eq 2
        end

        specify 'types and specimen extension uses taxonID from normalized taxonomy' do
          # Generate core CSV first to populate taxon_name_to_id mapping
          data_with_extension.csv

          csv_content = data_with_extension.types_and_specimen_extension_tmp.read
          types_csv = CSV.parse(csv_content, headers: true, col_sep: "\t")

          types_csv.each do |row|
            expect(row['id']).to be_present
            expect(row['id'].to_i).to be > 0
          end
        end

        specify 'types and specimen extension includes typeStatus' do
          # Generate core CSV first to populate taxon_name_to_id mapping
          data_with_extension.csv

          csv_content = data_with_extension.types_and_specimen_extension_tmp.read
          types_csv = CSV.parse(csv_content, headers: true, col_sep: "\t")

          types_csv.each do |row|
            expect(row['typeStatus']).to be_present
          end
        end

        specify 'zipfile includes types_and_specimen.tsv when extension enabled' do
          zipfile = data_with_extension.zipfile
          Zip::File.open(zipfile.path) do |zip|
            expect(zip.find_entry('types_and_specimen.tsv')).to be_present
          end
        end

        specify 'zipfile does not include types_and_specimen.tsv when extension disabled' do
          zipfile = data_without_extension.zipfile
          Zip::File.open(zipfile.path) do |zip|
            expect(zip.find_entry('types_and_specimen.tsv')).to be_nil
          end
        end

        specify 'meta.xml includes types and specimen extension when enabled' do
          meta_content = data_with_extension.meta.read

          expect(meta_content).to include('types_and_specimen.tsv')
          expect(meta_content).to include('http://rs.gbif.org/terms/1.0/TypesAndSpecimen')
        end

        specify 'meta.xml does not include types and specimen extension when disabled' do
          meta_content = data_without_extension.meta.read

          expect(meta_content).not_to include('types_and_specimen.tsv')
          expect(meta_content).not_to include('http://rs.gbif.org/terms/1.0/TypesAndSpecimen')
        end

        specify 'types and specimen extension rows star-join to correct core taxa with matching type material data' do
          core_content = data_with_extension.csv
          extension_content = data_with_extension.types_and_specimen_extension_tmp.read

          core_csv = CSV.parse(core_content, headers: true, col_sep: "\t")
          extension_csv = CSV.parse(extension_content, headers: true, col_sep: "\t")

          ext_row = extension_csv.first

          data_row = core_csv.find { |row| row['taxonID'] == ext_row['id'] }

          # Match data row's scientificName to one of our two specimens.
          scientific_name = data_row['scientificName']
          dwc_occ = if otu1.taxon_name.cached == scientific_name
                      holotype_specimen.dwc_occurrence
                    elsif otu2.taxon_name.cached == scientific_name
                      paratype_specimen.dwc_occurrence
                    end

          expect(ext_row['typeStatus']).to eq(dwc_occ.typeStatus)
          expect(ext_row['scientificName']).to eq(data_row['scientificName'])
        end
      end

      context 'with vernacular name extension' do
        let!(:language_en) { FactoryBot.create(:valid_language, alpha_2: 'en') }
        let!(:language_es) { FactoryBot.create(:valid_language, alpha_2: 'es') }

        let!(:common_name1) { FactoryBot.create(:valid_common_name, otu: otu1, name: 'Common Butterfly', language: language_en, start_year: 2000) }
        let!(:common_name2) { FactoryBot.create(:valid_common_name, otu: otu1, name: 'Mariposa Común', language: language_es) }
        let!(:common_name3) { FactoryBot.create(:valid_common_name, otu: otu2, name: 'Red Moth', language: language_en, start_year: 1950, end_year: 2020) }

        let(:data_with_extension) { Export::Dwca::ChecklistData.new(core_otu_scope_params: otu_scope, extensions: [Export::Dwca::ChecklistData::VERNACULAR_NAME_EXTENSION]) }
        let(:data_without_extension) { Export::Dwca::ChecklistData.new(core_otu_scope_params: otu_scope, extensions: []) }

        specify 'vernacular_name_extension flag is set when extension is requested' do
          expect(data_with_extension.vernacular_name_extension).to be true
          expect(data_without_extension.vernacular_name_extension).to be false
        end

        specify 'vernacular_name_extension_tmp returns nil when extension not requested' do
          expect(data_without_extension.vernacular_name_extension_tmp).to be_nil
        end

        specify 'vernacular_name_extension_tmp returns Tempfile when extension requested' do
          expect(data_with_extension.vernacular_name_extension_tmp).to be_a(Tempfile)
        end

        specify 'vernacular name extension CSV has correct headers' do
          # Generate core CSV first to populate taxon_name_to_id mapping
          data_with_extension.csv

          csv_content = data_with_extension.vernacular_name_extension_tmp.read
          csv = CSV.parse(csv_content, headers: true, col_sep: "\t")

          expect(csv.headers).to eq(['id', 'vernacularName', 'language', 'temporal'])
        end

        specify 'vernacular name extension includes all common names' do
          # Generate core CSV first to populate taxon_name_to_id mapping
          data_with_extension.csv

          csv_content = data_with_extension.vernacular_name_extension_tmp.read
          csv = CSV.parse(csv_content, headers: true, col_sep: "\t")

          expect(csv.length).to eq(3)
        end

        specify 'vernacular name extension uses taxonID from normalized taxonomy' do
          # Generate core CSV first to populate taxon_name_to_id mapping
          data_with_extension.csv

          csv_content = data_with_extension.vernacular_name_extension_tmp.read
          vn_csv = CSV.parse(csv_content, headers: true, col_sep: "\t")

          vn_csv.each do |row|
            expect(row['id']).to be_present
            expect(row['id'].to_i).to be > 0
          end
        end

        specify 'vernacular name extension includes vernacularName' do
          # Generate core CSV first to populate taxon_name_to_id mapping
          data_with_extension.csv

          csv_content = data_with_extension.vernacular_name_extension_tmp.read
          vn_csv = CSV.parse(csv_content, headers: true, col_sep: "\t")

          names = vn_csv.map { |row| row['vernacularName'] }
          expect(names).to include('Common Butterfly', 'Mariposa Común', 'Red Moth')
        end

        specify 'vernacular name extension includes language codes' do
          # Generate core CSV first to populate taxon_name_to_id mapping
          data_with_extension.csv

          csv_content = data_with_extension.vernacular_name_extension_tmp.read
          vn_csv = CSV.parse(csv_content, headers: true, col_sep: "\t")

          languages = vn_csv.map { |row| row['language'] }.uniq.compact
          expect(languages).to include('en', 'es')
        end

        specify 'vernacular name extension includes temporal information' do
          # Generate core CSV first to populate taxon_name_to_id mapping
          data_with_extension.csv

          csv_content = data_with_extension.vernacular_name_extension_tmp.read
          vn_csv = CSV.parse(csv_content, headers: true, col_sep: "\t")

          red_moth_row = vn_csv.find { |row| row['vernacularName'] == 'Red Moth' }
          expect(red_moth_row['temporal']).to eq('1950-2020')

          butterfly_row = vn_csv.find { |row| row['vernacularName'] == 'Common Butterfly' }
          expect(butterfly_row['temporal']).to eq('2000')
        end

        specify 'zipfile includes vernacular_name.tsv when extension enabled' do
          zipfile = data_with_extension.zipfile
          Zip::File.open(zipfile.path) do |zip|
            expect(zip.find_entry('vernacular_name.tsv')).to be_present
          end
        end

        specify 'zipfile does not include vernacular_name.tsv when extension disabled' do
          zipfile = data_without_extension.zipfile
          Zip::File.open(zipfile.path) do |zip|
            expect(zip.find_entry('vernacular_name.tsv')).to be_nil
          end
        end

        specify 'meta.xml includes vernacular name extension when enabled' do
          meta_content = data_with_extension.meta.read
          data_with_extension.meta.rewind

          expect(meta_content).to include('vernacular_name.tsv')
          expect(meta_content).to include('http://rs.gbif.org/terms/1.0/VernacularName')
        end

        specify 'meta.xml does not include vernacular name extension when disabled' do
          meta_content = data_without_extension.meta.read
          data_without_extension.meta.rewind

          expect(meta_content).not_to include('vernacular_name.tsv')
          expect(meta_content).not_to include('http://rs.gbif.org/terms/1.0/VernacularName')
        end

        specify 'vernacular name extension rows star-join to correct core taxa with matching common name data' do
          core_content = data_with_extension.csv
          extension_content = data_with_extension.vernacular_name_extension_tmp.read

          core_csv = CSV.parse(core_content, headers: true, col_sep: "\t")
          extension_csv = CSV.parse(extension_content, headers: true, col_sep: "\t")

          ext_row = extension_csv.first

          data_row = core_csv.find { |row| row['taxonID'] == ext_row['id'] }

          scientific_name = data_row['scientificName']
          common_name = if otu1.taxon_name.cached == scientific_name
                          [common_name1, common_name2].find { |cn| cn.name == ext_row['vernacularName'] }
                        elsif otu2.taxon_name.cached == scientific_name
                          common_name3 if common_name3.name == ext_row['vernacularName']
                        end

          expect(ext_row['vernacularName']).to eq(common_name.name)
          expect(ext_row['language']).to eq(common_name.language&.alpha_2)

          temporal_range = [common_name.start_year, common_name.end_year].compact.join('-').presence
          expect(ext_row['temporal']).to eq(temporal_range) if temporal_range
        end
      end

      specify '#cleanup returns truthy' do
        expect(data.cleanup).to be_truthy
      end
    end

    context 'with no matching records' do
      let(:empty_scope) { { otu_id: [999999] } }
      let(:empty_data) { Export::Dwca::ChecklistData.new(core_otu_scope_params: empty_scope) }

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

    context 'with infraspecific taxa of same name at different ranks' do
      # Test case: same infraspecific epithet at different ranks should create
      # distinct taxa e.g., "Aus bus subsp. cus" and "Aus bus var. cus" are
      # different taxa
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
      let(:infra_data) { Export::Dwca::ChecklistData.new(core_otu_scope_params: infra_scope) }
      let(:infra_csv) { CSV.parse(infra_data.csv, headers: true, col_sep: "\t") }

      specify 'subspecies and variety with same epithet create distinct taxa' do
        # Find the subspecies and variety taxa
        subspecies_taxon = infra_csv.find { |row| row['taxonRank'] == 'subspecies' }
        variety_taxon = infra_csv.find { |row| row['taxonRank'] == 'variety' }

        expect(subspecies_taxon['taxonID']).not_to eq(variety_taxon['taxonID'])

        expect(subspecies_taxon['infraspecificEpithet']).to eq('rubra')
        expect(variety_taxon['infraspecificEpithet']).to eq('rubra')

        # They should have different scientificNames (one with "subsp.", one
        # with "var.").
        expect(subspecies_taxon['scientificName']).not_to eq(variety_taxon['scientificName'])
      end

      specify 'subspecies and variety both have species as parent' do
        species_taxon = infra_csv.find { |row| row['taxonRank'] == 'species' && row['scientificName'].include?('alba') }
        species_id = species_taxon['taxonID']

        subspecies_taxon = infra_csv.find { |row| row['taxonRank'] == 'subspecies' }
        variety_taxon = infra_csv.find { |row| row['taxonRank'] == 'variety' }

        expect(subspecies_taxon['parentNameUsageID']).to eq(species_id)
        expect(variety_taxon['parentNameUsageID']).to eq(species_id)
      end

      specify 'total unique taxa includes both infraspecific ranks' do
        subspecies_count = infra_csv.count { |row| row['taxonRank'] == 'subspecies' }
        variety_count = infra_csv.count { |row| row['taxonRank'] == 'variety' }

        expect(subspecies_count).to eq(1)
        expect(variety_count).to eq(1)
      end

      specify 'epithet fields are correctly populated by rank 1' do
        # Species: should have specificEpithet but NOT infraspecificEpithet
        species_taxon = infra_csv.find { |row| row['taxonRank'] == 'species' && row['scientificName'].include?('alba') }
        expect(species_taxon).to be_present
        expect(species_taxon['specificEpithet']).to eq('alba')
        expect(species_taxon['infraspecificEpithet']).to be_nil.or be_empty
      end

      specify 'epithet fields are correctly populated by rank 2' do
        # Subspecies: should have BOTH specificEpithet and infraspecificEpithet
        subspecies_taxon = infra_csv.find { |row| row['taxonRank'] == 'subspecies' }
        expect(subspecies_taxon).to be_present
        expect(subspecies_taxon['specificEpithet']).to eq('alba')
        expect(subspecies_taxon['infraspecificEpithet']).to eq('rubra')
      end

      specify 'epithet fields are correctly populated by rank 3' do
        # Variety: should have BOTH specificEpithet and infraspecificEpithet
        variety_taxon = infra_csv.find { |row| row['taxonRank'] == 'variety' }
        expect(variety_taxon).to be_present
        expect(variety_taxon['specificEpithet']).to eq('alba')
        expect(variety_taxon['infraspecificEpithet']).to eq('rubra')
      end

      specify 'epithet fields are correctly populated by rank 4' do
        # Genus: should have NEITHER specificEpithet nor infraspecificEpithet
        genus_taxon = infra_csv.find { |row| row['taxonRank'] == 'genus' && row['scientificName'] == 'Rosa' }
        expect(genus_taxon).to be_present
        expect(genus_taxon['specificEpithet']).to be_nil.or be_empty
        expect(genus_taxon['infraspecificEpithet']).to be_nil.or be_empty
      end
    end

    context 'when subspecies exist but parent species is missing' do
      # Test case: subspecies specimens exist, but no species specimen exists
      # The parent species should be automatically extracted from the subspecies data
      let!(:root) { FactoryBot.create(:root_taxon_name) }
      let!(:kingdom) { Protonym.create!(name: 'Plantae', rank_class: Ranks.lookup(:icn, :kingdom), parent: root) }
      let!(:family) { Protonym.create!(name: 'Rosaceae', rank_class: Ranks.lookup(:icn, :family), parent: kingdom) }
      let!(:genus) { Protonym.create!(name: 'Prunus', rank_class: Ranks.lookup(:icn, :genus), parent: family) }
      let!(:species) { Protonym.create!(name: 'dulcis', rank_class: Ranks.lookup(:icn, :species), parent: genus) }
      let!(:subspecies1) { Protonym.create!(name: 'amara', rank_class: Ranks.lookup(:icn, :subspecies), parent: species) }
      let!(:subspecies2) { Protonym.create!(name: 'dulcis', rank_class: Ranks.lookup(:icn, :subspecies), parent: species) }

      # Create OTUs and specimens for ONLY the subspecies (not the species)
      let!(:otu_subspecies1) { FactoryBot.create(:valid_otu, taxon_name: subspecies1) }
      let!(:otu_subspecies2) { FactoryBot.create(:valid_otu, taxon_name: subspecies2) }

      before do
        [otu_subspecies1, otu_subspecies2].each do |otu|
          specimen = FactoryBot.create(:valid_specimen)
          FactoryBot.create(:valid_taxon_determination, otu: otu, taxon_determination_object: specimen)
          specimen.get_dwc_occurrence
        end
      end

      let(:orphan_scope) { { otu_id: [otu_subspecies1.id, otu_subspecies2.id] } }
      let(:orphan_data) { Export::Dwca::ChecklistData.new(core_otu_scope_params: orphan_scope) }
      let(:orphan_csv) { CSV.parse(orphan_data.csv, headers: true, col_sep: "\t") }

      specify 'parent species is automatically extracted from subspecies' do
        # Find the parent species - should be created automatically.
        species_taxon = orphan_csv.find { |row| row['taxonRank'] == 'species' && row['scientificName'] == 'Prunus dulcis' }
        expect(species_taxon).to be_present, 'Parent species should be automatically extracted'
      end

      specify 'subspecies link to the created species' do
        species_taxon = orphan_csv.find { |row| row['taxonRank'] == 'species' && row['scientificName'] == 'Prunus dulcis' }
        species_taxon_id = species_taxon['taxonID']

        # Both subspecies should link to the extracted parent species.
        subspecies1_taxon = orphan_csv.find { |row| row['taxonRank'] == 'subspecies' && row['infraspecificEpithet'] == 'amara' }
        subspecies2_taxon = orphan_csv.find { |row| row['taxonRank'] == 'subspecies' && row['infraspecificEpithet'] == 'dulcis' }

        expect(subspecies1_taxon['parentNameUsageID']).to eq(species_taxon_id)
        expect(subspecies2_taxon['parentNameUsageID']).to eq(species_taxon_id)
      end

      specify 'extracted species has appropriate fields cleared' do
        species_taxon = orphan_csv.find { |row| row['taxonRank'] == 'species' && row['scientificName'] == 'Prunus dulcis' }
        expect(species_taxon).to be_present

        # Species should have genus and specificEpithet
        expect(species_taxon['genus']).to eq('Prunus')
        expect(species_taxon['specificEpithet']).to eq('dulcis')

        expect(species_taxon['infraspecificEpithet']).to be_nil.or be_empty
        expect(species_taxon['higherClassification']).to be_present
      end
    end

    context 'with accepted_name_mode parameter' do
      let!(:root) { FactoryBot.create(:root_taxon_name) }
      let!(:kingdom) { Protonym.create!(name: 'Animalia', rank_class: Ranks.lookup(:iczn, :kingdom), parent: root) }
      let!(:family) { Protonym.create!(name: 'Felidae', rank_class: Ranks.lookup(:iczn, :family), parent: kingdom) }
      let!(:genus) { Protonym.create!(name: 'Felis', rank_class: Ranks.lookup(:iczn, :genus), parent: family) }

      # Create a valid species
      let!(:valid_species) { Protonym.create!(name: 'catus', rank_class: Ranks.lookup(:iczn, :species), parent: genus) }
      let!(:valid_otu) { FactoryBot.create(:valid_otu, taxon_name: valid_species) }
      let!(:valid_specimen) { FactoryBot.create(:valid_specimen) }
      let!(:valid_td) { FactoryBot.create(:valid_taxon_determination, taxon_determination_object: valid_specimen, otu: valid_otu) }

      # Create an invalid species (synonym)
      let!(:invalid_species) { Protonym.create!(name: 'domesticus', rank_class: Ranks.lookup(:iczn, :species), parent: genus) }
      let!(:invalid_otu) { FactoryBot.create(:valid_otu, taxon_name: invalid_species) }
      let!(:invalid_specimen) { FactoryBot.create(:valid_specimen) }
      let!(:invalid_td) { FactoryBot.create(:valid_taxon_determination, taxon_determination_object: invalid_specimen, otu: invalid_otu) }

      # Make invalid_species a synonym of valid_species
      let!(:synonym_relationship) do
        TaxonNameRelationship::Iczn::Invalidating::Synonym.create!(
          subject_taxon_name: invalid_species,
          object_taxon_name: valid_species
        )
      end

      before do
        valid_specimen.get_dwc_occurrence
        invalid_specimen.get_dwc_occurrence

        # Verify that cached_is_valid is set correctly after synonym
        # relationship is created.
        valid_species.reload
        invalid_species.reload
      end

      let(:replace_with_accepted_data) do
        ::Export::Dwca::ChecklistData.new(
          core_otu_scope_params: { otu_id: [valid_otu.id, invalid_otu.id] },
          accepted_name_mode: 'replace_with_accepted_name'
        )
      end

      let(:accepted_name_usage_id_data) do
        ::Export::Dwca::ChecklistData.new(
          core_otu_scope_params: { otu_id: [valid_otu.id, invalid_otu.id] },
          accepted_name_mode: 'accepted_name_usage_id'
        )
      end

      specify 'replace_with_accepted_name mode replaces invalid names with valid names' do
        replace_csv = CSV.parse(replace_with_accepted_data.csv, headers: true, col_sep: "\t")

        # Should include valid species
        valid_taxon = replace_csv.find { |row| row['scientificName']&.include?('catus') }
        expect(valid_taxon).to be_present, 'Valid species should be included'

        invalid_taxon = replace_csv.find { |row| row['scientificName']&.include?('domesticus') }
        expect(invalid_taxon).to be_nil, 'Invalid species name should be replaced with valid name, not appear separately'
      end

      specify 'accepted_name_usage_id mode includes both taxa' do
        all_csv = CSV.parse(accepted_name_usage_id_data.csv, headers: true, col_sep: "\t")

        # Both should be present with their original names
        valid_taxon = all_csv.find { |row| row['scientificName']&.include?('catus') }
        synonym_taxon = all_csv.find { |row| row['scientificName']&.include?('domesticus') }

        expect(valid_taxon).to be_present, 'Valid species should be included'
        expect(synonym_taxon).to be_present, 'Synonym should be included with original name'
      end

      specify 'replace_with_accepted_name mode does not have synonym columns' do
        replace_csv = CSV.parse(replace_with_accepted_data.csv, headers: true, col_sep: "\t")

        expect(replace_csv.headers).not_to include('acceptedNameUsageID')
        expect(replace_csv.headers).not_to include('taxonomicStatus')
      end

      specify 'accepted_name_usage_id mode includes acceptedNameUsageID and taxonomicStatus fields' do
        all_csv = CSV.parse(accepted_name_usage_id_data.csv, headers: true, col_sep: "\t")

        expect(all_csv.headers).to include('acceptedNameUsageID')
        expect(all_csv.headers).to include('taxonomicStatus')
      end

      specify 'accepted name has taxonomicStatus "accepted" and acceptedNameUsageID pointing to itself' do
        all_csv = CSV.parse(accepted_name_usage_id_data.csv, headers: true, col_sep: "\t")

        valid_taxon = all_csv.find { |row| row['scientificName']&.include?('catus') && row['taxonRank'] == 'species' }

        expect(valid_taxon['taxonomicStatus']).to eq('accepted')
        expect(valid_taxon['acceptedNameUsageID']).to eq(valid_taxon['taxonID'])
      end

      specify 'synonym has taxonomicStatus "synonym" and acceptedNameUsageID pointing to valid name' do
        all_csv = CSV.parse(accepted_name_usage_id_data.csv, headers: true, col_sep: "\t")

        synonym_taxon = all_csv.find { |row| row['scientificName']&.include?('domesticus') && row['taxonRank'] == 'species' }
        valid_taxon = all_csv.find { |row| row['scientificName']&.include?('catus') && row['taxonRank'] == 'species' }

        expect(synonym_taxon['taxonomicStatus']).to eq('synonym')
        expect(synonym_taxon['acceptedNameUsageID']).to eq(valid_taxon['taxonID'])
      end

      specify 'extracted higher taxa have taxonomicStatus "accepted"' do
        all_csv = CSV.parse(accepted_name_usage_id_data.csv, headers: true, col_sep: "\t")

        # Find extracted higher taxa (kingdom, family, genus) - these don't have
        # terminal TaxonName data. They're extracted from rank columns and
        # should be marked as accepted because DwcOccurrence builds
        # classification from valid_taxon_name (see
        # Shared::Taxonomy#taxonomy_for_object).
        kingdom_taxon = all_csv.find { |row| row['scientificName'] == 'Animalia' && row['taxonRank'] == 'kingdom' }
        family_taxon = all_csv.find { |row| row['scientificName'] == 'Felidae' && row['taxonRank'] == 'family' }
        genus_taxon = all_csv.find { |row| row['scientificName'] == 'Felis' && row['taxonRank'] == 'genus' }

        # All extracted higher taxa should be marked as accepted
        expect(kingdom_taxon['taxonomicStatus']).to eq('accepted')
        expect(kingdom_taxon['acceptedNameUsageID']).to eq(kingdom_taxon['taxonID'])

        expect(family_taxon['taxonomicStatus']).to eq('accepted')
        expect(family_taxon['acceptedNameUsageID']).to eq(family_taxon['taxonID'])

        expect(genus_taxon['taxonomicStatus']).to eq('accepted')
        expect(genus_taxon['acceptedNameUsageID']).to eq(genus_taxon['taxonID'])
      end

      context 'with terminal higher taxon that is a synonym' do
        # Create a genus-level OTU that is a synonym
        let!(:valid_genus) { Protonym.create!(name: 'Validus', rank_class: Ranks.lookup(:iczn, :genus), parent: family) }
        let!(:invalid_genus) { Protonym.create!(name: 'Invalidus', rank_class: Ranks.lookup(:iczn, :genus), parent: family) }
        let!(:valid_genus_otu) { FactoryBot.create(:valid_otu, taxon_name: valid_genus) }
        let!(:invalid_genus_otu) { FactoryBot.create(:valid_otu, taxon_name: invalid_genus) }

        # Create AssertedDistributions for genus-level OTUs (since we need occurrences)
        let!(:valid_ad) { FactoryBot.create(:valid_asserted_distribution, asserted_distribution_object: valid_genus_otu) }
        let!(:invalid_ad) { FactoryBot.create(:valid_asserted_distribution, asserted_distribution_object: invalid_genus_otu) }

        let!(:genus_synonym_relationship) do
          TaxonNameRelationship::Iczn::Invalidating::Synonym.create!(
            subject_taxon_name: invalid_genus,
            object_taxon_name: valid_genus
          )
        end

        before do
          valid_ad.get_dwc_occurrence
          invalid_ad.get_dwc_occurrence
          valid_genus.reload
          invalid_genus.reload
        end

        let(:genus_data) do
          ::Export::Dwca::ChecklistData.new(
            core_otu_scope_params: { otu_id: [valid_genus_otu.id, invalid_genus_otu.id] },
            accepted_name_mode: 'accepted_name_usage_id'
          )
        end

        specify 'terminal higher taxon that is valid has taxonomicStatus "accepted"' do
          genus_csv = CSV.parse(genus_data.csv, headers: true, col_sep: "\t")

          valid_genus_row = genus_csv.find { |row| row['scientificName'] == 'Validus' && row['taxonRank'] == 'genus' }

          expect(valid_genus_row['taxonomicStatus']).to eq('accepted')
          expect(valid_genus_row['acceptedNameUsageID']).to eq(valid_genus_row['taxonID'])
        end

        specify 'terminal higher taxon that is a synonym has taxonomicStatus "synonym"' do
          genus_csv = CSV.parse(genus_data.csv, headers: true, col_sep: "\t")

          invalid_genus_row = genus_csv.find { |row| row['scientificName'] == 'Invalidus' && row['taxonRank'] == 'genus' }
          valid_genus_row = genus_csv.find { |row| row['scientificName'] == 'Validus' && row['taxonRank'] == 'genus' }

          expect(invalid_genus_row['taxonomicStatus']).to eq('synonym')
          expect(invalid_genus_row['acceptedNameUsageID']).to eq(valid_genus_row['taxonID'])
        end
      end

      context 'when only synonym has occurrence (valid name auto-added)' do
        # This tests ensure_valid_names_for_synonyms specifically. Create a
        # synonym with an occurrence, but the valid name has NO occurrence. The
        # valid name should be automatically added to the output.

        let!(:valid_auto_species) { Protonym.create!(name: 'autovalidus', rank_class: Ranks.lookup(:iczn, :species), parent: genus) }
        let!(:synonym_auto_species) { Protonym.create!(name: 'autosynonymus', rank_class: Ranks.lookup(:iczn, :species), parent: genus) }
        let!(:synonym_auto_otu) { FactoryBot.create(:valid_otu, taxon_name: synonym_auto_species) }
        let!(:synonym_auto_specimen) { FactoryBot.create(:valid_specimen) }
        let!(:synonym_auto_td) { FactoryBot.create(:valid_taxon_determination, taxon_determination_object: synonym_auto_specimen, otu: synonym_auto_otu) }

        let!(:auto_synonym_relationship) do
          TaxonNameRelationship::Iczn::Invalidating::Synonym.create!(
            subject_taxon_name: synonym_auto_species,
            object_taxon_name: valid_auto_species
          )
        end

        before do
          synonym_auto_specimen.get_dwc_occurrence
          valid_auto_species.reload
          synonym_auto_species.reload
        end

        specify 'valid name is automatically added even without occurrence' do
          data = ::Export::Dwca::ChecklistData.new(
            core_otu_scope_params: { otu_id: [synonym_auto_otu.id] }, # Only synonym OTU!
            accepted_name_mode: 'accepted_name_usage_id'
          )

          csv = CSV.parse(data.csv, headers: true, col_sep: "\t")

          # Synonym should be present (has occurrence)
          synonym_row = csv.find { |row| row['scientificName']&.include?('autosynonymus') && row['taxonRank'] == 'species' }

          # Valid name should be present (auto-added by ensure_valid_names_for_synonyms)
          valid_row = csv.find { |row| row['scientificName']&.include?('autovalidus') && row['taxonRank'] == 'species' }
          expect(valid_row).to be_present, 'Valid name should be auto-added even without occurrence'
          expect(valid_row['taxonomicStatus']).to eq('accepted')

          # Synonym should point to valid name
          expect(synonym_row['acceptedNameUsageID']).to eq(valid_row['taxonID'])
        end

        specify 'auto-added valid name has correct higher classification' do
          data = ::Export::Dwca::ChecklistData.new(
            core_otu_scope_params: { otu_id: [synonym_auto_otu.id] },
            accepted_name_mode: 'accepted_name_usage_id'
          )

          csv = CSV.parse(data.csv, headers: true, col_sep: "\t")

          valid_row = csv.find { |row| row['scientificName']&.include?('autovalidus') && row['taxonRank'] == 'species' }

          expect(valid_row['genus']).to eq('Felis')
          expect(valid_row['family']).to eq('Felidae')
          expect(valid_row['kingdom']).to eq('Animalia')
        end
      end
    end

    context 'with homonyms (same scientific name in different kingdoms)' do
      # Create two separate taxonomic hierarchies with same species name "bus"
      # in genus "Aus", one in Animalia, one in Plantae.
      let!(:homonym_root) { FactoryBot.create(:root_taxon_name) }

      # Animalia hierarchy
      let!(:animalia) { Protonym.create!(name: 'Animalia', parent: homonym_root, rank_class: Ranks.lookup(:iczn, :kingdom)) }
      let!(:arthropoda) { Protonym.create!(name: 'Arthropoda', parent: animalia, rank_class: Ranks.lookup(:iczn, :phylum)) }
      let!(:insecta) { Protonym.create!(name: 'Insecta', parent: arthropoda, rank_class: Ranks.lookup(:iczn, :class)) }
      let!(:aus_animal) { Protonym.create!(name: 'Aus', parent: insecta, rank_class: Ranks.lookup(:iczn, :genus)) }
      let!(:bus_animal) { Protonym.create!(name: 'bus', parent: aus_animal, rank_class: Ranks.lookup(:iczn, :species)) }

      # Plantae hierarchy (using ICN)
      let!(:plantae) { Protonym.create!(name: 'Plantae', parent: homonym_root, rank_class: Ranks.lookup(:icn, :kingdom)) }
      let!(:magnoliophyta) { Protonym.create!(name: 'Magnoliophyta', parent: plantae, rank_class: Ranks.lookup(:icn, :phylum)) }
      let!(:magnoliopsida) { Protonym.create!(name: 'Magnoliopsida', parent: magnoliophyta, rank_class: Ranks.lookup(:icn, :class)) }
      let!(:aus_plant) { Protonym.create!(name: 'Aus', parent: magnoliopsida, rank_class: Ranks.lookup(:icn, :genus)) }
      let!(:bus_plant) { Protonym.create!(name: 'bus', parent: aus_plant, rank_class: Ranks.lookup(:icn, :species)) }

      # Create OTUs and specimens
      let!(:animal_otu) { FactoryBot.create(:valid_otu, taxon_name: bus_animal) }
      let!(:animal_specimen) { FactoryBot.create(:valid_specimen) }
      let!(:animal_td) { FactoryBot.create(:valid_taxon_determination, taxon_determination_object: animal_specimen, otu: animal_otu) }

      let!(:plant_otu) { FactoryBot.create(:valid_otu, taxon_name: bus_plant) }
      let!(:plant_specimen) { FactoryBot.create(:valid_specimen) }
      let!(:plant_td) { FactoryBot.create(:valid_taxon_determination, taxon_determination_object: plant_specimen, otu: plant_otu) }

      before do
        animal_specimen.get_dwc_occurrence
        plant_specimen.get_dwc_occurrence
      end

      context 'replace_with_accepted_name mode' do
        let(:replace_data) do
          ::Export::Dwca::ChecklistData.new(
            core_otu_scope_params: { otu_id: [animal_otu.id, plant_otu.id] },
            accepted_name_mode: 'replace_with_accepted_name'
          )
        end

        specify 'both homonyms appear as separate taxa' do
          csv = CSV.parse(replace_data.csv, headers: true, col_sep: "\t")

          aus_bus_rows = csv.select { |row| row['genus'] == 'Aus' && row['specificEpithet'] == 'bus' && row['taxonRank'] == 'species' }
          expect(aus_bus_rows.count).to eq(2), 'Both homonyms should appear in output'
        end

        specify 'homonyms have different taxonIDs' do
          csv = CSV.parse(replace_data.csv, headers: true, col_sep: "\t")

          aus_bus_rows = csv.select { |row| row['genus'] == 'Aus' && row['specificEpithet'] == 'bus' && row['taxonRank'] == 'species' }
          taxon_ids = aus_bus_rows.map { |row| row['taxonID'] }

          expect(taxon_ids.uniq.count).to eq(2), 'Homonyms should have distinct taxonIDs'
        end

        specify 'homonyms have different higher classifications' do
          csv = CSV.parse(replace_data.csv, headers: true, col_sep: "\t")

          animal_species = csv.find { |row| row['kingdom'] == 'Animalia' && row['genus'] == 'Aus' && row['specificEpithet'] == 'bus' && row['taxonRank'] == 'species' }
          plant_species = csv.find { |row| row['kingdom'] == 'Plantae' && row['genus'] == 'Aus' && row['specificEpithet'] == 'bus' && row['taxonRank'] == 'species' }

          expect(animal_species['kingdom']).to eq('Animalia')
          expect(animal_species['phylum']).to eq('Arthropoda')
          expect(animal_species['class']).to eq('Insecta')

          expect(plant_species['kingdom']).to eq('Plantae')
          expect(plant_species['phylum']).to eq('Magnoliophyta')
          expect(plant_species['class']).to eq('Magnoliopsida')
        end

        specify 'both Aus genera appear with different higher classifications' do
          csv = CSV.parse(replace_data.csv, headers: true, col_sep: "\t")

          animal_genus = csv.find { |row| row['kingdom'] == 'Animalia' && row['scientificName'] == 'Aus' && row['taxonRank'] == 'genus' }
          plant_genus = csv.find { |row| row['kingdom'] == 'Plantae' && row['scientificName'] == 'Aus' && row['taxonRank'] == 'genus' }

          expect(animal_genus['taxonID']).not_to eq(plant_genus['taxonID']), 'Homonymous genera should have different taxonIDs'
        end
      end

      context 'with vernacular name extension' do
        # Add vernacular names to distinguish the homonyms
        let!(:english) { FactoryBot.create(:valid_language, alpha_2: 'en') }
        let!(:animal_common_name) { FactoryBot.create(:valid_common_name, name: 'Animal Bug', otu: animal_otu, language: english) }
        let!(:plant_common_name) { FactoryBot.create(:valid_common_name, name: 'Plant Bug', otu: plant_otu, language: english) }

        let(:data_with_vernacular) do
          ::Export::Dwca::ChecklistData.new(
            core_otu_scope_params: { otu_id: [animal_otu.id, plant_otu.id] },
            accepted_name_mode: 'replace_with_accepted_name',
            extensions: [:vernacular_name]
          )
        end

        specify 'vernacular name extension links to correct homonym' do
          core_csv = CSV.parse(data_with_vernacular.csv, headers: true, col_sep: "\t")
          vernacular_csv = CSV.parse(data_with_vernacular.vernacular_name_extension_tmp.read, headers: true, col_sep: "\t")

          animal_species = core_csv.find { |row| row['kingdom'] == 'Animalia' && row['genus'] == 'Aus' && row['specificEpithet'] == 'bus' && row['taxonRank'] == 'species' }
          plant_species = core_csv.find { |row| row['kingdom'] == 'Plantae' && row['genus'] == 'Aus' && row['specificEpithet'] == 'bus' && row['taxonRank'] == 'species' }

          animal_bug = vernacular_csv.find { |row| row['vernacularName'] == 'Animal Bug' }
          plant_bug = vernacular_csv.find { |row| row['vernacularName'] == 'Plant Bug' }

          expect(animal_bug['id']).to eq(animal_species['taxonID']),
            'Animal Bug should link to Animal Aus bus taxonID'
          expect(plant_bug['id']).to eq(plant_species['taxonID']),
            'Plant Bug should link to Plant Aus bus taxonID'

          expect(animal_bug['id']).not_to eq(plant_bug['id']),
            'Vernacular names for homonyms should link to different taxonIDs'
        end
      end
    end
  end
end