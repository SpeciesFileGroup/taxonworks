require 'rails_helper'

describe SoundsHelper, type: :helper do
  describe '#sound_metadata' do
    let(:sound) { FactoryBot.create(:valid_sound) }

    context 'when the sound file is missing from storage' do
      before do
        path = ActiveStorage::Blob.service.path_for(sound.sound_file.attachment.key)
        File.delete(path)
      end

      it 'returns an error hash rather than raising' do
        expect(helper.sound_metadata(sound)).to eq({ error: 'Missing sound file' })
      end

      it 'does not raise even in production' do
        allow(Rails).to receive(:env).and_return(
          ActiveSupport::StringInquirer.new('production')
        )
        expect { helper.sound_metadata(sound) }.not_to raise_error
      end
    end
  end
end
