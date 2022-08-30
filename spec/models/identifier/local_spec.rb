require 'rails_helper'

describe Identifier::Local, type: :model, group: :identifiers do
  let(:local_identifier) {Identifier::Local.new}
  let(:otu) {FactoryBot.create(:valid_otu)}
  let(:namespace_name) {'foo'}
  let(:namespace_name2) {'bar'}
  let(:namespace) {FactoryBot.create(:valid_namespace, name: namespace_name )}
  let(:namespace2) {FactoryBot.create(:valid_namespace, name: namespace_name2 )}
  let(:specimen1) {FactoryBot.create(:valid_specimen)}
  let(:specimen2) {FactoryBot.create(:valid_specimen)}


  specify 'community shared 1' do
    o = FactoryBot.create(:valid_otu)
    i = FactoryBot.create(:valid_identifier_local, identifier_object: o)
    expect(i.project_id.blank?).to be_falsey
  end

  # Local identifiers are not shared
  specify 'community shared 2' do
    o = FactoryBot.create(:valid_source)
    i = FactoryBot.create(:valid_identifier_local, identifier_object: o)
    expect(i.project_id.blank?).to be_falsey
  end

  context 'validation' do
    before(:each) { local_identifier.valid? }

    specify 'unsaved namespace prevents save' do
      expect(Identifier::Local::AccessionCode.new(
        identifier_object: specimen1,
        namespace: Namespace.new,
        identifier: '123').save).to be_falsey
    end

    context 'requires' do
      specify 'namespace' do
        expect(local_identifier.errors.include?(:namespace_id)).to be_truthy
      end
    end

    context 'you can add multiple identifiers' do
      specify 'of the same type to a single object as long as namespace differs' do
        i1 = Identifier::Local::CatalogNumber.new(namespace: namespace, identifier_object: specimen1, identifier: 123)
        i2 = Identifier::Local::CatalogNumber.new(namespace: namespace2, identifier_object: specimen1, identifier: 345)
        expect(i1.save).to be_truthy
        expect(i2.save).to be_truthy
      end

      specify 'of the same type with the same namespace to a single object as long as the identifier differs' do
        i1 = Identifier::Local::CatalogNumber.new(namespace: namespace, identifier_object: specimen1, identifier: 123)
        i2 = Identifier::Local::CatalogNumber.new(namespace: namespace, identifier_object: specimen1, identifier: 345)
        expect(i1.save).to be_truthy
        expect(i2.save).to be_truthy
      end
    end

    context 'you can not add' do
      specify 'the same namespaced identifier to more than one object (of the same type)' do
        i1 = Identifier::Local::CatalogNumber.new(namespace: namespace, identifier_object: specimen1, identifier: 123)
        i2 = Identifier::Local::CatalogNumber.new(namespace: namespace, identifier_object: specimen2, identifier: 123)
        expect(i1.save).to be_truthy
        expect(i2.save).to be_falsey
        expect(i2.errors.include?(:identifier)).to be_truthy
      end

      specify 'the same namespaced identifier to more than one object (of different types)' do
        i1 = Identifier::Local::CatalogNumber.new(namespace: namespace, identifier_object: specimen1, identifier: 123)
        i2 = Identifier::Local::CatalogNumber.new(namespace: namespace, identifier_object: otu, identifier: 123)
        expect(i1.save).to be_truthy
        expect(i2.save).to be_falsey
        expect(i2.errors.include?(:identifier)).to be_truthy
      end
    end
  end

  specify 'cache is populated' do
    i1 = Identifier::Local::CatalogNumber.create(namespace: namespace, identifier_object: specimen1, identifier: 123)
    expect(i1.cached).to eq("#{namespace.short_name} 123")
  end

  specify 'virtual namespaces do not appear in cached' do
    namespace.update!(is_virtual: true)
    i1 = Identifier::Local::CatalogNumber.create(namespace: namespace, identifier_object: specimen1, identifier: 123)
    expect(i1.cached).to eq('123')
  end

  specify 'updating Namespace updates #cache' do
    i = Identifier::Local::CatalogNumber.create!(namespace: namespace, identifier_object: specimen1, identifier: 123)
    original = i.cached
    namespace.update!(short_name: 'cache_test_short', verbatim_short_name: 'cache_test_verbatim_short', delimiter: ':delimiter-test:')
    expect(i.reload.cached).to eq("cache_test_verbatim_short:delimiter-test:123")
  end


end
