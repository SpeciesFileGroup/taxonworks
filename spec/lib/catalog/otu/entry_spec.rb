require 'rails_helper'
require 'catalog/nomenclature/entry'

describe Catalog::Otu::Entry, group: :catalogs, type: :spinup do

  let(:root) { Project.find(Current.project_id).send(:create_root_taxon_name) }
  let(:genus) { Protonym.create!(parent: root, name: 'Aus', rank_class: Ranks.lookup(:iczn, :genus) )}
  let(:otu) { Otu.create!(name: 'something', taxon_name: genus) }

  let(:catalog_entry) { Catalog::Otu::Entry.new(otu) }

  specify '#items' do
    expect(catalog_entry.items.count).to eq(1)
  end

end


