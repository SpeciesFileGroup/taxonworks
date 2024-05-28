require 'rails_helper'

describe Queries::DwcOccurrence::Filter, type: :model, group: [:dwc_occurrence] do
  let(:query) { Queries::DwcOccurrence::Filter.new({}) }

  specify '#initialize' do
    expect(Queries::DwcOccurrence::Filter.new({})).to be_truthy
  end

  specify '#year' do
    c = FactoryBot.create(:valid_collecting_event, start_date_year: '1920')
    s = Specimen.create!(collecting_event: c)
    Specimen.create!()

    query.year = '1920'
    expect(query.all.first.dwc_occurrence_object).to eq(s)
  end

end
