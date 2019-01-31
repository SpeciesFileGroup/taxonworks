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

  specify 'creating a number of depictions with create! is relatively "fast"' do
    o = Otu.create!(name: 'a1')
    (0..50).each_with_index do |z, i|

      puts "[#{Time.now}] CREATING DEPICTION #{(i+1).to_s}"
      Benchmark.bm do |x|
        a = fixture_file_upload(
          Spec::Support::Utilities::Files.generate_png(file_name: "p#{i}"), 'image/png')
        # x.report {
          expect(Depiction.create!(image_attributes: { image_file: a }, depiction_object: o) ).to be_truthy
        # }
      end
    end
  end


end
