require 'rails_helper'
require 'catalog/distribution/entry_item'

describe Catalog::Distribution::EntryItem, group: :catalogs, type: :spinup do
  let(:root) { Project.find(Current.project_id).send(:create_root_taxon_name) }
  let(:species) { Protonym.create!(parent: root, name: 'aus', rank_class: Ranks.lookup(:iczn, :species) )}
  let(:c1) { FactoryBot.create(:valid_citation, citation_object: species) }
  let(:otu) { Otu.new(name: 'Jetson', taxon_name: species)}
  let(:ad) { FactoryBot.create(:valid_asserted_distribution, asserted_distribution_object: otu)}
  let(:co) { FactoryBot.create(:valid_collection_object) }
  let(:td) { TaxonDetermination.create!(taxon_determination_object: co, otu:) }
  let(:tm) { FactoryBot.create(:valid_type_material, protonym: species, collection_object: co)}

  context 'Asserted Distribution' do
    let(:entry_item) { Catalog::Distribution::EntryItem.new(object: ad, base_object: otu) }

    specify '#data_attributes' do
      # TODO this is currently only here to make sure we're not throwing an
      # exception.
      expect(entry_item.data_attributes['history-is-valid']).to be_nil
      expect(entry_item.data_attributes['history-otu-taxon-name-id']).to be_nil
    end
  end

end


