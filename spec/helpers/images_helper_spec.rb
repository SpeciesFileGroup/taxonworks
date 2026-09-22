require 'rails_helper'

RSpec.describe ImagesHelper, type: :helper do
  let(:image) { FactoryBot.create(:tiny_random_image) }

  specify '#image_api_attributes with attribution returns real URLs' do
    FactoryBot.create(:valid_attribution, attribution_object: image)

    a = helper.image_api_attributes(image)

    expect(a[:attributed]).to be true
    expect(a[:original]).to be_present
    expect(a[:thumb]).to be_present
    expect(a[:medium]).to be_present
    expect(a[:original_png]).to be_present
    expect(a[:as_png]).to be_present
    expect(a[:image_file_file_name]).to be_present
    expect(a[:message]).to be_nil
  end

  specify '#image_api_attributes without attribution redacts URLs' do
    a = helper.image_api_attributes(image)

    expect(a[:attributed]).to be false
    expect(a[:original]).to be_nil
    expect(a[:thumb]).to be_nil
    expect(a[:medium]).to be_nil
    expect(a[:original_png]).to be_nil
    expect(a[:as_png]).to be_nil
    expect(a[:image_file_file_name]).to be_nil
    expect(a[:message]).to include('lacks attribution')
  end
end
