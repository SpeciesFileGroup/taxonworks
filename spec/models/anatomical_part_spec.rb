require 'rails_helper'

RSpec.describe AnatomicalPart, type: :model do
  context 'validations' do
    let!(:otu) { FactoryBot.create(:valid_otu) }
    let!(:origin) { FactoryBot.create(:valid_collection_object) }

    before(:each) {
      origin.taxon_determinations << FactoryBot.create(:valid_taxon_determination, otu_id: otu.id)
    }

    specify 'name is valid' do
      expect(
        AnatomicalPart.createOriginatedAnatomicalPart({name: 'a', origin_object: origin})
      ).to be_truthy
    end

    specify 'uri and uri_label is valid' do
      expect(
        AnatomicalPart.createOriginatedAnatomicalPart(name: 'a', origin_object: origin,
        uri: 'http://val.id', uri_label: 'as a purl')
      ).to be_truthy
    end

     specify 'taxonomic_origin_object is required' do
      expect{
        AnatomicalPart.createOriginatedAnatomicalPart(name: 'a', origin_object: nil)
     }.to raise_error(TaxonWorks::Error)
    end

    specify 'uri alone is not valid' do
      expect{
        AnatomicalPart.createOriginatedAnatomicalPart(uri: 'http://alo.ne', origin_object: origin)
      }.to raise_error(TaxonWorks::Error)
    end

    specify 'uri_label alone is not valid' do
      expect {
        AnatomicalPart.createOriginatedAnatomicalPart(uri_label: 'a', origin_object: origin)
     }.to raise_error(TaxonWorks::Error)
    end

    specify 'name or uri/label required' do
      expect {
        AnatomicalPart.createOriginatedAnatomicalPart(origin_object: origin)
     }.to raise_error(TaxonWorks::Error)
    end

    specify 'invalid origin is caught' do
      expect {
        AnatomicalPart.createOriginatedAnatomicalPart(origin_object: FactoryBot.create(:valid_depiction), name: 'not again')
      }.to raise_error(TaxonWorks::Error)
    end

    specify 'taxonomic_origin_object must have a taxon_determination' do
      origin = Specimen.create!
      expect {
        AnatomicalPart.createOriginatedAnatomicalPart(origin_object: origin, name: 'no td')
      }.to raise_error(TaxonWorks::Error)
    end
  end


end
