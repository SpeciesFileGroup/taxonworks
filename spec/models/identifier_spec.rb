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

    context 'unique' do
      context 'Local identifier unique on type/object_type/cached' do
        specify 'Same identifier type, object type, cached fails' do
          i1 = Identifier::Local::CatalogNumber.new(namespace: namespace, identifier_object: specimen1, identifier: 123)
          i2 = Identifier::Local::CatalogNumber.new(namespace: namespace, identifier_object: specimen2, identifier: 123)
          expect(i1.save).to be_truthy
          expect(i2.save).to be_falsey
          expect(i2.errors.include?(:identifier)).to be_truthy
        end

        specify 'Same cached via virtual identifiers fails' do
          n1 = FactoryBot.create(:valid_namespace, is_virtual: true, short_name: 'AB')
          n2 = FactoryBot.create(:valid_namespace, is_virtual: true, short_name: 'YZ')
          i1 = Identifier::Local::CatalogNumber.new(namespace: n1, identifier_object: specimen1, identifier: 'MN 123')
          i2 = Identifier::Local::CatalogNumber.new(namespace: n2, identifier_object: specimen2, identifier: 'MN 123')
          expect(i1.save).to be_truthy
          expect(i2.save).to be_falsey
          expect(i2.errors.include?(:identifier)).to be_truthy
        end

        specify 'Same cached via virtual, non-virtual fails' do
          n1 = FactoryBot.create(:valid_namespace, short_name: 'CAW')
          n2 = FactoryBot.create(
            :valid_namespace, is_virtual: true, short_name: 'NOT_CAW'
          )
          i1 = Identifier::Local::CatalogNumber.new(
            namespace: n1, identifier_object: specimen1, identifier: '123'
          )
          i2 = Identifier::Local::CatalogNumber.new(
            namespace: n2, identifier_object: specimen2, identifier: 'CAW 123'
          )
          expect(i1.save).to be_truthy
          expect(i2.save).to be_falsey
          expect(i2.errors.include?(:identifier)).to be_truthy
        end

        specify 'Same cached, same object, different identifier types fails' do
          i1 = Identifier::Local::CatalogNumber.new(namespace: namespace, identifier_object: specimen1, identifier: 123)
          i2 = Identifier::Local::RecordNumber.new(namespace: namespace, identifier_object: specimen1, identifier: 123)
          expect(i1.save).to be_truthy
          expect(i2.save).to be_falsey
          expect(i2.errors.include?(:identifier)).to be_truthy
        end

        specify 'Same cached, same object, different identifier types 2 fails' do
          i1 = Identifier::Global.new(identifier_object: specimen1, identifier: 123)
          i2 = Identifier::Unknown.new(identifier_object: specimen1, identifier: 123)
          expect(i1.save).to be_truthy
          expect(i2.save).to be_falsey
          expect(i2.errors.include?(:identifier)).to be_truthy
        end

        specify 'Same cached, same identifier type, different object types *allowed*' do
          e = FactoryBot.create(:valid_extract)
          i1 = Identifier::Local::CatalogNumber.new(namespace: namespace, identifier_object: specimen1, identifier: 123)
          i2 = Identifier::Local::CatalogNumber.new(namespace: namespace, identifier_object: e, identifier: 123)
          expect(i1.save).to be_truthy
          expect(i2.save).to be_truthy
        end
      end

      specify 'Unknown type identifiers unique' do
        e = FactoryBot.create(:valid_extract)
        i1 = Identifier::Unknown.new(identifier_object: e, identifier: 123)
        i2 = Identifier::Unknown.new(identifier_object: specimen2, identifier: 123)
        expect(i1.save).to be_truthy
        expect(i2.save).to be_falsey
        expect(i2.errors.include?(:identifier)).to be_truthy
      end

      specify 'Global type identifiers unique' do
        e = FactoryBot.create(:valid_extract)
        i1 = Identifier::Global.new(identifier_object: specimen2, identifier: 123)
        i2 = Identifier::Global.new(identifier_object: e, identifier: 123)

        expect(i1.save).to be_truthy
        expect(i2.save).to be_falsey
        expect(i2.errors.include?(:identifier)).to be_truthy
      end
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

    specify 'collection_object record_number' do
      q = ::Queries::CollectionObject::Filter.new(collection_object_id: [co1.id, co2.id, co3.id])
      Identifier.batch_by_filter_scope(
        filter_query: { 'collection_object_query' => q.params },
        params: {
          identifier_types: ['Identifier::Local::RecordNumber'],
          namespace_id: n2.id
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
          namespace_id: n2.id
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
          namespace_id: n2.id
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
          namespace_id: n2.id
        },
        mode: :replace,
      )

      expect(ii1.reload.namespace_id).to eq(n2.id) # changed to n2
      expect(ii2.reload.namespace_id).to eq(n2.id) # stayed the same
      expect(ii3.reload.namespace_id).to eq(n2.id) # 2nd id on ce2 changed to n2
    end

    specify 'collecting_event field_number async' do
      q = ::Queries::CollectionObject::Filter.new(collecting_event_id: [ce1.id, ce2.id])
      Identifier.batch_by_filter_scope(
        filter_query: { 'collecting_event_query' => q.params },
        params: {
          identifier_types: ['Identifier::Local::FieldNumber'],
          namespace_id: n1.id
        },
        mode: :replace,
        async_cutoff: 0
      )

      perform_enqueued_jobs

      expect(ii1.reload.namespace_id).to eq(n1.id) # stayed the same
      expect(ii2.reload.namespace_id).to eq(n1.id) # changed to n1
      expect(ii3.reload.namespace_id).to eq(n1.id) # stayed the same
    end

  end

end
