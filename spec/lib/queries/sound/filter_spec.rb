require 'rails_helper'

describe Queries::Sound::Filter, type: :model, group: [:sounds, :filter] do

  let(:q) { Queries::Sound::Filter.new({}) }

  specify '#sound_id' do
    s = FactoryBot.create(:valid_sound)
    FactoryBot.create(:valid_sound) # not this

    q.sound_id = s.id
    expect(q.all.pluck(:id)).to contain_exactly(s.id)
  end

  context 'anatomical_part_query' do
    let(:anatomical_part) {
      FactoryBot.create(:valid_anatomical_part, ancestor: FactoryBot.create(:valid_specimen))
    }
    let!(:sound) { FactoryBot.create(:valid_sound, origin: anatomical_part) }

    specify 'matches Sounds whose origin is an AnatomicalPart in the query' do
      q.anatomical_part_query = ::Queries::AnatomicalPart::Filter.new(anatomical_part_id: anatomical_part.id)
      expect(q.all.pluck(:id)).to contain_exactly(sound.id)
    end

    specify 'is not intersected with an (empty) conveyance-based match' do
      # Regression: anatomical_part_query was applied twice (origin + conveyance),
      # and the conveyance match excluded origin-derived sounds.
      q.anatomical_part_query = ::Queries::AnatomicalPart::Filter.new(anatomical_part_id: anatomical_part.id)
      expect(q.all.pluck(:id)).to contain_exactly(sound.id)
    end

    specify 'ignores an origin CollectionObject whose id collides with the anatomical part id' do
      shared_id = 91_000_004
      ap = FactoryBot.create(:valid_anatomical_part, ancestor: FactoryBot.create(:valid_specimen), id: shared_id)
      s = FactoryBot.create(:valid_sound, origin: ap)

      colliding_co = FactoryBot.create(:valid_specimen, id: shared_id)
      FactoryBot.create(:valid_sound, origin: colliding_co)

      q.anatomical_part_query = ::Queries::AnatomicalPart::Filter.new(anatomical_part_id: ap.id)
      expect(q.all.pluck(:id)).to contain_exactly(s.id)
    end
  end

  context 'sort param' do
    let!(:snd_a) {
      FactoryBot.create(:valid_sound).tap { |s| s.update_columns(name: 'Alpha sound') }
    }
    let!(:snd_z) {
      FactoryBot.create(:valid_sound).tap { |s| s.update_columns(name: 'Zeta sound') }
    }

    def sorted_ids(sort_key)
      Queries::Pager.new(Queries::Sound::Filter.new(sort: sort_key).all, sort: sort_key).ordered.where(id: [snd_a.id, snd_z.id]).pluck(:id)
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
