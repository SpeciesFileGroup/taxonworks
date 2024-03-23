require 'rails_helper'

describe Queries::AlternateValue::Filter, type: :model, group: :alternate_values do
  
  let(:query) { Queries::AlternateValue::Filter.new({}) }

  let(:p) { ActionController::Parameters.new }

  specify '#ignores_project? with alternatve_value_object' do
    q = Queries::AlternateValue::Filter.new( p.merge(alternate_value_object_id: 1, alternate_value_object_type: 'GeographicArea'))
    expect(q.ignores_project?).to be_truthy
  end

  specify '#ignores_project? with shallow_params 1' do
    q = Queries::AlternateValue::Filter.new( p.merge(geographic_area_id: '123'))
    expect(q.ignores_project?).to be_truthy
  end

  specify '#ignores_project? with shallow_params 2' do
    q = Queries::AlternateValue::Filter.new( p.merge(otu_id: '123') )
    expect(q.ignores_project?).to be_falsey
  end
end

