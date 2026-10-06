require 'rails_helper'

describe Queries::Documentation::Filter, type: :model do

  specify '#documentation_object_type as an Array' do
    d1 = FactoryBot.create(:valid_documentation)
    descriptor = FactoryBot.create(:valid_descriptor)
    Documentation.create!(documentation_object: descriptor, document: d1.document)

    q = Queries::Documentation::Filter.new(ActionController::Parameters.new(documentation_object_type: ['CollectingEvent']))
    expect(q.all).to contain_exactly(d1)
  end
end
