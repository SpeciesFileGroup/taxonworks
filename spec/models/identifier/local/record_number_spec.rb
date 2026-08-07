require 'rails_helper'
describe Identifier::Local::RecordNumber, type: :model, group: :identifiers do

  let(:n) { FactoryBot.create(:valid_namespace, short_name: 'NS', delimiter: nil) }

  specify 'assigned to invalid object' do
    i = Identifier::Local::RecordNumber.create(identifier: '345', namespace: n, identifier_object: FactoryBot.create(:valid_collecting_event))
    expect(i.errors.key?(:identifier_object_type)).to be_truthy
  end

  specify 'assigned to CollectionObject' do
    i = Identifier::Local::RecordNumber.create(identifier: '345', namespace: n, identifier_object: Specimen.create!)
    expect(i.errors.key?(:identifier_object_type)).to be_falsey
  end

  specify 'assigned to FieldOccurrence' do
    i = Identifier::Local::RecordNumber.create(identifier: '345', namespace: n, identifier_object: FactoryBot.create(:valid_field_occurrence))
    expect(i.errors.key?(:identifier_object_type)).to be_falsey
  end

  specify 'may be duplicated across specimens' do
    i = Identifier::Local::RecordNumber.create!(identifier: '345', namespace: n, identifier_object: Specimen.create!)
    j = Identifier::Local::RecordNumber.new(identifier: '345', namespace: n, identifier_object: Specimen.create!)
    expect(j.valid?).to be_truthy
  end

  specify 'may be duplicated across field occurrences' do
    i = Identifier::Local::RecordNumber.create!(identifier: '345', namespace: n, identifier_object: FactoryBot.create(:valid_field_occurrence))
    j = Identifier::Local::RecordNumber.new(identifier: '345', namespace: n, identifier_object: FactoryBot.create(:valid_field_occurrence))
    expect(j.valid?).to be_truthy
  end
end
