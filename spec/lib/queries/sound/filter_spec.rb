require 'rails_helper'

describe Queries::Sound::Filter, type: :model, group: [:filter, :sound] do

  context 'sort param' do
    let!(:snd_a) {
      FactoryBot.create(:valid_sound).tap { |s| s.update_columns(name: 'Alpha sound') }
    }
    let!(:snd_z) {
      FactoryBot.create(:valid_sound).tap { |s| s.update_columns(name: 'Zeta sound') }
    }

    def sorted_ids(sort_key)
      Queries::Sound::Filter.new(sort: sort_key)
        .all.where(id: [snd_a.id, snd_z.id]).pluck(:id)
    end

    specify 'sort=name orders alphabetically' do
      expect(sorted_ids('name')).to eq([snd_a.id, snd_z.id])
    end

    specify 'sort=-name desc' do
      expect(sorted_ids('-name')).to eq([snd_z.id, snd_a.id])
    end

    specify 'unknown sort key ignored' do
      expect(sorted_ids('no_such_column')).to contain_exactly(snd_a.id, snd_z.id)
    end
  end
end
