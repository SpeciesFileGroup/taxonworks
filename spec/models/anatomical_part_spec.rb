require 'rails_helper'

RSpec.describe AnatomicalPart, type: :model do
  context 'validations' do
    let!(:origin) { FactoryBot.create(:valid_collection_object) }
    specify 'name is valid' do
      a = AnatomicalPart.new(name: 'a', taxonomic_origin_object: origin)
      expect(a.valid?).to be_truthy
    end

    specify 'uri and uri_label is valid' do
      a = AnatomicalPart.new(name: 'a', taxonomic_origin_object: origin,
        uri: 'http://val.id', uri_label: 'as a purl')
      expect(a.valid?).to be_truthy
    end

     specify 'taxonomic_origin_object is required' do
      a = AnatomicalPart.new(name: 'a')
      expect(a.valid?).to be_falsey
    end

    specify 'uri alone is not valid' do
      a = AnatomicalPart.new(uri: 'http://alo.ne', taxonomic_origin_object: origin)
      expect(a.valid?).to be_falsey
    end

    specify 'uri_label alone is not valid' do
      a = AnatomicalPart.new(uri_label: 'a', taxonomic_origin_object: origin)
      expect(a.valid?).to be_falsey
    end

    specify 'name or uri/label required' do
      a = AnatomicalPart.new(taxonomic_origin_object: origin)
      expect(a.valid?).to be_falsey
    end

  end


end
