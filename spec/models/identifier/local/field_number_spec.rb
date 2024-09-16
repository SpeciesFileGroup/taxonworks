require 'rails_helper'
describe Identifier::Local::FieldNumber, type: :model, group: :identifiers do

  let(:n) { FactoryBot.create(:valid_namespace, short_name: 'NS', delimiter: nil) } 

  specify 'assigned to CollectingEvent only 1' do
    i = Identifier::Local::FieldNumber.create(identifier: '345', namespace: n, identifier_object: Specimen.create!)
    expect(i.errors.key?(:identifier_object_type)).to be_truthy
  end

  specify 'assigned to CollectingEvent only 2' do
    i = Identifier::Local::FieldNumber.create(identifier: '345', namespace: n, identifier_object: FactoryBot.create(:valid_collecting_event))
    expect(i.errors.key?(:identifier_object_type)).to be_falsey
  end

  specify 'must be same as verbatim_trip_identifier if provided' do
    c = FactoryBot.create(:valid_collecting_event, verbatim_trip_identifier: 'NS345')

    i = Identifier::Local::FieldNumber.new(identifier: '345', namespace: n, identifier_object: c)
    expect(i.valid?).to be_falsey
    expect(i.errors.key?(:identifier)).to be_truthy
  end
  
end