require 'rails_helper'

describe 'AlternateValues', :type => :model do
  let(:instance_with_alternate_values) { TestAlternateValue.new }

  context 'reflections / foreign keys' do
    specify 'has many alternates' do
      expect(instance_with_alternate_values).to respond_to(:alternate_values)
      expect(instance_with_alternate_values.alternate_values.count == 0).to be_truthy
    end
  end

  context 'methods' do
    before do
      instance_with_alternate_values.string = 'Testing alternate values'
      instance_with_alternate_values.save

      misspelled = AlternateValue::Misspelling.create(
        value:                            'tast1',
        alternate_value_object_attribute: 'string',
        alternate_value_object:           instance_with_alternate_values)

      alt_spell = AlternateValue::AlternateSpelling.create(
        value:                            'test1',
        alternate_value_object_attribute: 'string',
        alternate_value_object:           instance_with_alternate_values)

      trans = AlternateValue::Translation.create(
        value:                            'gibberish',
        language:                         FactoryGirl.create(:valid_language),
        alternate_value_object_attribute: 'string',
        alternate_value_object:           instance_with_alternate_values
      )
      abbrv = AlternateValue::Abbreviation.create(
        value:                            'tst',
        alternate_value_object_attribute: 'string',
        alternate_value_object:           instance_with_alternate_values
      )
    end

    context 'instance methods' do
      specify '#alternate_valued? with none attached' do
        tav = TestAlternateValue.new
        expect(tav.alternate_valued?).to be_falsey
      end

      specify '#alternate_valued? with some attached' do
        # tav =   TestAlternateValue.new
        # tav.string = 'Foo'
        # tav.alternate_values << AlternateValue::Misspelling.new(alternate_value_object_attribute: :string, value: 'Fu')
        expect(instance_with_alternate_values.alternate_valued?).to be_truthy
      end

      specify '#all_values_for uses string' do
        expect(instance_with_alternate_values.all_values_for('string')).to \
          eq(['gibberish', 'test1', 'Testing alternate values', 'tst', 'tast1'].sort)
      end
      specify '#all_values_for uses symbol' do
        expect(instance_with_alternate_values.all_values_for(:string)).to \
          eq(['gibberish', 'test1', 'Testing alternate values', 'tst', 'tast1'].sort)
      end
      context 'on destruct of primary' do
        specify 'attached values are destroyed' do
          expect(instance_with_alternate_values.alternate_values.count).to eq(4)
          expect(instance_with_alternate_values.destroy).to be_truthy
          expect(AlternateValue.count).to eq(0)
        end
      end
    end

    context 'class methods' do
      specify '.with_alternate_value_on' do
        # find me all the TestAlternateValue objects that have an alternate value of 'test1' on attribute 'string'
        expect(TestAlternateValue.with_alternate_value_on('string', 'test1').to_a).to eq([instance_with_alternate_values])
        expect(TestAlternateValue.with_alternate_value_on('string', 'foo').to_a).to eq([])
      end
    end

  end
end

class TestAlternateValue < ApplicationRecord
  include FakeTable
  include Shared::AlternateValues

  ALTERNATE_VALUES_FOR = [:string]
end


