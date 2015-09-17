require 'rails_helper'

RSpec.describe SqedDepiction, type: :model do

  let(:sqed_depiction) {SqedDepiction.new}
  let(:valid_sqed_depiction) { FactoryGirl.create(:valid_sqed_depiction) }

  context 'validation' do
    before{sqed_depiction.valid?}
    
    specify 'depiction is required' do
      expect(sqed_depiction.errors.include?(:depiction)).to be_truthy 
    end

    specify 'Foo is not a valid layout' do
      sqed_depiction.layout = 'Foo'
      expect(sqed_depiction.errors.include?(:layout)).to be_truthy      
    end

    specify 'SqedConfig::LAYOUTS.first is a valid layout' do
      sqed_depiction.layout = SqedConfig::LAYOUTS.keys.first
      sqed_depiction.valid?
      expect(sqed_depiction.errors.include?(:layout)).to be_falsey
    end

  end

  context 'hstore fields' do


    let(:metadata_map) {  {0 => :curator_metadata, 1 => :identifier, 2 => :image_registration, 3 => :annotated_specimen }  }

    specify 'metadata_map serializes a hash' do
      valid_sqed_depiction.metadata_map = metadata_map
      valid_sqed_depiction.save!
      valid_sqed_depiction.reload
      expect(valid_sqed_depiction.metadata_map.class).to eq(Hash) 
    end
  end

  context "#extraction_metadata" do
    specify ':boundary_finder' do
      expect(valid_sqed_depiction.extraction_metadata[:boundary_finder].name).to eq("Sqed::BoundaryFinder::ColorLineFinder")
    end

    specify ':layout' do
      expect(valid_sqed_depiction.extraction_metadata[:layout]).to eq(:cross)
    end

    specify ':metadata_map' do
      expect(valid_sqed_depiction.extraction_metadata[:metadata_map]).to eq({0 => :curator_metadata, 1 => :identifier, 2 => :image_registration, 3 => :annotated_specimen })
    end

    specify ':has_border' do
      expect(valid_sqed_depiction.extraction_metadata[:has_border]).to eq(false)
    end

  end


end
