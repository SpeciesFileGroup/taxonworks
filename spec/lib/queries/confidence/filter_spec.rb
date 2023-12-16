require 'rails_helper'

describe Queries::Confidence::Filter, type: :model do

  specify '#polymorphic_id 1' do
    query = Queries::Confidence::Filter.new(collecting_event_id: 1)
    expect(query.all.to_sql).to eq("SELECT \"confidences\".* FROM \"confidences\" WHERE \"confidences\".\"confidence_object_id\" = 1 AND \"confidences\".\"confidence_object_type\" = 'CollectingEvent' AND \"confidences\".\"project_id\" IN (1)")
  end

  # foo is ignored
  specify '#polymorphic_id 2' do
    query = Queries::Confidence::Filter.new(collecting_event_id: 1, foo: 1)
    expect(query.all.to_sql).to eq("SELECT \"confidences\".* FROM \"confidences\" WHERE \"confidences\".\"confidence_object_id\" = 1 AND \"confidences\".\"confidence_object_type\" = 'CollectingEvent' AND \"confidences\".\"project_id\" IN (1)")
  end

end
