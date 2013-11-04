require 'spec_helper'
require 'dwca/import'

describe Dwca::Import do
  before(:all) {
    @archive_path = (Rails.root + 'spec/files/dwca/insects_5k.tar.gz')
  }

  context 'incoming archive' do
    specify 'can be opened with read_dwc()' do
      expect(a = Dwca::Import.read_dwc(@archive_path.to_s)).to be_true
      expect(a.class).to eq(DarwinCore)
    end
  end

  context 'open archive' do
    before(:all) {
      @dwc = Dwca::Import.read_dwc(@archive_path.to_s)
      @data, @errors = @dwc.core.read 
    }
    specify 'has 5000 records' do
      expect(@data.size).to eq(5000) 
    end
    specify 'has 0 errors' do
      expect(@errors.size).to eq(0) 
    end

    context 'TW objects' do
      specify 'Dwc::Import::Data' do
        d = Dwca::Import::Data.new
        Dwca::Import::DWC2TW.keys.each do |m|
          expect(d).to respond_to("#{m}s".to_sym)
        end
      end

      specify 'referenced_models' do
        expect( Dwca::Import.referenced_models(@dwc.core)).to eq([:biocuration_classification, :biological_association, :collecting_event, :collection_object, :georeference, :identifier, :otu, :taxon_determination, :taxon_name, :type_specimen])
      end 

      specify 'row_object'

    end

    context 'persistance' do

    end

  end

end
