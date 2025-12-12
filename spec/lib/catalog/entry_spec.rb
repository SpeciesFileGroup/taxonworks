require 'rails_helper'
require 'catalog/entry'

describe Catalog::Entry, group: :catalogs, type: :spinup do

  let!(:o) { Otu.create!(name: 'foo') }
  let!(:source) { FactoryBot.create(:valid_source_bibtex, year: 2019) }
  let!(:topic1) { FactoryBot.create(:valid_topic, name: 'Juice') }
  let!(:topic2) { FactoryBot.create(:valid_topic, name: 'Syrup') }
  let!(:citation) { Citation.create!(is_original: true, source:, citation_object: o, citation_topics_attributes: [{topic: topic1}, {topic: topic2} ]) }

  let(:catalog_entry) { Catalog::Entry.new(o.reload) }

  specify '#items' do
    expect(catalog_entry.items.count).to eq(1)
  end

  specify '#dates' do
    expect(catalog_entry.dates).to eq([source.nomenclature_date])
  end

  specify '#dates' do
    expect(catalog_entry.dates).to contain_exactly(citation.source.nomenclature_date)
  end

  specify '#sources' do
    expect(catalog_entry.sources).to contain_exactly(citation.source)
  end

  specify '#topics' do
    expect(catalog_entry.topics).to contain_exactly(topic1, topic2)
  end

  context '#topics with multiple items' do
    let!(:source2) { FactoryBot.create(:valid_source_bibtex, year: 2020) }
    let!(:source3) { FactoryBot.create(:valid_source_bibtex, year: 2021) }
    let!(:topic3) { FactoryBot.create(:valid_topic, name: 'Honey') }
    let!(:citation2) { Citation.create!(source: source2, citation_object: o, citation_topics_attributes: [{topic: topic1}, {topic: topic3}]) }
    let!(:citation3) { Citation.create!(source: source3, citation_object: o, citation_topics_attributes: [{topic: topic2}]) }

    specify 'collects all unique topics from all items' do
      entry = Catalog::Entry.new(o.reload)
      # Manually add items with different topics to test all_topics collection
      entry.items << Catalog::EntryItem.new(object: o, citation: citation2)
      entry.items << Catalog::EntryItem.new(object: o, citation: citation3)

      expect(entry.items.count).to eq(3)
      expect(entry.topics).to contain_exactly(topic1, topic2, topic3)
    end

    specify 'deduplicates topics that appear in multiple citations' do
      entry = Catalog::Entry.new(o.reload)
      # Add items where topics overlap
      entry.items << Catalog::EntryItem.new(object: o, citation: citation2) # has topic1, topic3
      entry.items << Catalog::EntryItem.new(object: o, citation: citation3) # has topic2

      # topic1 appears in citation and citation2, topic2 appears in citation and citation3
      # Should still only return 3 unique topics
      expect(entry.topics.count).to eq(3)
      expect(entry.topics.uniq.count).to eq(3) # Verify no duplicates
    end
  end

  specify '#date_range' do
    expect(catalog_entry.date_range).to eq([source.nomenclature_date, source.nomenclature_date])
  end

  specify '#year_hash' do
    expect(catalog_entry.year_hash).to eq({citation.source.year => 1})
  end

  specify '#year_hash' do
    expect(catalog_entry.year_hash).to eq({citation.source.year => 1})
  end

  specify '#first_item?' do
    expect(catalog_entry.first_item?(catalog_entry.items.first)).to be_truthy
  end

  specify '#original_citation_present?' do
    expect(catalog_entry.original_citation_present?).to be_truthy
  end

  specify '#items_by_object' do
    expect(catalog_entry.items_by_object(catalog_entry.items.first.object)).to contain_exactly(catalog_entry.items.first)
  end

  specify '#ordered_by_nomenclature_date' do
    catalog_entry.items << Otu.create!(name: 'foo')
    expect(catalog_entry.ordered_by_nomenclature_date).to be_truthy
  end

end


