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

end
