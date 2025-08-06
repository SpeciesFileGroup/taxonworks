require 'rails_helper'
require 'catalog/distribution/entry'

describe Catalog::Distribution::Entry, group: [:catalogs, :distribution_catalog, :geo, :shared_geo], type: :spinup do

  let(:root) { Project.find(Current.project_id).send(:create_root_taxon_name) }
  let(:species) { Protonym.create!(parent: root, name: 'aus', rank_class: Ranks.lookup(:iczn, :species) )}
  let!(:c1) { FactoryBot.create(:valid_citation, citation_object: species) }
  let!(:otu) { Otu.new(name: 'Jetson', taxon_name: species)}
  let!(:ad) { FactoryBot.create(:valid_asserted_distribution, asserted_distribution_object: otu)}
  let!(:co) { FactoryBot.create(:valid_collection_object) }
  let!(:td) { TaxonDetermination.create!(taxon_determination_object: co, otu:) }
  let!(:tm) { FactoryBot.create(:valid_type_material, protonym: species, collection_object: co)}
  let(:catalog_entry) { Catalog::Distribution::Entry.new([otu]) }

  specify '#items' do
    expect(catalog_entry.items.count).to eq(3)
  end

  specify '#asserted_distribution_items' do
    expect(catalog_entry.asserted_distribution_items.count).to eq(1)
  end

end
