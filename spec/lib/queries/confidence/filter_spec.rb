require 'rails_helper'

describe Queries::Confidence::Filter, type: :model do

  let(:query) { Queries::Confidence::Filter.new({}) }

  specify '#options 1' do
    p = ActionController::Parameters.new(collecting_event_id: 1 )
    query.options = p 
    expect(query.all.to_sql).to eq("SELECT DISTINCT \"confidences\".* FROM \"confidences\" WHERE \"confidences\".\"confidence_object_id\" = 1 AND \"confidences\".\"confidence_object_type\" = 'CollectingEvent'")
  end

  # foo is ignored
  specify '#options 2' do
    p = ActionController::Parameters.new(collecting_event_id: 1, foo: 1 )
    query.options = p 
    expect(query.all.to_sql).to eq("SELECT DISTINCT \"confidences\".* FROM \"confidences\" WHERE \"confidences\".\"confidence_object_id\" = 1 AND \"confidences\".\"confidence_object_type\" = 'CollectingEvent'")
  end

end
