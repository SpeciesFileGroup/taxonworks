require 'rails_helper'

describe Queries::Tag::Filter, type: :model do

  let(:keyword) { FactoryBot.create(:valid_keyword) }

  specify '#asserted_environment_query_facet' do
    ae = FactoryBot.create(:valid_asserted_environment)
    other_ae = FactoryBot.create(:valid_asserted_environment)
    t = Tag.create!(tag_object: ae, keyword:)
    Tag.create!(tag_object: other_ae, keyword:)

    q = Queries::Tag::Filter.new(asserted_environment_query: { asserted_environment_id: [ae.id] })
    expect(q.all).to contain_exactly(t)
  end

  specify '#lead_query_facet' do
    key = FactoryBot.create(:valid_lead)
    other_key = FactoryBot.create(:valid_lead, text: 'Other key')
    t = Tag.create!(tag_object: key, keyword:)
    Tag.create!(tag_object: other_key, keyword:)

    q = Queries::Tag::Filter.new(lead_query: { lead_id: [key.id] })
    expect(q.all).to contain_exactly(t)
  end
end
