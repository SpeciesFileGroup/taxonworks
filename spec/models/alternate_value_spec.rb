require 'rails_helper'

describe AlternateValue do
  let (:alternate_value) { FactoryGirl.build(:alternate_value)}

  context 'associations' do
    context 'belongs_to' do
      specify 'language' do
        expect(alternate_value).to respond_to(:language)
      end

      specify 'alternate_value_object' do
        expect(alternate_value).to respond_to(:alternate_value_object)
      end
    end
  end

  context 'validation' do
    context 'required' do
      before(:each) {
        alternate_value.valid?
      }
      specify 'alternate_value_object' do
        expect(alternate_value.errors.include?(:alternate_value_object)).to be_truthy
      end

      specify 'alternate_value_object_attribute' do 
        expect(alternate_value.errors.include?(:alternate_value_object_attribute)).to be_truthy
      end

      specify 'value' do 
        expect(alternate_value.errors.include?(:value)).to be_truthy
      end

      specify 'type' do 
        expect(alternate_value.errors.include?(:type)).to be_truthy
      end
    end

    specify 'alternate_value_object_attribute is legal column of alternate_value_object' do
      alternate_value.alternate_value_object = FactoryGirl.build(:valid_serial)
      alternate_value.alternate_value_object_attribute = 'foo'
      alternate_value.valid?
      expect(alternate_value.errors.include?(:alternate_value_object_attribute)).to be_truthy
      alternate_value.alternate_value_object_attribute = 'name'
      alternate_value.valid?
      expect(alternate_value.errors.include?(:alternate_value_object_attribute)).to be_falsey
    end

    specify 'value is not identical to existing value' do
      alternate_value.alternate_value_object = FactoryGirl.build(:valid_serial, name: 'foo')
      alternate_value.alternate_value_object_attribute = 'name'
      alternate_value.value = 'foo'
      alternate_value.valid?
      expect(alternate_value.errors.include?(:value)).to be_truthy
      alternate_value.value = 'bar'
      alternate_value.valid?
      expect(alternate_value.errors.include?(:value)).to be_falsey
    end

    specify 'valid type' do
      av = FactoryGirl.build_stubbed(:valid_alternate_value)
      expect(av.valid?).to be_truthy
      av.type = 'Foo'
      expect(av.valid?).to be_falsey
      expect(av.errors.include?(:type)).to be_truthy
    end

    specify 'can not provide an alternate value for a empty or nil field' do
      sb = FactoryGirl.build_stubbed(:valid_source_bibtex)    # relies on valid_source_bibtex not having an assigned author
      alternate_value.alternate_value_object = sb
      alternate_value.alternate_value_object_attribute = 'author'
      alternate_value.value = 'foo'
      alternate_value.valid?
      expect(alternate_value.errors.include?(:value)).to be_truthy
    end

    specify 'can not add alternate values to NON_ANNOTATABLE_COLUMNS' do
      skip
    end

  end

  context 'scopes' do
    specify 'with_alternate_value_on' do
      o = FactoryGirl.build(:valid_serial)
      o.alternate_values << FactoryGirl.build(:valid_alternate_value_abbreviation, alternate_value_object: o, value: 'foo') 
      o.save!

      expect(Serial.with_alternate_value_on(:name, 'foo').count).to eq(1)
      expect(Serial.with_alternate_value_on(:name, 'foo').first.id).to eq(o.id) # see the serial_factory
    end
  end

  context 'use' do
    specify 'adding an alternate value' do 
      s = FactoryGirl.build(:valid_serial)
      s.alternate_values << FactoryGirl.build(:valid_alternate_value_abbreviation, alternate_value_object: s, value: 'JOR')
      expect(s.save).to be_truthy
      expect(s.alternate_values.count).to eq(1)
    end

    specify 'original_value' do
      expect(alternate_value).to respond_to(:original_value)
      tmp = 'my journal'
      o = FactoryGirl.build(:valid_serial, name: tmp)
      v = FactoryGirl.build(:valid_alternate_value_abbreviation, value: 'foo', alternate_value_object_attribute: 'name', alternate_value_object: o ) 
      expect(v.original_value).to eq(tmp) # see the serial_factory
    end
  end

end
