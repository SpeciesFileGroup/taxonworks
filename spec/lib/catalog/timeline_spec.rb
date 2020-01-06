require 'rails_helper'
require 'catalog/timeline'

describe Catalog::Timeline, group: :catalogs, type: :spinup do

  let(:catalog) { Catalog::Timeline.new(targets: []) }

  let(:root) { Project.find(Current.project_id).send(:create_root_taxon_name) }
  let(:genus) { Protonym.create!(parent: root, name: 'Aus', rank_class: Ranks.lookup(:iczn, :genus) )}
  let(:otu) { Otu.create!(name: 'something', taxon_name: genus) }

  specify '#items' do
    expect(catalog.items).to eq([]) 
  end

  specify '#items_chronologically' do
    expect(catalog.items_chronologically).to eq([]) 
  end

  context 'with an item' do
    let(:c) { Catalog::Timeline.new(targets: [otu]) }

    specify '#entries' do
      expect(c.entries.count).to eq(2) # one otu, one for TN
    end

    specify '#items' do
      expect(c.items.count).to eq(2)
    end

    specify '#items_chronologically' do
      expect(c.items_chronologically.count).to eq(2)
    end

  end

end


