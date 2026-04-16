require 'rails_helper'
#require 'catalog/nomenclature/entry'

describe Catalog::Inventory, group: :catalogs, type: :spinup do

  let!(:root) { Project.find(Current.project_id).send(:create_root_taxon_name) }
  let!(:genus) { Protonym.create!(parent: root, name: 'Aus', rank_class: Ranks.lookup(:iczn, :genus) )}
  let!(:otu) { Otu.create!(name: 'something', taxon_name: genus) }

  let!(:source1) { FactoryBot.create(:valid_source_bibtex, year: 2019) }
  let!(:source2) { FactoryBot.create(:valid_source_bibtex, year: 2020) }
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
    specify 'returns a hash keyed by coordinate OTU id' do
      expect(c.citations_summary).to be_a(Hash)
      expect(c.citations_summary.keys).to contain_exactly(otu.id)
    end

    specify 'returns one entry per unique (type, source) pair per OTU' do
      expect(c.citations_summary[otu.id].size).to eq(2)
    end

    specify 'entry has type, source, pages, is_original, and topics keys' do
      entry = c.citations_summary[otu.id].first
      expect(entry.keys).to contain_exactly(:type, :source, :pages, :is_original, :topics)
    end

    specify 'types reflect the cited object classes' do
      types = c.citations_summary[otu.id].map { |e| e[:type] }
      expect(types).to contain_exactly('AssertedDistribution', 'Specimen')
    end

    specify 'sources match the citations' do
      sources = c.citations_summary[otu.id].map { |e| e[:source] }
      expect(sources).to contain_exactly(source1, source2)
    end

    specify 'is_original reflects citation value' do
      entry = c.citations_summary[otu.id].find { |e| e[:type] == 'Specimen' }
      expect(entry[:is_original]).to eq(true)
    end

    specify 'pages reflects citation value' do
      ad.citations.first.update!(pages: '12-15')
      entry = c.citations_summary[otu.id].find { |e| e[:type] == 'AssertedDistribution' }
      expect(entry[:pages]).to eq('12-15')
    end

    context 'merging by (type, source)' do
      let!(:ad2) { AssertedDistribution.create!(
        asserted_distribution_object: otu,
        asserted_distribution_shape: FactoryBot.create(:valid_geographic_area),
        source: source1
      )}

      specify 'two items of the same type and source produce one entry' do
        expect(c.citations_summary[otu.id].count { |e| e[:type] == 'AssertedDistribution' }).to eq(1)
      end
    end

    context 'multiple coordinate OTUs' do
      let!(:otu2) { Otu.create!(name: 'coordinate', taxon_name: genus) }
      let!(:source3) { FactoryBot.create(:valid_source_bibtex, year: 2021) }
      let!(:ad3) { AssertedDistribution.create!(
        asserted_distribution_object: otu2,
        asserted_distribution_shape: FactoryBot.create(:valid_geographic_area),
        source: source3
      )}

      specify 'summary is keyed by each coordinate OTU id' do
        expect(c.citations_summary.keys).to contain_exactly(otu.id, otu2.id)
      end

      specify 'entries for each OTU contain only that OTU\'s citations' do
        expect(c.citations_summary[otu.id].map { |e| e[:source] }).to contain_exactly(source1, source2)
        expect(c.citations_summary[otu2.id].map { |e| e[:source] }).to contain_exactly(source3)
      end

      specify 'coordinate OTU with no inventory data is absent from the hash' do
        otu3 = Otu.create!(name: 'no data', taxon_name: genus)
        expect(c.citations_summary.keys).not_to include(otu3.id)
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
        entry = c.citations_summary[otu.id].find { |e| e[:type] == 'AssertedDistribution' }
        expect(entry[:topics]).to contain_exactly(topic1, topic2)
      end
    end
  end
end

