require 'rails_helper'
require 'catalog/entry'

describe Catalog::Entry, group: :catalogs, type: :spinup do

  let!(:o) { Otu.create!(name: 'foo') }
  let!(:source) { FactoryBot.create(:valid_source_bibtex, year: 2019) }
  let!(:topic1) { FactoryBot.create(:valid_topic, name: 'Juice') }
  let!(:topic2) { FactoryBot.create(:valid_topic, name: 'Syrup') }
  let!(:citation) { Citation.create!(is_original: true, source:, citation_object: o, citation_topics_attributes: [{topic: topic1}, {topic: topic2} ]) }

  let(:catalog_entry) { Catalog::Entry.new(o) }

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


