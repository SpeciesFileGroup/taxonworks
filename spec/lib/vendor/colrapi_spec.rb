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
    # The real classification subresource returns kingdom-first (distal-to-proximal) —
    # confirmed directly against the live ChecklistBank API.
    let(:classification) {
      [
        col_classification_entry(id: 'N',     name: 'Animalia', rank: 'kingdom'),
        col_classification_entry(id: 'CH2',   name: 'Chordata', rank: 'phylum'),
        col_classification_entry(id: '6256T', name: 'Hominidae', rank: 'family'),
        col_classification_entry(id: '636X2', name: 'Homo',     rank: 'genus'),
      ]
    }

    before do
      allow(::Colrapi).to receive(:taxon)
        .with('3LR', taxon_id: '6MB3T', subresource: 'classification')
        .and_return(classification)
    end

    it 'calls Colrapi.taxon with subresource: classification' do
      described_class.ancestors('3LR', '6MB3T')
      expect(::Colrapi).to have_received(:taxon)
        .with('3LR', taxon_id: '6MB3T', subresource: 'classification')
    end

    it 'returns an array of classification entries' do
      result = described_class.ancestors('3LR', '6MB3T')
      expect(result).to be_an(Array)
      expect(result.length).to eq(4)
    end

    it 'each entry has id, name (String), and rank' do
      result = described_class.ancestors('3LR', '6MB3T')
      entry = result.first
      expect(entry['name']).to be_a(String)
      expect(entry['rank']).to be_a(String)
      expect(entry['id']).to be_a(String)
    end

    it 'returns entries in distal-to-proximal order (kingdom before genus)' do
      result = described_class.ancestors('3LR', '6MB3T')
      ranks = result.map { |e| e['rank'] }
      expect(ranks.first).to eq('kingdom')
      expect(ranks.last).to eq('genus')
    end

    context 'when Colrapi raises an error' do
      before do
        allow(::Colrapi).to receive(:taxon).and_raise(StandardError, 'timeout')
      end

      it 'returns an empty array' do
        expect(described_class.ancestors('3LR', '6MB3T')).to eq([])
      end
    end
  end

  # ── rank_class_for ────────────────────────────────────────────────────────────

  describe '.rank_class_for' do
    # When col_code is recognized only that code's lookup is used; otherwise
    # falls back through all four codes in order.
    it 'resolves species as ICN for botanical code' do
      result = described_class.rank_class_for('species', col_code: 'botanical')
      expect(result).to include('Icn')
      expect(result).not_to include('Iczn')
    end

    it 'resolves species as ICZN for zoological code' do
      result = described_class.rank_class_for('species', col_code: 'zoological')
      expect(result).to include('Iczn')
      expect(result).not_to include('::Icn::')
    end

    it 'resolves genus as ICNP for bacterial code' do
      result = described_class.rank_class_for('genus', col_code: 'bacterial')
      expect(result).to include('Icnp')
    end

    it 'resolves genus as ICVCN for virus code (CoL\'s name for it)' do
      result = described_class.rank_class_for('genus', col_code: 'virus')
      expect(result).to include('Icvcn')
    end

    it 'doesn\'t fall back to another code when col_code is recognized' do
      expect(described_class.rank_class_for('variety', col_code: 'zoological'))
        .to be_nil
    end

    it 'falls back through all codes when col_code is nil' do
      expect(described_class.rank_class_for('species')).to include('Iczn')
    end

    it 'returns nil for unknown rank' do
      expect(described_class.rank_class_for('domain')).to be_nil
    end

    it 'returns nil for blank rank' do
      expect(described_class.rank_class_for('')).to be_nil
      expect(described_class.rank_class_for(nil)).to be_nil
    end

    it 'is case-insensitive' do
      expect(described_class.rank_class_for('SPECIES', col_code: 'zoological'))
        .to eq(described_class.rank_class_for('species', col_code: 'zoological'))
    end
  end

  # ── classified_usage ─────────────────────────────────────────────────────────

  describe '.protonym_name_from' do
    specify 'a subgenus is its infragenericEpithet' do
      name = {
        'scientificName' => 'Aedes (Stegomyia)', 'genus' => 'Aedes',
        'infragenericEpithet' => 'Stegomyia', 'rank' => 'subgenus'
      }
      expect(described_class.protonym_name_from(name)).to eq('Stegomyia')
    end

    specify 'a species in a subgenus is its specificEpithet' do
      name = {
        'scientificName' => 'Aedes (Stegomyia) aegypti', 'genus' => 'Aedes',
        'infragenericEpithet' => 'Stegomyia', 'specificEpithet' => 'aegypti',
        'rank' => 'species'
      }
      expect(described_class.protonym_name_from(name)).to eq('aegypti')
    end

    specify 'a genus is its uninomial' do
      name = { 'scientificName' => 'Aedes', 'uninomial' => 'Aedes' }
      expect(described_class.protonym_name_from(name)).to eq('Aedes')
    end
  end

  describe '.classified_usage' do
    let(:col_result) { col_nameusage_result }

    # ancestors() (the real classification subresource) returns kingdom-first
    # (distal before proximal) — family before genus here.
    let(:classification) {
      [
        col_classification_entry(id: '6256T', name: 'Hominidae', rank: 'family'),
        col_classification_entry(id: '636X2', name: 'Homo', rank: 'genus'),
      ]
    }

    before do
      allow(described_class).to receive(:ancestors)
      .with(described_class::DATASETS[:col], '6MB3T')
      .and_return(classification)
    end

    subject(:extension) { described_class.classified_usage(col_result) }

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

    it 'alignment entries have rank, col_name, col_id, dataset_id, col_authorship' do
      entry = extension[:alignment].first
      expect(entry).to include(:rank, :col_name, :col_id, :dataset_id, :col_authorship)
    end

    it 'alignment entry dataset_id is the main CoL dataset' do
      entry = extension[:alignment].first
      expect(entry[:dataset_id]).to eq(described_class::DATASETS[:col])
    end

    it 'extension includes col_dataset_id defaulting to main CoL dataset' do
      expect(extension[:col_dataset_id]).to eq(described_class::DATASETS[:col])
    end

    context 'when the extended dataset was searched' do
      before do
        allow(described_class).to receive(:ancestors)
          .with('3LXR', '6MB3T')
          .and_return(classification)
      end

      let(:ext) {
        described_class.classified_usage(col_result, dataset_id: '3LXR')
      }

      it 'extension col_dataset_id reflects the searched dataset' do
        expect(ext[:col_dataset_id]).to eq('3LXR')
      end

      it 'takes the alignment from that dataset' do
        expect(ext[:alignment].map { |a| a[:dataset_id] }.uniq)
          .to eq(['3LXR'])
      end
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

    context 'when an ancestor rank has no TaxonWorks equivalent' do
      let(:classification) {
        [
          col_classification_entry(id: '8VVWB', name: 'Osteichthyes', rank: 'parvphylum'),
          col_classification_entry(id: '6256T', name: 'Hominidae', rank: 'family')
        ]
      }

      it 'flags that row rank_unknown' do
        expect(extension[:alignment].map { |r| [r[:rank], r[:rank_unknown]] })
          .to eq([['parvphylum', true], ['family', false]])
      end
    end

    context 'when result is subgenus rank' do
      # As CoL parses it: genus + infragenericEpithet, no uninomial
      let(:subgenus_result) {
        {
          'id'     => 'SG1',
          'status' => 'accepted',
          'name'   => {
            'scientificName' => 'Cicadula (Cyperana)',
            'genus' => 'Cicadula',
            'infragenericEpithet' => 'Cyperana',
            'rank'           => 'subgenus',
            'authorship'     => 'Ribaut, 1946'
          },
          'label'     => 'Cicadula (Cyperana) Ribaut, 1946',
          'labelHtml' => '<i>Cicadula (Cyperana)</i> Ribaut, 1946'
        }
      }

      before do
        allow(described_class).to receive(:ancestors)
          .with(described_class::DATASETS[:col], 'SG1').and_return([])
      end

      subject(:ext) { described_class.classified_usage(subgenus_result) }

      it 'col_name is the subgenus epithet' do
        expect(ext[:col_name]).to eq('Cyperana')
      end

      it 'col_rank is subgenus' do
        expect(ext[:col_rank]).to eq('subgenus')
      end

      it 'col_authorship is preserved' do
        expect(ext[:col_authorship]).to eq('Ribaut, 1946')
      end
    end

    context 'when the result is not accepted' do
      # CoL hangs a synonym off its accepted taxon, so the only classification
      # it has is the accepted name's - nothing about the synonym's own genus
      # or family (e.g. "Cercopis aptera", a cercopid genus, -> Falcidius
      # aptera in Issidae).
      let(:col_result) {
        col_nameusage_result(
          id: '9XJPQ', scientific_name: 'Cercopis aptera', status: 'synonym'
        ).merge(
          'accepted' => {
            'id' => '3DT8H',
            'name' => {
              'scientificName' => 'Falcidius aptera',
              'authorship' => '(Fabricius, 1794)', 'rank' => 'species'
            }
          }
        )
      }

      it 'has no alignment, and fetches none' do
        expect(extension[:alignment]).to eq([])
        expect(described_class).not_to have_received(:ancestors)
      end

      it 'is flagged non_accepted' do
        expect(extension[:non_accepted]).to be true
      end

      it 'carries the accepted name' do
        expect(extension[:accepted]).to eq(
          col_name: 'Falcidius aptera', col_authorship: '(Fabricius, 1794)'
        )
      end

      context 'as an ambiguous synonym' do
        let(:col_result) {
          col_nameusage_result(
            id: 'AMB1', scientific_name: 'Crayracion',
            status: 'ambiguous synonym'
          )
        }

        it 'is flagged non_accepted, with no accepted name' do
          expect(extension[:non_accepted]).to be true
          expect(extension[:accepted]).to be_nil
        end
      end

      context 'as provisionally accepted' do
        let(:col_result) {
          col_nameusage_result(status: 'provisionally accepted')
        }

        it 'is treated as accepted' do
          expect(extension[:non_accepted]).to be false
          expect(extension[:alignment]).not_to be_empty
        end
      end
    end

    context 'with a subgenus ancestor' do
      let(:classification) {
        [
          col_classification_entry(id: 'G1', name: 'Aedes', rank: 'genus'),
          col_classification_entry(
            id: 'SG1', name: 'Aedes (Stegomyia)', rank: 'subgenus'
          )
        ]
      }

      it 'keeps its name as CoL gives it (keys and creation reduce it)' do
        expect(extension[:alignment].map { |a| a[:col_name] })
          .to eq(['Aedes', 'Aedes (Stegomyia)'])
      end
    end

    context 'when col_key is blank' do
      let(:col_result_no_id) { col_nameusage_result(id: nil) }

      it 'skips the ancestors call and returns empty alignment' do
        ext = described_class.classified_usage(col_result_no_id)
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

      subject(:ext) { described_class.classified_usage(denormed_result, dataset_id: '9802') }

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

  # ── col_rank_sort ────────────────────────────────────────────────────────────

  describe '.col_rank_sort' do
    it 'uses the lookup for the given code' do
      expect(described_class.col_rank_sort('genus', 'botanical'))
        .to eq(::RANK_SORT[::ICN_LOOKUP['genus']])
    end

    it 'treats an unrecognized code as zoological' do
      expect(described_class.col_rank_sort('genus', nil))
        .to eq(::RANK_SORT[::ICZN_LOOKUP['genus']])
    end

    it 'does not fall back to another code' do
      expect(::ICZN_LOOKUP['variety']).to be_nil
      expect(::ICN_LOOKUP['variety']).to be_present
      expect(described_class.col_rank_sort('variety', 'zoological')).to be_nil
    end

    it 'orders a more specific rank higher' do
      expect(described_class.col_rank_sort('species', 'zoological'))
        .to be > described_class.col_rank_sort('genus', 'zoological')
    end
  end

  # ── resolve_accepted_names ───────────────────────────────────────────────────

  describe '.resolve_accepted_names' do
    def stub_hits(*hits)
      allow(::Colrapi).to receive(:nameusage)
        .and_return({ 'total' => hits.size, 'result' => hits })
    end

    def synonym_of(hit, id:, name:, authorship: 'Linnaeus, 1758')
      hit.merge(
        'accepted' => {
          'id' => id,
          'status' => 'accepted',
          'name' => { 'scientificName' => name, 'authorship' => authorship }
        }
      )
    end

    context 'when CoL has no results' do
      before { stub_hits }

      it 'returns nothing' do
        expect(described_class.resolve_accepted_names('Nonexistens')).to eq([])
      end
    end

    context 'when the hit is accepted' do
      before do
        stub_hits(col_nameusage_result(
          id: '6MB3T', scientific_name: 'Homo sapiens', status: 'accepted'
        ))
      end

      it 'resolves to the matched name itself' do
        result = described_class.resolve_accepted_names('Homo sapiens').first
        expect(result[:matched_name]).to eq('Homo sapiens')
        expect(result[:matched_status]).to eq('accepted')
        expect(result[:valid_name]).to eq('Homo sapiens')
        expect(result[:valid_col_key]).to eq('6MB3T')
        expect(result[:valid_status]).to eq('accepted')
        expect(result[:dataset_id]).to eq('3LR')
      end

      it 'returns the hit itself as valid_col_result' do
        result = described_class.resolve_accepted_names('Homo sapiens').first
        expect(result[:valid_col_result]).to include('id' => '6MB3T')
      end
    end

    context 'when the hit is a synonym with a single accepted target' do
      let(:synonym_result) do
        synonym_of(
          col_nameusage_result(
            id: 'SYN1', scientific_name: 'Bison bison', status: 'synonym'
          ),
          id: 'ACC1', name: 'Bos bison'
        )
      end

      before { stub_hits(synonym_result) }

      it 'resolves to the accepted target, not the matched synonym' do
        result = described_class.resolve_accepted_names('Bison bison').first
        expect(result[:matched_name]).to eq('Bison bison')
        expect(result[:matched_authorship]).to eq('Linnaeus, 1758')
        expect(result[:matched_status]).to eq('synonym')
        expect(result[:matched_col_key]).to eq('SYN1')
        expect(result[:valid_name]).to eq('Bos bison')
        expect(result[:valid_col_key]).to eq('ACC1')
        expect(result[:valid_authorship]).to eq('Linnaeus, 1758')
        expect(result[:valid_status]).to eq('accepted')
      end

      it 'returns the nested accepted usage as valid_col_result' do
        result = described_class.resolve_accepted_names('Bison bison').first
        expect(result[:valid_col_result]).to eq(synonym_result['accepted'])
      end
    end

    # CoL attaches an `accepted` usage to these too, but it isn't what the
    # name means.
    specify 'misapplied names are skipped' do
      stub_hits(
        synonym_of(
          col_nameusage_result(
            id: 'MIS1', scientific_name: 'Crayracion', status: 'misapplied'
          ),
          id: 'ACC3', name: 'Lagocephalus'
        )
      )
      expect(described_class.resolve_accepted_names('Crayracion')).to eq([])
    end

    # A pro parte synonym: one hit per accepted name.
    specify 'an ambiguous synonym resolves to each of its targets' do
      stub_hits(
        synonym_of(
          col_nameusage_result(
            id: 'AB1', scientific_name: 'Abax brunnipes',
            status: 'ambiguous synonym'
          ),
          id: 'AP1', name: 'Abax parallelepipedus parallelepipedus'
        ),
        synonym_of(
          col_nameusage_result(
            id: 'AB2', scientific_name: 'Abax brunnipes',
            status: 'ambiguous synonym'
          ),
          id: 'AC1', name: 'Abax carinatus carinatus'
        )
      )
      results = described_class.resolve_accepted_names('Abax brunnipes')
      expect(results.map { |r| [r[:valid_col_key], r[:matched_status]] })
        .to eq([%w{AP1 ambiguous\ synonym}, %w{AC1 ambiguous\ synonym}])
    end

    specify 'an accepted name reached by an ambiguous and a plain synonym ' \
      'comes from the plain one' do
      stub_hits(
        synonym_of(
          col_nameusage_result(
            id: 'AMB1', scientific_name: 'Aus bus',
            status: 'ambiguous synonym'
          ),
          id: 'ACC1', name: 'Cus dus'
        ),
        synonym_of(
          col_nameusage_result(
            id: 'SYN1', scientific_name: 'Aus bus', status: 'synonym'
          ),
          id: 'ACC1', name: 'Cus dus'
        )
      )
      results = described_class.resolve_accepted_names('Aus bus')
      expect(results.map { |r| r[:matched_col_key] }).to eq(%w{SYN1})
    end

    specify 'a provisionally accepted hit resolves to itself' do
      stub_hits(col_nameusage_result(
        id: 'PRO1', scientific_name: 'Aus bus',
        status: 'provisionally accepted'
      ))
      result = described_class.resolve_accepted_names('Aus bus').first
      expect(result[:valid_col_key]).to eq('PRO1')
      expect(result[:valid_status]).to eq('provisionally accepted')
    end

    # Abies alba Mill. (accepted) and its later homonym Abies alba (Aiton)
    # Michx., a synonym of Picea glauca; a misapplied use is skipped.
    specify 'homonyms each resolve, in CoL order' do
      stub_hits(
        col_nameusage_result(
          id: 'AA1', scientific_name: 'Abies alba', status: 'accepted'
        ),
        synonym_of(
          col_nameusage_result(
            id: 'AA2', scientific_name: 'Abies alba', status: 'synonym'
          ),
          id: 'PG1', name: 'Picea glauca', authorship: '(Moench) Voss'
        ),
        synonym_of(
          col_nameusage_result(
            id: 'AA3', scientific_name: 'Abies alba', status: 'misapplied'
          ),
          id: 'PO1', name: 'Picea omorika'
        )
      )
      results = described_class.resolve_accepted_names('Abies alba')
      expect(results.map { |r| r[:valid_col_key] }).to eq(%w{AA1 PG1})
    end

    specify 'an accepted name reached twice is given once, as itself' do
      stub_hits(
        synonym_of(
          col_nameusage_result(
            id: 'SYN1', scientific_name: 'Aus bus', status: 'synonym'
          ),
          id: 'ACC1', name: 'Aus bus'
        ),
        col_nameusage_result(
          id: 'ACC1', scientific_name: 'Aus bus', status: 'accepted'
        ),
        synonym_of(
          col_nameusage_result(
            id: 'SYN2', scientific_name: 'Aus bus', status: 'synonym'
          ),
          id: 'ACC1', name: 'Aus bus'
        )
      )
      results = described_class.resolve_accepted_names('Aus bus')
      expect(results.map { |r| r[:matched_col_key] }).to eq(%w{ACC1})
    end

    specify 'two synonyms of one accepted name give it once' do
      stub_hits(
        synonym_of(
          col_nameusage_result(
            id: 'SYN1', scientific_name: 'Aus bus', status: 'synonym'
          ),
          id: 'ACC1', name: 'Cus dus'
        ),
        synonym_of(
          col_nameusage_result(
            id: 'SYN2', scientific_name: 'Aus bus', status: 'synonym'
          ),
          id: 'ACC1', name: 'Cus dus'
        )
      )
      results = described_class.resolve_accepted_names('Aus bus')
      expect(results.map { |r| r[:matched_col_key] }).to eq(%w{SYN1})
    end

    context 'with an explicit dataset_id' do
      before do
        allow(::Colrapi).to receive(:nameusage)
          .with('9802', hash_including(q: 'Mus musculus'))
          .and_return({ 'total' => 1, 'result' => [
            col_nameusage_result(scientific_name: 'Mus musculus')
          ] })
      end

      it 'passes the dataset through to the search and the result' do
        result = described_class
          .resolve_accepted_names('Mus musculus', dataset_id: '9802').first
        expect(result[:dataset_id]).to eq('9802')
      end
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

    context 'with species-group and subgenus ancestors' do
      # As CoL parses them: genus/infragenericEpithet/specificEpithet
      def record(id, parent_id, rank, name_fields)
        {
          'id' => id, 'parentId' => parent_id, 'status' => 'accepted',
          'name' => name_fields.merge('rank' => rank)
        }
      end

      before do
        {
          'SSP1' => record('SSP1', 'SP1', 'subspecies',
            'scientificName' => 'Aedes (Stegomyia) aegypti formosus',
            'genus' => 'Aedes', 'infragenericEpithet' => 'Stegomyia',
            'specificEpithet' => 'aegypti',
            'infraspecificEpithet' => 'formosus'),
          'SP1' => record('SP1', 'SG1', 'species',
            'scientificName' => 'Aedes (Stegomyia) aegypti',
            'genus' => 'Aedes', 'infragenericEpithet' => 'Stegomyia',
            'specificEpithet' => 'aegypti'),
          'SG1' => record('SG1', 'G1', 'subgenus',
            'scientificName' => 'Aedes (Stegomyia)', 'genus' => 'Aedes',
            'infragenericEpithet' => 'Stegomyia'),
          'G1' => record('G1', nil, 'genus',
            'scientificName' => 'Aedes', 'uninomial' => 'Aedes')
        }.each do |id, r|
          allow(::Colrapi).to receive(:taxon)
            .with('9802', taxon_id: id).and_return(r)
        end
      end

      it 'names them as CoL gives them, like the classification subresource' do
        names = described_class.ancestors_via_parent_id('9802', 'SSP1')
          .map { |e| e['name'] }
        expect(names)
          .to eq(['Aedes', 'Aedes (Stegomyia)', 'Aedes (Stegomyia) aegypti'])
      end
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

        ext = described_class.classified_usage(lepisma_result)

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

        ext = described_class.classified_usage(botanical_result)

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

        ext = described_class.classified_usage(subgenus_result)

        expect(ext[:col_rank]).to eq('subgenus')
        expect(ext[:col_name]).to eq('Cyperana'),
          "Expected 'Cyperana' but got '#{ext[:col_name]}'; raw scientificName: #{subgenus_result.dig('name', 'scientificName').inspect}"
      end
    end
  end

  context 'VCR integration — Crayracion ambiguous synonym against default CoL dataset (3LR)' do
    it 'has no alignment and no accepted name' do
      VCR.use_cassette('colrapi_build_extension_crayracion_ambiguous_synonym') do
        search_result = ::Vendor::Colrapi.search('Crayracion')
        crayracion_result = search_result['result'].find { |r|
          r.dig('name', 'scientificName') == 'Crayracion' && r['status'] == 'ambiguous synonym'
        }
        skip 'No ambiguous synonym result for Crayracion found in CoL 3LR' if crayracion_result.nil?

        ext = described_class.classified_usage(crayracion_result)

        expect(ext[:col_status]).to eq('ambiguous synonym')
        expect(ext[:non_accepted]).to be true
        expect(ext[:alignment]).to eq([])
        expect(ext[:accepted]).to be_nil
      end
    end
  end

  context 'VCR integration — Campa synonym against default CoL dataset (3LR)' do
    it 'has no alignment, and carries its accepted name' do
      VCR.use_cassette('colrapi_build_extension_campa_synonym') do
        search_result = ::Vendor::Colrapi.search('Campa')
        campa_result  = search_result['result'].find { |r|
          r.dig('name', 'scientificName') == 'Campa' && r['status'] == 'synonym'
        }
        skip 'No synonym result for Campa found in CoL 3LR' if campa_result.nil?

        ext = described_class.classified_usage(campa_result)

        expect(ext[:col_status]).to eq('synonym')
        expect(ext[:non_accepted]).to be true
        expect(ext[:alignment]).to eq([])
        expect(ext[:accepted][:col_name])
          .to eq(campa_result.dig('accepted', 'name', 'scientificName'))
      end
    end
  end

  # ── Outdated Names (name_status) ─────────────────────────────────────────────

  # nameusage_search result entries wrap the usage: { 'usage' => { ... } }
  def col_search_usage(name:, status:, accepted: nil, rank: 'species')
    usage = {
      'name' => { 'scientificName' => name, 'rank' => rank },
      'status' => status
    }
    if accepted
      usage['accepted'] = {
        'name' => { 'scientificName' => accepted, 'rank' => rank },
        'status' => 'accepted'
      }
    end
    { 'usage' => usage }
  end

  def col_search_result(*usages)
    { 'total' => usages.size, 'result' => usages }
  end

  # Erythroneura > Erythroneura (Erythroneura) > vitis > vitata
  let(:subspecies) { FactoryBot.create(:iczn_subspecies) }
  let(:species) { subspecies.parent }

  describe '.name_status' do
    def status_for(*usages, target: species)
      allow(::Colrapi).to receive(:nameusage_search)
        .and_return(col_search_result(*usages))
      described_class.name_status(target)
    end

    specify 'queries CoL without the subgenus' do
      expect(::Colrapi).to receive(:nameusage_search)
        .with(q: 'Erythroneura vitis', dataset_id: '3LR', rank: 'species')
        .and_return(col_search_result)
      described_class.name_status(species)
    end

    specify 'queries CoL for a subgenus by its whole name' do
      expect(::Colrapi).to receive(:nameusage_search)
        .with(q: 'Erythroneura (Erythroneura)', dataset_id: '3LR',
          rank: 'subgenus')
        .and_return(col_search_result)
      described_class.name_status(species.parent)
    end

    specify 'an invalid Protonym is looked up by its original combination' do
      species.update_columns(
        cached_is_valid: false,
        cached_original_combination: 'Typhlocyba vitis'
      )
      expect(::Colrapi).to receive(:nameusage_search)
        .with(q: 'Typhlocyba vitis', dataset_id: '3LR', rank: 'species')
        .and_return(col_search_result(
          col_search_usage(
            name: 'Typhlocyba vitis', status: 'synonym',
            accepted: 'Erythroneura (Erythroneura) ontari'
          )
        ))
      r = described_class.name_status(species)
      expect(r[:taxonworks_name]).to eq('Typhlocyba vitis')
      expect(r[:provisional_status]).to eq(:synonym)
    end

    specify 'an invalid Protonym is looked up at the rank it was ' \
      'published at' do
      # The subspecies vitata, published as the species "Erythroneura vitata"
      genus = species.parent.parent
      subspecies.update!(original_genus: genus, original_species: subspecies)
      subspecies.update_column(:cached_is_valid, false)
      expect(::Colrapi).to receive(:nameusage_search)
        .with(q: 'Erythroneura vitata', dataset_id: '3LR', rank: 'species')
        .and_return(col_search_result)
      described_class.name_status(subspecies.reload)
    end

    specify 'an invalid Protonym without original combination ' \
      'relationships is looked up at its own rank' do
      subspecies.update_columns(
        cached_is_valid: false,
        cached_original_combination: 'Typhlocyba vitata'
      )
      expect(::Colrapi).to receive(:nameusage_search)
        .with(q: 'Typhlocyba vitata', dataset_id: '3LR', rank: 'subspecies')
        .and_return(col_search_result)
      described_class.name_status(subspecies)
    end

    specify 'a valid Protonym is looked up by its current form' do
      species.update_column(:cached_original_combination, 'Typhlocyba vitis')
      expect(::Colrapi).to receive(:nameusage_search)
        .with(q: 'Erythroneura vitis', dataset_id: '3LR', rank: 'species')
        .and_return(col_search_result)
      described_class.name_status(species)
    end

    specify 'a Combination is looked up at its own rank, not its ' \
      'protonym\'s' do
      # "Erythroneura vitata": the subspecies vitata, published as a species
      combination = Combination.create!(
        genus: species.parent.parent, species: subspecies
      )
      expect(::Colrapi).to receive(:nameusage_search)
        .with(q: 'Erythroneura vitata', dataset_id: '3LR', rank: 'species')
        .and_return(col_search_result)
      described_class.name_status(combination.reload)
    end

    specify 'takes a name string when there\'s no TaxonName' do
      r = status_for(
        col_search_usage(
          name: 'Aus bus', status: 'synonym', accepted: 'Aus (Aus) cus'
        ),
        target: 'Aus (Aus) bus'
      )
      expect(r[:taxonworks_name]).to eq('Aus (Aus) bus')
      expect(r[:provisional_status]).to eq(:synonym)
    end

    specify 'a subgenus TaxonName is matched by its epithet' do
      subgenus = species.parent
      r = status_for(
        col_search_usage(
          name: 'Erythroneura (Erythroneura)', status: 'accepted',
          rank: 'subgenus'
        ),
        target: subgenus
      )
      expect(r[:provisional_status]).to eq(:accepted)
    end

    specify 'no name is undeterminable, without a query' do
      expect(::Colrapi).not_to receive(:nameusage_search)
      expect(described_class.name_status(nil)[:provisional_status])
        .to eq(:undeterminable)
    end

    specify 'a synonym without the subgenus is outdated' do
      r = status_for(
        col_search_usage(
          name: 'Erythroneura vitis', status: 'synonym',
          accepted: 'Erythroneura (Erythroneura) ontari'
        )
      )
      expect(r[:provisional_status]).to eq(:synonym)
    end

    specify 'a synonym of the same name (e.g. its original combination) ' \
      'is accepted' do
      r = status_for(
        col_search_usage(
          name: 'Erythroneura vitis', status: 'synonym',
          accepted: 'Erythroneura (Erythroneura) vitis'
        )
      )
      expect(r[:provisional_status]).to eq(:accepted)
    end

    specify 'an accepted usage wins over ambiguous synonyms of the name' do
      r = status_for(
        col_search_usage(
          name: 'Erythroneura vitis', status: 'ambiguous synonym',
          accepted: 'Aus bus'
        ),
        col_search_usage(
          name: 'Erythroneura (Erythroneura) vitis', status: 'accepted'
        )
      )
      expect(r[:provisional_status]).to eq(:accepted)
    end

    specify 'only ambiguous synonyms is ambiguous' do
      r = status_for(
        col_search_usage(
          name: 'Erythroneura vitis', status: 'ambiguous synonym',
          accepted: 'Aus bus'
        )
      )
      expect(r[:provisional_status]).to eq(:ambiguous_synonym)
    end

    specify 'results that never match the name are undeterminable' do
      r = status_for(
        col_search_usage(name: 'Erythroneura vitisii', status: 'accepted')
      )
      expect(r[:provisional_status]).to eq(:undeterminable)
    end

    specify 'no results are undeterminable' do
      expect(status_for[:provisional_status]).to eq(:undeterminable)
    end

    specify 'reports the TaxonWorks name and every usage CoL returned' do
      r = status_for(
        col_search_usage(name: 'Erythroneura vitisii', status: 'accepted'),
        col_search_usage(
          name: 'Erythroneura vitis', status: 'synonym',
          accepted: 'Erythroneura (Erythroneura) ontari'
        )
      )
      expect(r[:taxonworks_name]).to eq('Erythroneura (Erythroneura) vitis')
      expect(r[:col_usages].map { |u| u.dig(:usage, :name) })
        .to eq(['Erythroneura vitisii', 'Erythroneura vitis'])
      expect(r[:col_usages].last[:accepted])
        .to eq(name: 'Erythroneura (Erythroneura) ontari', status: 'accepted')
    end
  end

end
