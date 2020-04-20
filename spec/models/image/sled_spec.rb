require 'rails_helper'

describe Image::Sled, type: :model, group: :images do

  let(:i) { FactoryBot.build(:valid_image) }

  after(:each) {
    i.destroy
    i.run_callbacks(:commit)
  }

  specify '#sled_image_attributes 1' do
    i.update(sled_image_attributes: {metadata: [] })
    expect(SledImage.all.count).to eq(1)
  end

  specify '#sled_image_attributes 2' do
    i.update(sled_image_attributes: {metadata: '[]' })
    expect(SledImage.all.count).to eq(1)
  end

  specify '#sled_image_attributes 3' do
    i.update(sled_image_attributes: {metadata: nil})
    expect(SledImage.all.count).to eq(1)
  end

end
