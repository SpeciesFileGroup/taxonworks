require 'rails_helper'

describe DataAttribute, :type => :model do
  let(:attribute) {DataAttribute.new}


  context 'validation' do
    before(:each) {
      attribute.valid?
    }
    context 'requires' do

      specify 'attribute_subject' do 
        # this eliminate all model based validation requirements
        attribute.type = 'ImportAttribute'
        attribute.value = 'asdf'
        attribute.import_predicate = 'jkl'
        expect{attribute.save}.to raise_error ActiveRecord::StatementInvalid
      end

      specify 'value' do
        expect(attribute.errors.include?(:value)).to be_truthy
      end

      specify 'type' do
        expect(attribute.errors.include?(:type)).to be_truthy
      end
    end

    specify 

    # Hmmm.. review this
    specify 'key/value is unique' do
      a = FactoryGirl.create(:valid_data_attribute, value: 'black')
      p = ImportAttribute.new(attribute_subject: a.attribute_subject, import_predicate: 'hair color', value: 'black')
      expect(p.valid?).to be_falsey
      expect(p.errors.include?(:value)).to be_truthy
    end
  end
end
