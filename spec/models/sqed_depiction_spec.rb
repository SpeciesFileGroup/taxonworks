require 'rails_helper'

RSpec.describe SqedDepiction, type: :model do

  let(:sqed_depiction) { SqedDepiction.new }
  let(:valid_sqed_depiction) { FactoryBot.create(:valid_sqed_depiction) }

  specify 'depiction is of CollectionObject 1' do
    valid_sqed_depiction.depiction.depiction_object = FactoryBot.create(:valid_otu)
    valid_sqed_depiction.valid?
    expect(valid_sqed_depiction.errors[:depiction]).to_not be_empty
  end

  specify 'depiction is of CollectionObject 2' do
    valid_sqed_depiction.depiction.depiction_object = FactoryBot.create(:valid_specimen)
    valid_sqed_depiction.valid?
    expect(valid_sqed_depiction.errors[:depiction]).to be_empty
  end

  context 'validation' do
    before { sqed_depiction.valid? }

    specify 'depiction_id is required' do
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

  context 'jsonb fields' do
    let(:metadata_map) { {0 => :curator_metadata, 1 => :identifier, 2 => :image_registration, 3 => :annotated_specimen} }

    specify 'metadata_map serializes a hash' do
      valid_sqed_depiction.metadata_map = metadata_map
      valid_sqed_depiction.save!
      valid_sqed_depiction.reload
      expect(valid_sqed_depiction.metadata_map.class).to eq(Hash)
    end
  end

  context '#extraction_metadata' do
    specify ':boundary_finder' do
      expect(valid_sqed_depiction.extraction_metadata[:boundary_finder]).to eq(Sqed::BoundaryFinder::ColorLineFinder)
    end

    specify ':layout' do
      expect(valid_sqed_depiction.extraction_metadata[:layout]).to eq(:cross)
    end

    specify ':metadata_map' do
      expect(valid_sqed_depiction.extraction_metadata[:metadata_map]).to eq({0 => :curator_metadata, 1 => :identifier, 2 => :image_registration, 3 => :annotated_specimen})
    end

    specify ':has_border' do
      expect(valid_sqed_depiction.extraction_metadata[:has_border]).to eq(false)
    end
  end

  specify '#rebuild 1' do
    valid_sqed_depiction.rebuild = true
    expect(valid_sqed_depiction.save!).to be_truthy
  end

  specify '#rebuild 2' do
    valid_sqed_depiction.update(rebuild: true)
    expect(valid_sqed_depiction.save!).to be_truthy
  end

end
