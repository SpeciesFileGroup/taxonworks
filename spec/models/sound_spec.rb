require 'rails_helper'

RSpec.describe Sound, type: :model do


  let(:s) { FactoryBot.build(:valid_sound) }

  # Might get in the way of parallel tests
  #  https://guides.rubyonrails.org/active_storage_overview.html#discarding-files-created-during-tests
  after(:all) { FileUtils.rm_rf(ActiveStorage::Blob.service.root) }

  specify 'file exists' do
    s.save
    path = ActiveStorage::Blob.service.path_for(s.sound_file.attachment.key)
    expect(File.exist?(path)).to be_truthy
  end

  specify 'file removed on destroy' do
    s.save
    path = ActiveStorage::Blob.service.path_for(s.sound_file.attachment.key)
    s.destroy!
    expect(File.exist?(path)).to be_falsey
  end

  specify 'content type is checked' do
    s.sound_file = Rack::Test::UploadedFile.new(
      Spec::Support::Utilities::Files.generate_tiny_random_sized_png(
        file_name: 'foo.png',
      ), 'image/png')

    s.valid?
    expect(s.errors[:sound_file].any?).to be_truthy
  end

  context 'supported mime-types' do
    ::Sound::ALLOWED_CONTENT_TYPES.collect{|t| t.split('/').last}.each do |extension|
      p = (Rails.root + "spec/files/sounds/sound1.#{extension}")
      if File.exist?(p)
        specify extension do
          s.sound_file = file_fixture_upload(
            Rack::Test::UploadedFile.new(p, "audio/#{extension}")
          )
          # puts '    (as: ' + s.sound_file.content_type + ')'
          s.valid?
          expect(s.errors[:sound_file].any?).to be_falsey
        end
      end
    end
  end

  specify 'observations' do
    s = FactoryBot.create(:valid_sound)
    o = FactoryBot.create(:valid_observation, observation_object: s)
    expect(s.observations.pluck(:id)).to contain_exactly(o.id)
  end

  specify 'origins' do
    s = FactoryBot.create(:valid_sound)
    o = FactoryBot.create(:valid_specimen)
    s.origin = o
    s.save!
    expect(s.old_objects).to contain_exactly(o)
  end

end
