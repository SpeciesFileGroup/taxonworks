require 'rails_helper'
require 'catalog/entry_item'

describe Catalog::EntryItem, group: :catalogs, type: :spinup do

  let(:otu1) { Otu.create!(name: 'phoo') }
  let(:otu2) { Otu.create!(name: 'barr') }
  let(:source) { FactoryBot.create(:valid_source, year: 1920) }

  let(:entry_item) { Catalog::EntryItem.new(object: otu1, base_object: otu2) }

  specify '#html_helper' do
    expect(entry_item.html_helper).to eq(:object_tag)
  end

  specify '#cited?' do
    expect(entry_item.cited?).to be_falsey
  end

  specify '#source' do
    expect(entry_item.source).to eq(nil)
  end

  # Working because is_original: true in citation
  specify '#nomenclature_date' do
    Citation.create!(citation_object: otu1, source:, is_original: true)
    expect(entry_item.nomenclature_date.year).to eq(1920)
  end

  specify '#object_class' do
    expect(entry_item.object_class).to eq('Otu')
  end

  specify '#origin' do
    expect(entry_item.origin).to eq('otu')
  end

  context 'citations' do
    let!(:c) { Citation.create!(citation_object: otu1, source:, is_original: true) }
    let(:entry_item2) { Catalog::EntryItem.new(object: otu1, base_object: otu2, citation: c) }

    specify '#source' do
      expect(entry_item2.source).to eq(c.source)
    end

    specify '#cited?' do
      expect(entry_item2.cited?).to be_truthy
    end
  end

end


