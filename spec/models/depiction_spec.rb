require 'rails_helper'

RSpec.describe Depiction, type: :model do
  let(:depiction) { Depiction.new() }
  let(:image_file) { fixture_file_upload( Spec::Support::Utilities::Files.generate_png, 'image/png') }
  let(:specimen) { FactoryBot.create(:valid_specimen) }

  specify 'new depiction also creates new (nested) image' do
    depiction.image_attributes = {image_file: image_file}
    depiction.depiction_object = specimen
    expect(depiction.save).to be_truthy

    expect(depiction.image.reload).to be_truthy
  end

  specify 'CPU usage must not increase exponentially every time a depiction is added for the same OTU' do
    o = Otu.create!(name:'a1')
    a = fixture_file_upload(Spec::Support::Utilities::Files.generate_png(file_name: "test.png"), 'image/png')
    last_utime = 2
    ratio = 1
    limit = 5

    10.times do |i|
      o = Otu.find(o.id) # VERY IMPORTANT TO RE-FETCH THE OBJECT TO TRIGGER THE PROBLEM!

      bm = Benchmark.measure do
        expect(Depiction.create!(image_attributes: { image_file: a }, depiction_object: o) ).to be_truthy
      end

      break if (ratio = bm.utime/last_utime) > limit
      last_utime = bm.utime
    end

    expect(ratio).to be <= limit
  end


end
