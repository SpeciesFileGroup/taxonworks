require 'rails_helper'

describe Queries::AlternateValue::Filter, type: :model, group: :alternate_values do
  
  let(:query) { Queries::AlternateValue::Filter.new({}) }

  let(:p) { ActionController::Parameters.new }
  
  specify '#ignores_project? 1' do
    q = Queries::AlternateValue::Filter.new( p.merge(geographic_area_id: '123'))
    expect(q.ignores_project?).to be_truthy
  end
  
  specify '#ignores_project? 1' do
    q = Queries::AlternateValue::Filter.new( p.merge(otu_id: '123') )
    expect(q.ignores_project?).to be_falsey
  end
end

