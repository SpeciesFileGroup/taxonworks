require 'spec_helper'

describe Serial do

  it 'should only save valid serials' do
    # to be valid it must have a name
    s = Serial.new()
    expect(s.save).to be_false
    s.name = 'Test Serial 1'
    expect(s.save).to be_true
  end

  it 'should soft validate duplicate serials' do
    s = FactoryGirl.build(:valid_serial)
    s.soft_validate()
    expect(s.soft_validations.messages_on(:name).empty?).to be_true
    expect(s.save).to be_true
    s.soft_validate()
    expect(s.soft_validations.messages_on(:name).empty?).to be_true

    j = FactoryGirl.build(:valid_serial)
    expect(j.valid?).to be_true

    # soft validate new record
    j.soft_validate()
    expect(j.soft_validations.messages_on(:name).empty?).to be_false
    expect(j.soft_validations.messages).to include 'There is another serial with this name in the database.'
    expect(j.save).to be_true

    # soft validate edited record
    k = FactoryGirl.build(:preceding_serial)
    expect(k.save).to be_true
    k.soft_validate()
    expect(k.soft_validations.messages_on(:name).empty?).to be_true
    k.name = s.name
    k.soft_validate()
    expect(k.soft_validations.messages_on(:name).empty?).to be_false
    expect(k.soft_validations.messages).to include 'There is another serial with this name in the database.'

  end
  it 'should set the language based on valid languages' do
    pending 'not implemented yet'
  end

  it 'should use English as the default language' do
    pending 'is this true?'
  end



  it 'should list all preceding serials' do
    pending 'not implemented yet'
  end

  it 'should list all succeeding serials' do
    pending 'not implemented yet'
  end
end
