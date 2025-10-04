require 'rails_helper'

RSpec.describe AnatomicalPart, type: :model do
  context 'validations' do
    let!(:otu) { FactoryBot.create(:valid_otu) }
    let!(:origin) { FactoryBot.create(:valid_collection_object) }
    let!(:inbound_origin_relationship_attributes) {
      {
        old_object_id: origin.id,
        old_object_type: origin.class.base_class.name
      }
    }

    before(:each) {
      origin.taxon_determinations << FactoryBot.create(:valid_taxon_determination, otu_id: otu.id)
    }

    specify 'inbound_origin_relationship is required for valid AnitomicalPart' do
      a = AnatomicalPart.new({name: 'a'})
      expect(a.valid?).to be_falsey
    end

    specify 'name is valid' do
      expect(
        AnatomicalPart.create!({name: 'a', inbound_origin_relationship_attributes:})
      ).to be_truthy
    end

    specify 'uri and uri_label is valid' do
      expect(
        AnatomicalPart.create!(name: 'a', inbound_origin_relationship_attributes:,
        uri: 'http://val.id', uri_label: 'as a purl')
      ).to be_truthy
    end

    specify 'uri alone is not valid' do
      expect{
        AnatomicalPart.create!(uri: 'http://alo.ne',
          inbound_origin_relationship_attributes:)
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    specify 'uri_label alone is not valid' do
      expect {
        AnatomicalPart.create!(uri_label: 'a',
          inbound_origin_relationship_attributes:)
     }.to raise_error(ActiveRecord::RecordInvalid)
    end

    specify 'name or uri/label required' do
      expect {
        AnatomicalPart.create!(inbound_origin_relationship_attributes:)
     }.to raise_error(ActiveRecord::RecordInvalid)
    end

    specify 'invalid origin type is caught' do
      expect {
        AnatomicalPart.create!(
          inbound_origin_relationship_attributes: {
            old_object_id: FactoryBot.create(:valid_depiction).id,
            old_object_type: 'Depiction'
          },
          name: 'not again')
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    specify 'taxonomic_origin_object must have a taxon_determination' do
      origin = Specimen.create!
      expect {
        AnatomicalPart.create!(
          inbound_origin_relationship_attributes: {
            old_object_id: origin.id,
            old_object_type: origin.class.base_class.name
          },
        name: 'no td')
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end


end
