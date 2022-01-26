require 'rails_helper'

describe Queries::DwcOccurrence::Filter, type: :model, group: [:dwc_occurrence] do
  let(:query) { Queries::DwcOccurrence::Filter.new({}) }

  specify '#initialize' do
    expect(q = Queries::DwcOccurrence::Filter.new).to be_truthy
  end
end
