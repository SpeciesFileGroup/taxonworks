require 'rails_helper'

describe 'AlternateValues', :type => :model do
  let(:instance_with_alternate_values) { TestAlternateValue.new   }

  # TODO rename to :instance_with_alternate_values throughout and delete this line
  let(:class_with_alternate_values) { TestAlternateValue.new }

  context 'reflections / foreign keys' do
    specify 'has many alternates' do
      expect(class_with_alternate_values).to respond_to(:alternate_values)
      expect(class_with_alternate_values.alternate_values.count == 0).to be_truthy
    end
  end

  specify '#has_alternate_values? is false when there are not alternative values' do
    expect(class_with_alternate_values).to respond_to(:has_alternate_values?)
    expect(class_with_alternate_values.has_alternate_values?).to eq(false)
  end

  context 'methods' do
    before do
      class_with_alternate_values.string = 'Testing alternate values'
      class_with_alternate_values.save

      misspelled  = AlternateValue::Misspelling.create(
          value: 'tast1',
          alternate_value_object_attribute: 'string',
          alternate_value_object: class_with_alternate_values)

      alt_spell  = AlternateValue::AlternateSpelling.create(
        value: 'test1',
        alternate_value_object_attribute: 'string',
        alternate_value_object: class_with_alternate_values)

      trans = AlternateValue::Translation.create(
          value: 'gibberish',
          language: FactoryGirl.create(:valid_language),
          alternate_value_object_attribute: 'string',
          alternate_value_object: class_with_alternate_values
      )
      abbrv = AlternateValue::Abbreviation.create(
          value: 'tst',
          alternate_value_object_attribute: 'string',
          alternate_value_object: class_with_alternate_values
      )
    end

    specify 'alternate_valued?' do
      expect(instance_with_alternate_values.alternate_valued?).to eq(false)
    end

    # TODO add a countering example once we add an alternate value to our instance_with_alternate_values



    specify '#all_values_for' do
      expect(class_with_alternate_values.all_values_for('string')).to \
            eq(['gibberish', 'test1', 'Testing alternate values', 'tst', 'tast1'].sort)
    end

    specify '.with_alternate_value_on' do
      # find me all the TestAlternateValue objects that have an alternate value of 'test1' on attribute 'string'
      expect(TestAlternateValue.with_alternate_value_on('string', 'test1').to_a).to \
        eq([class_with_alternate_values])
      expect(TestAlternateValue.with_alternate_value_on('string', 'foo').to_a).to  \
      eq([])
    end
  end
end

class TestAlternateValue < ActiveRecord::Base
  include FakeTable
  include Shared::AlternateValues
end


