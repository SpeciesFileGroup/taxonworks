require 'rails_helper'

describe Collector, type: :model do

  let(:p) { FactoryBot.create(:valid_person) }
  let(:ce) { FactoryBot.create(:valid_collecting_event) }

  specify '#dwc_occurrences' do
    ce.collectors << p
    s = Specimen.create!(collecting_event: ce)

    expect(p.roles.first.dwc_occurrences).to contain_exactly(DwcOccurrence.first)
  end

  # If updated you should also manually test the delayed version using
  # Delayed::Worker.new.work_off
  specify 'on create triggers dwc rebuild' do
    s = Specimen.create!(collecting_event: ce)

    expect(s.dwc_occurrence.recordedBy).to eq(nil)
    ce.collectors << p

    expect(s.dwc_occurrence.reload.recordedBy).to eq(p.cached)
  end

  # Requires CollectingEvent to reference Collector in cached_cached, it does not yet.
  # specify 'People updates trigger cached update on CollectingEvent only for cached_cached'  do
  #   ce = FactoryBot.create(:valid_collecting_event)
  #   r = FactoryBot.create(:valid_collector, role_object: ce)
  #   p = r.person
  #   p.update!(last_name: 'Jones')
  #   expect(ce.reload.cached).to match(/Jones/)
  # end

end
