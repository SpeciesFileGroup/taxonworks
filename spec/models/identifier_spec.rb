require 'rails_helper'

describe Identifier, type: :model, group: [:annotators, :identifiers] do
  include ActiveJob::TestHelper

  let(:identifier) { FactoryBot.build(:identifier) }
  let(:namespace) { FactoryBot.create(:valid_namespace) }
  let(:specimen1) { FactoryBot.create(:valid_specimen) }
  let(:specimen2) { FactoryBot.create(:valid_specimen) }
  let(:serial) { FactoryBot.create(:valid_serial) }

  specify 'validate annotated_object' do
    p = FactoryBot.create(:valid_person)
    p.destroy
    i = Identifier::Global::Wikidata.new(identifier_object: p, identifier: 'Q1234')
    expect(i.valid?).to be_falsey
  end

  specify 'over-ride validate annotated_object' do
    p = FactoryBot.create(:valid_person)
    p.destroy
    i = Identifier::Global::Wikidata.new(identifier_object: p, identifier: 'Q1234', annotator_batch_mode: true)
    expect(i.valid?).to be_truthy
  end

  specify '.prefer 1' do
    c =  'Identifier::Local::CatalogNumber'
    specimen1.identifiers << FactoryBot.build(:valid_identifier_local, type: c)
    specimen1.identifiers << FactoryBot.build(:uri_identifier)

    expect(specimen1.identifiers.prefer(c).first.type).to eq(c)
  end

  specify '.prefer 2' do
    c =  'Identifier::Local::CatalogNumber'
    specimen1.identifiers << FactoryBot.build(:valid_identifier_local, type: c)
    specimen1.identifiers << FactoryBot.build(:uri_identifier)
    expect(specimen1.identifiers.prefer('Identifier::Global::Uri').first.type).to_not eq(c)
  end

  context 'validation' do

    context 'requires' do
      before { identifier.valid? }

      # !! This test fails not because of a validation, but because of a NOT NULL constraint.
      specify 'identifier_object' do
        # this eliminate all model based validation requirements
        identifier.type = 'Identifier::Local::CatalogNumber'
        identifier.namespace_id = FactoryBot.create(:valid_namespace).id
        identifier.identifier = '123'
        expect(identifier.save).to be_falsey

        # Now catches that object is missing
        # expect { identifier.save }.to raise_error ActiveRecord::StatementInvalid
      end

      specify 'identifier' do
        expect(identifier.errors.include?(:identifier)).to be_truthy
      end

      specify 'type' do
        expect(identifier.errors.include?(:type)).to be_truthy
      end
    end

    specify 'has an identifier_object' do
      expect(identifier).to respond_to(:identifier_object)
      expect(identifier.identifier_object).to be(nil)
    end

    specify 'you can\'t add non-unique identifiers of the same type to a two objects' do
      i1 = Identifier::Local::CatalogNumber.new(namespace: namespace, identifier_object: specimen1, identifier: 123)
      i2 = Identifier::Local::CatalogNumber.new(namespace: namespace, identifier_object: specimen2, identifier: 123)
      expect(i1.save).to be_truthy
      expect(i2.save).to be_falsey
      expect(i2.errors.include?(:identifier)).to be_truthy
    end
  end

  # sanity check for Housekeeping, which is tested elsewhere
  context 'sets housekeeping' do
    before { identifier.valid? }
    specify 'creator' do
      expect(identifier.errors.include?(:creator)).to be_falsey
    end

    specify 'updater' do
      expect(identifier.errors.include?(:updater)).to be_falsey
    end

    context 'non community object' do
      specify 'with <<' do
        expect(specimen1.identifiers.count).to eq(0)
        specimen1.identifiers << Identifier::Local::CatalogNumber.new(namespace: namespace, identifier: 456)
        expect(specimen1.save).to be_truthy
        expect(specimen1.identifiers.first.creator.nil?).to be_falsey
        expect(specimen1.identifiers.first.updater.nil?).to be_falsey
        expect(specimen1.identifiers.first.project.nil?).to be_falsey
      end

      specify 'with .build' do
        expect(specimen1.identifiers.count).to eq(0)
        specimen1.identifiers.build(type: 'Identifier::Local::CatalogNumber', namespace: namespace, identifier: 456)
        expect(specimen1.save).to be_truthy
        expect(specimen1.identifiers.first.creator.nil?).to be_falsey
        expect(specimen1.identifiers.first.updater.nil?).to be_falsey
        expect(specimen1.identifiers.first.project.nil?).to be_falsey
      end

      specify 'with new and <<' do
        s = FactoryBot.build(:valid_specimen)
        s.identifiers << Identifier::Local::CatalogNumber.new(namespace: namespace, identifier: 456)
        expect(s.save).to be_truthy
        expect(s.identifiers.count).to eq(1)
        expect(s.identifiers.first.id).to_not be(nil)
        expect(s.identifiers.first.creator.nil?).to be_falsey
        expect(s.identifiers.first.updater.nil?).to be_falsey
        expect(s.identifiers.first.project.nil?).to be_falsey
      end

      specify 'with new and build' do
        s = FactoryBot.build(:valid_specimen)
        s.identifiers.build(type: 'Identifier::Local::CatalogNumber', namespace: namespace, identifier: 456)

        expect(s.save).to be_truthy
        expect(s.identifiers.count).to eq(1)
        expect(s.identifiers.first.creator.nil?).to be_falsey
        expect(s.identifiers.first.updater.nil?).to be_falsey
        expect(s.identifiers.first.project.nil?).to be_falsey
      end
    end

    context 'with community object and is_community_annotation == true' do
      specify 'with .build' do
        expect(serial.identifiers.count).to eq(0)
        serial.identifiers.build(type: 'Identifier::Global::Issn', identifier: 'ISSN 0375-0825', is_community_annotation: true)
        expect(serial.save).to be_truthy
        expect(serial.identifiers.first.creator.nil?).to be_falsey
        expect(serial.identifiers.first.updater.nil?).to be_falsey
        expect(serial.identifiers.first.project.nil?).to be_truthy
      end

      specify 'with <<' do
        expect(serial.identifiers.count).to eq(0)
        serial.identifiers << Identifier::Global::Issn.new(identifier: 'ISSN 0375-0825', is_community_annotation: true)
        expect(serial.save).to be_truthy
        expect(serial.identifiers.first.creator.nil?).to be_falsey
        expect(serial.identifiers.first.updater.nil?).to be_falsey
        expect(serial.identifiers.first.project.nil?).to be_truthy
      end

      specify 'with new and <<' do
        s = FactoryBot.build(:valid_serial)
        s.identifiers << Identifier::Global::Issn.new(identifier: 'ISSN 0375-0825', is_community_annotation: true)
        expect(s.save).to be_truthy
        expect(s.identifiers.count).to eq(1)
        expect(s.identifiers.first.creator.nil?).to be_falsey
        expect(s.identifiers.first.updater.nil?).to be_falsey
        expect(s.identifiers.first.project.nil?).to be_truthy
      end

      specify 'with new and build' do
        s = FactoryBot.build(:valid_serial)
        s.identifiers.build(
          type: 'Identifier::Global::Issn',
          identifier: 'ISSN 0375-0825',
          is_community_annotation: true)
        expect(s.save).to be_truthy
        expect(s.identifiers.count).to eq(1)
        expect(s.identifiers.first.creator.nil?).to be_falsey
        expect(s.identifiers.first.updater.nil?).to be_falsey
        expect(s.identifiers.first.project.nil?).to be_truthy
      end
    end
  end

  specify '#labels_attributes with #text' do
    i = Identifier::Local::CatalogNumber.create!(
      identifier_object: specimen1,
      namespace: namespace,
      identifier: 123,
      labels_attributes: [ {
        total: 1,
        type: 'Label::QrCode',
        text: 'My label'
      }]
    )

    expect(Label.first.text).to eq('My label')
  end

  specify '#labels_attributes with #text_method' do
    i = Identifier::Local::CatalogNumber.create!(
      identifier_object: specimen1,
      namespace: namespace,
      identifier: 123,
      labels_attributes: [{
        total: 1,
        type: 'Label::QrCode',
        text_method: :build_cached
      }]
    )

    expect(Label.first.text).to eq(namespace.short_name + ' ' + '123')
  end

  context 'concerns' do
    it_behaves_like 'is_data'
  end

  context '#batch_by_filter_scope' do
    let!(:n1) { Namespace.create!(name: 'First', short_name: 'second')}
    let!(:n2) { Namespace.create!(name: 'Third', short_name: 'fourth')}
    let!(:n3v) { Namespace.create!(name: 'Fifth', short_name: 'sixth',
      is_virtual: true)}
    let!(:n4) { Namespace.create!(name: 'Fourth', short_name: 'eighth')}

    let!(:co1) { FactoryBot.create(:valid_specimen) }
    let!(:co2) { FactoryBot.create(:valid_specimen) }
    let!(:co3) { FactoryBot.create(:valid_specimen) }

    let!(:i1) { Identifier::Local::CatalogNumber.create!(namespace: n1, identifier: '11', identifier_object: co1) }
    let!(:i2) { Identifier::Local::CatalogNumber.create!(namespace: n2, identifier: '21', identifier_object: co3) }
    let!(:i3) { Identifier::Local::RecordNumber.create!(namespace: n1, identifier: '31', identifier_object: co3) }

    let!(:ce1) { FactoryBot.create(:valid_collecting_event) }
    let!(:ce2) { FactoryBot.create(:valid_collecting_event) }

    let!(:ii1) { Identifier::Local::FieldNumber.create!(namespace: n1, identifier: '11', identifier_object: ce1) }
    let!(:ii2) { Identifier::Local::FieldNumber.create!(namespace: n2, identifier: '21', identifier_object: ce2) }
    let!(:ii3) { Identifier::Local::FieldNumber.create!(namespace: n1, identifier: '31', identifier_object: ce2) }
    let!(:ii4v) { Identifier::Local::FieldNumber.create!(namespace: n3v, identifier: 'ASDF1234', identifier_object: ce2) }

    specify 'collection_object record_number' do
      q = ::Queries::CollectionObject::Filter.new(collection_object_id: [co1.id, co2.id, co3.id])
      Identifier.batch_by_filter_scope(
        filter_query: { 'collection_object_query' => q.params },
        params: {
          identifier_types: ['Identifier::Local::RecordNumber'],
          namespace_id: n2.id,
          namespaces_to_replace: [n1, n2, n3v]
        },
        mode: :replace,
      )

      expect(i1.reload.namespace_id).to eq(n1.id) # not a RecordNumber, unchanged
      expect(i2.reload.namespace_id).to eq(n2.id) # not a RecordNumber, unchanged
      expect(i3.reload.namespace_id).to eq(n2.id) # changed to n2
    end

    specify 'collection_object catalog_number async' do
      q = ::Queries::CollectionObject::Filter.new(collection_object_id: [co1.id, co2.id, co3.id])
      Identifier.batch_by_filter_scope(
        filter_query: { 'collection_object_query' => q.params },
        params: {
          identifier_types: ['Identifier::Local::CatalogNumber'],
          namespace_id: n2.id,
          namespaces_to_replace: [n1, n2, n3v]
        },
        mode: :replace,
        async_cutoff: 0
      )

      perform_enqueued_jobs

      expect(i1.reload.namespace_id).to eq(n2.id) # changed to n2
      expect(i2.reload.namespace_id).to eq(n2.id) # stayed the same
      expect(i3.reload.namespace_id).to eq(n1.id) # not a CatalogNumber, unchanged
    end

    specify 'collection_object [catalog_number, record_number]' do
      q = ::Queries::CollectionObject::Filter.new(collection_object_id: [co1.id, co2.id, co3.id])
      Identifier.batch_by_filter_scope(
        filter_query: { 'collection_object_query' => q.params },
        params: {
          identifier_types: ['Identifier::Local::RecordNumber', 'Identifier::Local::CatalogNumber'],
          namespace_id: n2.id,
          namespaces_to_replace: [n1, n2, n3v]
        },
        mode: :replace,
      )

      expect(i1.reload.namespace_id).to eq(n2.id) # catalog_number changed to n2
      expect(i2.reload.namespace_id).to eq(n2.id) # stayed the same
      expect(i3.reload.namespace_id).to eq(n2.id) # record_number changed to n2
    end

    specify 'collecting_event field_number' do
      q = ::Queries::CollectionObject::Filter.new(collecting_event_id: [ce1.id, ce2.id])
      Identifier.batch_by_filter_scope(
        filter_query: { 'collecting_event_query' => q.params },
        params: {
          identifier_types: ['Identifier::Local::FieldNumber'],
          namespace_id: n2.id,
          namespaces_to_replace: [n1, n2, n3v]
        },
        mode: :replace,
      )

      expect(ii1.reload.namespace_id).to eq(n2.id) # changed to n2
      expect(ii2.reload.namespace_id).to eq(n2.id) # stayed the same
      expect(ii3.reload.namespace_id).to eq(n2.id) # 2nd id on ce2 changed to n2
    end

    specify 'collecting_event field_number' do
      q = ::Queries::CollectionObject::Filter.new(collecting_event_id: [ce1.id, ce2.id])
      Identifier.batch_by_filter_scope(
        filter_query: { 'collecting_event_query' => q.params },
        params: {
          identifier_types: ['Identifier::Local::FieldNumber'],
          namespace_id: n4.id,
          namespaces_to_replace: [n1]
        },
        mode: :replace,
      )

      expect(ii1.reload.namespace_id).to eq(n4.id) # changed to n4
      # Stays the same, even though it's on a collecting event that matches
      # filter_query.
      expect(ii2.reload.namespace_id).to eq(n2.id)
      expect(ii3.reload.namespace_id).to eq(n4.id) # 2nd id on ce2 changed to n4
    end

    specify 'collecting_event field_number async' do
      q = ::Queries::CollectionObject::Filter.new(collecting_event_id: [ce1.id, ce2.id])
      Identifier.batch_by_filter_scope(
        filter_query: { 'collecting_event_query' => q.params },
        params: {
          identifier_types: ['Identifier::Local::FieldNumber'],
          namespace_id: n1.id,
          namespaces_to_replace: [n1, n2, n3v]
        },
        mode: :replace,
        async_cutoff: 0
      )

      perform_enqueued_jobs

      expect(ii1.reload.namespace_id).to eq(n1.id) # stayed the same
      expect(ii2.reload.namespace_id).to eq(n1.id) # changed to n1
      expect(ii3.reload.namespace_id).to eq(n1.id) # stayed the same
    end

    context 'virtual identifiers #virtual_namespace_prefix' do
      specify 'removes matching virtual prefix' do
        q = ::Queries::CollectionObject::Filter.new(collecting_event_id: [ce2.id])
        Identifier.batch_by_filter_scope(
          filter_query: { 'collecting_event_query' => q.params },
          params: {
            identifier_types: ['Identifier::Local::FieldNumber'],
            namespace_id: n1.id,
            namespaces_to_replace: [n1, n2, n3v],
            virtual_namespace_prefix: 'ASDF'
          },
          mode: :replace,
        )

        ii4v.reload
        expect(ii4v.namespace_id).to eq(n1.id)
        expect(ii4v.identifier).to eq('1234')
      end

      specify "Doesn't remove matching prefix on non-virtual" do
        i = ii4v.identifier
        ii2.update!(identifier: i) # not virtual, on ce2

        q = ::Queries::CollectionObject::Filter.new(collecting_event_id: [ce2.id])
        Identifier.batch_by_filter_scope(
          filter_query: { 'collecting_event_query' => q.params },
          params: {
            identifier_types: ['Identifier::Local::FieldNumber'],
            namespace_id: n1.id,
            namespaces_to_replace: [n1, n2, n3v],
            virtual_namespace_prefix: 'ASDF'
          },
          mode: :replace,
        )

        ii2.reload
        expect(ii2.namespace_id).to eq(n2.id)
        expect(ii2.identifier).to eq(i)
      end

      specify "Doesn't affect non-matching virtual" do
        i = ii2.identifier
        ii2.update!(namespace_id: n3v.id) # now virtual

        q = ::Queries::CollectionObject::Filter.new(collecting_event_id: [ce2.id])
        Identifier.batch_by_filter_scope(
          filter_query: { 'collecting_event_query' => q.params },
          params: {
            identifier_types: ['Identifier::Local::FieldNumber'],
            namespace_id: n1.id,
            namespaces_to_replace: [n1, n2, n3v],
            virtual_namespace_prefix: 'ASDF'
          },
          mode: :replace,
        )

        ii2.reload
        expect(ii2.namespace_id).to eq(n3v.id)
        expect(ii2.identifier).to eq(i)
      end

      specify "Won't produce invalid empty identifier" do
        q = ::Queries::CollectionObject::Filter.new(collecting_event_id: [ce2.id])
        Identifier.batch_by_filter_scope(
          filter_query: { 'collecting_event_query' => q.params },
          params: {
            identifier_types: ['Identifier::Local::FieldNumber'],
            namespace_id: n1.id,
            namespaces_to_replace: [n1, n2, n3v],
            virtual_namespace_prefix: 'ASDF1234'
          },
          mode: :replace,
        )

        ii4v.reload
        # Unchanged.
        expect(ii4v.namespace_id).to eq(n3v.id)
        expect(ii4v.identifier).to eq('ASDF1234')
      end

      specify "Can't combine #virtual_namespace_prefix with moving to a virtual namespace" do
        q = ::Queries::CollectionObject::Filter.new(collecting_event_id: [ce2.id])
        r = Identifier.batch_by_filter_scope(
          filter_query: { 'collecting_event_query' => q.params },
          params: {
            identifier_types: ['Identifier::Local::FieldNumber'],
            namespace_id: n3v.id, # virtual
            namespaces_to_replace: [n1, n2, n3v],
            virtual_namespace_prefix: 'ASDF'
          },
          mode: :replace,
        )

        expect(r[:errors].present?).to be true
      end

      specify 'Does not update when non-virtual destination of virtual identifier already exists' do
        n3 = Namespace.create!(name: 'QWERTY', short_name: 'QWERTYSHORT')
        # This identifier should prevent ii4v from being converted to
        # non-virtual with namespace n3.
        ii4 = Identifier::Local::FieldNumber.create!(namespace: n3, identifier: '1234', identifier_object: ce2)

        q = ::Queries::CollectionObject::Filter.new(collecting_event_id: [ce2.id])
        r = Identifier.batch_by_filter_scope(
          filter_query: { 'collecting_event_query' => q.params },
          params: {
            identifier_types: ['Identifier::Local::FieldNumber'],
            namespace_id: n3.id,
            namespaces_to_replace: [n3v],
            virtual_namespace_prefix: 'ASDF'
          },
          mode: :replace
        )

        expect(r[:not_updated]).to contain_exactly(ii4v.id)
        expect(ii4v.reload.is_virtual?).to be_truthy
      end
    end

  end

end
