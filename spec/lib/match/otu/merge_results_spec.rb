require 'rails_helper'

describe Match::Otu::MergeResults, type: :model do
  def merge(tn_results:, otu_results:)
    Match::Otu::MergeResults.new(tn_results:, otu_results:).call
  end

  let(:tn_matched) { { scientific_name: 'Aus bus', taxon_name_id: 1, taxon_name: :tn, otus: [:tn_otu], ambiguous: false, matched: true } }
  let(:tn_unmatched) { { scientific_name: 'Aus bus', taxon_name_id: nil, taxon_name: nil, otus: [], ambiguous: false, matched: false } }
  let(:otu_matched) { { scientific_name: 'Aus bus', taxon_name_id: 2, taxon_name: :otu_tn, otus: [:otu_otu], ambiguous: false, matched: true } }
  let(:otu_unmatched) { { scientific_name: 'Aus bus', taxon_name_id: nil, taxon_name: nil, otus: [], ambiguous: false, matched: false } }

  specify 'TaxonName matched, OTU-name unmatched: keeps the TaxonName result, tagged taxon_name' do
    result = merge(tn_results: [tn_matched], otu_results: [otu_unmatched]).first
    expect(result[:match_source]).to eq('taxon_name')
    expect(result[:taxon_name_id]).to eq(1)
    expect(result[:ambiguous]).to be false
  end

  specify 'TaxonName unmatched, OTU-name matched: uses the OTU-name result, tagged otu' do
    result = merge(tn_results: [tn_unmatched], otu_results: [otu_matched]).first
    expect(result[:match_source]).to eq('otu')
    expect(result[:taxon_name_id]).to eq(2)
    expect(result[:scientific_name]).to eq('Aus bus')
  end

  specify 'both matched: keeps the TaxonName result, tagged both, forced ambiguous' do
    result = merge(tn_results: [tn_matched], otu_results: [otu_matched]).first
    expect(result[:match_source]).to eq('both')
    expect(result[:taxon_name_id]).to eq(1)
    expect(result[:ambiguous]).to be true
  end

  specify 'neither matched: tagged with a nil match_source' do
    result = merge(tn_results: [tn_unmatched], otu_results: [otu_unmatched]).first
    expect(result[:match_source]).to be_nil
    expect(result[:matched]).to be false
  end

  specify 'preserves input order across multiple names' do
    result = merge(
      tn_results: [tn_matched, tn_unmatched],
      otu_results: [otu_unmatched, otu_matched]
    )
    expect(result.map { |r| r[:match_source] }).to eq(['taxon_name', 'otu'])
  end
end
