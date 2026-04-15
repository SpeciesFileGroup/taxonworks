require 'rails_helper'

describe Identifier::Global::Uuid::InaturalistObservation, type: :model, group: [:field_occurrences] do

  specify '#url returns an iNaturalist observation URL for the stored uuid' do
    identifier = Identifier::Global::Uuid::InaturalistObservation.new(
      identifier: '23037fff-dbe6-478e-9ecd-efb942d5174e'
    )
    expect(identifier.url).to eq('https://www.inaturalist.org/observations/23037fff-dbe6-478e-9ecd-efb942d5174e')
  end

end
