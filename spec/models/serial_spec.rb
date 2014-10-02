require 'rails_helper'

describe Serial, :type => :model do

  it 'should only save valid serials' do
    # to be valid it must have a name
    s = Serial.new()
    expect(s.save).to be_falsey
    s.name = 'Test Serial 1'
    expect(s.save).to be_truthy
  end

  it 'should soft validate duplicate serials' do
    name = 'Fixed name'
    s = FactoryGirl.build(:valid_serial, name: name)
    s.soft_validate()

    expect(s.soft_validations.messages_on(:name).empty?).to be_truthy
    expect(s.save).to be_truthy
    
    s.soft_validate()
    expect(s.soft_validations.messages_on(:name).empty?).to be_truthy

    j = FactoryGirl.build(:valid_serial, name: name)
    expect(j.valid?).to be_truthy

    # soft validate new record
    j.soft_validate()
    expect(j.soft_validations.messages_on(:name).empty?).to be_falsey
    
    expect(j.soft_validations.messages).to include 'There is another serial with this name in the database.'
    expect(j.save).to be_truthy

    # Soft validate edited record
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

  context 'Serial Chronology' do
    before {
      @a = Serial.create(name: 'A')
      @b = Serial.create(name: 'B')
      @c = Serial.create(name: 'C')
      @d = Serial.create(name: 'D')
      @e = Serial.create(name: 'E')
      @f = Serial.create(name: 'F')
      @g = Serial.create(name: 'G')
      @h = Serial.create(name: 'H')

      #  a & b merge into e splits into g & h
      SerialChronology::SerialMerge.create(preceding_serial: @a, succeeding_serial: @e)
      SerialChronology::SerialMerge.create(preceding_serial: @b, succeeding_serial: @e)
      SerialChronology::SerialMerge.create(preceding_serial: @e, succeeding_serial: @g)
      SerialChronology::SerialMerge.create(preceding_serial: @e, succeeding_serial: @h)

      # d becomes f
      SerialChronology::SerialSequence.create(preceding_serial: @d, succeeding_serial: @f)
    }
    specify '#immediately_preceding_serials - immediately preceding serial(s if merge)' do
      expect(@e.immediately_preceding_serials.order(:name).to_a).to eq([@a, @b])
      expect(@h.immediately_preceding_serials.to_a).to eq([@e])
      expect(@d.immediately_preceding_serials.to_a).to eq([])
      expect(@f.immediately_preceding_serials.to_a).to eq([@d])
    end

    specify '#all_previous - should list all historically related previous serials' do
      # want all previous serials of h == [e,[a,b]]
      expect(@h.all_previous).to eq([@e, [@a, @b]])
    end

    specify '#immediately_succeeding_serials - immediately succeeding serial(s if split)' do
      expect(@a.immediately_succeeding_serials.to_a).to eq([@e])
      expect(@e.immediately_succeeding_serials.order(:name).to_a).to eq([@g, @h])
      expect(@h.immediately_succeeding_serials.to_a).to eq([])
      expect(@d.immediately_succeeding_serials.to_a).to eq([@f])
    end
    specify '#all_succeeding_serials - should list all historically related succeeding serials' do
      # want all succeeding serials of a == [e, [g,h]]
      expect(@a.all_succeeding).to eq([@e, [@g, @h]])
      expect(@d.all_succeeding).to eq([@f])
      expect(@f.all_succeeding).to eq([])

      @i = Serial.create(name: 'I')
      SerialChronology::SerialSequence.create(preceding_serial: @f, succeeding_serial: @i)
      expect(@d.all_succeeding).to eq([@f, [@i]])
    end

    specify 'should be able to delete & re-arrange serial chronologies' do
      SerialChronology::SerialSequence.create(preceding_serial: @f, succeeding_serial: @a)
      # d => f=> a merge b => e splits g & h
      expect(@h.all_previous).to eq([@e, [@a, [@f,[@d]], @b]])

      # delete [@f, @d]
      expect(@f.immediately_preceding_serials).to eq([@d])
      r = SerialChronology::SerialSequence.where(preceding_serial: @d, succeeding_serial: @f)  # returns an array
      expect(r.count).to eq(1)
      expect(r.first.destroy).to be_truthy

      SerialChronology::SerialSequence.create(preceding_serial: @d, succeeding_serial: @b)
      # f => a ; d =>b  ; a & b merge to e which splits to g & h
      expect(@h.all_previous).to eq([@e, [@a, [@f], @b, [@d]]])
    end
    skip '#full_chronology - should list the full serial tree' do
      # Not sure we're going to implement this - it is complex to represent a full chronology because we need
      # to represent siblings somehow and how do you handle translations? Also do you provide full trees for siblings
      # as well?
    end
  end

  context 'Serial translations' do
    before {
      @c = Serial.create(name: 'C')
      @d = Serial.create(name: 'D')
      @c.translated_from_serial= @d
      @c.save!
      @a = Serial.create(name: 'A')
    }
    context 'find translations of a serial' do
      specify 'single serial' do
        expect(@d.translations.to_a).to eq([@c])
      end
      specify 'no translations' do
        expect(@c.translations.to_a).to eq([])
      end
      specify 'mult translations' do
        @a.translated_from_serial = @d
        @a.save!
        expect(@d.translations.order(:name).to_a).to eq([@a,@c])
      end
    end
  end
end
