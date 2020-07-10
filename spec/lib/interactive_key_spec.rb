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
      observation_matrix.reload
      expect(interactive_key.descriptor_available_languages.count).to eq(2)
    end

  end
end
