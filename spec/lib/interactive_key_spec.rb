require 'rails_helper'
require 'interactive_key'

describe InteractiveKey, type: :model, group: :observation_matrix do

  context 'respond to' do
    let(:observation_matrix) { ObservationMatrix.create!(name: 'Matrix') }
    let(:otu1) { Otu.create!(name: 'phoo') }
    let(:otu2) { Otu.create!(name: 'barr') }
    let(:descriptor1) { Descriptor::Working.create!(name: 'working1') }
    let(:descriptor2) { Descriptor::Working.create!(name: 'working2') }
    let!(:rus) { FactoryBot.create(:russian) }
    let!(:eng) { FactoryBot.create(:english) }

    let(:interactive_key) { InteractiveKey.new(observation_matrix_id: observation_matrix.id, project_id: observation_matrix.project_id) }

    specify 'observation_matrix' do
      expect(interactive_key.observation_matrix).to eq(observation_matrix)
    end

    specify 'observation_matrix_citation' do
      source = FactoryBot.create(:valid_source)
      observation_matrix.source = source
      expect(interactive_key.observation_matrix_citation.id).to eq(source.id)
    end

    specify 'descriptor_available_languages' do
      eng
      observation_matrix.observation_matrix_column_items << ObservationMatrixColumnItem::Single::Descriptor.new(descriptor: descriptor1)
      observation_matrix.observation_matrix_column_items << ObservationMatrixColumnItem::Single::Descriptor.new(descriptor: descriptor2)
      a = AlternateValue.create(type: 'AlternateValue::Translation', value: 'zzz', alternate_value_object: descriptor1, alternate_value_object_attribute: 'name', language_id: rus.id)
      expect(interactive_key.descriptor_available_languages.count).to eq(2)
    end

    specify 'language_to_use' do
      eng
      observation_matrix.observation_matrix_column_items << ObservationMatrixColumnItem::Single::Descriptor.new(descriptor: descriptor1)
      observation_matrix.observation_matrix_column_items << ObservationMatrixColumnItem::Single::Descriptor.new(descriptor: descriptor2)
      a = AlternateValue.create(type: 'AlternateValue::Translation', value: 'zzz', alternate_value_object: descriptor1, alternate_value_object_attribute: 'name', language_id: rus.id)
      interactive_key = InteractiveKey.new(observation_matrix_id: observation_matrix.id, project_id: observation_matrix.project_id, language_id: rus.id)
      expect(interactive_key.language_to_use).to eq(rus)
    end

    specify 'descriptor_available_keywords' do
      observation_matrix.observation_matrix_column_items << ObservationMatrixColumnItem::Single::Descriptor.new(descriptor: descriptor1)
      observation_matrix.observation_matrix_column_items << ObservationMatrixColumnItem::Single::Descriptor.new(descriptor: descriptor2)
      k = Keyword.create(name: 'zzz', definition: 'zzzzzzzzzzzzzzzzzzzzzzzzz')
      descriptor1.tags.create(keyword: k)
      expect(interactive_key.descriptor_available_keywords.count).to eq(1)
    end

    specify 'descriptor_weight' do
      observation_matrix.observation_matrix_column_items << ObservationMatrixColumnItem::Single::Descriptor.new(descriptor: descriptor1)
      observation_matrix.observation_matrix_column_items << ObservationMatrixColumnItem::Single::Descriptor.new(descriptor: descriptor2)
      interactive_key = InteractiveKey.new(observation_matrix_id: observation_matrix.id, project_id: observation_matrix.project_id)
      expect(interactive_key.list_of_descriptors.count).to eq(2)
      descriptor1.weight = 0
      descriptor1.save
      interactive_key = InteractiveKey.new(observation_matrix_id: observation_matrix.id, project_id: observation_matrix.project_id)
      expect(interactive_key.list_of_descriptors.count).to eq(1)
    end

    specify 'descriptors_with_keywords' do
      observation_matrix.observation_matrix_column_items << ObservationMatrixColumnItem::Single::Descriptor.new(descriptor: descriptor1)
      observation_matrix.observation_matrix_column_items << ObservationMatrixColumnItem::Single::Descriptor.new(descriptor: descriptor2)
      k1 = Keyword.create(name: 'zzz1', definition: 'zzzzzzzzzzzzzzzzzzzzzzzzz')
      k2 = Keyword.create(name: 'zzz2', definition: 'zzzzzzzzzzzzzzzzzzzzzzzzzz')
      t1 = descriptor1.tags.create(keyword: k1)
      t2 = descriptor2.tags.create(keyword: k2)
      interactive_key = InteractiveKey.new(observation_matrix_id: observation_matrix.id, project_id: observation_matrix.project_id, keyword_ids: t1.id)
      expect(interactive_key.list_of_descriptors.count).to eq(1)
      interactive_key = InteractiveKey.new(observation_matrix_id: observation_matrix.id, project_id: observation_matrix.project_id, keyword_ids: t1.id.to_s + '|' + t2.id.to_s)
      expect(interactive_key.list_of_descriptors.count).to eq(2)
    end

    specify 'rows_with_filter' do
      o1 = observation_matrix.observation_matrix_row_items << ObservationMatrixRowItem::Single::Otu.new(otu: otu1)
      o2 = observation_matrix.observation_matrix_row_items << ObservationMatrixRowItem::Single::Otu.new(otu: otu2)
      interactive_key = InteractiveKey.new(observation_matrix_id: observation_matrix.id, project_id: observation_matrix.project_id, row_filter: observation_matrix.observation_matrix_rows.first.id)
      expect(interactive_key.remaining.count).to eq(1)
      interactive_key = InteractiveKey.new(observation_matrix_id: observation_matrix.id, project_id: observation_matrix.project_id, row_filter: observation_matrix.observation_matrix_rows.first.id.to_s + '|' + observation_matrix.observation_matrix_rows.last.id.to_s)
      expect(interactive_key.remaining.count).to eq(2)
    end
  end

  context 'interactive key functionality' do
    before(:all) do
      @observation_matrix =  ObservationMatrix.create!(name: 'Matrix')
      @genus1 = FactoryBot.create(:relationship_genus, name: 'Aus')
      @genus2 = FactoryBot.create(:relationship_genus, name: 'Bus')
      @genus3 = FactoryBot.create(:relationship_genus, name: 'Cus')
      @species1 = FactoryBot.create(:iczn_species, name: 'aa', parent: @genus1)
      @species2 = FactoryBot.create(:iczn_species, name: 'aaa', parent: @genus1)
      @species3 = FactoryBot.create(:iczn_species, name: 'aaaa', parent: @genus1)
      @species4 = FactoryBot.create(:iczn_species, name: 'bb', parent: @genus2)
      @species5 = FactoryBot.create(:iczn_species, name: 'bbb', parent: @genus2)
      @species6 = FactoryBot.create(:iczn_species, name: 'bbbb', parent: @genus2)

      @otu1 =  Otu.create!(taxon_name: @species1)
      @otu2 =  Otu.create!(taxon_name: @species2)
      @otu3 =  Otu.create!(taxon_name: @species3)
      @otu4 =  Otu.create!(taxon_name: @species4)
      @otu5 =  Otu.create!(taxon_name: @species5)
      @otu6 =  Otu.create!(taxon_name: @species6)
      @otu7 =  Otu.create!(taxon_name: @genus3)
      @otu8 =  Otu.create!(name: 'a8')
      @otu9 =  Otu.create!(name: 'b9')
      @collection_object =  CollectionObject::BiologicalCollectionObject.create(total: 1, )
      @taxon_determination =  TaxonDetermination.create(otu: @otu1, biological_collection_object: @collection_object)

      @observation_matrix.observation_matrix_row_items << ObservationMatrixRowItem::Single::Otu.new(otu: @otu1)
      @observation_matrix.observation_matrix_row_items << ObservationMatrixRowItem::Single::Otu.new(otu: @otu2)
      @observation_matrix.observation_matrix_row_items << ObservationMatrixRowItem::Single::Otu.new(otu: @otu3)
      @observation_matrix.observation_matrix_row_items << ObservationMatrixRowItem::Single::Otu.new(otu: @otu4)
      @observation_matrix.observation_matrix_row_items << ObservationMatrixRowItem::Single::Otu.new(otu: @otu5)
      @observation_matrix.observation_matrix_row_items << ObservationMatrixRowItem::Single::Otu.new(otu: @otu6)
      @observation_matrix.observation_matrix_row_items << ObservationMatrixRowItem::Single::Otu.new(otu: @otu7)
      @observation_matrix.observation_matrix_row_items << ObservationMatrixRowItem::Single::Otu.new(otu: @otu8)
      @observation_matrix.observation_matrix_row_items << ObservationMatrixRowItem::Single::Otu.new(otu: @otu9)
      @observation_matrix.observation_matrix_row_items << ObservationMatrixRowItem::Single::CollectionObject.new(collection_object: @collection_object)

      @descriptor1 =  Descriptor::Qualitative.create!(name: 'Descriptor 1')
      @cs1 =  CharacterState.create!(name: 'State1', label: '0', descriptor: @descriptor1)
      @cs2 =  CharacterState.create!(name: 'State2', label: '1', descriptor: @descriptor1)
      @cs3 =  CharacterState.create!(name: 'State3', label: '2', descriptor: @descriptor1)
      @descriptor2 =  Descriptor::Qualitative.create!(name: 'Descriptor 2')
      @cs4 =  CharacterState.create!(name: 'State4', label: '0', descriptor: @descriptor2)
      @cs5 =  CharacterState.create!(name: 'State5', label: '1', descriptor: @descriptor2)
      @cs6 =  CharacterState.create!(name: 'State6', label: '2', descriptor: @descriptor2)
      @descriptor3 =  Descriptor::Qualitative.create!(name: 'Descriptor 3')
      @cs7 =  CharacterState.create!(name: 'State7', label: '0', descriptor: @descriptor3)
      @cs8 =  CharacterState.create!(name: 'State8', label: '1', descriptor: @descriptor3)
      @descriptor4 =  Descriptor::Qualitative.create!(name: 'Descriptor 4')
      @cs9 =  CharacterState.create!(name: 'State9', label: '0', descriptor: @descriptor4)
      @cs10 =  CharacterState.create!(name: 'State10', label: '1', descriptor: @descriptor4)
      @descriptor5 =  Descriptor::Sample.create!(name: 'Descriptor 5')
      @descriptor6 =  Descriptor::Continuous.create!(name: 'Descriptor 6')
      @descriptor7 =  Descriptor::PresenceAbsence.create!(name: 'Descriptor 7')

      @observation_matrix.observation_matrix_column_items << ObservationMatrixColumnItem::Single::Descriptor.new(descriptor: @descriptor1)
      @observation_matrix.observation_matrix_column_items << ObservationMatrixColumnItem::Single::Descriptor.new(descriptor: @descriptor2)
      @observation_matrix.observation_matrix_column_items << ObservationMatrixColumnItem::Single::Descriptor.new(descriptor: @descriptor3)
      @observation_matrix.observation_matrix_column_items << ObservationMatrixColumnItem::Single::Descriptor.new(descriptor: @descriptor4)
      @observation_matrix.observation_matrix_column_items << ObservationMatrixColumnItem::Single::Descriptor.new(descriptor: @descriptor5)
      @observation_matrix.observation_matrix_column_items << ObservationMatrixColumnItem::Single::Descriptor.new(descriptor: @descriptor6)
      @observation_matrix.observation_matrix_column_items << ObservationMatrixColumnItem::Single::Descriptor.new(descriptor: @descriptor7)

      # 0   2   0   1   1-2   1 true
      # 1   1   1   0   2-3   2 false
      # 2   0   0   1   1-3   3 true
      # 0   2   -   -   3-4   4 false
      # 1   1   0   1   2-4   1 true
      # 2   0   1   0   1-2   2 false
      # 0   2   0   1   1-3   3 true
      # 1   1   1   0   2-3   4 false
      # 1   0   0   1   1-2   1 true
      # 0   2   1   0   1     2 true

      Observation::Qualitative.create!(descriptor: @descriptor1, otu: @otu1, character_state: @cs1)
      Observation::Qualitative.create!(descriptor: @descriptor1, otu: @otu2, character_state: @cs2)
      Observation::Qualitative.create!(descriptor: @descriptor1, otu: @otu3, character_state: @cs3)
      Observation::Qualitative.create!(descriptor: @descriptor1, otu: @otu4, character_state: @cs1)
      Observation::Qualitative.create!(descriptor: @descriptor1, otu: @otu5, character_state: @cs2)
      Observation::Qualitative.create!(descriptor: @descriptor1, otu: @otu6, character_state: @cs3)
      Observation::Qualitative.create!(descriptor: @descriptor1, otu: @otu7, character_state: @cs1)
      Observation::Qualitative.create!(descriptor: @descriptor1, otu: @otu8, character_state: @cs2)
      Observation::Qualitative.create!(descriptor: @descriptor1, otu: @otu9, character_state: @cs3)
      Observation::Qualitative.create!(descriptor: @descriptor1, collection_object: @collection_object, character_state: @cs1)

      Observation::Qualitative.create!(descriptor: @descriptor2, otu: @otu1, character_state: @cs6)
      Observation::Qualitative.create!(descriptor: @descriptor2, otu: @otu2, character_state: @cs5)
      Observation::Qualitative.create!(descriptor: @descriptor2, otu: @otu3, character_state: @cs4)
      Observation::Qualitative.create!(descriptor: @descriptor2, otu: @otu4, character_state: @cs6)
      Observation::Qualitative.create!(descriptor: @descriptor2, otu: @otu5, character_state: @cs5)
      Observation::Qualitative.create!(descriptor: @descriptor2, otu: @otu6, character_state: @cs4)
      Observation::Qualitative.create!(descriptor: @descriptor2, otu: @otu7, character_state: @cs6)
      Observation::Qualitative.create!(descriptor: @descriptor2, otu: @otu8, character_state: @cs5)
      Observation::Qualitative.create!(descriptor: @descriptor2, otu: @otu9, character_state: @cs4)
      Observation::Qualitative.create!(descriptor: @descriptor2, collection_object: @collection_object, character_state: @cs6)

      Observation::Qualitative.create!(descriptor: @descriptor3, otu: @otu1, character_state: @cs7)
      Observation::Qualitative.create!(descriptor: @descriptor3, otu: @otu2, character_state: @cs8)
      Observation::Qualitative.create!(descriptor: @descriptor3, otu: @otu3, character_state: @cs7)
      Observation::Qualitative.create!(descriptor: @descriptor3, otu: @otu5, character_state: @cs7)
      Observation::Qualitative.create!(descriptor: @descriptor3, otu: @otu6, character_state: @cs8)
      Observation::Qualitative.create!(descriptor: @descriptor3, otu: @otu7, character_state: @cs7)
      Observation::Qualitative.create!(descriptor: @descriptor3, otu: @otu8, character_state: @cs8)
      Observation::Qualitative.create!(descriptor: @descriptor3, otu: @otu9, character_state: @cs7)
      Observation::Qualitative.create!(descriptor: @descriptor3, collection_object: @collection_object, character_state: @cs8)

      Observation::Qualitative.create!(descriptor: @descriptor4, otu: @otu1, character_state: @cs10)
      Observation::Qualitative.create!(descriptor: @descriptor4, otu: @otu2, character_state: @cs9)
      Observation::Qualitative.create!(descriptor: @descriptor4, otu: @otu3, character_state: @cs10)
      Observation::Qualitative.create!(descriptor: @descriptor4, otu: @otu5, character_state: @cs10)
      Observation::Qualitative.create!(descriptor: @descriptor4, otu: @otu6, character_state: @cs9)
      Observation::Qualitative.create!(descriptor: @descriptor4, otu: @otu7, character_state: @cs10)
      Observation::Qualitative.create!(descriptor: @descriptor4, otu: @otu8, character_state: @cs9)
      Observation::Qualitative.create!(descriptor: @descriptor4, otu: @otu9, character_state: @cs10)
      Observation::Qualitative.create!(descriptor: @descriptor4, collection_object: @collection_object, character_state: @cs9)

      Observation::Sample.create!(descriptor: @descriptor5, otu: @otu1, sample_min: 1, sample_max: 2)
      Observation::Sample.create!(descriptor: @descriptor5, otu: @otu2, sample_min: 2, sample_max: 3)
      Observation::Sample.create!(descriptor: @descriptor5, otu: @otu3, sample_min: 1, sample_max: 3)
      Observation::Sample.create!(descriptor: @descriptor5, otu: @otu4, sample_min: 3, sample_max: 4)
      Observation::Sample.create!(descriptor: @descriptor5, otu: @otu5, sample_min: 2, sample_max: 4)
      Observation::Sample.create!(descriptor: @descriptor5, otu: @otu6, sample_min: 1, sample_max: 2)
      Observation::Sample.create!(descriptor: @descriptor5, otu: @otu7, sample_min: 1, sample_max: 3)
      Observation::Sample.create!(descriptor: @descriptor5, otu: @otu8, sample_min: 2, sample_max: 3)
      Observation::Sample.create!(descriptor: @descriptor5, otu: @otu9, sample_min: 1, sample_max: 2)
      Observation::Sample.create!(descriptor: @descriptor5, collection_object: @collection_object, sample_min: 1)

      Observation::Continuous.create!(descriptor: @descriptor6, otu: @otu1, continuous_value: 1)
      Observation::Continuous.create!(descriptor: @descriptor6, otu: @otu2, continuous_value: 2)
      Observation::Continuous.create!(descriptor: @descriptor6, otu: @otu3, continuous_value: 3)
      Observation::Continuous.create!(descriptor: @descriptor6, otu: @otu4, continuous_value: 4)
      Observation::Continuous.create!(descriptor: @descriptor6, otu: @otu5, continuous_value: 1)
      Observation::Continuous.create!(descriptor: @descriptor6, otu: @otu6, continuous_value: 2)
      Observation::Continuous.create!(descriptor: @descriptor6, otu: @otu7, continuous_value: 3)
      Observation::Continuous.create!(descriptor: @descriptor6, otu: @otu8, continuous_value: 4)
      Observation::Continuous.create!(descriptor: @descriptor6, otu: @otu9, continuous_value: 1)
      Observation::Continuous.create!(descriptor: @descriptor6, collection_object: @collection_object, continuous_value: 2)

      Observation::PresenceAbsence.create!(descriptor: @descriptor7, otu: @otu1, presence: true)
      Observation::PresenceAbsence.create!(descriptor: @descriptor7, otu: @otu2, presence: false)
      Observation::PresenceAbsence.create!(descriptor: @descriptor7, otu: @otu3, presence: true)
      Observation::PresenceAbsence.create!(descriptor: @descriptor7, otu: @otu4, presence: false)
      Observation::PresenceAbsence.create!(descriptor: @descriptor7, otu: @otu5, presence: true)
      Observation::PresenceAbsence.create!(descriptor: @descriptor7, otu: @otu6, presence: false)
      Observation::PresenceAbsence.create!(descriptor: @descriptor7, otu: @otu7, presence: true)
      Observation::PresenceAbsence.create!(descriptor: @descriptor7, otu: @otu8, presence: false)
      Observation::PresenceAbsence.create!(descriptor: @descriptor7, otu: @otu9, presence: true)
      Observation::PresenceAbsence.create!(descriptor: @descriptor7, collection_object: @collection_object, presence: true)
    end

    specify 'valid matrix' do
      ik =  InteractiveKey.new(observation_matrix_id: @observation_matrix.id,
                               project_id: @observation_matrix.project_id)
      expect(ik.remaining.count).to eq(10)
      expect(ik.eliminated.count).to eq(0)
      expect(ik.list_of_descriptors.count).to eq(7)
    end

    specify 'sorting: ordered' do
      ik =  InteractiveKey.new(observation_matrix_id: @observation_matrix.id,
                               project_id: @observation_matrix.project_id,
                               sorting: 'ordered')
      expect(ik.list_of_descriptors.count).to eq(7)
    end

    specify 'sorting: weighted' do
      ik =  InteractiveKey.new(observation_matrix_id: @observation_matrix.id,
                               project_id: @observation_matrix.project_id,
                               sorting: 'weighted')
      expect(ik.list_of_descriptors.count).to eq(7)
    end

    specify 'sorting: optimized' do
      ik =  InteractiveKey.new(observation_matrix_id: @observation_matrix.id,
                               project_id: @observation_matrix.project_id,
                               sorting: 'optimized')
      expect(ik.list_of_descriptors.count).to eq(7)
    end

    specify 'indentified_to_rank: otu' do
      ik =  InteractiveKey.new(observation_matrix_id: @observation_matrix.id,
                               project_id: @observation_matrix.project_id,
                               identified_to_rank: 'otu')
      expect(ik.remaining.count).to eq(9)
    end

    specify 'indentified_to_rank: species' do
      ik =  InteractiveKey.new(observation_matrix_id: @observation_matrix.id,
                               project_id: @observation_matrix.project_id,
                               identified_to_rank: 'species')
      expect(ik.remaining.count).to eq(9)
    end

    specify 'indentified_to_rank: genus' do
      ik =  InteractiveKey.new(observation_matrix_id: @observation_matrix.id,
                               project_id: @observation_matrix.project_id,
                               identified_to_rank: 'genus')
      expect(ik.remaining.count).to eq(5)
    end

    specify 'selected_descriptors 1.1' do
      ik =  InteractiveKey.new(observation_matrix_id: @observation_matrix.id,
                               project_id: @observation_matrix.project_id,
                               selected_descriptors: @descriptor1.id.to_s + ':' + @cs1.id.to_s)
      expect(ik.remaining.count).to eq(4)
      expect(ik.eliminated.count).to eq(6)
    end

    specify 'selected_descriptors 1.1 & 1.2' do
      ik =  InteractiveKey.new(observation_matrix_id: @observation_matrix.id,
                               project_id: @observation_matrix.project_id,
                               selected_descriptors: @descriptor1.id.to_s + ':' + @cs1.id.to_s + '|' + @cs2.id.to_s)
      expect(ik.remaining.count).to eq(7)
      expect(ik.eliminated.count).to eq(3)
    end

    specify 'selected_descriptors 1.1 & 1.2 & 2.5' do
      ik =  InteractiveKey.new(observation_matrix_id: @observation_matrix.id,
                               project_id: @observation_matrix.project_id,
                               selected_descriptors: @descriptor1.id.to_s + ':' + @cs1.id.to_s + '|' + @cs2.id.to_s + '||' + @descriptor2.id.to_s + ':' + @cs5.id.to_s)
      expect(ik.remaining.count).to eq(3)
      expect(ik.eliminated.count).to eq(7)
    end

    specify 'selected_descriptors 1.1 & 1.2 & 2.5 + error_tolerance = 1' do
      ik =  InteractiveKey.new(observation_matrix_id: @observation_matrix.id,
                               project_id: @observation_matrix.project_id,
                               selected_descriptors: @descriptor1.id.to_s + ':' + @cs1.id.to_s + '|' + @cs2.id.to_s + '||' + @descriptor2.id.to_s + ':' + @cs5.id.to_s,
                               error_tolerance: 1)
      expect(ik.remaining.count).to eq(7)
      expect(ik.eliminated.count).to eq(3)
    end

    specify 'selected_descriptors 1.1 & 1.2 & 2.5 + error_tolerance = 2' do
      ik =  InteractiveKey.new(observation_matrix_id: @observation_matrix.id,
                               project_id: @observation_matrix.project_id,
                               selected_descriptors: @descriptor1.id.to_s + ':' + @cs1.id.to_s + '|' + @cs2.id.to_s + '||' + @descriptor2.id.to_s + ':' + @cs5.id.to_s,
                               error_tolerance: 2)
      expect(ik.remaining.count).to eq(10)
      expect(ik.eliminated.count).to eq(0)
    end

    specify 'selected_descriptors 3.8' do
      ik =  InteractiveKey.new(observation_matrix_id: @observation_matrix.id,
                               project_id: @observation_matrix.project_id,
                               selected_descriptors: @descriptor3.id.to_s + ':' + @cs8.id.to_s)
      expect(ik.remaining.count).to eq(5)
      expect(ik.eliminated.count).to eq(5)
    end

    specify 'selected_descriptors 3.8 + eliminate_unknown' do
      ik =  InteractiveKey.new(observation_matrix_id: @observation_matrix.id,
                               project_id: @observation_matrix.project_id,
                               selected_descriptors: @descriptor3.id.to_s + ':' + @cs8.id.to_s,
                               eliminate_unknown: 'true')
      expect(ik.remaining.count).to eq(4)
      expect(ik.eliminated.count).to eq(6)
    end

    specify 'selected_descriptors 5:3' do
      ik =  InteractiveKey.new(observation_matrix_id: @observation_matrix.id,
                               project_id: @observation_matrix.project_id,
                               selected_descriptors: @descriptor5.id.to_s + ':3')
      expect(ik.remaining.count).to eq(6)
      expect(ik.eliminated.count).to eq(4)
    end

    specify 'selected_descriptors 5:2-3' do
      ik =  InteractiveKey.new(observation_matrix_id: @observation_matrix.id,
                               project_id: @observation_matrix.project_id,
                               selected_descriptors: @descriptor5.id.to_s + ':2-3')
      expect(ik.remaining.count).to eq(9)
      expect(ik.eliminated.count).to eq(1)
    end

    specify 'selected_descriptors 5:0.5-2' do
      ik =  InteractiveKey.new(observation_matrix_id: @observation_matrix.id,
                               project_id: @observation_matrix.project_id,
                               selected_descriptors: @descriptor5.id.to_s + ':0.5-2')
      expect(ik.remaining.count).to eq(9)
      expect(ik.eliminated.count).to eq(1)
    end

    specify 'selected_descriptors 5:3-5' do
      ik =  InteractiveKey.new(observation_matrix_id: @observation_matrix.id,
                               project_id: @observation_matrix.project_id,
                               selected_descriptors: @descriptor5.id.to_s + ':3-5')
      expect(ik.remaining.count).to eq(6)
      expect(ik.eliminated.count).to eq(4)
    end

    specify 'selected_descriptors 5:0-7' do
      ik =  InteractiveKey.new(observation_matrix_id: @observation_matrix.id,
                               project_id: @observation_matrix.project_id,
                               selected_descriptors: @descriptor5.id.to_s + ':0-7')
      expect(ik.remaining.count).to eq(10)
      expect(ik.eliminated.count).to eq(0)
    end

    specify 'selected_descriptors 6:2' do
      ik =  InteractiveKey.new(observation_matrix_id: @observation_matrix.id,
                               project_id: @observation_matrix.project_id,
                               selected_descriptors: @descriptor6.id.to_s + ':2')
      expect(ik.remaining.count).to eq(3)
      expect(ik.eliminated.count).to eq(7)
    end

    specify 'selected_descriptors 7:true' do
      ik =  InteractiveKey.new(observation_matrix_id: @observation_matrix.id,
                               project_id: @observation_matrix.project_id,
                               selected_descriptors: @descriptor7.id.to_s + ':true')
      expect(ik.remaining.count).to eq(6)
      expect(ik.eliminated.count).to eq(4)
    end

    specify 'selected_descriptors 7:false' do
      ik =  InteractiveKey.new(observation_matrix_id: @observation_matrix.id,
                               project_id: @observation_matrix.project_id,
                               selected_descriptors: @descriptor7.id.to_s + ':false')
      expect(ik.remaining.count).to eq(4)
      expect(ik.eliminated.count).to eq(6)
    end

  end

end
