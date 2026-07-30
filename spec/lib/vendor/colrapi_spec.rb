require 'rails_helper'

# Fixture helpers — mirror the actual Colrapi API response shapes.
#
# nameusage result entries are FLAT hashes (no 'usage' wrapper):
#   { 'id', 'status', 'name' => { 'scientificName', 'rank', ... }, 'label', 'labelHtml', ... }
#
# classification (ancestors) entries have 'name' as a plain String (uninomial):
#   { 'id', 'name' => 'Homo', 'rank' => 'genus', 'label', 'labelHtml' }
#
# taxon (single-record) entries returned by Colrapi.taxon without subresource have 'name' as a Hash
# and include a 'parentId' field for iterative traversal.

def col_nameusage_result(id: '6MB3T', scientific_name: 'Homo sapiens', rank: 'species', status: 'accepted', parent_id: nil)
  result = {
    'id'     => id,
    'status' => status,
    'name'   => {
      'scientificName' => scientific_name,
      'rank'           => rank,
      'authorship'     => 'Linnaeus, 1758',
      'specificEpithet' => scientific_name.split.last
    },
    'label'     => "#{scientific_name} Linnaeus, 1758",
    'labelHtml' => "<i>#{scientific_name}</i> Linnaeus, 1758"
  }
  result['parentId'] = parent_id if parent_id
  result
end

def col_classification_entry(id:, name:, rank:)
  # In classification responses 'name' is a plain String
  { 'id' => id, 'name' => name, 'rank' => rank, 'label' => name, 'labelHtml' => name }
end

# A full taxon record as returned by Colrapi.taxon without subresource —
# used in ancestors_via_parent_id traversal.
def col_taxon_record(id:, name:, rank:, parent_id: nil, authorship: nil)
  {
    'id'       => id,
    'parentId' => parent_id,
    'status'   => 'accepted',
    'name'     => {
      'scientificName' => name,
      'rank'           => rank,
      'authorship'     => authorship,
      'uninomial'      => rank.downcase == 'species' ? nil : name
    },
    'label'     => [name, authorship].compact.join(' '),
    'labelHtml' => name
  }
end

describe Vendor::Colrapi, type: :model do

  # ── search ────────────────────────────────────────────────────────────────────

  describe '.search' do
    context 'when Colrapi returns results' do
      before do
        allow(::Colrapi).to receive(:nameusage)
          .with('3LR', q: 'Homo sapiens', limit: 20)
          .and_return({ 'total' => 1, 'result' => [col_nameusage_result] })
      end

      it 'calls Colrapi.nameusage with dataset_id as positional argument' do
        result = described_class.search('Homo sapiens')
        expect(::Colrapi).to have_received(:nameusage).with('3LR', q: 'Homo sapiens', limit: 20)
      end

      it 'returns a hash with total and result keys' do
        result = described_class.search('Homo sapiens')
        expect(result).to include('total', 'result')
      end

      it 'result entries are flat hashes with id, status, name, label' do
        result = described_class.search('Homo sapiens')
        entry = result['result'].first
        expect(entry).to include('id', 'status', 'name', 'label')
        expect(entry.dig('name', 'scientificName')).to eq('Homo sapiens')
        expect(entry['id']).to eq('6MB3T')
        expect(entry['status']).to eq('accepted')
      end
    end

    context 'when Colrapi raises an error' do
      before do
        allow(::Colrapi).to receive(:nameusage).and_raise(StandardError, 'network error')
      end

      it 'returns a safe empty response' do
        result = described_class.search('Anything')
        expect(result).to eq({ 'total' => 0, 'result' => [] })
      end
    end
  end

  # ── ancestors ─────────────────────────────────────────────────────────────────

  describe '.ancestors' do
    let(:classification) {
      [
        col_classification_entry(id: '636X2', name: 'Homo',     rank: 'genus'),
        col_classification_entry(id: '6256T', name: 'Hominidae', rank: 'family'),
        col_classification_entry(id: 'CH2',   name: 'Chordata', rank: 'phylum'),
        col_classification_entry(id: 'N',     name: 'Animalia', rank: 'kingdom'),
      ]
    }

    before do
      allow(::Colrapi).to receive(:taxon)
        .with('3LR', taxon_id: '6MB3T', subresource: 'classification')
        .and_return(classification)
    end

    it 'calls Colrapi.taxon with subresource: classification' do
      described_class.ancestors('6MB3T')
      expect(::Colrapi).to have_received(:taxon)
        .with('3LR', taxon_id: '6MB3T', subresource: 'classification')
    end

    it 'returns an array of classification entries' do
      result = described_class.ancestors('6MB3T')
      expect(result).to be_an(Array)
      expect(result.length).to eq(4)
    end

    it 'each entry has id, name (String), and rank' do
      result = described_class.ancestors('6MB3T')
      entry = result.first
      expect(entry['name']).to be_a(String)
      expect(entry['rank']).to be_a(String)
      expect(entry['id']).to be_a(String)
    end

    it 'returns entries in proximal-to-distal order (genus before kingdom)' do
      result = described_class.ancestors('6MB3T')
      ranks = result.map { |e| e['rank'] }
      expect(ranks.first).to eq('genus')
      expect(ranks.last).to eq('kingdom')
    end

    context 'when Colrapi raises an error' do
      before do
        allow(::Colrapi).to receive(:taxon).and_raise(StandardError, 'timeout')
      end

      it 'returns an empty array' do
        expect(described_class.ancestors('6MB3T')).to eq([])
      end
    end
  end

  # ── build_extension ───────────────────────────────────────────────────────────

  describe '.build_extension' do
    let(:col_result) { col_nameusage_result }

    let(:classification) {
      [
        col_classification_entry(id: '636X2', name: 'Homo', rank: 'genus'),
        col_classification_entry(id: '6256T', name: 'Hominidae', rank: 'family'),
      ]
    }

    before do
      allow(described_class).to receive(:ancestors)
      .with('6MB3T')
      .and_return(classification)
    end

    subject(:extension) { described_class.build_extension(col_result, nil) }

    it 'extracts col_key from top-level id' do
      expect(extension[:col_key]).to eq('6MB3T')
    end

    it 'extracts col_name from name.scientificName' do
      expect(extension[:col_name]).to eq('sapiens')
    end

    it 'extracts col_status from top-level status' do
      expect(extension[:col_status]).to eq('accepted')
    end

    it 'builds alignment from classification entries' do
      expect(extension[:alignment]).to be_an(Array)
      expect(extension[:alignment].length).to eq(2)
    end

    it 'alignment entries have rank, col_name, col_id, dataset_id, taxonworks_id, taxonworks_name, match' do
      entry = extension[:alignment].first
      expect(entry).to include(:rank, :col_name, :col_id, :dataset_id, :taxonworks_id, :taxonworks_name, :match)
    end

    it 'alignment entry dataset_id is the main CoL dataset' do
      entry = extension[:alignment].first
      expect(entry[:dataset_id]).to eq(described_class::DATASETS[:col])
    end

    it 'extension includes col_dataset_id defaulting to main CoL dataset' do
      expect(extension[:col_dataset_id]).to eq(described_class::DATASETS[:col])
    end

    it 'extension col_dataset_id reflects the searched dataset when provided' do
      ext = described_class.build_extension(col_result, nil, dataset_id: '3LXR')
      expect(ext[:col_dataset_id]).to eq('3LXR')
    end

    # Also - the alignment starts at the top
    it 'alignment entry col_name comes from the plain-string name field' do
      entry = extension[:alignment].first
      expect(entry[:col_name]).to eq('Hominidae')
    end

    it 'alignment entry rank is downcased' do
      entry = extension[:alignment].first
      expect(entry[:rank]).to eq('family')
    end

    it 'alignment entry match is none when TaxonName not in project' do
      entry = extension[:alignment].first
      expect(entry[:match]).to eq('none')
      expect(entry[:taxonworks_id]).to be_nil
    end

    context 'when a TaxonName matches an ancestor name' do
      let!(:taxon_name) { FactoryBot.create(:valid_taxon_name) }

      let(:classification_with_match) {
        [col_classification_entry(id: 'XXX', name: taxon_name.cached, rank: 'family')]
      }

      before do
        allow(described_class).to receive(:ancestors)
          .with('6MB3T')
          .and_return(classification_with_match)
      end

      it 'sets match to exact and populates taxonworks_id' do
        ext = described_class.build_extension(col_result, taxon_name.project_id)
        entry = ext[:alignment].first
        expect(entry[:match]).to eq('exact')
        expect(entry[:taxonworks_id]).to eq(taxon_name.id)
        expect(entry[:taxonworks_name]).to eq(taxon_name.cached)
      end
    end

    context 'when result is subgenus rank with paren-wrapped combination' do
      let(:subgenus_result) {
        {
          'id'     => 'SG1',
          'status' => 'accepted',
          'name'   => {
            'scientificName' => 'Cicadula (Cyperana)',
            'uninomial'      => 'Cicadula (Cyperana)',
            'rank'           => 'subgenus',
            'authorship'     => 'Ribaut, 1946'
          },
          'label'     => 'Cicadula (Cyperana) Ribaut, 1946',
          'labelHtml' => '<i>Cicadula (Cyperana)</i> Ribaut, 1946'
        }
      }

      before do
        allow(described_class).to receive(:ancestors).with('SG1').and_return([])
      end

      subject(:ext) { described_class.build_extension(subgenus_result, nil) }

      it 'col_name extracts the epithet from inside the parentheses' do
        expect(ext[:col_name]).to eq('Cyperana')
      end

      it 'col_rank is subgenus' do
        expect(ext[:col_rank]).to eq('subgenus')
      end

      it 'col_authorship is preserved' do
        expect(ext[:col_authorship]).to eq('Ribaut, 1946')
      end
    end

    context 'when col_key is blank' do
      let(:col_result_no_id) { col_nameusage_result(id: nil) }

      it 'skips the ancestors call and returns empty alignment' do
        ext = described_class.build_extension(col_result_no_id, nil)
        expect(described_class).not_to have_received(:ancestors)
        expect(ext[:alignment]).to eq([])
      end
    end

    context 'when dataset is external/denormed (non-backbone)' do
      let(:denormed_result) { col_nameusage_result(id: 'SP1', scientific_name: 'Mus musculus', rank: 'species', parent_id: 'GEN1') }

      let(:genus_record)  { col_taxon_record(id: 'GEN1', name: 'Mus',      rank: 'genus',   parent_id: 'FAM1') }
      let(:family_record) { col_taxon_record(id: 'FAM1', name: 'Muridae',  rank: 'family',  parent_id: nil) }

      before do
        allow(described_class).to receive(:ancestors_via_parent_id)
          .with('9802', 'SP1')
          .and_return([
            col_classification_entry(id: 'FAM1', name: 'Muridae', rank: 'family'),
            col_classification_entry(id: 'GEN1', name: 'Mus',     rank: 'genus')
          ])
      end

      subject(:ext) { described_class.build_extension(denormed_result, nil, dataset_id: '9802') }

      it 'calls ancestors_via_parent_id rather than ancestors' do
        ext
        expect(described_class).to have_received(:ancestors_via_parent_id).with('9802', 'SP1')
        expect(described_class).not_to have_received(:ancestors)
      end

      it 'builds alignment from the denormed ancestor chain' do
        expect(ext[:alignment].length).to eq(2)
      end

      it 'alignment rows carry the external dataset_id' do
        ext[:alignment].each do |row|
          expect(row[:dataset_id]).to eq('9802')
        end
      end

      it 'col_dataset_id reflects the external dataset' do
        expect(ext[:col_dataset_id]).to eq('9802')
      end
    end
  end

  # ── col_backbone_dataset? ────────────────────────────────────────────────────

  describe '.col_backbone_dataset?' do
    it 'returns true for the main CoL dataset' do
      expect(described_class.col_backbone_dataset?('3LR')).to be true
    end

    it 'returns true for the extended CoL dataset' do
      expect(described_class.col_backbone_dataset?('3LXR')).to be true
    end

    it 'returns false for an external dataset' do
      expect(described_class.col_backbone_dataset?('9802')).to be false
    end

    it 'returns false for blank input' do
      expect(described_class.col_backbone_dataset?('')).to be false
    end
  end

  # ── ancestors_via_parent_id ──────────────────────────────────────────────────

  describe '.ancestors_via_parent_id' do
    # Species → genus → family chain, family has no parent (chain stops)
    let(:species_record) { col_taxon_record(id: 'SP1', name: 'Mus musculus', rank: 'species', parent_id: 'GEN1') }
    let(:genus_record)   { col_taxon_record(id: 'GEN1', name: 'Mus',     rank: 'genus',   parent_id: 'FAM1') }
    let(:family_record)  { col_taxon_record(id: 'FAM1', name: 'Muridae', rank: 'family',  parent_id: nil) }

    before do
      allow(::Colrapi).to receive(:taxon).with('9802', taxon_id: 'SP1').and_return(species_record)
      allow(::Colrapi).to receive(:taxon).with('9802', taxon_id: 'GEN1').and_return(genus_record)
      allow(::Colrapi).to receive(:taxon).with('9802', taxon_id: 'FAM1').and_return(family_record)
    end

    subject(:chain) { described_class.ancestors_via_parent_id('9802', 'SP1') }

    it 'returns an array of ancestor hashes' do
      expect(chain).to be_an(Array)
    end

    it 'does not include the starting taxon' do
      names = chain.map { |e| e['name'] }
      expect(names).not_to include('Mus musculus')
    end

    it 'returns ancestors in distal-first order (family before genus) matching the classification subresource' do
      expect(chain[0]['name']).to eq('Muridae')
      expect(chain[1]['name']).to eq('Mus')
    end

    it 'each entry has id, name (String), rank' do
      entry = chain.first
      expect(entry['id']).to be_a(String)
      expect(entry['name']).to be_a(String)
      expect(entry['rank']).to be_a(String)
    end

    it 'stops when parentId is blank' do
      expect(chain.length).to eq(2)
    end

    context 'when the initial taxon has no parentId' do
      let(:orphan) { col_taxon_record(id: 'ROOT', name: 'Animalia', rank: 'kingdom', parent_id: nil) }

      before do
        allow(::Colrapi).to receive(:taxon).with('9802', taxon_id: 'ROOT').and_return(orphan)
      end

      it 'returns an empty chain' do
        expect(described_class.ancestors_via_parent_id('9802', 'ROOT')).to eq([])
      end
    end

    context 'when Colrapi raises an error' do
      before do
        allow(::Colrapi).to receive(:taxon).and_raise(StandardError, 'timeout')
      end

      it 'returns an empty array' do
        expect(described_class.ancestors_via_parent_id('9802', 'SP1')).to eq([])
      end
    end

  end

  # ── VCR integration ──────────────────────────────────────────────────────────

  context 'VCR integration — Mammal Diversity Database (dataset 9802)' do
    it 'retrieves real ancestors for Mus musculus via parentId traversal' do
      VCR.use_cassette('colrapi_denormed_ancestors_mus_musculus') do
        search_result = ::Vendor::Colrapi.search('Mus musculus', dataset_id: '9802')
        taxon_id = search_result.dig('result', 0, 'id')
        skip 'No results returned from dataset 9802' if taxon_id.blank?

        chain = described_class.ancestors_via_parent_id('9802', taxon_id)

        expect(chain).to be_an(Array)
        expect(chain).to all(include('id', 'name', 'rank'))
        expect(chain.map { |e| e['name'] }).to all(be_a(String))
      end
    end
  end

  context 'VCR integration — Lepisma authorship in default CoL dataset (3LR)' do
    # CoL 3LR returns two results for "Lepisma":
    #   1. Accepted zoological genus (id: 5CN8) — no authorship field in name hash,
    #      basionymOrCombinationAuthorship: {}, label: "Lepisma".  CoL has no author
    #      data for this record; col_authorship is correctly nil.
    #   2. Botanical synonym (id: 5TBX9, authorship: "E.Mey.") — a different organism.
    # TODO: Failing because authorship is no longer absent. Either update expectation or find new example if the intention is to test nil authorship
    xit 'accepted Lepisma (zoological) has nil col_authorship — CoL carries no author data for this record' do
      VCR.use_cassette('colrapi_lepisma_authorship') do
        search_result = ::Vendor::Colrapi.search('Lepisma')
        lepisma_result = search_result['result'].find { |r|
          r.dig('name', 'scientificName') == 'Lepisma' && r['status'] == 'accepted'
        }
        skip 'No accepted result for Lepisma found in CoL 3LR' if lepisma_result.nil?

        ext = described_class.build_extension(lepisma_result, nil)

        expect(ext[:col_authorship]).to be_nil
        expect(ext[:col_name]).to eq('Lepisma')
        expect(ext[:col_status]).to eq('accepted')
      end
    end

    it 'botanical Lepisma synonym has col_authorship populated from name.authorship' do
      VCR.use_cassette('colrapi_lepisma_authorship') do
        search_result = ::Vendor::Colrapi.search('Lepisma')
        botanical_result = search_result['result'].find { |r|
          r.dig('name', 'scientificName') == 'Lepisma' && r['status'] == 'synonym'
        }
        skip 'No synonym result for Lepisma found in CoL 3LR' if botanical_result.nil?

        ext = described_class.build_extension(botanical_result, nil)

        expect(ext[:col_authorship]).to eq('E.Mey.')
      end
    end
  end

  context 'VCR integration — Cicadula (Cyperana) subgenus in default CoL dataset (3LR)' do
    it 'col_name is the epithet Cyperana, not the full combination Cicadula (Cyperana)' do
      VCR.use_cassette('colrapi_subgenus_cicadula_cyperana') do
        search_result = ::Vendor::Colrapi.search('Cicadula (Cyperana)')
        subgenus_result = search_result['result'].find { |r|
          r.dig('name', 'rank')&.downcase == 'subgenus'
        }
        skip 'No subgenus result for Cicadula (Cyperana) found in CoL 3LR' if subgenus_result.nil?

        ext = described_class.build_extension(subgenus_result, nil)

        expect(ext[:col_rank]).to eq('subgenus')
        expect(ext[:col_name]).to eq('Cyperana'),
          "Expected 'Cyperana' but got '#{ext[:col_name]}'; raw scientificName: #{subgenus_result.dig('name', 'scientificName').inspect}"
      end
    end
  end

  context 'VCR integration — Crayracion ambiguous synonym against default CoL dataset (3LR)' do
    it 'alignment does not contain a genus-rank ancestor for the ambiguous synonym Crayracion' do
      VCR.use_cassette('colrapi_build_extension_crayracion_ambiguous_synonym') do
        search_result = ::Vendor::Colrapi.search('Crayracion')
        crayracion_result = search_result['result'].find { |r|
          r.dig('name', 'scientificName') == 'Crayracion' && r['status'] == 'ambiguous synonym'
        }
        skip 'No ambiguous synonym result for Crayracion found in CoL 3LR' if crayracion_result.nil?

        ext = described_class.build_extension(crayracion_result, nil)

        expect(ext[:col_status]).to eq('ambiguous synonym')
        expect(ext[:col_rank]).to eq('genus')

        alignment_ranks = ext[:alignment].map { |r| r[:rank] }
        alignment_col_names = ext[:alignment].map { |r| r[:col_name] }

        expect(alignment_ranks).not_to include('genus'),
          "genus-rank ancestor must not appear in alignment for genus-rank ambiguous synonym; got: #{ext[:alignment].map { |r| [r[:rank], r[:col_name]] }.inspect}"

        expect(alignment_col_names).to include('Tetraodontidae'),
          "Tetraodontidae (family) should appear as the proximal ancestor; got: #{alignment_col_names.inspect}"
      end
    end
  end

  context 'VCR integration — Campa synonym against default CoL dataset (3LR)' do
    it 'alignment does not contain the accepted genus as an ancestor of the synonym' do
      VCR.use_cassette('colrapi_build_extension_campa_synonym') do
        search_result = ::Vendor::Colrapi.search('Campa')
        campa_result  = search_result['result'].find { |r|
          r.dig('name', 'scientificName') == 'Campa' && r['status'] == 'synonym'
        }
        skip 'No synonym result for Campa found in CoL 3LR' if campa_result.nil?

        accepted_name = campa_result.dig('accepted', 'name', 'scientificName')
        accepted_id   = campa_result.dig('accepted', 'id')

        ext = described_class.build_extension(campa_result, nil)

        expect(ext[:col_status]).to eq('synonym')

        alignment_col_names = ext[:alignment].map { |r| r[:col_name] }
        alignment_col_ids   = ext[:alignment].map { |r| r[:col_id] }
        alignment_ranks     = ext[:alignment].map { |r| r[:rank] }

        expect(alignment_col_names).not_to include(accepted_name),
          "Accepted name '#{accepted_name}' must not appear in alignment for synonym 'Campa'"
        expect(alignment_col_ids).not_to include(accepted_id),
          "Accepted name ID '#{accepted_id}' must not appear in alignment for synonym 'Campa'"

        # No ancestor may be at the same rank as the synonym itself (genus cannot parent genus).
        expect(alignment_ranks).not_to include(ext[:col_rank]),
          "Ancestor at same rank '#{ext[:col_rank]}' must not appear for synonym 'Campa'; got ranks: #{alignment_ranks.inspect}"
      end
    end
  end

end
