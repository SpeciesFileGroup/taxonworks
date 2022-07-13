require 'rails_helper'

describe Identifier::Global::Uuid, type: :model, group: :identifiers do

  let(:id) { Identifier::Global::Uuid::TaxonworksDwcOccurrence.new }

  specify 'assigns to dwc_occurrence indexable objects only' do
    id.identifier_object = FactoryBot.create(:valid_otu)
    id.valid?
    expect(id.errors.messages[:identifier_object_type]).to_not be_empty
  end
end
