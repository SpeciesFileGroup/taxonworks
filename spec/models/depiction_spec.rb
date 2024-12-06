require 'rails_helper'

RSpec.describe Depiction, type: :model, groups: [:images, :observation_matrix] do
  let(:depiction) { Depiction.new() }
  let(:image_file) { Rack::Test::UploadedFile.new( Spec::Support::Utilities::Files.generate_png, 'image/png') }
  let(:specimen) { FactoryBot.create(:valid_specimen) }

  specify 'dwc_occurrence hooks' do
    s = Specimen.create!
    expect(s.dwc_occurrence.associatedMedia).to eq(nil)
    d = Depiction.create!(depiction_object: s, image: FactoryBot.create(:valid_image))
    expect(s.dwc_occurrence.reload.associatedMedia).to match('http://127.0.0.1:3000/api/v1/images/')
  end

  specify 'when moving to a new collection object old is destroyed if an image stub' do
    o1 = FactoryBot.create(:valid_collection_object)
    o2 = FactoryBot.create(:valid_collection_object)

    d = FactoryBot.create(:valid_depiction, depiction_object: o2)

    FactoryBot.create(:valid_sqed_depiction, depiction: d)

    d.update!(depiction_object: o1)

    expect(CollectionObject.where(id: o2.id).any?).to be_falsey
  end

  specify 'destroying depiction does not destroy related Observation::Media 2 when not last' do
    o = FactoryBot.create(:valid_observation, type: 'Observation::Media', descriptor: Descriptor::Media.create!(name: 'test'))

    d = FactoryBot.create(:valid_depiction, depiction_object: o)

    # Can not test with this because of the way callbacks are created
    # FactoryBot.create(:valid_depiction, depiction_object: o)

    e = Depiction.create(depiction_object: o, image: FactoryBot.build(:valid_image)) # must be that in valid_depiction for test to be correct

    d.destroy!
    expect(Observation.find(o.id)).to be_truthy
  end

  specify 'updating depiction destroys related Observation::Media 1 if there are no others' do
    o = FactoryBot.create(:valid_observation, type: 'Observation::Media', descriptor: Descriptor::Media.create!(name: 'test'))
    d = FactoryBot.create(:valid_depiction, depiction_object: o)

    d.update!(depiction_object: FactoryBot.create(:valid_observation, type: 'Observation::Media', descriptor: Descriptor::Media.create!(name: 'test2') ) )

    expect {Observation.find(o.id)}.to raise_error ActiveRecord::RecordNotFound
    expect(Depiction.find(d.id).id).to be_truthy
  end

  # Deprecated for unify()
  # specify 'updating from OTU to Observation' do
  #   o = FactoryBot.create(:valid_observation, type: 'Observation::Media', descriptor: Descriptor::Media.create!(name: 'test'))
  #   d1 = FactoryBot.create(:valid_depiction, depiction_object: o)

  #   otu = Otu.create!(name: 'Foo')
  #   d2 = Depiction.create(depiction_object: otu, image: d1.image)

  #   d2.update!(depiction_object: o)

  #   expect(d2.depiction_object).to eq(o)
  #   expect(otu.reload).to be_truthy
  # end

  specify 'destroying depiction destroys related Observation::Media 1' do
    o = FactoryBot.create(:valid_observation, type: 'Observation::Media', descriptor: Descriptor::Media.create!(name: 'test'))
    d = FactoryBot.create(:valid_depiction, depiction_object: o)
    d.destroy!
    expect {Observation.find(o.id)}.to raise_error ActiveRecord::RecordNotFound
  end

  specify 'new depiction uses exisiting image if file is duplicate' do
    a = FactoryBot.create(:valid_image)
    depiction.image_attributes = {image_file: a.image_file}
    depiction.depiction_object = specimen
    expect(depiction.save).to be_truthy
    expect(depiction.image.reload).to eq(a)
    expect(Image.all.size).to eq(1)
  end

  specify 'new depiction also creates new (nested) image' do
    depiction.image_attributes = {image_file: FactoryBot.create(:valid_image).image_file}
    depiction.depiction_object = specimen
    expect(depiction.save).to be_truthy
    expect(depiction.image.reload).to be_truthy
  end

  # Could have been related to bad image validation in Depiction
  specify 'CPU usage must not increase exponentially every time a depiction is added for the same OTU' do
    o = Otu.create!(name:'a1')
    last_utime = 2

    8.times do |i|
      o = Otu.find(o.id) # VERY IMPORTANT TO RE-FETCH THE OBJECT TO TRIGGER THE PROBLEM!

      a = Rack::Test::UploadedFile.new(Spec::Support::Utilities::Files.generate_tiny_random_png(file_name: "test.png"), 'image/png')
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
