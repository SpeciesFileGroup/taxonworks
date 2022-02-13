require 'rails_helper'
require 'tools/interactive_key'

describe Tools::InteractiveKey, type: :model, group: :observation_matrix do

  # Alias the class 
  let(:key) { Tools::InteractiveKey } 

  context 'respond to' do
    let(:observation_matrix) { ObservationMatrix.create!(name: 'Matrix') }
    let(:otu1) { Otu.create!(name: 'phoo') }
    let(:otu2) { Otu.create!(name: 'barr') }
    let(:descriptor1) { Descriptor::Working.create!(name: 'working1') }
    let(:descriptor2) { Descriptor::Working.create!(name: 'working2') }
    let!(:rus) { FactoryBot.create(:russian) }
    let!(:eng) { FactoryBot.create(:english) }

    let(:interactive_key) { key.new(observation_matrix_id: observation_matrix.id, project_id: observation_matrix.project_id) }

    let(:source) { FactoryBot.create(:valid_source) }

    specify 'observation_matrix' do
      expect(interactive_key.observation_matrix).to eq(observation_matrix)
    end

    specify 'observation_matrix_citation' do
      observation_matrix.source = source
      expect(interactive_key.observation_matrix_citation.id).to eq(source.id)
    end

    specify 'descriptor_available_languages' do
      observation_matrix.observation_matrix_column_items << ObservationMatrixColumnItem::Single::Descriptor.new(descriptor: descriptor1)
      observation_matrix.observation_matrix_column_items << ObservationMatrixColumnItem::Single::Descriptor.new(descriptor: descriptor2)
      a = AlternateValue.create(type: 'AlternateValue::Translation', value: 'zzz', alternate_value_object: descriptor1, alternate_value_object_attribute: 'name', language_id: rus.id)
      expect(interactive_key.descriptor_available_languages.count).to eq(2)
    end

    specify 'language_to_use' do
      observation_matrix.observation_matrix_column_items << ObservationMatrixColumnItem::Single::Descriptor.new(descriptor: descriptor1)
      observation_matrix.observation_matrix_column_items << ObservationMatrixColumnItem::Single::Descriptor.new(descriptor: descriptor2)
      a = AlternateValue.create(type: 'AlternateValue::Translation', value: 'zzz', alternate_value_object: descriptor1, alternate_value_object_attribute: 'name', language_id: rus.id)
      interactive_key = key.new(observation_matrix_id: observation_matrix.id, project_id: observation_matrix.project_id, language_id: rus.id)
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
      interactive_key = key.new(observation_matrix_id: observation_matrix.id, project_id: observation_matrix.project_id)
      expect(interactive_key.list_of_descriptors.count).to eq(2)
      descriptor1.weight = 0
      descriptor1.save
      interactive_key = key.new(observation_matrix_id: observation_matrix.id, project_id: observation_matrix.project_id)
      expect(interactive_key.list_of_descriptors.count).to eq(1)
    end

    specify 'descriptors_with_keywords' do
      observation_matrix.observation_matrix_column_items << ObservationMatrixColumnItem::Single::Descriptor.new(descriptor: descriptor1)
      observation_matrix.observation_matrix_column_items << ObservationMatrixColumnItem::Single::Descriptor.new(descriptor: descriptor2)
      k1 = Keyword.create(name: 'zzz1', definition: 'zzzzzzzzzzzzzzzzzzzzzzzzz')
      k2 = Keyword.create(name: 'zzz2', definition: 'zzzzzzzzzzzzzzzzzzzzzzzzzz')
      t1 = descriptor1.tags.create(keyword: k1)
      t2 = descriptor2.tags.create(keyword: k2)
      interactive_key = key.new(observation_matrix_id: observation_matrix.id, project_id: observation_matrix.project_id, keyword_ids: t1.id)
      expect(interactive_key.list_of_descriptors.count).to eq(1)
      interactive_key = key.new(observation_matrix_id: observation_matrix.id, project_id: observation_matrix.project_id, keyword_ids: t1.id.to_s + '|' + t2.id.to_s)
      expect(interactive_key.list_of_descriptors.count).to eq(2)
    end

    # TODO:  strangely named, does not match the variable
    specify 'rows_with_filter' do
      observation_matrix.observation_matrix_row_items << ObservationMatrixRowItem::Single.new(observation_object: otu1)
      observation_matrix.observation_matrix_row_items << ObservationMatrixRowItem::Single.new(observation_object: otu2)

      # interactive_key = key.new(observation_matrix_id: observation_matrix.id, project_id: observation_matrix.project_id, row_filter: observation_matrix.observation_matrix_rows.first.id)
      # expect(interactive_key.remaining.count).to eq(1)
      interactive_key = key.new(
        observation_matrix_id: observation_matrix.id,
        project_id: observation_matrix.project_id,
        row_filter: observation_matrix.observation_matrix_rows.first.id.to_s + '|' + observation_matrix.observation_matrix_rows.last.id.to_s)

      expect(interactive_key.remaining.count).to eq(2)
    end
  end

  context 'interactive key functionality' do

    # See spec/support/shared_contexts/shared_observation_matrices.rb
    include_context 'complex observation matrix'

    specify 'valid matrix' do
      ik =  key.new(
        observation_matrix_id: observation_matrix.id,
        project_id: observation_matrix.project_id)
      expect(ik.remaining.count).to eq(10)
      expect(ik.eliminated.count).to eq(0)
      expect(ik.list_of_descriptors.count).to eq(7)
    end

    specify 'sorting: ordered' do
      ik =  key.new(
        observation_matrix_id: observation_matrix.id,
        project_id: observation_matrix.project_id,
        sorting: 'ordered')
      expect(ik.list_of_descriptors.count).to eq(7)
    end

    specify 'sorting: weighted' do
      ik =  key.new(
        observation_matrix_id: observation_matrix.id,
        project_id: observation_matrix.project_id,
        sorting: 'weighted')
      expect(ik.list_of_descriptors.count).to eq(7)
    end

    specify 'sorting: optimized' do
      ik = key.new(
        observation_matrix_id: observation_matrix.id,
        project_id: observation_matrix.project_id,
        sorting: 'optimized')
      expect(ik.list_of_descriptors.count).to eq(7)
    end

    specify 'row_filter' do
      ik = key.new(
          observation_matrix_id: observation_matrix.id,
          project_id: observation_matrix.project_id,
          row_filter: r1.id.to_s + '|' + r2.id.to_s + '|' + r10.id.to_s)
      expect(ik.remaining.count).to eq(3)
      expect(ik.eliminated.count).to eq(7)
    end

    specify 'otu_filter' do
      ik = key.new(
          observation_matrix_id: observation_matrix.id,
          project_id: observation_matrix.project_id,
          otu_filter: otu1.id.to_s + '|' + otu2.id.to_s + '|' + otu3.id.to_s)
      expect(ik.remaining.count).to eq(4)
      expect(ik.eliminated.count).to eq(6)
    end

    specify 'indentified_to_rank: otu' do
      ik =  key.new(
        observation_matrix_id: observation_matrix.id,
        project_id: observation_matrix.project_id,
        identified_to_rank: 'otu')
      expect(ik.remaining.count).to eq(9)
    end

    specify 'indentified_to_rank: species' do
      ik =  key.new(
        observation_matrix_id: observation_matrix.id,
        project_id: observation_matrix.project_id,
        identified_to_rank: 'species')
      expect(ik.remaining.count).to eq(9)
    end

    specify 'indentified_to_rank: genus' do
      ik =  key.new(
        observation_matrix_id: observation_matrix.id,
        project_id: observation_matrix.project_id,
        identified_to_rank: 'genus')
      expect(ik.remaining.count).to eq(5)
    end

    specify 'selected_descriptors 1.1' do
      ik =  key.new(
        observation_matrix_id: observation_matrix.id,
        project_id: observation_matrix.project_id,
        selected_descriptors: descriptor1.id.to_s + ':' + cs1.id.to_s)
      expect(ik.remaining.count).to eq(4)
      expect(ik.eliminated.count).to eq(6)
    end

    specify 'selected_descriptors 1.2' do
      ik =  key.new(
          observation_matrix_id: observation_matrix.id,
          project_id: observation_matrix.project_id,
          selected_descriptors: descriptor1.id.to_s + ':' + cs2.id.to_s)
      expect(ik.remaining.count).to eq(4)
      expect(ik.eliminated.count).to eq(6)
    end

    specify 'selected_descriptors 1.1 & 1.2' do
      ik =  key.new(
        observation_matrix_id: observation_matrix.id,
        project_id: observation_matrix.project_id,
        selected_descriptors: descriptor1.id.to_s + ':' + cs1.id.to_s + '|' + cs2.id.to_s)
      expect(ik.remaining.count).to eq(7)
      expect(ik.eliminated.count).to eq(3)
    end

    specify 'selected_descriptors 1.1 & 1.2 & 2.5' do
      ik =  key.new(
        observation_matrix_id: observation_matrix.id,
        project_id: observation_matrix.project_id,
        selected_descriptors: descriptor1.id.to_s + ':' + cs1.id.to_s + '|' + cs2.id.to_s + '||' + descriptor2.id.to_s + ':' + cs5.id.to_s)
      expect(ik.remaining.count).to eq(3)
      expect(ik.eliminated.count).to eq(7)
    end

    specify 'selected_descriptors 1.1 & 1.2 & 2.5 + error_tolerance = 1' do
      ik =  key.new(
        observation_matrix_id: observation_matrix.id,
        project_id: observation_matrix.project_id,
        selected_descriptors: descriptor1.id.to_s + ':' + cs1.id.to_s + '|' + cs2.id.to_s + '||' + descriptor2.id.to_s + ':' + cs5.id.to_s,
        error_tolerance: 1)
      expect(ik.remaining.count).to eq(7)
      expect(ik.eliminated.count).to eq(3)
    end

    specify 'selected_descriptors 1.1 & 1.2 & 2.5 + error_tolerance = 2' do
      ik =  key.new(
        observation_matrix_id: observation_matrix.id,
        project_id: observation_matrix.project_id,
        selected_descriptors: descriptor1.id.to_s + ':' + cs1.id.to_s + '|' + cs2.id.to_s + '||' + descriptor2.id.to_s + ':' + cs5.id.to_s,
        error_tolerance: 2)
      expect(ik.remaining.count).to eq(10)
      expect(ik.eliminated.count).to eq(0)
    end

    specify 'selected_descriptors 3.8' do
      ik =  key.new(
        observation_matrix_id: observation_matrix.id,
        project_id: observation_matrix.project_id,
        selected_descriptors: descriptor3.id.to_s + ':' + cs8.id.to_s)
      expect(ik.remaining.count).to eq(5)
      expect(ik.eliminated.count).to eq(5)
    end

    specify 'selected_descriptors 3.8 + eliminate_unknown' do
      ik =  key.new(
        observation_matrix_id: observation_matrix.id,
        project_id: observation_matrix.project_id,
        selected_descriptors: descriptor3.id.to_s + ':' + cs8.id.to_s,
        eliminate_unknown: 'true')
      expect(ik.remaining.count).to eq(4)
      expect(ik.eliminated.count).to eq(6)
    end

    specify 'selected_descriptors 5:3' do
      ik =  key.new(
        observation_matrix_id: observation_matrix.id,
        project_id: observation_matrix.project_id,
        selected_descriptors: descriptor5.id.to_s + ':3')
      expect(ik.remaining.count).to eq(6)
      expect(ik.eliminated.count).to eq(4)
    end

    specify 'selected_descriptors 5:2-3' do
      ik =  key.new(
        observation_matrix_id: observation_matrix.id,
        project_id: observation_matrix.project_id,
        selected_descriptors: descriptor5.id.to_s + ':2-3')
      expect(ik.remaining.count).to eq(9)
      expect(ik.eliminated.count).to eq(1)
    end

    specify 'selected_descriptors 5:0.5-2' do
      ik =  key.new(
        observation_matrix_id: observation_matrix.id,
        project_id: observation_matrix.project_id,
        selected_descriptors: descriptor5.id.to_s + ':0.5-2')
      expect(ik.remaining.count).to eq(9)
      expect(ik.eliminated.count).to eq(1)
    end

    specify 'selected_descriptors 5:3-5' do
      ik =  key.new(
        observation_matrix_id: observation_matrix.id,
        project_id: observation_matrix.project_id,
        selected_descriptors: descriptor5.id.to_s + ':3-5')
      expect(ik.remaining.count).to eq(6)
      expect(ik.eliminated.count).to eq(4)
    end

    specify 'selected_descriptors 5:0-7' do
      ik =  key.new(
        observation_matrix_id: observation_matrix.id,
        project_id: observation_matrix.project_id,
        selected_descriptors: descriptor5.id.to_s + ':0-7')
      expect(ik.remaining.count).to eq(10)
      expect(ik.eliminated.count).to eq(0)
    end

    specify 'selected_descriptors 6:2' do
      ik =  key.new(
        observation_matrix_id: observation_matrix.id,
        project_id: observation_matrix.project_id,
        selected_descriptors: descriptor6.id.to_s + ':2')
      expect(ik.remaining.count).to eq(3)
      expect(ik.eliminated.count).to eq(7)
    end

    specify 'selected_descriptors 7:true' do
      ik =  key.new(
        observation_matrix_id: observation_matrix.id,
        project_id: observation_matrix.project_id,
        selected_descriptors: descriptor7.id.to_s + ':true')
      expect(ik.remaining.count).to eq(6)
      expect(ik.eliminated.count).to eq(4)
    end

    specify 'selected_descriptors 7:false' do
      ik =  key.new(
        observation_matrix_id: observation_matrix.id,
        project_id: observation_matrix.project_id,
        selected_descriptors: descriptor7.id.to_s + ':false')
      expect(ik.remaining.count).to eq(4)
      expect(ik.eliminated.count).to eq(6)
    end

    specify 'soft_validate row 1' do
      row = r1.find_or_build_row(r1.row_objects.first)
      row.soft_validate(only_sets: :cannot_be_separated)
      expect(row.soft_validations.messages_on(:base).empty?).to be_truthy
    end

    specify 'soft_validate row 2' do
      otu11 = Otu.create!(name: 'b11')
      r11 = ObservationMatrixRowItem::Single.create!(observation_object: otu11, observation_matrix: observation_matrix)
      row = r11.find_or_build_row(r11.row_objects.first)
      row.soft_validate(only_sets: :cannot_be_separated)
      expect(row.soft_validations.messages_on(:base).count).to eq(1)
    end

  end
end
