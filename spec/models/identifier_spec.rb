require 'rails_helper'

describe Identifier, type: :model, group: [:annotators, :identifiers] do
  let(:identifier) { FactoryBot.build(:identifier) }
  let(:namespace) { FactoryBot.create(:valid_namespace) }
  let(:specimen1) { FactoryBot.create(:valid_specimen) }
  let(:specimen2) { FactoryBot.create(:valid_specimen) }
  let(:serial) { FactoryBot.create(:valid_serial) }

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
      before do
        identifier.valid?
      end

      # !! This test fails not because of a validation, but because of a NOT NULL constraint. 
      specify 'identifier_object' do
        # this eliminate all model based validation requirements
        identifier.type = 'Identifier::Local::CatalogNumber'
        identifier.namespace_id = FactoryBot.create(:valid_namespace).id
        identifier.identifier   = '123'

        expect { identifier.save }.to raise_error ActiveRecord::StatementInvalid
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

end
