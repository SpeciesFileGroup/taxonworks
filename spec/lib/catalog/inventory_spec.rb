require 'rails_helper'
#require 'catalog/nomenclature/entry'

describe Catalog::Inventory, group: :catalogs, type: :spinup do

  let!(:root) { Project.find(Current.project_id).send(:create_root_taxon_name) }
  let!(:genus) { Protonym.create!(parent: root, name: 'Aus', rank_class: Ranks.lookup(:iczn, :genus) )}
  let!(:otu) { Otu.create!(name: 'something', taxon_name: genus) }

  let!(:source1) { FactoryBot.create(:valid_source_bibtex, year: 2019) }
  let!(:source2) { FactoryBot.create(:valid_source_bibtex, year: 2020) }
  let!(:citation2) { Citation.create!(is_original: true, source: source2,
    citation_object: )}
  let!(:ad) { AssertedDistribution.create!(asserted_distribution_object: otu, asserted_distribution_shape: FactoryBot.create(:valid_geographic_area), source: source1)} # 'citation1'
  let!(:co) { FactoryBot.create(:valid_collection_object) }
  let!(:td) { TaxonDetermination.create!(taxon_determination_object: co, otu:)}
  let!(:citation2) { Citation.create!(is_original: true, source: source2,
    citation_object: co)}

  let(:c) { Catalog::Inventory.new(targets: [otu]) }

  specify '#items' do
    expect(c.items.count).to eq(2)
  end

  specify 'all_dates' do
    expect(Catalog.year_metadata(c.sources, c.items)).to eq({
      2019 => 1,
      2020 => 1
    })
  end

  specify 'citation origins' do
    origins = c.items.map { |i| i.data_attributes['history-origin'] }
    expect(origins).to contain_exactly('asserted distribution', 'specimen')
  end

  context '#citations_summary' do
    specify 'returns one entry per unique (type, source) pair' do
      expect(c.citations_summary.size).to eq(2)
    end

    specify 'entry has type, source, and topics keys' do
      entry = c.citations_summary.first
      expect(entry.keys).to contain_exactly(:type, :source, :topics)
    end

    specify 'types reflect the cited object classes' do
      types = c.citations_summary.map { |e| e[:type] }
      expect(types).to contain_exactly('AssertedDistribution', 'Specimen')
    end

    specify 'sources match the citations' do
      sources = c.citations_summary.map { |e| e[:source] }
      expect(sources).to contain_exactly(source1, source2)
    end

    context 'merging by (type, source)' do
      let!(:ad2) { AssertedDistribution.create!(
        asserted_distribution_object: otu,
        asserted_distribution_shape: FactoryBot.create(:valid_geographic_area),
        source: source1
      )}

      specify 'two items of the same type and source produce one entry' do
        expect(c.citations_summary.count { |e| e[:type] == 'AssertedDistribution' }).to eq(1)
      end
    end

    context 'topics' do
      let!(:topic1) { FactoryBot.create(:valid_topic) }
      let!(:topic2) { FactoryBot.create(:valid_topic) }
      let!(:ad2) { AssertedDistribution.create!(
        asserted_distribution_object: otu,
        asserted_distribution_shape: FactoryBot.create(:valid_geographic_area),
        source: source1
      )}
      let!(:citation_ad1_topic) { ad.citations.first.topics << topic1 }
      let!(:citation_ad2_topic) { ad2.citations.first.topics << topic2 }

      specify 'topics are unioned across items of the same (type, source)' do
        entry = c.citations_summary.find { |e| e[:type] == 'AssertedDistribution' }
        expect(entry[:topics]).to contain_exactly(topic1, topic2)
      end
    end
  end
end


