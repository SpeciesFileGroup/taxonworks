require 'rails_helper'

describe Collector, type: :model do

  # Requires CollectingEvent to reference Collector in cached_cached, it does not yet.
  # specify 'People updates trigger cached update on CollectingEvent only for cached_cached'  do
  #   ce = FactoryBot.create(:valid_collecting_event)
  #   r = FactoryBot.create(:valid_collector, role_object: ce)

  #   p = r.person

  #   p.update!(last_name: 'Jones')

  #   expect(ce.reload.cached).to match(/Jones/)
  # end

end
