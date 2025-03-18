require 'rails_helper'

describe Collector, type: :model do
  include ActiveJob::TestHelper

  let(:p) { FactoryBot.create(:valid_person) }
  let(:ce) { FactoryBot.create(:valid_collecting_event) }

  specify '#dwc_occurrences' do
    ce.collectors << p
    s = Specimen.create!(collecting_event: ce)

    expect(p.roles.first.dwc_occurrences).to contain_exactly(DwcOccurrence.first)
  end

  specify 'on create triggers dwc rebuild' do
    s = Specimen.create!(collecting_event: ce)

    expect(s.dwc_occurrence.recordedBy).to eq(nil)
    ce.collectors << p

    perform_enqueued_jobs
    expect(s.dwc_occurrence.reload.recordedBy).to eq(p.cached)
  end

end
