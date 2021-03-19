require 'rails_helper'

describe Queries::Identifier::Filter, type: :model, group: :identifiers do

  let(:s1) { FactoryBot.create(:valid_specimen) }
  let(:s2) { FactoryBot.create(:valid_specimen) }
  let(:s2) { FactoryBot.create(:valid_extract) }

  let(:query) { Queries::OriginRelationship::Filter.new({}) }

  specify '#old_global_object_id' do
    o = OriginRelationship.create!(old_object: s1, new_object: s2)

    query.old_global_object_id = s1.to_global_id.to_s
    expect(query.all.map(&:id)).to contain_exactly(o.id)
  end

end
