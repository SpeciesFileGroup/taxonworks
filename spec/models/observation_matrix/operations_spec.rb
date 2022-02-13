require 'rails_helper'

RSpec.describe ObservationMatrix, type: :model, group: :observation_matrix do

  let!(:om) { FactoryBot.create(:valid_observation_matrix) }

  let!(:row_object1) { FactoryBot.create(:valid_otu, name: 'row1') }
  let!(:row_object2) { FactoryBot.create(:valid_otu, name: 'row2') }
  let!(:row_object3) { FactoryBot.create(:valid_otu, name: 'row3') }
  let!(:row_object4) { FactoryBot.create(:valid_specimen) }
  let!(:row_object5) { FactoryBot.create(:valid_specimen) }

  # Standard format
  let!(:descriptor1) { Descriptor::Qualitative.create!(name: 'descriptor1') }
  let!(:character_state1_1) { CharacterState.create!(descriptor: descriptor1, label: 'a', name: 'start') }
  let!(:character_state1_2) { CharacterState.create!(descriptor: descriptor1, label: 'b', name: 'middle' ) }
  let!(:character_state1_3) { CharacterState.create!(descriptor: descriptor1, label: 'c', name: 'end' ) }

  # Strange state labels
  let!(:descriptor2) { Descriptor::Qualitative.create!(name: 'descriptor2') }
  let!(:character_state2_1) { CharacterState.create!(descriptor: descriptor2, label: 's', name: 'Short' ) }
  let!(:character_state2_2) { CharacterState.create!(descriptor: descriptor2, label: 'MED', name: 'Medium' ) }
  let!(:character_state2_3) { CharacterState.create!(descriptor: descriptor2, label: 'LONG', name: 'Long' ) }

  # Numeric state labels
  let!(:descriptor3) { Descriptor::Qualitative.create!(name: 'descriptor3') }
  let!(:character_state3_1) { CharacterState.create!(descriptor: descriptor3, label: '0', name: 'none' ) }
  let!(:character_state3_2) { CharacterState.create!(descriptor: descriptor3, label: '1', name: 'one' ) }
  let!(:character_state3_3) { CharacterState.create!(descriptor: descriptor3, label: '5', name: 'five' ) }

  let!(:descriptor4) { Descriptor::Continuous.create!(name: 'continuous', default_unit: 'mm') }
  let!(:descriptor5) { Descriptor::PresenceAbsence.create!(name: 'presence absence')  }
  let!(:descriptor6) { Descriptor::Sample.create!(name: 'sample') }


  #    desc1            desc2           descr3             desc4       desc5         desc6
  #    qualitative      qualitative     qualitative        continuous  boolean       sample
  # 1  a {1}            -               0 {2}              20 mm  {3}  -             1 2 n=5 mm {4}
  # 2  b {5}            LONG {6}        1 {7}              40 mm {8}   true {9}      1 cm {10}
  # 3  ab {11 12}       s {13}          0 1 5 {14 15 16}   1 cm {17}   false {18}    0.1 5.22 mm {19}
  # 4  c                MED             1                  0.01 mm     -             -
  # 5  -                s MED           -                  -           true false    0.1 0.3 n=5 m=5 mm

  # row 1
  let!(:o1) { Observation.create!(observation_object: row_object1, descriptor: descriptor1, character_state: character_state1_1) }
  let!(:o2) { Observation.create!(observation_object: row_object1, descriptor: descriptor3, character_state: character_state3_1) }
  let!(:o3) { Observation.create!(observation_object: row_object1, descriptor: descriptor4, continuous_value: 20, continuous_unit: 'mm' ) }
  let!(:o4) { Observation.create!(observation_object: row_object1, descriptor: descriptor6, sample_min: 1, sample_max: 2, sample_n: 5, sample_units: 'mm') }

  # row 2
  let!(:o5) { Observation.create!(observation_object: row_object2, descriptor: descriptor1, character_state: character_state1_2) }
  let!(:o6) { Observation.create!(observation_object: row_object2, descriptor: descriptor2, character_state: character_state2_3) }
  let!(:o7) { Observation.create!(observation_object: row_object2, descriptor: descriptor3, character_state: character_state3_3) }
  let!(:o8) { Observation.create!(observation_object: row_object2, descriptor: descriptor4, continuous_value: 40, continuous_unit: 'mm' ) }
  let!(:o9) { Observation.create!(observation_object: row_object2, descriptor: descriptor6, presence: true ) }
  let!(:o10){ Observation.create!(observation_object: row_object2, descriptor: descriptor6, sample_min: 1, sample_units: 'cm') }

  # row 3
  let!(:o11) { Observation.create!(observation_object: row_object3, descriptor: descriptor1, character_state: character_state1_1) }
  let!(:o12) { Observation.create!(observation_object: row_object3, descriptor: descriptor1, character_state: character_state1_2) }
  let!(:o13) { Observation.create!(observation_object: row_object3, descriptor: descriptor2, character_state: character_state2_1) }
  let!(:o14) { Observation.create!(observation_object: row_object3, descriptor: descriptor3, character_state: character_state3_1) }
  let!(:o15) { Observation.create!(observation_object: row_object3, descriptor: descriptor3, character_state: character_state3_2) }
  let!(:o16) { Observation.create!(observation_object: row_object3, descriptor: descriptor3, character_state: character_state3_3) }
  let!(:o17) { Observation.create!(observation_object: row_object3, descriptor: descriptor4, continuous_value: 1, continuous_unit: 'cm' ) }
  let!(:o18) { Observation.create!(observation_object: row_object3, descriptor: descriptor5, presence: false) }
  let!(:o19) { Observation.create!(observation_object: row_object3, descriptor: descriptor6, sample_min: 0.1, sample_max: 5.22, sample_units: 'mm') }

  # row 4
  let!(:o20) { Observation.create!(observation_object: row_object4, descriptor: descriptor1, character_state: character_state1_2) }
  let!(:o21) { Observation.create!(observation_object: row_object4, descriptor: descriptor2, character_state: character_state2_2) }
  let!(:o22) { Observation.create!(observation_object: row_object4, descriptor: descriptor3, character_state: character_state3_2) }
  let!(:o23) { Observation.create!(observation_object: row_object4, descriptor: descriptor4, continuous_value: 0.01, continuous_unit: 'm' ) }

  # row 5
  let!(:o24) { Observation.create!(observation_object: row_object5, descriptor: descriptor2, character_state: character_state2_1) }
  let!(:o25) { Observation.create!(observation_object: row_object5, descriptor: descriptor2, character_state: character_state2_2) }
  let!(:o26) { Observation.create!(observation_object: row_object5, descriptor: descriptor5, presence: false) }
  let!(:o27) { Observation.create!(observation_object: row_object5, descriptor: descriptor5, presence: true) }
  let!(:o28) { Observation.create!(observation_object: row_object5, descriptor: descriptor6, sample_min: 0.1, sample_max: 0.3, sample_n: 5, sample_median: 5, sample_units: 'mm') }

  # Add rows
  let!(:om_row_item1) { ObservationMatrixRowItem::Single.create!(observation_matrix: om, observation_object: row_object1) }
  let!(:om_row_item2) { ObservationMatrixRowItem::Single.create!(observation_matrix: om, observation_object: row_object2) }
  let!(:om_row_item3) { ObservationMatrixRowItem::Single.create!(observation_matrix: om, observation_object: row_object3) }
  let!(:om_row_item4) { ObservationMatrixRowItem::Single.create!(observation_matrix: om, observation_object: row_object4) }
  let!(:om_row_item5) { ObservationMatrixRowItem::Single.create!(observation_matrix: om, observation_object: row_object5) }

  # Add columns
  let!(:om_column_item1) { ObservationMatrixColumnItem::Single::Descriptor.create!(observation_matrix: om, descriptor: descriptor1) }
  let!(:om_column_item2) { ObservationMatrixColumnItem::Single::Descriptor.create!(observation_matrix: om, descriptor: descriptor2) }
  let!(:om_column_item3) { ObservationMatrixColumnItem::Single::Descriptor.create!(observation_matrix: om, descriptor: descriptor3) }
  let!(:om_column_item4) { ObservationMatrixColumnItem::Single::Descriptor.create!(observation_matrix: om, descriptor: descriptor4) }
  let!(:om_column_item5) { ObservationMatrixColumnItem::Single::Descriptor.create!(observation_matrix: om, descriptor: descriptor5) }
  let!(:om_column_item6) { ObservationMatrixColumnItem::Single::Descriptor.create!(observation_matrix: om, descriptor: descriptor6) }

  specify '#qualitative_descriptors' do
    expect(om.qualitative_descriptors).to contain_exactly(descriptor1, descriptor2, descriptor3)
  end

  specify '#continuous_descriptors' do
    expect(om.continuous_descriptors).to contain_exactly(descriptor4)
  end

  specify '#presence_absence_descriptors' do
    expect(om.presence_absence_descriptors).to contain_exactly(descriptor5)
  end

  specify '#sample_descriptors' do
    expect(om.sample_descriptors).to contain_exactly(descriptor6)
  end

  specify '#cell_count' do
    expect(om.cell_count).to eq(30)
  end

  specify '#is_media_matrix?' do
    expect(om.is_media_matrix?).to eq(false)
  end

  # columns, rows
  context '#observations_in_grid' do
    let(:g) { om.observations_in_grid(row_index: true, column_index: true) }

    specify ':grid 1' do
      expect(g[:grid][0][0].map(&:id)).to contain_exactly(o1.id)
    end

    specify ':grid 2' do
      expect(g[:grid][1][0]).to contain_exactly()
    end

    specify ':grid 3' do
      expect(g[:grid][2][0].map(&:id)).to contain_exactly(o2.id)
    end

    specify ':grid 4' do
      expect(g[:grid][5][0].map(&:id)).to contain_exactly(o4.id)
    end

    specify ':grid 5' do
      expect(g[:grid][2][2].map(&:id)).to contain_exactly(o14.id, o15.id, o16.id)
    end

    specify ':rows 1' do
      expect(g[:rows]).to contain_exactly(
        row_object1.class.base_class.name + row_object1.to_param,
        row_object2.class.base_class.name + row_object2.to_param,
        row_object3.class.base_class.name + row_object3.to_param,
        row_object4.class.base_class.name + row_object4.to_param,
        row_object5.class.base_class.name + row_object5.to_param,
      )
    end

    specify ':cols 1' do
      expect(g[:cols]).to contain_exactly(
        descriptor1.id,
        descriptor2.id,
        descriptor3.id,
        descriptor4.id,
        descriptor5.id,
        descriptor6.id,
      )
    end
  end

  specify '#polymorphic_cells_for_descriptor 1' do
    expect( om.polymorphic_cells_for_descriptor(descriptor_id: descriptor1.id) ).to eq({0 => [character_state1_1.id, character_state1_2.id] })
  end

  specify '#observations_hash' do
    expect(om.observations_hash[descriptor1.id][row_object1.class.base_class.name +  row_object1.to_param].map(&:id)).to contain_exactly(o1.id)
  end
end
