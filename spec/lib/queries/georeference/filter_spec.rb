require 'rails_helper'

describe Queries::Georeference::Filter, type: :model, group: [:geo, :collecting_events] do

  let(:query) { Queries::Georeference::Filter.new({}) }

  let!(:ce1) { FactoryBot.create(:valid_collecting_event) }

  let!(:g1) { FactoryBot.create(:valid_georeference, collecting_event: ce1) }
  let!(:g2) { FactoryBot.create(:valid_georeference, collecting_event: ce1) }

  context 'query params' do
    specify 'none' do
      expect(query.all.map(&:id)).to contain_exactly(g1.id, g2.id)
    end

    specify '#collecting_event_id 1' do
      query.collecting_event_id = ce1.id
      expect(query.all.map(&:id)).to contain_exactly(g1.id, g2.id)
    end

    specify '#collecting_event_id 1' do
      query.collecting_event_id = [ ce1.id ]
      expect(query.all.map(&:id)).to contain_exactly(g1.id, g2.id)
    end
  end

end
