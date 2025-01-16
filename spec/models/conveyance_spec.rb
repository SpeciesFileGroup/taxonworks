require 'rails_helper'

RSpec.describe Conveyance, type: :model, groups: [:sounds] do

  let(:conveyance) { Conveyance.new() }
  let(:specimen) { FactoryBot.create(:valid_specimen) }

  specify 'new conveyance also creates new (nested) sound' do
    conveyance.sound_attributes = {sound_file: file_fixture_upload(
      Rack::Test::UploadedFile.new(Rails.root + 'spec/files/sounds/sound1.mp3', "audio/mpeg")
    ) }
    conveyance.conveyance_object = specimen
    expect(conveyance.save).to be_truthy
    expect(conveyance.sound.reload).to be_truthy
  end

end
