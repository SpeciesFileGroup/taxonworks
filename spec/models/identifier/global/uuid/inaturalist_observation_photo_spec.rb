require 'rails_helper'

describe Identifier::Global::Uuid::InaturalistObservationPhoto, type: :model, group: [:field_occurrences] do

  specify 'is invalid when attached to a non-Image object' do
    identifier = Identifier::Global::Uuid::InaturalistObservationPhoto.new(
      identifier: '23037fff-dbe6-478e-9ecd-efb942d5174e',
      identifier_object: FactoryBot.build(:valid_otu)
    )
    expect(identifier.valid?).to be false
    expect(identifier.errors[:identifier_object]).to be_present
  end

  specify 'is valid when attached to an Image' do
    identifier = Identifier::Global::Uuid::InaturalistObservationPhoto.new(
      identifier: '23037fff-dbe6-478e-9ecd-efb942d5174e',
      identifier_object: FactoryBot.build(:valid_image)
    )
    expect(identifier.valid?).to be true
  end

end
