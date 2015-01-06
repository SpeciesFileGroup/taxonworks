require 'rails_helper'

describe Identifier::Local, :type => :model do
  let(:local_identifier) {Identifier::Local.new}
  let(:otu) {FactoryGirl.create(:valid_otu)}
  let(:namespace_name) {'foo'}
  let(:namespace_name2) {'bar'}
  let(:namespace) {FactoryGirl.create(:valid_namespace, name: namespace_name )}
  let(:namespace2) {FactoryGirl.create(:valid_namespace, name: namespace_name2 )}
  let(:specimen1) {FactoryGirl.create(:valid_specimen)}
  let(:specimen2) {FactoryGirl.create(:valid_specimen)}

  context 'validation' do
    before(:each) {
      local_identifier.valid?
    }
    context 'requires' do
      specify 'namespace' do
        expect(local_identifier.errors.include?(:namespace)).to be_truthy
      end
    end

    specify 'you can add multiple identifiers of the same type to a single object as long as namespace differs' do
      i1 = Identifier::Local::CatalogNumber.new(namespace: namespace, identifier_object: specimen1, identifier: 123)
      i2 = Identifier::Local::CatalogNumber.new(namespace: namespace2, identifier_object: specimen1, identifier: 345)
      expect(i1.save).to be_truthy
      expect(i2.save).to be_truthy
    end

    specify 'you can not add multiple identifiers of the same type to a single object' do
      i1 = Identifier::Local::CatalogNumber.new(namespace: namespace, identifier_object: specimen1, identifier: 123)
      i2 = Identifier::Local::CatalogNumber.new(namespace: namespace, identifier_object: specimen1, identifier: 345)
      expect(i1.save).to be_truthy
      expect(i2.save).to be_falsey
      expect(i2.errors.include?(:namespace)).to be_truthy
    end

    specify 'you can not add the same namespaced identifier to more than one object (of the same type)' do
      i1 = Identifier::Local::CatalogNumber.new(namespace: namespace, identifier_object: specimen1, identifier: 123)
      i2 = Identifier::Local::CatalogNumber.new(namespace: namespace, identifier_object: specimen2, identifier: 123)
      expect(i1.save).to be_truthy
      expect(i2.save).to be_falsey
      expect(i2.errors.include?(:identifier)).to be_truthy
    end

    specify 'you can not add the same namespaced identifier to more than one object (of different types)' do
      i1 = Identifier::Local::CatalogNumber.new(namespace: namespace, identifier_object: specimen1, identifier: 123)
      i2 = Identifier::Local::CatalogNumber.new(namespace: namespace, identifier_object: otu, identifier: 123)
      expect(i1.save).to be_truthy
      expect(i2.save).to be_falsey
      expect(i2.errors.include?(:identifier)).to be_truthy
    end

  end
end
