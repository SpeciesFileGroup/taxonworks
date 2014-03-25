require 'spec_helper'

describe Identifier do

  let(:identifier) { FactoryGirl.build(:identifier) }

  before(:each) {
    @n = FactoryGirl.create(:valid_namespace)
    @s1 = FactoryGirl.create(:valid_specimen)
    @s2 = FactoryGirl.create(:valid_specimen)
  }

  context 'validation' do
    context 'requires' do
      before do
        identifier.save
      end

      specify 'identifier' do
        expect(identifier.errors.include?(:identifier)).to be_true
      end

      specify 'identified_object' do
        expect(identifier.errors.include?(:identified_object)).to be_true
      end

      specify 'type' do
        expect(identifier.errors.include?(:type)).to be_true
      end
    end

    specify 'has an identified_object' do
      expect(identifier).to respond_to(:identified_object)
      expect(identifier.identified_object).to be(nil)   
    end

    specify 'you can\'t add multiple identifiers of the same type to a single object' do
      i1 = Identifier::Local::CatalogNumber.new(namespace: @n, identified_object: @s1, identifier: 123)
      i2 = Identifier::Local::CatalogNumber.new(namespace: @n, identified_object: @s1, identifier: 345)
      expect(i1.save).to be_true
      expect(i2.save).to be_false
      expect(i2.errors.include?(:type)).to be_true
    end

    specify 'you can\'t add non-unique identifiers of the same type to a two objects' do
      i1 = Identifier::Local::CatalogNumber.new(namespace: @n, identified_object: @s1, identifier: 123)
      i2 = Identifier::Local::CatalogNumber.new(namespace: @n, identified_object: @s2, identifier: 123)
      expect(i1.save).to be_true
      expect(i2.save).to be_false
      expect(i2.errors.include?(:identifier)).to be_true
    end
  end

  context 'scopes' do
    specify '#of_type(some_type_short_name) returns identifiers of that type' do
      i2 = Identifier::Global::Uri.create(identified_object: @s1, identifier: 'http:://foo.com/123')
      i1 = Identifier::Local::CatalogNumber.create(identified_object: @s1, namespace: @n, identifier: 123)

      expect(@s1.identifiers.of_type(:uri).to_a).to eq([i2])
      expect(@s1.identifiers.of_type(:catalog_number).to_a).to eq([i1])
    end
  end
  # src.of_type(:isbn) should return one and only one identifier






end



