require 'spec_helper'
require 'dwca/import'

describe Dwca::Import do
  before(:all) {
    @archive_path = (Rails.root + 'spec/files/dwca/insects_5k.tar.gz')
    @dwc = Dwca::Import.new_dwc(@archive_path.to_s)
    @data, @errors = @dwc.core.read 
  }

  context 'incoming archive' do
    specify 'can be opened with read_dwc()' do
      expect(a = Dwca::Import.new_dwc(@archive_path.to_s)).to be_truthy
      expect(a.class).to eq(DarwinCore)
    end
  end

  context 'open archive' do
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


  context 'Dwca::Import::Manager' do
    let(:manager) {Dwca::Import::Manager.new(data: @data, errors: @errors, core_fields: @dwc.core.fields)}

    specify 'attributes' do
      expect(manager).to respond_to(:field_index, :available_objects, :row_number, :i, :data, :errors, :tw_objects)
    end

    context 'referenced_models' do
      before(:all) {
        @result = [:biocuration_classification, :biological_association, :collecting_event, :collection_object, :georeference, :identifier, :otu, :taxon_determination, :taxon_name, :type_specimen]
      }
      specify 'referenced_models()' do
        expect(manager.send(:referenced_models, @dwc.core.fields)).to eq(@result)
      end
      specify '#available_objects' do
        expect(manager.available_objects).to eq(@result)
      end
    end

    specify 'field_index' do
      expect(manager.field_index["http://rs.tdwg.org/dwc/terms/samplingProtocol"]).to eq(1)
    end

    specify 'cell' do
      expect(manager.cell(@data.first, 'http://rs.tdwg.org/dwc/terms/eventDate')).to eq('1994-4-21')
    end

    specify 'row_id' do
      expect(manager.row_id(@data.last)).to eq('73117')
    end

    context 'build_object' do
      specify 'otu' do
        expect(manager.build_object(@data.first, Otu.new).name).to eq('Stenacron carolina (Banks 1914)')
      end
    end

    specify 'build_row_objects' do
      expect(result = manager.build_row_objects(@data.first, [:otu, :collection_object, :collecting_event])).to be_truthy
      expect(result[:otu].name).to eq('Stenacron carolina (Banks 1914)')
      expect(result[:collection_object].total).to eq(3)
      expect(result[:collecting_event].verbatim_method).to eq(nil)

    # expect(result[:collecting_event].start_date_year).to eq('1994')
    # expect(result[:collecting_event].start_date_month).to eq('4')
    # expect(result[:collecting_event].start_date_day).to eq('21')
    end
  end
end
