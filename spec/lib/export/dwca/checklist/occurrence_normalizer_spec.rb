# frozen_string_literal: true

require 'rails_helper'

describe Export::Dwca::Checklist::OccurrenceNormalizer, type: :model, group: :darwin_core do
  let(:raw_csv) do
    CSV.generate(col_sep: "\t") do |csv|
      csv << ['scientificName', 'taxonRank']
      csv << ['Aus bus', 'species']
    end
  end

  let(:normalizer) do
    described_class.new(
      raw_csv: raw_csv,
      accepted_name_mode: 'replace_with_accepted_name',
      otu_to_taxon_name_data: {},
      occurrence_to_otu: {}
    )
  end

  describe '#remove_empty_columns' do
    specify 'removes columns with no data across all taxa' do
      taxa = [
        { 'id' => 1, 'scientificName' => 'Aus', 'family' => 'Idae', 'order' => nil },
        { 'id' => 2, 'scientificName' => 'Bus', 'family' => 'Idae', 'order' => nil }
      ]

      result = normalizer.send(:remove_empty_columns, taxa)

      expect(result.first.keys).not_to include('order')
    end

    specify 'keeps required columns even if empty' do
      taxa = [
        { 'id' => 1, 'scientificName' => '', 'taxonRank' => '', 'family' => 'Idae' }
      ]

      result = normalizer.send(:remove_empty_columns, taxa)

      expect(result.first.keys).to include('id', 'scientificName', 'taxonRank')
    end

    specify 'keeps columns with at least one non-empty value' do
      taxa = [
        { 'id' => 1, 'scientificName' => 'Aus', 'author' => nil },
        { 'id' => 2, 'scientificName' => 'Bus', 'author' => 'Smith' }
      ]

      result = normalizer.send(:remove_empty_columns, taxa)

      expect(result.first.keys).to include('author')
      expect(result.last['author']).to eq('Smith')
    end

    specify 'returns empty array unchanged' do
      result = normalizer.send(:remove_empty_columns, [])
      expect(result).to eq([])
    end
  end

  describe '#normalize_occurrence_taxon' do
    let(:taxon_name_metadata) { { scientific_name_authorship: 'Jones, 1850' } }

    let(:taxon) do
      {
        'kingdom' => 'Animalia',
        'phylum' => 'Arthropoda',
        'class' => 'Insecta',
        'order' => 'Lepidoptera',
        'family' => 'Noctuidae',
        'genus' => 'Aus',
        'scientificName' => 'Aus bus',
        'taxonRank' => 'species',
        'specificEpithet' => 'bus',
        'scientificNameAuthorship' => 'Smith, 1900'
      }
    end

    specify 'clears ranks lower than the current rank' do
      taxon['taxonRank'] = 'family'
      normalizer.send(:normalize_occurrence_taxon, taxon, 'family', nil, taxon_name_info: taxon_name_metadata)

      expect(taxon['family']).to eq('Noctuidae')
      expect(taxon['genus']).to be_nil
      expect(taxon['specificEpithet']).to be_nil
    end

    specify 'computes higherClassification from retained rank columns' do
      taxon['taxonRank'] = 'genus'
      taxon['scientificName'] = 'Aus'
      normalizer.send(:normalize_occurrence_taxon, taxon, 'genus', nil, taxon_name_info: taxon_name_metadata)

      expect(taxon['higherClassification']).to eq(
        "Animalia#{Export::Dwca::DELIMITER}Arthropoda#{Export::Dwca::DELIMITER}" \
        "Insecta#{Export::Dwca::DELIMITER}Lepidoptera#{Export::Dwca::DELIMITER}Noctuidae"
      )
    end

    specify 'sets higherClassification to nil for top rank' do
      taxon['taxonRank'] = 'kingdom'
      normalizer.send(:normalize_occurrence_taxon, taxon, 'kingdom', nil, taxon_name_info: taxon_name_metadata)

      expect(taxon['higherClassification']).to be_nil
    end

    specify 'keeps fields for rank columns and scientificName' do
      taxon['taxonRank'] = 'genus'
      taxon['scientificName'] = 'Aus'
      normalizer.send(:normalize_occurrence_taxon, taxon, 'genus', nil, taxon_name_info: taxon_name_metadata)

      expect(taxon['scientificName']).to eq('Aus')
      expect(taxon['taxonRank']).to eq('genus')
    end

    specify 'replaces inherited authorship with the extracted taxon authorship' do
      taxon['taxonRank'] = 'genus'
      normalizer.send(:normalize_occurrence_taxon, taxon, 'genus', nil, taxon_name_info: taxon_name_metadata)

      expect(taxon['scientificNameAuthorship']).to eq('Jones, 1850')
    end

    specify 'keeps specificEpithet for species rank' do
      taxon['taxonRank'] = 'species'
      normalizer.send(:normalize_occurrence_taxon, taxon, 'species', nil, taxon_name_info: taxon_name_metadata)

      expect(taxon['specificEpithet']).to eq('bus')
    end

    specify 'keeps specificEpithet and infraspecificEpithet for subspecies' do
      taxon['taxonRank'] = 'subspecies'
      taxon['infraspecificEpithet'] = 'cus'
      normalizer.send(:normalize_occurrence_taxon, taxon, 'subspecies', nil, taxon_name_info: taxon_name_metadata)

      expect(taxon['specificEpithet']).to eq('bus')
      expect(taxon['infraspecificEpithet']).to eq('cus')
    end
  end

  describe '.combine_scientific_name' do
    specify 'combines cached name and authorship when both are present' do
      expect(described_class.combine_scientific_name('Aus bus', 'Smith, 1900')).to eq('Aus bus Smith, 1900')
    end

    specify 'returns cached name when authorship is absent' do
      expect(described_class.combine_scientific_name('Aus', nil)).to eq('Aus')
    end
  end

  describe '#determine_accepted_name_usage' do
    let(:taxon_name_id_to_taxon_id) { { 100 => 5, 200 => 10 } }
    let(:taxon_name_info) { { 100 => { scientific_name: 'Validus Author, 1900' } } }

    context 'in replace_with_accepted_name mode' do
      specify 'returns nil for both values' do
        result = normalizer.send(
          :determine_accepted_name_usage,
          {},
          1,
          1,
          taxon_name_info,
          taxon_name_id_to_taxon_id
        )

        expect(result).to eq([nil, nil, nil])
      end
    end

    context 'in accepted_name_usage_id mode' do
      let(:normalizer) do
        described_class.new(
          raw_csv: raw_csv,
          accepted_name_mode: 'accepted_name_usage_id',
          otu_to_taxon_name_data: {},
          occurrence_to_otu: {}
        )
      end

      specify 'returns self-reference for valid names' do
        taxon = { 'taxon_name_cached_is_valid' => true }

        result = normalizer.send(
          :determine_accepted_name_usage,
          taxon,
          5,
          100,
          taxon_name_info,
          taxon_name_id_to_taxon_id
        )

        expect(result).to eq([5, 'accepted', nil])
      end

      specify 'returns acceptedNameUsageID with fallback synonym status when no gbif status stored' do
        taxon = {
          'taxon_name_cached_is_valid' => false,
          'taxon_name_cached_valid_taxon_name_id' => 100
        }

        result = normalizer.send(
          :determine_accepted_name_usage,
          taxon,
          7,
          200,
          taxon_name_info,
          taxon_name_id_to_taxon_id
        )

        expect(result).to eq([5, 'synonym', 'Validus Author, 1900'])
      end

      specify 'returns self-reference as accepted when invalid name points to itself and no gbif status is stored' do
        taxon = {
          'taxon_name_cached_is_valid' => false,
          'taxon_name_cached_valid_taxon_name_id' => 200,
          'scientificName' => 'Selfus Author, 1901'
        }

        result = normalizer.send(
          :determine_accepted_name_usage,
          taxon,
          10,
          200,
          taxon_name_info,
          taxon_name_id_to_taxon_id
        )

        expect(result).to eq([10, 'accepted', 'Selfus Author, 1901'])
      end

      specify 'uses stored gbif_taxonomic_status when present (homotypicSynonym)' do
        taxon = {
          'taxon_name_cached_is_valid'          => false,
          'taxon_name_cached_valid_taxon_name_id' => 100,
          'taxon_name_gbif_taxonomic_status'    => 'homotypicSynonym'
        }

        result = normalizer.send(
          :determine_accepted_name_usage,
          taxon,
          7,
          200,
          taxon_name_info,
          taxon_name_id_to_taxon_id
        )

        expect(result).to eq([5, 'homotypicSynonym', 'Validus Author, 1900'])
      end

      specify 'uses stored gbif_taxonomic_status when present (misapplied)' do
        taxon = {
          'taxon_name_cached_is_valid'          => false,
          'taxon_name_cached_valid_taxon_name_id' => 100,
          'taxon_name_gbif_taxonomic_status'    => 'misapplied'
        }

        result = normalizer.send(
          :determine_accepted_name_usage,
          taxon,
          7,
          200,
          taxon_name_info,
          taxon_name_id_to_taxon_id
        )

        expect(result).to eq([5, 'misapplied', 'Validus Author, 1900'])
      end

      specify 'returns self-reference for extracted taxa with no validity data' do
        taxon = {}

        result = normalizer.send(
          :determine_accepted_name_usage,
          taxon,
          8,
          200,
          taxon_name_info,
          taxon_name_id_to_taxon_id
        )

        expect(result).to eq([8, 'accepted', nil])
      end
    end
  end

  describe '#assign_taxon_uuids' do
    specify 'assigns UUID taxonIDs from OTU identifiers' do
      otu = FactoryBot.create(:valid_otu)
      otu.update!(taxon_name: FactoryBot.create(:root_taxon_name))
      tn_id = otu.taxon_name_id

      all_taxa = { tn_id => { 'scientificName' => 'Animalia' } }
      taxon_name_info = { tn_id => { rank: 'kingdom', parent_id: nil } }

      taxa_with_ids, mapping = normalizer.send(:assign_taxon_uuids, all_taxa, taxon_name_info)

      expect(Utilities::Uuid.uuid?(mapping[tn_id])).to be(true)
      expect(taxa_with_ids.size).to eq(1)
    end

    specify 'skips taxa whose OTU only has non-UUID global identifiers' do
      root = FactoryBot.create(:root_taxon_name)
      otu = FactoryBot.create(:valid_otu, taxon_name: root)
      FactoryBot.create(:uri_identifier, identifier_object: otu, identifier: 'https://example.test/otus/1')
      tn_id = root.id

      all_taxa = { tn_id => { 'scientificName' => 'Animalia' } }
      taxon_name_info = { tn_id => { rank: 'kingdom', parent_id: nil } }

      taxa_with_ids, mapping = normalizer.send(:assign_taxon_uuids, all_taxa, taxon_name_info)

      expect(mapping).to be_empty
      expect(taxa_with_ids).to be_empty
    end

    specify 'processes taxa in rank order (higher ranks first)' do
      root = FactoryBot.create(:root_taxon_name)
      tn_class  = Protonym.create!(name: 'Insecta',     rank_class: Ranks.lookup(:iczn, :class),  parent: root)
      tn_order  = Protonym.create!(name: 'Lepidoptera', rank_class: Ranks.lookup(:iczn, :order),  parent: tn_class)
      tn_family = Protonym.create!(name: 'Noctuidae',   rank_class: Ranks.lookup(:iczn, :family), parent: tn_order)

      FactoryBot.create(:valid_otu, taxon_name: tn_class)
      FactoryBot.create(:valid_otu, taxon_name: tn_order)
      FactoryBot.create(:valid_otu, taxon_name: tn_family)

      all_taxa = {
        tn_family.id => { 'scientificName' => 'Noctuidae' },
        tn_class.id  => { 'scientificName' => 'Insecta' },
        tn_order.id  => { 'scientificName' => 'Lepidoptera' }
      }
      taxon_name_info = {
        tn_family.id => { rank: 'family', parent_id: tn_order.id },
        tn_class.id  => { rank: 'class',  parent_id: nil },
        tn_order.id  => { rank: 'order',  parent_id: tn_class.id }
      }

      taxa_with_ids, _mapping = normalizer.send(:assign_taxon_uuids, all_taxa, taxon_name_info)

      expect(taxa_with_ids.map { |t| t[:rank] }).to eq(['class', 'order', 'family'])
    end
  end

  describe '#taxon_name_id_to_otu_uuid' do
    specify 'returns the lowest-position UUID when an OTU has multiple global UUID identifiers' do
      otu = FactoryBot.create(:valid_otu, taxon_name: FactoryBot.create(:root_taxon_name))

      # acts_as_list add_new_at: :top means the last created gets position 1
      first_uuid  = "aaaaaaaa-0000-0000-0000-000000000001"
      second_uuid = "bbbbbbbb-0000-0000-0000-000000000002"

      Identifier::Global::Uuid.create!(identifier_object: otu, identifier: first_uuid)
      Identifier::Global::Uuid.create!(identifier_object: otu, identifier: second_uuid)

      # second_uuid was created last, so it has position 1 (highest priority)
      result = normalizer.send(:taxon_name_id_to_otu_uuid, [otu.taxon_name_id])
      expect(result[otu.taxon_name_id]).to eq(second_uuid)
    end
  end

  describe '#build_final_taxon' do
    let(:taxon) do
      {
        'scientificName' => 'Aus bus',
        'taxonRank' => 'species',
        'genus' => 'Aus',
        'family' => 'Noctuidae'
      }
    end

    let(:taxon_name_info) do
      {
        100 => { rank: 'species', parent_id: 50, scientific_name_authorship: 'Smith, 1900' },
        50 => { rank: 'genus', parent_id: 25, scientific_name_authorship: 'Jones, 1850' },
        25 => { rank: 'family', parent_id: nil, scientific_name_authorship: 'Brown, 1800' }
      }
    end

    let(:taxon_name_id_to_taxon_id) do
      { 100 => 10, 50 => 5, 25 => 2 }
    end

    specify 'sets id and taxonID to assigned value' do
      result = normalizer.send(
        :build_final_taxon,
        taxon,
        10,
        100,
        taxon_name_info,
        taxon_name_id_to_taxon_id
      )

      expect(result['id']).to eq(10)
      expect(result['taxonID']).to eq(10)
    end

    specify 'sets parentNameUsageID to parent taxon ID' do
      result = normalizer.send(
        :build_final_taxon,
        taxon,
        10,
        100,
        taxon_name_info,
        taxon_name_id_to_taxon_id
      )

      expect(result['parentNameUsageID']).to eq(5)
    end

    specify 'walks up hierarchy if immediate parent not in export' do
      # Parent genus (50) not in export, should use grandparent family (25)
      mapping_without_genus = { 100 => 10, 25 => 2 }

      result = normalizer.send(
        :build_final_taxon,
        taxon,
        10,
        100,
        taxon_name_info,
        mapping_without_genus
      )

      expect(result['parentNameUsageID']).to eq(2)
    end

    specify 'sets parentNameUsageID to nil for root taxa' do
      root_taxon_name_info = { 25 => { rank: 'family', parent_id: nil } }

      result = normalizer.send(
        :build_final_taxon,
        taxon,
        2,
        25,
        root_taxon_name_info,
        { 25 => 2 }
      )

      expect(result['parentNameUsageID']).to be_nil
    end

    specify 'excludes internal fields from output' do
      taxon_with_internal = taxon.merge(
        'dwc_occurrence_object_type' => 'CollectionObject',
        'dwc_occurrence_object_id' => 123,
        'taxon_name_id' => 100,
        'taxon_name_gbif_taxonomic_status' => 'homotypicSynonym'
      )

      result = normalizer.send(
        :build_final_taxon,
        taxon_with_internal,
        10,
        100,
        taxon_name_info,
        taxon_name_id_to_taxon_id
      )

      expect(result.keys).not_to include(
        'dwc_occurrence_object_type',
        'dwc_occurrence_object_id',
        'taxon_name_id',
        'taxon_name_gbif_taxonomic_status'
      )
    end

    specify 'includes acceptedNameUsageID in accepted_name_usage_id mode' do
      normalizer_with_mode = described_class.new(
        raw_csv: raw_csv,
        accepted_name_mode: 'accepted_name_usage_id',
        otu_to_taxon_name_data: {},
        occurrence_to_otu: {}
      )

      taxon_with_validity = taxon.merge('taxon_name_cached_is_valid' => true)

      result = normalizer_with_mode.send(
        :build_final_taxon,
        taxon_with_validity,
        10,
        100,
        taxon_name_info,
        taxon_name_id_to_taxon_id
      )

      expect(result['acceptedNameUsageID']).to eq(10)
      expect(result['taxonomicStatus']).to eq('accepted')
    end

    specify 'preserves the normalized taxon authorship when building the final row' do
      extracted_genus_taxon = taxon.merge(
        'scientificName' => 'Aus',
        'taxonRank' => 'genus',
        'scientificNameAuthorship' => 'Jones, 1850'
      )

      result = normalizer.send(
        :build_final_taxon,
        extracted_genus_taxon,
        5,
        50,
        taxon_name_info,
        taxon_name_id_to_taxon_id
      )

      expect(result['scientificNameAuthorship']).to eq('Jones, 1850')
    end

    specify 'preserves normalized higherClassification from exported rank columns' do
      genus_taxon_with_extra_classification = taxon.merge(
        'scientificName' => 'Kabakra',
        'taxonRank' => 'genus',
        'kingdom' => 'Animalia',
        'phylum' => 'Arthropoda',
        'class' => 'Insecta',
        'order' => 'Hemiptera',
        'superfamily' => 'Membracoidea',
        'family' => 'Cicadellidae',
        'subfamily' => 'Typhlocybinae',
        'tribe' => 'Erythroneurini',
        'higherClassification' => 'Animalia | Arthropoda | Insecta | Hemiptera | Membracoidea | Cicadellidae | Typhlocybinae | Erythroneurini'
      )

      result = normalizer.send(
        :build_final_taxon,
        genus_taxon_with_extra_classification,
        50,
        50,
        taxon_name_info,
        taxon_name_id_to_taxon_id
      )

      expect(result['higherClassification']).to eq(
        'Animalia | Arthropoda | Insecta | Hemiptera | Membracoidea | Cicadellidae | Typhlocybinae | Erythroneurini'
      )
    end
  end

  describe '#add_terminal_taxon' do
    let(:all_taxa) { {} }
    let(:ancestor_lookup) { {} }

    specify 'two homonyms with the same name string but different taxon_name_ids are both stored' do
      row1 = CSV::Row.new(['scientificName', 'taxonRank', 'family'], ['Aus', 'genus', 'Aidae'])
      row2 = CSV::Row.new(['scientificName', 'taxonRank', 'family'], ['Aus', 'genus', 'Bidae'])

      normalizer.send(:add_terminal_taxon, row1, 100, 'genus', all_taxa, ancestor_lookup)
      normalizer.send(:add_terminal_taxon, row2, 200, 'genus', all_taxa, ancestor_lookup)

      expect(all_taxa.size).to eq(2)
      expect(all_taxa[100]['family']).to eq('Aidae')
      expect(all_taxa[200]['family']).to eq('Bidae')
    end

    specify 'the same taxon encountered a second time is not overwritten' do
      row1 = CSV::Row.new(['scientificName', 'taxonRank'], ['Aus bus', 'species'])
      row2 = CSV::Row.new(['scientificName', 'taxonRank'], ['not this one', 'species'])

      normalizer.send(:add_terminal_taxon, row1, 100, 'species', all_taxa, ancestor_lookup)
      normalizer.send(:add_terminal_taxon, row2, 100, 'species', all_taxa, ancestor_lookup)

      expect(all_taxa.size).to eq(1)
      expect(all_taxa[100]['scientificName']).to eq('Aus bus')
    end

    specify 'uses the original full scientific name in accepted_name_usage_id mode when authorship metadata is available' do
      accepted_normalizer = described_class.new(
        raw_csv: raw_csv,
        accepted_name_mode: 'accepted_name_usage_id',
        otu_to_taxon_name_data: {},
        occurrence_to_otu: {}
      )

      row = CSV::Row.new(
        ['scientificName', 'taxonRank', 'taxon_name_cached'],
        ['replacement value', 'species', 'Aus bus']
      )
      taxon_name_info = {
        100 => { scientific_name_authorship: 'Smith, 1900' }
      }

      accepted_normalizer.send(:add_terminal_taxon, row, 100, 'species', all_taxa, ancestor_lookup, taxon_name_info)

      expect(all_taxa[100]['scientificName']).to eq('Aus bus Smith, 1900')
    end
  end

  describe '#store_taxon_name_metadata' do
    let(:row) { CSV::Row.new(['scientificName'], ['Aus bus']) }

    specify 'stores gbif_taxonomic_status from tn_data into the row' do
      tn_data = {
        cached: 'Aus bus',
        cached_is_valid: false,
        cached_valid_taxon_name_id: 100,
        gbif_taxonomic_status: 'homotypicSynonym'
      }

      normalizer.send(:store_taxon_name_metadata, row, tn_data)

      expect(row['taxon_name_gbif_taxonomic_status']).to eq('homotypicSynonym')
    end

    specify 'stores nil when gbif_taxonomic_status is absent from tn_data' do
      tn_data = { cached: 'Aus bus', cached_is_valid: true, cached_valid_taxon_name_id: nil }

      normalizer.send(:store_taxon_name_metadata, row, tn_data)

      expect(row['taxon_name_gbif_taxonomic_status']).to be_nil
    end
  end

  describe '#extract_parent_species_for_taxon' do
    let(:all_taxa) { {} }

    specify 'does not create a parent species when genus is absent from the row' do
      row = CSV::Row.new(
        ['scientificName', 'taxonRank', 'genus', 'specificEpithet', 'infraspecificEpithet'],
        ['bus cus', 'subspecies', nil, 'bus', 'cus']
      )
      normalizer.send(:extract_parent_species_for_taxon, row, 'subspecies', 100, {}, all_taxa)
      expect(all_taxa).to be_empty
    end

    specify 'does not create a parent species when specificEpithet is absent from the row' do
      row = CSV::Row.new(
        ['scientificName', 'taxonRank', 'genus', 'specificEpithet', 'infraspecificEpithet'],
        ['Aus cus', 'subspecies', 'Aus', nil, 'cus']
      )
      normalizer.send(:extract_parent_species_for_taxon, row, 'subspecies', 100, {}, all_taxa)
      expect(all_taxa).to be_empty
    end

    specify 'does not create a parent species when no species ancestor exists in the lookup' do
      row = CSV::Row.new(
        ['scientificName', 'taxonRank', 'genus', 'specificEpithet', 'infraspecificEpithet'],
        ['Aus bus cus', 'subspecies', 'Aus', 'bus', 'cus']
      )
      normalizer.send(:extract_parent_species_for_taxon, row, 'subspecies', 100, {}, all_taxa)
      expect(all_taxa).to be_empty
    end

    specify 'does not duplicate a parent species that is already in all_taxa' do
      row = CSV::Row.new(
        ['scientificName', 'taxonRank', 'genus', 'specificEpithet', 'infraspecificEpithet'],
        ['Aus bus cus', 'subspecies', 'Aus', 'bus', 'cus']
      )
      all_taxa[50] = { 'scientificName' => 'Aus bus', 'taxon_name_id' => 50 }
      ancestor_lookup = { '100:species' => 50 }

      normalizer.send(:extract_parent_species_for_taxon, row, 'subspecies', 100, ancestor_lookup, all_taxa)
      expect(all_taxa.size).to eq(1)
    end

    specify 'constructs parent species scientificName as a bare binomial when taxon metadata is unavailable' do
      row = CSV::Row.new(
        ['scientificName', 'taxonRank', 'genus', 'specificEpithet',
         'infraspecificEpithet', 'scientificNameAuthorship'],
        ['Aus bus cus', 'subspecies', 'Aus', 'bus', 'cus', 'Smith, 1900']
      )
      ancestor_lookup = { '100:species' => 50 }

      normalizer.send(:extract_parent_species_for_taxon, row, 'subspecies', 100, ancestor_lookup, all_taxa)
      expect(all_taxa[50]['scientificName']).to eq('Aus bus')
    end

    specify 'uses the full species name with authorship when taxon metadata is available' do
      row = CSV::Row.new(
        ['scientificName', 'taxonRank', 'genus', 'specificEpithet',
         'infraspecificEpithet', 'scientificNameAuthorship'],
        ['Aus bus cus', 'subspecies', 'Aus', 'bus', 'cus', 'Smith, 1900']
      )
      ancestor_lookup = { '100:species' => 50 }
      taxon_name_info = {
        50 => {
          scientific_name: 'Aus bus (Smith, 1900)',
          scientific_name_authorship: '(Smith, 1900)'
        }
      }

      normalizer.send(:extract_parent_species_for_taxon, row, 'subspecies', 100, ancestor_lookup, all_taxa, taxon_name_info)
      expect(all_taxa[50]['scientificName']).to eq('Aus bus (Smith, 1900)')
    end
  end

  describe '#extract_ancestor_taxa' do
    let(:all_taxa) { {} }

    specify 'does not create ancestor rows for synonym rows' do
      # Synonyms have parentNameUsageID=nil so ancestor rows serve no purpose;
      # creating them from the occurrence row would also be wrong because the
      # row carries the valid name's column values, not the synonym's.
      row = CSV::Row.new(
        ['scientificName', 'taxonRank', 'genus', 'family', 'taxon_name_cached_is_valid'],
        ['Xus xus', 'species', 'Xus', 'Xidae', false]
      )
      ancestor_lookup = { '500:genus' => 50, '500:family' => 25 }

      normalizer.send(:extract_ancestor_taxa, row, 500, 'species', ancestor_lookup, all_taxa)

      expect(all_taxa).to be_empty
    end

    specify 'uses the ancestor full scientific name when taxon metadata is available' do
      row = CSV::Row.new(
        ['scientificName', 'taxonRank', 'genus', 'family'],
        ['Aus bus', 'species', 'Aus', 'Xidae']
      )
      ancestor_lookup = { '500:genus' => 50, '500:family' => 25 }
      taxon_name_info = {
        50 => { scientific_name: 'Aus Jones, 1850', scientific_name_authorship: 'Jones, 1850' },
        25 => { scientific_name: 'Xidae Smith, 1800', scientific_name_authorship: 'Smith, 1800' }
      }

      normalizer.send(:extract_ancestor_taxa, row, 500, 'species', ancestor_lookup, all_taxa, taxon_name_info)

      expect(all_taxa[50]['scientificName']).to eq('Aus Jones, 1850')
      expect(all_taxa[25]['scientificName']).to eq('Xidae Smith, 1800')
    end

    specify 'stops walking toward the root when an ancestor is already present (early termination)' do
      # Family already in all_taxa - loop must break there and not add kingdom or phylum.
      all_taxa[25] = { 'scientificName' => 'Noctuidae', 'taxonRank' => 'family' }

      row = CSV::Row.new(
        ['scientificName', 'taxonRank', 'kingdom', 'phylum', 'family', 'genus'],
        ['Aus bus', 'species', 'Animalia', 'Arthropoda', 'Noctuidae', 'Aus']
      )
      ancestor_lookup = {
        '100:kingdom' => 1,
        '100:phylum'  => 5,
        '100:family'  => 25,
        '100:genus'   => 50
      }

      normalizer.send(:extract_ancestor_taxa, row, 100, 'species', ancestor_lookup, all_taxa)

      expect(all_taxa[50]).to be_present               # genus was added before the break
      expect(all_taxa[25]['scientificName']).to eq('Noctuidae') # family unchanged
      expect(all_taxa[1]).to be_nil                    # kingdom never reached
      expect(all_taxa[5]).to be_nil                    # phylum never reached
    end
  end

  describe '#determine_accepted_name_usage' do
    context 'in accepted_name_usage_id mode when valid name has no UUID in the export' do
      let(:normalizer) do
        described_class.new(
          raw_csv: raw_csv,
          accepted_name_mode: 'accepted_name_usage_id',
          otu_to_taxon_name_data: {},
          occurrence_to_otu: {}
        )
      end

      specify 'returns nil acceptedNameUsageID and synonym status before row-level filtering' do
        taxon = {
          'taxon_name_cached_is_valid' => false,
          'taxon_name_cached_valid_taxon_name_id' => 999
        }

        result = normalizer.send(:determine_accepted_name_usage, taxon, 7, { 100 => 'some-uuid' })

        expect(result).to eq([nil, 'synonym'])
      end

      specify 'build_final_taxon returns nil for a synonym whose accepted name is absent from the export' do
        taxon = {
          'scientificName' => 'Aus bus',
          'taxon_name_cached_is_valid' => false,
          'taxon_name_cached_valid_taxon_name_id' => 999
        }

        result = normalizer.send(
          :build_final_taxon,
          taxon,
          7,
          100,
          { 100 => { rank: 'species', parent_id: nil } },
          { 100 => 7 }
        )

        expect(result).to be_nil
      end
    end
  end

  describe '#ensure_valid_names_for_synonyms' do
    specify 'does not create a duplicate when the valid name is already in all_taxa' do
      valid_tn = FactoryBot.create(:root_taxon_name)

      synonym_taxon = {
        'scientificName' => 'Aus bus var. cus',
        'taxonRank'      => 'variety',
        'taxon_name_cached_is_valid'            => false,
        'taxon_name_cached_valid_taxon_name_id' => valid_tn.id
      }
      existing_valid_taxon = {
        'scientificName'             => valid_tn.cached,
        'taxonRank'                  => 'species',
        'taxon_name_cached_is_valid' => true
      }

      all_taxa = { 999 => synonym_taxon, valid_tn.id => existing_valid_taxon }
      result = normalizer.send(:ensure_valid_names_for_synonyms, all_taxa)

      expect(result.size).to eq(2)
      expect(result[valid_tn.id]['taxonRank']).to eq('species')  # not overwritten
    end

    specify 'creates the valid name entry when it is absent from all_taxa' do
      valid_tn = FactoryBot.create(:root_taxon_name)

      synonym_taxon = {
        'scientificName' => 'Aus bus var. cus',
        'taxonRank'      => 'variety',
        'taxon_name_cached_is_valid'            => false,
        'taxon_name_cached_valid_taxon_name_id' => valid_tn.id
      }

      all_taxa = { 999 => synonym_taxon }
      result = normalizer.send(:ensure_valid_names_for_synonyms, all_taxa)

      expect(result[valid_tn.id]).to be_present
      expect(result[valid_tn.id]['taxon_name_cached_is_valid']).to be(true)
    end
  end

  describe '.infraspecific_rank_names' do
    specify 'returns array of infraspecific ranks' do
      ranks = described_class.infraspecific_rank_names

      expect(ranks).to be_an(Array)
      expect(ranks).to include('subspecies', 'variety', 'form')
      expect(ranks).not_to include('species')
    end

    specify 'does not include ICZN aggregate taxa above species' do
      ranks = described_class.infraspecific_rank_names
      expect(ranks).not_to include('superspecies', 'supersuperspecies', 'subsuperspecies')
    end
  end

  describe '#fix_synonym_rank_columns' do
    let(:normalizer_accepted) do
      described_class.new(
        raw_csv: raw_csv,
        accepted_name_mode: 'accepted_name_usage_id',
        otu_to_taxon_name_data: {},
        occurrence_to_otu: {}
      )
    end

    context 'when a synonym is a form nested under a subspecies' do
      # ICN hierarchy: root → genus(Aus) → species(bus) → subspecies(cus) → form(dus)
      let!(:root)       { FactoryBot.create(:root_taxon_name) }
      let!(:genus)      { Protonym.create!(name: 'Aus', rank_class: Ranks.lookup(:icn, :genus), parent: root) }
      let!(:species)    { Protonym.create!(name: 'bus', rank_class: Ranks.lookup(:icn, :species), parent: genus) }
      let!(:subspecies) { Protonym.create!(name: 'cus', rank_class: Ranks.lookup(:icn, :subspecies), parent: species) }
      let!(:form)       { Protonym.create!(name: 'dus', rank_class: Ranks.lookup(:icn, :form), parent: subspecies) }

      let(:all_taxa) do
        {
          form.id => {
            'taxon_name_id'                      => form.id,
            'scientificName'                     => 'Aus bus cus f. dus',
            'taxon_name_cached_is_valid'         => false,
            'taxon_name_cached_valid_taxon_name_id' => species.id,
            # DwcOccurrence stored the valid name's hierarchy — wrong values inherited
            'genus'               => 'Xus',
            'family'              => 'Xidae',
            'higherClassification' => 'Plantae|Xidae|Xus',
            'specificEpithet'     => nil,
            'infraspecificEpithet' => nil,
            'taxonRank'           => 'species'
          }
        }
      end
      let(:result) { normalizer_accepted.send(:fix_synonym_rank_columns, all_taxa) }

      specify 'infraspecificEpithet is the form epithet, not the subspecies epithet' do
        expect(result[form.id]['infraspecificEpithet']).to eq('dus')
      end

      specify 'taxonRank is form' do
        expect(result[form.id]['taxonRank']).to eq('form')
      end

      specify 'specificEpithet is the species epithet' do
        expect(result[form.id]['specificEpithet']).to eq('bus')
      end

      specify 'genus is corrected from the synonym hierarchy' do
        expect(result[form.id]['genus']).to eq('Aus')
      end

      specify 'family is corrected from the synonym hierarchy' do
        # family comes from synonym ancestors; ICN hierarchy has no family in this fixture,
        # so it will be nil — the point is it is NOT the valid name's placeholder 'Xidae'
        expect(result[form.id]['family']).not_to eq('Xidae')
      end

      specify 'higherClassification reflects the synonym hierarchy' do
        expect(result[form.id]['higherClassification']).not_to include('Xidae')
      end
    end
  end

  describe '#normalize in accepted_name_usage_id mode with an infraspecific synonym' do
    # DwcOccurrence stores the *valid* name's rank and hierarchy for a synonym,
    # so the occurrence row for a subspecies synonym with a species valid name
    # arrives with taxonRank="species", genus from the valid name, etc.
    # fix_synonym_rank_columns corrects the name components: synonyms
    # carry no parentNameUsageID or classification hierarchy — only their own
    # name parts.
    let!(:root)           { FactoryBot.create(:root_taxon_name) }
    let!(:valid_genus)    { Protonym.create!(name: 'Xus',  rank_class: Ranks.lookup(:iczn, :genus),      parent: root) }
    let!(:valid_genus_otu){ FactoryBot.create(:valid_otu, taxon_name: valid_genus) }
    let!(:valid_species)  { Protonym.create!(name: 'xus',  rank_class: Ranks.lookup(:iczn, :species),    parent: valid_genus) }
    let!(:valid_otu)      { FactoryBot.create(:valid_otu, taxon_name: valid_species) }
    let!(:syn_genus)      { Protonym.create!(name: 'Aus',  rank_class: Ranks.lookup(:iczn, :genus),      parent: root) }
    let!(:syn_species)    { Protonym.create!(name: 'bus',  rank_class: Ranks.lookup(:iczn, :species),    parent: syn_genus) }
    let!(:syn_subspecies) { Protonym.create!(name: 'cus',  rank_class: Ranks.lookup(:iczn, :subspecies), parent: syn_species) }
    let!(:otu)            { FactoryBot.create(:valid_otu, taxon_name: syn_subspecies) }

    # DwcOccurrence for a synonym stores the *valid* name's scientificName,
    # taxonRank, genus, and specificEpithet.
    let(:syn_raw_csv) do
      CSV.generate(col_sep: "\t") do |csv|
        csv << %w[dwc_occurrence_object_type dwc_occurrence_object_id
                  scientificName taxonRank genus specificEpithet family]
        csv << ['CollectionObject', '1', 'Xus xus', 'species', 'Xus', 'xus', 'Xidae']
      end
    end

    let(:syn_occurrence_to_otu)        { { 'CollectionObject:1' => otu.id } }
    let(:syn_otu_to_taxon_name_data) do
      {
        otu.id => {
          id:                          syn_subspecies.id,
          cached:                      'Aus bus cus',
          cached_is_valid:             false,
          cached_valid_taxon_name_id:  valid_species.id,
          gbif_taxonomic_status:       'synonym'
        }
      }
    end

    let(:syn_normalizer) do
      described_class.new(
        raw_csv:                 syn_raw_csv,
        accepted_name_mode:      'accepted_name_usage_id',
        otu_to_taxon_name_data:  syn_otu_to_taxon_name_data,
        occurrence_to_otu:       syn_occurrence_to_otu
      )
    end

    let(:output_rows) do
      csv_output, _mapping = syn_normalizer.normalize
      CSV.parse(csv_output, headers: true, col_sep: "\t")
    end

    let(:synonym_row) { output_rows.find { |r| r['scientificName'] == 'Aus bus cus' } }
    let(:accepted_row) { output_rows.find { |r| r['scientificName'] == 'Xus xus' } }
    let(:accepted_genus_row) { output_rows.find { |r| r['scientificName'] == 'Xus' && r['taxonRank'] == 'genus' } }

    specify 'synonym itself has correct taxonRank after correction' do
      expect(synonym_row).to be_present
      expect(synonym_row['taxonRank']).to eq('subspecies')
    end

    specify 'synonym has correct genus from its own hierarchy' do
      expect(synonym_row['genus']).to eq('Aus')
    end

    specify 'synonym has no parentNameUsageID' do
      expect(synonym_row['parentNameUsageID']).to be_nil
    end

    specify 'synonym has no family from the valid name hierarchy' do
      # family comes from the synonym's own ancestors, not the valid name's
      expect(synonym_row['family']).not_to eq('Xidae')
    end

    specify 'auto-added accepted row is normalized to the valid species rank' do
      expect(accepted_row).to be_present
      expect(accepted_row['taxonRank']).to eq('species')
      expect(accepted_row['specificEpithet']).to eq('xus')
      expect(accepted_row['infraspecificEpithet']).to be_nil
      expect(accepted_row['higherClassification']).to eq('Xidae | Xus')
    end

    specify 'adds the corrected accepted genus even though no genus row was input' do
      expect(accepted_genus_row).to be_present
      expect(accepted_genus_row['taxonomicStatus']).to eq('accepted')
    end
  end

  describe '#normalize with empty input' do
    specify 'returns newline and empty hash for empty CSV' do
      empty_csv = CSV.generate(col_sep: "\t") { |csv| csv << ['scientificName'] }

      normalizer = described_class.new(
        raw_csv: empty_csv,
        accepted_name_mode: 'replace_with_accepted_name',
        otu_to_taxon_name_data: {},
        occurrence_to_otu: {}
      )

      csv_output, mapping = normalizer.normalize

      expect(csv_output).to eq("\n")
      expect(mapping).to eq({})
    end
  end
end
