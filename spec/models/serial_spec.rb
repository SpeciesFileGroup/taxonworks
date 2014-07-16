require 'rails_helper'

describe Serial do

  it 'should only save valid serials' do
    # to be valid it must have a name
    s = Serial.new()
    expect(s.save).to be_falsey
    s.name = 'Test Serial 1'
    expect(s.save).to be_truthy
  end

  it 'should soft validate duplicate serials' do
    s = FactoryGirl.build(:valid_serial)
    s.soft_validate()
    expect(s.soft_validations.messages_on(:name).empty?).to be_truthy
    expect(s.save).to be_truthy
    s.soft_validate()
    expect(s.soft_validations.messages_on(:name).empty?).to be_truthy

    j = FactoryGirl.build(:valid_serial)
    expect(j.valid?).to be_truthy

    # soft validate new record
    j.soft_validate()
    expect(j.soft_validations.messages_on(:name).empty?).to be_falsey
    expect(j.soft_validations.messages).to include 'There is another serial with this name in the database.'
    expect(j.save).to be_truthy

    # soft validate edited record
    k = FactoryGirl.build(:preceding_serial)
    expect(k.save).to be_truthy
    k.soft_validate()
    expect(k.soft_validations.messages_on(:name).empty?).to be_truthy
    k.name = s.name
    k.soft_validate()
    expect(k.soft_validations.messages_on(:name).empty?).to be_falsey
    expect(k.soft_validations.messages).to include 'There is another serial with this name in the database.'

    # TODO 'should check for duplicate between name & other serial tags'
    # create alternate value/types synonym, translation, abbreviation
    # add an alternate value/synonym
    # add an alternate value/translations
    # add an alternate value/abbreviation
  end
  context 'should set the language based on valid languages' do
    before(:each) do
      @eng = FactoryGirl.build(:english)
      @eng.save
      @rus = FactoryGirl.build(:russian)
      @rus.save
      @cre = FactoryGirl.build(:creole_eng)
      @cre.save
      @s = FactoryGirl.build(:valid_serial)
    end
    specify 'should be able to get & set language by 3 letter abbreviation' do
      @s.language_abbrev = 'eng'
      expect(@s.save).to be_truthy
      expect(@s.primary_language_id).to eq(@eng.id)
      expect(@s.language_abbrev).to eq('eng')
      @s.language_abbrev = 'test'
      expect(@s.primary_language_id).to be_nil
      expect(@s.save).to be_truthy
    end
    specify 'should be able to get & set language by full name' do
      @s.language = 'English'
      expect(@s.save).to be_truthy
      expect(@s.primary_language_id).to eq(@eng.id)
      expect(@s.language).to eq('English')
      @s.language = 'test'
      expect(@s.primary_language_id).to be_nil
      expect(@s.save).to be_truthy
     end
    specify 'if set by primary language id, should be able to get language full name & abbreviation' do
      @s.primary_language_id = @eng.id
      expect(@s.language).to eq('English')
      expect(@s.language_abbrev).to eq('eng')
      expect(@s.save).to be_truthy
    end

  end

  it 'should list the Serial Chronology'

  it 'should list all preceding serials' do
    skip 'not implemented yet'
  end

  it 'should list all succeeding serials' do
    skip 'not implemented yet'
  end
end
