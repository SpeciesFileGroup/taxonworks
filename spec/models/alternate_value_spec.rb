require 'rails_helper'

describe AlternateValue, group: :annotators do
  let(:alternate_value) { AlternateValue.new }

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

    specify 'illegal column name invalidates' do
      alternate_value.alternate_value_object           = FactoryGirl.build(:valid_serial)
      alternate_value.alternate_value_object_attribute = 'foo'
      alternate_value.valid?
      expect(alternate_value.errors.include?(:alternate_value_object_attribute)).to be_truthy
    end

    specify 'legal column name is legal' do
      alternate_value.alternate_value_object           = FactoryGirl.build(:valid_serial)
      alternate_value.alternate_value_object_attribute = 'name'
      alternate_value.value = "10"
      alternate_value.valid?
      expect(alternate_value.errors.include?(:alternate_value_object_attribute)).to be_falsey
    end

    specify 'value is not identical to existing value' do
      alternate_value.alternate_value_object  = FactoryGirl.build(:valid_serial, name: 'foo')
      alternate_value.alternate_value_object_attribute = 'name'
      alternate_value.value = 'foo'
     
      alternate_value.valid?
      
      expect(alternate_value.errors.include?(:alternate_value_object_attribute)).to be_truthy

      alternate_value.value = 'bar'
      alternate_value.valid?
      expect(alternate_value.errors.include?(:alternate_value_object_attribute)).to be_falsey
    end

    # Note that av.type = 'Foo' succeeds to save, but fails to load afterwards.  Type should be set on new.
    specify 'valid type' do
      av = FactoryGirl.build(:valid_alternate_value, type: 'Foo').attributes
      expect { AlternateValue.new(av) }.to raise_error
    end

    specify 'can not provide an alternate value for a empty or nil field' do
      sb  = FactoryGirl.build_stubbed(:valid_source_bibtex) # relies on valid_source_bibtex not having an assigned author
      alternate_value.alternate_value_object  = sb
      alternate_value.alternate_value_object_attribute = 'author'
      alternate_value.value  = 'foo'
      alternate_value.valid?
      expect(alternate_value.errors.include?(:alternate_value_object_attribute)).to be_truthy
    end
  end

  context 'scopes' do
    specify 'with_alternate_value_on using <<' do
      o = FactoryGirl.create(:valid_serial)
      o.alternate_values << FactoryGirl.build(:valid_alternate_value_abbreviation, value: 'foo')
      o.save!

      expect(Serial.with_alternate_value_on(:name, 'foo').count).to eq(1)
      expect(Serial.with_alternate_value_on(:name, 'foo').first.id).to eq(o.id) # see the serial_factory
    end
  end

  context 'use' do
    specify 'adding an alternate value' do
      s = FactoryGirl.create(:valid_serial)
      s.alternate_values << FactoryGirl.build(:valid_alternate_value_abbreviation, value: 'JOR')
      expect(s.save).to be_truthy
      expect(s.alternate_values.count).to eq(1)
    end

    specify 'original_value' do
      expect(alternate_value).to respond_to(:original_value)
      tmp = 'my journal'
      o   = FactoryGirl.build(:valid_serial, name: tmp)
      v   = FactoryGirl.build(:valid_alternate_value_abbreviation, value: 'foo', alternate_value_object_attribute: 'name', alternate_value_object: o)
      expect(v.original_value).to eq(tmp) # see the serial_factory
    end

    context 'for community data project_id is not set when is_community_annotation == true' do 
      specify 'on save' do
        o                                                = FactoryGirl.build(:valid_serial, name: 'The Serial')
        alternate_value.alternate_value_object           = o  # setting object let's current schema work
        alternate_value.alternate_value_object_attribute = 'name'
        alternate_value.value                            = 'T.S.'
        alternate_value.type                             = 'AlternateValue::Abbreviation'
        alternate_value.is_community_annotation = true
        expect(alternate_value.valid?).to be(true)
        expect(alternate_value.project_id).to eq(nil)
      end

      specify 'when using <<' do
        o    = FactoryGirl.create(:valid_serial, name: 'The Serial')
        altv = AlternateValue.new(type:                             'AlternateValue::AlternateSpelling',
                                  value:                            'Blorf',
                                  alternate_value_object_attribute: 'name',
                                  created_by_id: $user_id,
                                  is_community_annotation: true
                                 )
        o.alternate_values << altv
        expect(o.valid?).to be_truthy
        expect(o.save).to be_truthy
        expect(o.alternate_values.size).to eq(1)
        expect(altv.valid?).to be_truthy
        expect(o.alternate_values.first).to eq(altv)
        expect(o.alternate_values.first.project_id).to eq(nil)
      end
    end

    specify 'project_id is set for non community data' do
      o                                                = FactoryGirl.build(:valid_controlled_vocabulary_term)
      alternate_value.alternate_value_object           = o
      alternate_value.alternate_value_object_attribute = 'name'
      alternate_value.value                            = 'T.S.'
      alternate_value.type                             = 'AlternateValue::Abbreviation'
      expect(alternate_value.valid?).to be(true)
      expect(alternate_value.project_id).to eq(1)
    end
  end

  context 'concerns' do
    it_behaves_like 'is_data'
  end

end
