require 'rails_helper'

describe 'Identifiable', type: :model, group: [:identifiers] do
  let(:identifiable_instance) {TestIdentifiable.new}
  let(:identifiable_class) {TestIdentifiable}

  context 'associations' do
    specify 'has many identifiers' do
      expect(identifiable_instance.identifiers << Identifier.new).to be_truthy
    end
  end

   context 'methods' do
    specify '#identified?' do
      expect(identifiable_instance.identified?).to eq(false)
    end

    specify '#identified? with some identifiers' do
      identifiable_instance.save!
      identifiable_instance.identifiers << Identifier::Global::Uri.new(identifier: 'http:/uri.org/foo/123')
      expect(identifiable_instance.identified?).to eq(true)
    end

    context 'with some records created' do
      let(:namespace_name1) {'INHSIC'}
      let(:namespace_name2) {'NCSU'}
      let(:namespace_name3) {'CNC'}

      let!(:n1) {FactoryBot.create(:valid_namespace, short_name: namespace_name1) }
      let!(:n2) {FactoryBot.create(:valid_namespace, name: namespace_name2) }
      let!(:n3) {FactoryBot.create(:valid_namespace, short_name: namespace_name3) }

      let!(:identifier1) { Identifier::Local::CatalogNumber.create!( identifier_object: identifiable_instance, identifier: '123', namespace: n1) }
      let!(:identifier2) { Identifier::Local::CatalogNumber.create!( identifier_object: identifiable_instance, identifier: '456', namespace: n2) }
      let!(:identifier3) { Identifier::Local::CatalogNumber.create!( identifier_object: identifiable_instance, identifier: '789', namespace: n3) }

      specify '#with_identifier_type_and_namespace' do
        expect(identifiable_class.with_identifier_type_and_namespace('Identifier::Local::CatalogNumber', n1.id)).to contain_exactly(identifiable_instance)
      end

      specify '.with_identifiers_sorted' do
        expect(identifiable_class.with_identifiers_sorted.to_a).to be_truthy
      end

      specify '#identifiers' do
        expect(identifiable_instance.identifiers).to contain_exactly(identifier1, identifier2, identifier3)
      end

      specify '#identified?' do
        identifiable_instance.project_id = 1
        expect(identifiable_instance.identified?).to eq(true)
      end

      specify '#with_namespaced_identifier(namespace_name, identifier)' do
        expect(identifiable_class.with_namespaced_identifier('foo', '123').count).to eq(0)
        expect(identifiable_class.with_namespaced_identifier(namespace_name1, '123').all.count).to eq(1)
      end

      specify '#with_identifier(value)' do
        expect(identifiable_class.with_identifier('INHSIC 123').count).to eq(1)
        expect(identifiable_class.with_identifier(['INHSIC 123', 'CNC 789']).count).to eq(2)
      end

      context 'on destroy' do
        specify 'attached identifiers are destroyed' do
          expect(identifiable_instance.identifiers.count).to eq(3)
          expect(identifiable_instance.destroy).to be_truthy
          expect(Identifier.count).to eq(0)
        end
      end

    end
  end

end

class TestIdentifiable < ApplicationRecord
  include FakeTable
  include Shared::Identifiers
end


