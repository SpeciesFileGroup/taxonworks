require 'rails_helper'

describe Queries::Attribution::Filter, type: :model do

  specify '#attribution_object_type as an Array' do
    a1 = FactoryBot.create(:valid_attribution)
    content = FactoryBot.create(:valid_content)
    FactoryBot.create(:valid_attribution, attribution_object: content)

    q = Queries::Attribution::Filter.new(ActionController::Parameters.new(attribution_object_type: ['Image']))
    expect(q.all).to contain_exactly(a1)
  end
end
