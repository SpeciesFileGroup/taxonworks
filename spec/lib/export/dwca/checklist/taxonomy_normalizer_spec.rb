# frozen_string_literal: true

require 'rails_helper'

describe Export::Dwca::Checklist::TaxonomyNormalizer, type: :model, group: :darwin_core do
  let(:normalizer) do
    described_class.new(
      raw_csv: raw_csv,
      accepted_name_mode: 'replace_with_accepted_name',
      otu_to_taxon_name_data: {},
      occurrence_to_otu: {}
    )
  end

  let(:raw_csv) do
    CSV.generate(col_sep: "\t") do |csv|
      csv << ['scientificName', 'taxonRank']
      csv << ['Aus bus', 'species']
    end
  end

  describe '#remove_empty_columns' do
    specify 'removes columns with no data across all taxa' do
      taxa = [
        { 'id' => 1, 'scientificName' => 'Aus', 'family' => 'Idae', 'order' => nil },
        { 'id' => 2, 'scientificName' => 'Bus', 'family' => 'Idae', 'order' => nil }
      ]

      result = normalizer.send(:remove_empty_columns, taxa)

      expect(result.first.keys).to include('id', 'scientificName', 'family')
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

  describe '#clear_lower_ranks' do
    let(:taxon) do
      {
        'kingdom' => 'Animalia',
        'phylum' => 'Arthropoda',
        'class' => 'Insecta',
        'order' => 'Lepidoptera',
        'family' => 'Noctuidae',
        'genus' => 'Aus',
        'scientificName' => 'Aus',
        'taxonRank' => 'genus',
        'specificEpithet' => 'bus',
        'scientificNameAuthorship' => 'Smith, 1900'
      }
    end

    specify 'clears ranks lower than the current rank' do
      normalizer.send(:clear_lower_ranks, taxon, 'family')

      expect(taxon['family']).to eq('Noctuidae')
      expect(taxon['genus']).to be_nil
      expect(taxon['specificEpithet']).to be_nil
    end

    specify 'computes higherClassification from higher ranks' do
      normalizer.send(:clear_lower_ranks, taxon, 'genus')

      expected = "Animalia#{Export::Dwca::DELIMITER}Arthropoda#{Export::Dwca::DELIMITER}" \
                 "Insecta#{Export::Dwca::DELIMITER}Lepidoptera#{Export::Dwca::DELIMITER}Noctuidae"
      expect(taxon['higherClassification']).to eq(expected)
    end

    specify 'sets higherClassification to nil for top rank' do
      normalizer.send(:clear_lower_ranks, taxon, 'kingdom')

      expect(taxon['higherClassification']).to be_nil
    end

    specify 'keeps fields for rank columns and scientificName' do
      normalizer.send(:clear_lower_ranks, taxon, 'genus')

      expect(taxon['scientificName']).to eq('Aus')
      expect(taxon['taxonRank']).to eq('genus')
      expect(taxon['family']).to eq('Noctuidae')
    end

    specify 'clears non-rank fields for extracted taxa' do
      normalizer.send(:clear_lower_ranks, taxon, 'family', 'species')

      # Should clear authorship and epithet since we're extracting family from species
      expect(taxon['scientificNameAuthorship']).to be_nil
      expect(taxon['specificEpithet']).to be_nil
    end

    specify 'keeps specificEpithet for species rank' do
      normalizer.send(:clear_lower_ranks, taxon, 'species')

      expect(taxon['specificEpithet']).to eq('bus')
    end

    specify 'keeps specificEpithet and infraspecificEpithet for subspecies' do
      taxon['infraspecificEpithet'] = 'cus'
      normalizer.send(:clear_lower_ranks, taxon, 'subspecies')

      expect(taxon['specificEpithet']).to eq('bus')
      expect(taxon['infraspecificEpithet']).to eq('cus')
    end
  end

  describe '#determine_accepted_name_usage' do
    let(:taxon_name_id_to_taxon_id) { { 100 => 5, 200 => 10 } }

    context 'in replace_with_accepted_name mode' do
      specify 'returns nil for both values' do
        result = normalizer.send(
          :determine_accepted_name_usage,
          {},
          1,
          taxon_name_id_to_taxon_id
        )

        expect(result).to eq([nil, nil])
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
          taxon_name_id_to_taxon_id
        )

        expect(result).to eq([5, 'accepted'])
      end

      specify 'returns acceptedNameUsageID for synonyms' do
        taxon = {
          'taxon_name_cached_is_valid' => false,
          'taxon_name_cached_valid_taxon_name_id' => 100
        }

        result = normalizer.send(
          :determine_accepted_name_usage,
          taxon,
          7,
          taxon_name_id_to_taxon_id
        )

        expect(result).to eq([5, 'synonym'])
      end

      specify 'returns self-reference for extracted taxa with no validity data' do
        taxon = {}

        result = normalizer.send(
          :determine_accepted_name_usage,
          taxon,
          8,
          taxon_name_id_to_taxon_id
        )

        expect(result).to eq([8, 'accepted'])
      end
    end
  end

  describe '#assign_sequential_taxon_ids' do
    specify 'assigns sequential IDs starting from 1' do
      all_taxa = {
        100 => { 'scientificName' => 'Aus' },
        200 => { 'scientificName' => 'Bus' }
      }
      taxon_name_info = {
        100 => { rank: 'genus', parent_id: nil },
        200 => { rank: 'genus', parent_id: nil }
      }

      taxa_with_ids, mapping = normalizer.send(
        :assign_sequential_taxon_ids,
        all_taxa,
        taxon_name_info
      )

      expect(mapping[100]).to eq(1)
      expect(mapping[200]).to eq(2)
      expect(taxa_with_ids.size).to eq(2)
    end

    specify 'processes taxa in rank order' do
      all_taxa = {
        100 => { 'scientificName' => 'Noctuidae' },   # family
        200 => { 'scientificName' => 'Insecta' },     # class
        300 => { 'scientificName' => 'Lepidoptera' }  # order
      }
      taxon_name_info = {
        100 => { rank: 'family', parent_id: 300 },
        200 => { rank: 'class', parent_id: nil },
        300 => { rank: 'order', parent_id: 200 }
      }

      taxa_with_ids, mapping = normalizer.send(
        :assign_sequential_taxon_ids,
        all_taxa,
        taxon_name_info
      )

      # Class first, then order, then family
      expect(mapping[200]).to eq(1)  # class
      expect(mapping[300]).to eq(2)  # order
      expect(mapping[100]).to eq(3)  # family
    end

    specify 'sorts alphabetically within same rank' do
      all_taxa = {
        100 => { 'scientificName' => 'Zus' },
        200 => { 'scientificName' => 'Aus' },
        300 => { 'scientificName' => 'Mus' }
      }
      taxon_name_info = {
        100 => { rank: 'genus', parent_id: nil },
        200 => { rank: 'genus', parent_id: nil },
        300 => { rank: 'genus', parent_id: nil }
      }

      taxa_with_ids, mapping = normalizer.send(
        :assign_sequential_taxon_ids,
        all_taxa,
        taxon_name_info
      )

      expect(mapping[200]).to eq(1)  # Aus
      expect(mapping[300]).to eq(2)  # Mus
      expect(mapping[100]).to eq(3)  # Zus
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
        100 => { rank: 'species', parent_id: 50 },
        50 => { rank: 'genus', parent_id: 25 },
        25 => { rank: 'family', parent_id: nil }
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
        'taxon_name_id' => 100
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
        'taxon_name_id'
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
  end

  describe '.infraspecific_rank_names' do
    specify 'returns array of infraspecific ranks' do
      ranks = described_class.infraspecific_rank_names

      expect(ranks).to be_an(Array)
      expect(ranks).to include('subspecies', 'variety', 'form')
      expect(ranks).not_to include('species')
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
