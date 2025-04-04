require 'rails_helper'

RSpec.describe Conveyance, type: :model, groups: [:sounds] do

  let(:conveyance) { Conveyance.new() }
  let(:specimen) { FactoryBot.create(:valid_specimen) }

  specify 'needs a conveyance_object' do
    a = FactoryBot.build(:valid_conveyance, conveyance_object: nil)
    expect(a.valid?).to be_falsey 
  end

  specify 'no duplicate sounds per object' do
    a = FactoryBot.create(:valid_conveyance)
    b = FactoryBot.build(:valid_conveyance, conveyance_object: a.conveyance_object, sound: a.sound)
    expect(b.valid?).to be_falsey 
  end

  specify 'end time after start time' do
    a = FactoryBot.build(
      :valid_conveyance,
      start_time: 2.0,
      end_time: 1.1
    )
    expect(a.valid?).to be_falsey 
  end

  specify 'new conveyance also creates new (nested) sound' do
    conveyance.sound_attributes = {sound_file: file_fixture_upload(
      Rack::Test::UploadedFile.new(Rails.root + 'spec/files/sounds/sound1.mp3', "audio/mpeg")
    ) }
    conveyance.conveyance_object = specimen
    expect(conveyance.save).to be_truthy
    expect(conveyance.sound.reload).to be_truthy
  end

end
