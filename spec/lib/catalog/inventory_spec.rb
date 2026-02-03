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
end


