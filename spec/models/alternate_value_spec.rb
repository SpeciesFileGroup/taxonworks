require 'rails_helper'

describe AlternateValue, group: :annotators do
  let(:alternate_value) { AlternateValue.new }

  context 'Dual::Annotator' do

    specify '#force_community_check, with is_community_annotation' do
      g = FactoryBot.create(:valid_geographic_area)
      a = AlternateValue::Abbreviation.create!(
        alternate_value_object: g,
        value: 'A.',
        alternate_value_object_attribute: :name,
        is_community_annotation: true)
      expect(a.project_id.nil?).to be_truthy
    end

    specify '#force_community_check, without is_community_annotation' do
      g = FactoryBot.create(:valid_geographic_area)
      a = AlternateValue::Abbreviation.create!(alternate_value_object: g, value: 'A.', alternate_value_object_attribute: :name )
      expect(a.project_id.nil?).to be_truthy
    end

    specify '#force_community_check, subclasses' do
      o = FactoryBot.create(:valid_common_name)
      a = AlternateValue::Abbreviation.create!(
        alternate_value_object: o,
        value: 'A.',
        alternate_value_object_attribute: :name,
        is_community_annotation: true)
      expect(a.project_id.nil?).to be_truthy
    end
  end

  context 'associations' do
    context 'belongs_to' do
      specify 'language' do
        expect(alternate_value.language = Language.new).to be_truthy
      end

      specify 'alternate_value_object' do
        expect(alternate_value.alternate_value_object = Serial.new).to be_truthy
      end
    end
  end

  context 'validation' do
    context 'required' do
      before(:each) {
        alternate_value.valid?
      }

      specify 'alternate_value_object' do
        # This eliminate all model based validation requirements
        alternate_value.type = 'AlternateValue::Abbreviation'
        alternate_value.value = 'asdf'
        alternate_value.alternate_value_object_attribute = 'name'
        expect{alternate_value.save}.to raise_error ActiveRecord::StatementInvalid
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
      alternate_value.alternate_value_object = FactoryBot.build(:valid_serial)
      alternate_value.alternate_value_object_attribute = 'foo'
      alternate_value.valid?
      expect(alternate_value.errors.include?(:alternate_value_object_attribute)).to be_truthy
    end

    specify 'legal column name is legal' do
      alternate_value.alternate_value_object = FactoryBot.build(:valid_serial)
      alternate_value.alternate_value_object_attribute = 'name'
      alternate_value.value = '10'
      alternate_value.valid?
      expect(alternate_value.errors.include?(:alternate_value_object_attribute)).to be_falsey
    end

    specify 'value is not identical to existing value' do
      alternate_value.alternate_value_object = FactoryBot.build(:valid_serial, name: 'foo')
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
      av = FactoryBot.build(:valid_alternate_value, type: 'Foo').attributes
      expect { AlternateValue.new(av) }.to raise_error(ActiveRecord::SubclassNotFound)
    end

    specify 'can not provide an alternate value for a empty or nil field' do
      sb  = FactoryBot.build_stubbed(:valid_source_bibtex) # relies on valid_source_bibtex not having an assigned author
      alternate_value.alternate_value_object = sb
      alternate_value.alternate_value_object_attribute = 'author'
      alternate_value.value = 'foo'
      alternate_value.valid?
      expect(alternate_value.errors.include?(:alternate_value_object_attribute)).to be_truthy
    end
  end

  context 'scopes' do
    specify 'with_alternate_value_on using <<' do
      o = FactoryBot.create(:valid_serial)
      o.alternate_values << FactoryBot.build(:valid_alternate_value_abbreviation, value: 'foo')
      o.save!

      expect(Serial.with_alternate_value_on(:name, 'foo').count).to eq(1)
      expect(Serial.with_alternate_value_on(:name, 'foo').first.id).to eq(o.id) # see the serial_factory
    end
  end

  context 'use' do

    context 'adding an alternate_value' do
      specify 'with <<' do
        s = FactoryBot.create(:valid_serial)
        s.alternate_values << FactoryBot.build(:valid_alternate_value_abbreviation, value: 'JOR')
        expect(s.save).to be_truthy
        expect(s.alternate_values.count).to eq(1)
      end

      specify 'with nested_attributes' do
        s = Sequence.new(
          sequence: 'ACGT',
          name: 'foo',
          sequence_type: 'DNA',
          alternate_values_attributes: [
            {type: 'AlternateValue::Abbreviation',
             value: 'fo.',
             alternate_value_object_attribute: :name}
          ])
        expect(s.save!).to be_truthy
        expect(s.alternate_values.reload.first.value).to eq('fo.')
      end
    end

    specify 'original_value' do
      expect(alternate_value).to respond_to(:original_value)
      tmp = 'my journal'
      o   = FactoryBot.build(:valid_serial, name: tmp)
      v   = FactoryBot.build(:valid_alternate_value_abbreviation, value: 'foo', alternate_value_object_attribute: 'name', alternate_value_object: o)
      expect(v.original_value).to eq(tmp) # see the serial_factory
    end

    context 'for community data project_id is not set when is_community_annotation == true' do
      specify 'on save' do
        o                                                = FactoryBot.build(:valid_serial, name: 'The Serial')
        alternate_value.alternate_value_object           = o  # setting object let's current schema work
        alternate_value.alternate_value_object_attribute = 'name'
        alternate_value.value                            = 'T.S.'
        alternate_value.type                             = 'AlternateValue::Abbreviation'
        alternate_value.is_community_annotation = true
        expect(alternate_value.valid?).to be(true)
        expect(alternate_value.project_id).to eq(nil)
      end

      specify 'when using <<' do
        o    = FactoryBot.create(:valid_serial, name: 'The Serial')
        altv = AlternateValue.new(
          type: 'AlternateValue::AlternateSpelling',
          value: 'Blorf',
          alternate_value_object_attribute: 'name',
          created_by_id: Current.project_id,
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
      o                                                = FactoryBot.build(:valid_controlled_vocabulary_term)
      alternate_value.alternate_value_object           = o
      alternate_value.alternate_value_object_attribute = 'name'
      alternate_value.value                            = 'T.S.'
      alternate_value.type                             = 'AlternateValue::Abbreviation'
      expect(alternate_value.valid?).to be(true)
      alternate_value.save!
      expect(alternate_value.project_id).to eq(1)
    end
  end

  context 'concerns' do
    it_behaves_like 'is_data'
  end

end
