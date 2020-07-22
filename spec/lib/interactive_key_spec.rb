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

#    observation_matrix.observation_matrix_row_items << ObservationMatrixRowItem::SingleOtu.new(otu: otu1)
#    observation_matrix.observation_matrix_row_items << ObservationMatrixRowItem::SingleOtu.new(otu: otu2)
#    observation_matrix.observation_matrix_column_items << ObservationMatrixColumnItem::SingleDescriptor.new(descriptor: descriptor1)
#    observation_matrix.observation_matrix_column_items << ObservationMatrixColumnItem::SingleDescriptor.new(descriptor: descriptor2)

    specify 'observation_matrix' do
      expect(interactive_key.observation_matrix).to eq(observation_matrix)
    end

    specify 'descriptor_available_languages' do
      eng
      observation_matrix.observation_matrix_column_items << ObservationMatrixColumnItem::SingleDescriptor.new(descriptor: descriptor1)
      observation_matrix.observation_matrix_column_items << ObservationMatrixColumnItem::SingleDescriptor.new(descriptor: descriptor2)
      a = AlternateValue.create(type: 'AlternateValue::Translation', value: 'zzz', alternate_value_object: descriptor1, alternate_value_object_attribute: 'name', language_id: rus.id)
      expect(interactive_key.descriptor_available_languages.count).to eq(2)
    end

    specify 'language_to_use' do
      eng
      observation_matrix.observation_matrix_column_items << ObservationMatrixColumnItem::SingleDescriptor.new(descriptor: descriptor1)
      observation_matrix.observation_matrix_column_items << ObservationMatrixColumnItem::SingleDescriptor.new(descriptor: descriptor2)
      a = AlternateValue.create(type: 'AlternateValue::Translation', value: 'zzz', alternate_value_object: descriptor1, alternate_value_object_attribute: 'name', language_id: rus.id)
      interactive_key = InteractiveKey.new(observation_matrix_id: observation_matrix.id, project_id: observation_matrix.project_id, language_id: rus.id)
      expect(interactive_key.language_to_use).to eq(rus)
    end

    specify 'descriptor_available_keywords' do
      observation_matrix.observation_matrix_column_items << ObservationMatrixColumnItem::SingleDescriptor.new(descriptor: descriptor1)
      observation_matrix.observation_matrix_column_items << ObservationMatrixColumnItem::SingleDescriptor.new(descriptor: descriptor2)
      k = Keyword.create(name: 'zzz', definition: 'zzzzzzzzzzzzzzzzzzzzzzzzz')
      descriptor1.tags.create(keyword: k)
      expect(interactive_key.descriptor_available_keywords.count).to eq(1)
    end

    specify 'descriptor_weight' do
      observation_matrix.observation_matrix_column_items << ObservationMatrixColumnItem::SingleDescriptor.new(descriptor: descriptor1)
      observation_matrix.observation_matrix_column_items << ObservationMatrixColumnItem::SingleDescriptor.new(descriptor: descriptor2)
      interactive_key = InteractiveKey.new(observation_matrix_id: observation_matrix.id, project_id: observation_matrix.project_id)
      expect(interactive_key.descriptors_with_filter.count).to eq(2)
      descriptor1.weight = 0
      descriptor1.save
      interactive_key = InteractiveKey.new(observation_matrix_id: observation_matrix.id, project_id: observation_matrix.project_id)
      expect(interactive_key.descriptors_with_filter.count).to eq(1)
    end

    specify 'descriptors_with_keywords' do
      observation_matrix.observation_matrix_column_items << ObservationMatrixColumnItem::SingleDescriptor.new(descriptor: descriptor1)
      observation_matrix.observation_matrix_column_items << ObservationMatrixColumnItem::SingleDescriptor.new(descriptor: descriptor2)
      k1 = Keyword.create(name: 'zzz1', definition: 'zzzzzzzzzzzzzzzzzzzzzzzzz')
      k2 = Keyword.create(name: 'zzz2', definition: 'zzzzzzzzzzzzzzzzzzzzzzzzzz')
      t1 = descriptor1.tags.create(keyword: k1)
      t2 = descriptor2.tags.create(keyword: k2)
      interactive_key = InteractiveKey.new(observation_matrix_id: observation_matrix.id, project_id: observation_matrix.project_id, keyword_ids: t1.id)
      expect(interactive_key.descriptors_with_filter.count).to eq(1)
      interactive_key = InteractiveKey.new(observation_matrix_id: observation_matrix.id, project_id: observation_matrix.project_id, keyword_ids: t1.id.to_s + '|' + t2.id.to_s)
      expect(interactive_key.descriptors_with_filter.count).to eq(2)
    end

    specify 'rows_with_filter' do
      o1 = observation_matrix.observation_matrix_row_items << ObservationMatrixRowItem::SingleOtu.new(otu: otu1)
      o2 = observation_matrix.observation_matrix_row_items << ObservationMatrixRowItem::SingleOtu.new(otu: otu2)
      interactive_key = InteractiveKey.new(observation_matrix_id: observation_matrix.id, project_id: observation_matrix.project_id, row_filter: observation_matrix.observation_matrix_rows.first.id)
      expect(interactive_key.rows_with_filter.count).to eq(1)
      interactive_key = InteractiveKey.new(observation_matrix_id: observation_matrix.id, project_id: observation_matrix.project_id, row_filter: observation_matrix.observation_matrix_rows.first.id.to_s + '|' + observation_matrix.observation_matrix_rows.last.id.to_s)
      expect(interactive_key.rows_with_filter.count).to eq(2)
    end


  end
end
