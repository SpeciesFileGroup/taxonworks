require 'rails_helper'

describe 'Paperclip::Rotator', type: :model, group: [:image] do

  let(:i) { FactoryBot.build(:valid_image) }

  specify '#rotate can be applied' do
    expect(i.rotate = 180).to be_truthy
  end

  specify '#reprocess! passes' do
    i.rotate = 180
    expect(i.image_file.reprocess!).to be_truthy
  end

end
