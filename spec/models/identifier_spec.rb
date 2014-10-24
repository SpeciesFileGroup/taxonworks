require 'rails_helper'

describe Identifier, :type => :model do

  let(:identifier) { FactoryGirl.build(:identifier) }
  let(:namespace) {FactoryGirl.create(:valid_namespace)}
  let(:specimen1) {FactoryGirl.create(:valid_specimen)}
  let(:specimen2) {FactoryGirl.create(:valid_specimen)}

  context 'validation' do
    context 'requires' do
      before do
        identifier.save
      end

      specify 'identifier' do
        expect(identifier.errors.include?(:identifier)).to be_truthy
      end

      specify 'identified_object' do
        expect(identifier.errors.include?(:identified_object)).to be_truthy
      end

      specify 'type' do
        expect(identifier.errors.include?(:type)).to be_truthy
      end
    end

    specify 'has an identified_object' do
      expect(identifier).to respond_to(:identified_object)
      expect(identifier.identified_object).to be(nil)   
    end

    specify 'you can\'t add multiple identifiers of the same type to a single object' do
      i1 = Identifier::Local::CatalogNumber.new(namespace: namespace, identified_object: specimen1, identifier: 123)
      i2 = Identifier::Local::CatalogNumber.new(namespace: namespace, identified_object: specimen1, identifier: 345)
      expect(i1.save).to be_truthy
      expect(i2.save).to be_falsey
      expect(i2.errors.include?(:type)).to be_truthy
    end

    specify 'you can\'t add non-unique identifiers of the same type to a two objects' do
      i1 = Identifier::Local::CatalogNumber.new(namespace: namespace, identified_object: specimen1, identifier: 123)
      i2 = Identifier::Local::CatalogNumber.new(namespace: namespace, identified_object: specimen2, identifier: 123)
      expect(i1.save).to be_truthy
      expect(i2.save).to be_falsey
      expect(i2.errors.include?(:identifier)).to be_truthy
    end
  end

  context 'scopes' do
    specify '#of_type(some_type_short_name) returns identifiers of that type' do
      i2 = Identifier::Global::Uri.create(identified_object: specimen1, identifier: 'http:://foo.com/123')
      i1 = Identifier::Local::CatalogNumber.create(identified_object: specimen1, namespace: namespace, identifier: 123)

      expect(specimen1.identifiers.of_type(:uri).to_a).to eq([i2])
      expect(specimen1.identifiers.of_type(:catalog_number).to_a).to eq([i1])
    end
  end

end



