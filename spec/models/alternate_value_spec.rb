require 'spec_helper'

describe AlternateValue do
  let (:alternate_value) { FactoryGirl.build(:alternate_value)}

  context 'associations' do
    context 'belongs_to' do
      specify 'language' do
        expect(alternate_value).to respond_to(:language)
      end

      specify 'alternate_object' do
        expect(alternate_value).to respond_to(:alternate_object)
      end
    end
  end

  context 'validation' do
    context 'required' do
      before(:each) {
        alternate_value.valid?
      }
      specify 'alternate_object' do
        expect(alternate_value.errors.include?(:alternate_object)).to be_truthy
      end

      specify 'alternate_object_attribute' do 
        expect(alternate_value.errors.include?(:alternate_object_attribute)).to be_truthy
      end

      specify 'value' do 
        expect(alternate_value.errors.include?(:value)).to be_truthy
      end

      specify 'type' do 
        expect(alternate_value.errors.include?(:type)).to be_truthy
      end
    end

    specify 'alternate_object_attribute is legal column of alternate_object' do
      alternate_value.alternate_object = FactoryGirl.build_stubbed(:valid_protonym)
      alternate_value.alternate_object_attribute = 'foo'
      alternate_value.valid?
      expect(alternate_value.errors.include?(:alternate_object_attribute)).to be_truthy
      alternate_value.alternate_object_attribute = 'name'
      alternate_value.valid?
      expect(alternate_value.errors.include?(:alternate_object_attribute)).to be_falsey
    end

    specify 'value is not identical to existing value' do
      alternate_value.alternate_object = FactoryGirl.build_stubbed(:valid_otu, name: 'foo')
      alternate_value.alternate_object_attribute = 'name'
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
      otu = FactoryGirl.build_stubbed(:valid_otu, name: '')
      alternate_value.alternate_object = otu
      alternate_value.alternate_object_attribute = 'name'
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
      o = FactoryGirl.build(:valid_otu)
      o.alternate_values << FactoryGirl.build(:valid_alternate_value_abbreviation, alternate_object: o, value: 'foo') 
      o.save!

      expect(Otu.with_alternate_value_on(:name, 'foo').count).to eq(1)
      expect(Otu.with_alternate_value_on(:name, 'foo').first.name).to eq('my concept') # see the otu_factory
    end
  end

  context 'use' do
    specify 'adding an alternate value' do 
      o = FactoryGirl.build(:valid_otu)
      o.alternate_values << FactoryGirl.build(:valid_alternate_value_abbreviation, alternate_object: o, value: 'foo') 
      expect(o.save).to be_truthy
      expect(o.alternate_values.count).to eq(1)
    end

    specify 'original_value' do
      expect(alternate_value).to respond_to(:original_value)
      v = FactoryGirl.build(:valid_alternate_value_abbreviation, value: 'foo', alternate_object_attribute: 'name') 
      expect(v.original_value).to eq('my concept') # see the otu_factory
    end
  end

end
