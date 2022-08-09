require 'rails_helper'

RSpec.describe Depiction, type: :model, groups: [:images, :observation_matrix] do
  let(:depiction) { Depiction.new() }
  let(:image_file) { Rack::Test::UploadedFile.new( Spec::Support::Utilities::Files.generate_png, 'image/png') }
  let(:specimen) { FactoryBot.create(:valid_specimen) }

  specify 'destroying depiction does not destroy related Observation::Media 2 when not last' do
    o = FactoryBot.create(:valid_observation, type: 'Observation::Media', descriptor: Descriptor::Media.create!(name: 'test')) 
    d = FactoryBot.create(:valid_depiction, depiction_object: o)

    FactoryBot.create(:valid_depiction, depiction_object: o)

    d.destroy!
    expect(Observation.find(o.id)).to be_truthy
  end

  specify 'destroying depiction destroys related Observation::Media 1' do
    o = FactoryBot.create(:valid_observation, type: 'Observation::Media', descriptor: Descriptor::Media.create!(name: 'test')) 
    d = FactoryBot.create(:valid_depiction, depiction_object: o)
    d.destroy!
    expect {Observation.find(o.id)}.to raise_error ActiveRecord::RecordNotFound
  end

  specify 'new depiction also creates new (nested) image' do
    depiction.image_attributes = {image_file: image_file}
    depiction.depiction_object = specimen
    expect(depiction.save).to be_truthy
    expect(depiction.image.reload).to be_truthy
  end

  specify 'CPU usage must not increase exponentially every time a depiction is added for the same OTU' do
    o = Otu.create!(name:'a1')
    a = Rack::Test::UploadedFile.new(Spec::Support::Utilities::Files.generate_png(file_name: "test.png"), 'image/png')
    last_utime = 2

    8.times do |i|
      o = Otu.find(o.id) # VERY IMPORTANT TO RE-FETCH THE OBJECT TO TRIGGER THE PROBLEM!
      bm = Benchmark.measure { Depiction.create!(image_attributes: { image_file: a }, depiction_object: o) }
      expect(bm.utime/last_utime).to be <= 5
      last_utime = bm.utime
    end
  end

  specify '#svg_clip 1' do
    a = FactoryBot.build(:valid_depiction)
    a.svg_clip = 'asfdasdf<a>'
    expect{a.save}.to raise_error ActiveRecord::StatementInvalid, /PG::InvalidXmlContent: ERROR:  invalid XML content/
  end

  specify '#svg_clip 2' do
    a = FactoryBot.build(:valid_depiction)
    a.svg_clip = '<clipPath></clipPath>'
    expect(a.save).to be_truthy
  end

end
