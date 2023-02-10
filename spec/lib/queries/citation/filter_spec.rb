require 'rails_helper'

describe Queries::Citation::Filter, type: :model do

  let(:query) { Queries::Citation::Filter.new({}) }

  specify '#options 1' do
    p = ActionController::Parameters.new(collecting_event_id: 1 )
    query.options = p 
    expect(query.all.to_sql).to eq("SELECT DISTINCT \"citations\".* FROM \"citations\" WHERE \"citations\".\"citation_object_id\" = 1 AND \"citations\".\"citation_object_type\" = 'CollectingEvent' AND (\"citations\".\"project_id\" = 1)")
  end

  # foo is ignored
  specify '#options 2' do
    p = ActionController::Parameters.new(collecting_event_id: 1, foo: 1 )
    query.options = p 
    expect(query.all.to_sql).to eq("SELECT DISTINCT \"citations\".* FROM \"citations\" WHERE \"citations\".\"citation_object_id\" = 1 AND \"citations\".\"citation_object_type\" = 'CollectingEvent' AND (\"citations\".\"project_id\" = 1)")
  end

end
