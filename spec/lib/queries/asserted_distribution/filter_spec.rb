require 'rails_helper'
# require 'support/shared_contexts/shared_geo'

describe Queries::AssertedDistribution::Filter, type: :model, group: [:geo, :collection_objects, :otus, :shared_geo] do
  let(:q) { Queries::AssertedDistribution::Filter.new({}) }

  let(:a) { FactoryBot.create(:valid_asserted_distribution) }

  specify '#otu_id' do
    o = a.otu_id
    q.otu_id = o
    expect(q.all.map(&:id)).to contain_exactly(a.id)
  end

  specify '#geographic_area_id' do
    o = a.geographic_area_id
    q.geographic_area_id = o
    expect(q.all.map(&:id)).to contain_exactly(a.id)
  end

  # Source query integration
  specify '#source_id' do
    FactoryBot.create(:valid_asserted_distribution)
    o = a.source.id
    q.citation_query.source_id = o

    expect(q.all.map(&:id)).to contain_exactly(a.id)

  end

end
