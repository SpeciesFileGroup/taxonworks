require 'spec_helper'
require 'dwca/import'

describe Dwca::Import do
  before(:all) {
    @archive_path = (Rails.root + 'spec/files/dwca/insects_5k.tar.gz')
  }

  context 'incoming archive' do
    specify 'can be opened with read_dwc()' do
      expect(a = Dwca::Import.new_dwc(@archive_path.to_s)).to be_true
      expect(a.class).to eq(DarwinCore)
    end
  end

  context 'open archive' do
    before(:all) {
      @dwc = Dwca::Import.new_dwc(@archive_path.to_s)
      @data, @errors = @dwc.core.read 
    }
    specify 'has 5000 records' do
      expect(@data.size).to eq(5000) 
    end
    specify 'has 0 errors' do
      expect(@errors.size).to eq(0) 
    end
  end


  context 'TW objects' do
    specify 'Dwc::Import::TwObjects' do
      d = Dwca::Import::TwObjects.new
      Dwca::Import::DWC2TW.keys.each do |m|
        expect(d).to respond_to("#{m}s".to_sym)
      end
    end
  end
end


describe Dwca::Import::Manger do
  let(:manager) {Dwca::Import::Manger.new}

  specify 'attributes' do
    expect(manager).to respond_to(:field_index, :available_objects, :row_number, :i, :data, :errors, :tw_objects)
  end

end
