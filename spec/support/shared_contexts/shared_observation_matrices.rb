# Useage:
#    spec/lib/tools/interactive_key_spec.rb
#    spec/lib/tools/description/from_observation_matrix_spec.rb
shared_context 'complex observation matrix' do

    let(:observation_matrix) {  ObservationMatrix.create!(name: 'Matrix') }

    let(:genus1) { FactoryBot.create(:relationship_genus, name: 'Aus') }
    let(:genus2) {  FactoryBot.create(:relationship_genus, name: 'Bus') }
    let(:genus3) {  FactoryBot.create(:relationship_genus, name: 'Cus') }

    let(:species1) { FactoryBot.create(:iczn_species, name: 'aa', parent: genus1) }
    let(:species2) { FactoryBot.create(:iczn_species, name: 'aaa', parent: genus1) }
    let(:species3) { FactoryBot.create(:iczn_species, name: 'aaaa', parent: genus1) }
    let(:species4) { FactoryBot.create(:iczn_species, name: 'bb', parent: genus2) }
    let(:species5) { FactoryBot.create(:iczn_species, name: 'bbb', parent: genus2) }
    let(:species6) { FactoryBot.create(:iczn_species, name: 'bbbb', parent: genus2) }

    let(:otu1) { Otu.create!(taxon_name: species1) }
    let(:otu2) { Otu.create!(taxon_name: species2) }
    let(:otu3) { Otu.create!(taxon_name: species3) }
    let(:otu4) { Otu.create!(taxon_name: species4) }
    let(:otu5) { Otu.create!(taxon_name: species5) }
    let(:otu6) { Otu.create!(taxon_name: species6) }
    let(:otu7) { Otu.create!(taxon_name: genus3) }
    let(:otu8) { Otu.create!(name: 'a8') }
    let(:otu9) { Otu.create!(name: 'b9') }

    let(:collection_object) { Specimen.create! }
    let!(:taxon_determination) { TaxonDetermination.create(otu: otu1, biological_collection_object: collection_object) }

    let(:descriptor1) { Descriptor::Qualitative.create!(name: 'Descriptor 1') }
    let(:cs1) { CharacterState.create!(name: 'State1', label: '0', descriptor: descriptor1) }
    let(:cs2) { CharacterState.create!(name: 'State2', label: '1', descriptor: descriptor1) }
    let(:cs3) { CharacterState.create!(name: 'State3', label: '2', descriptor: descriptor1) }

    let(:descriptor2) { Descriptor::Qualitative.create!(name: 'Descriptor 2') }
    let(:cs4) { CharacterState.create!(name: 'State4', label: '0', descriptor: descriptor2)}
    let(:cs5) { CharacterState.create!(name: 'State5', label: '1', descriptor: descriptor2)}
    let(:cs6) { CharacterState.create!(name: 'State6', label: '2', descriptor: descriptor2)}

    let(:descriptor3) { Descriptor::Qualitative.create!(name: 'Descriptor 3') }
    let(:cs7) { CharacterState.create!(name: 'State7', label: '0', descriptor: descriptor3) }
    let(:cs8) { CharacterState.create!(name: 'State8', label: '1', descriptor: descriptor3) }

    let(:descriptor4) { Descriptor::Qualitative.create!(name: 'Descriptor 4') }
    let(:cs9) { CharacterState.create!(name: 'State9', label: '0', descriptor: descriptor4) }
    let(:cs10) { CharacterState.create!(name: 'State10', label: '1', descriptor: descriptor4) }

    let(:descriptor5) { Descriptor::Sample.create!(name: 'Descriptor 5') }
    let(:descriptor6) { Descriptor::Continuous.create!(name: 'Descriptor 6') }
    let(:descriptor7) { Descriptor::PresenceAbsence.create!(name: 'Descriptor 7') }

    let!(:r1) { ObservationMatrixRowItem::Single.create!(observation_object: otu1, observation_matrix: observation_matrix) }
    let!(:r2) { ObservationMatrixRowItem::Single.create!(observation_object: otu2, observation_matrix: observation_matrix) }
    let!(:r3) { ObservationMatrixRowItem::Single.create!(observation_object: otu3, observation_matrix: observation_matrix) }
    let!(:r4) { ObservationMatrixRowItem::Single.create!(observation_object: otu4, observation_matrix: observation_matrix) }
    let!(:r5) { ObservationMatrixRowItem::Single.create!(observation_object: otu5, observation_matrix: observation_matrix) }
    let!(:r6) { ObservationMatrixRowItem::Single.create!(observation_object: otu6, observation_matrix: observation_matrix) }
    let!(:r7) { ObservationMatrixRowItem::Single.create!(observation_object: otu7, observation_matrix: observation_matrix) }
    let!(:r8) { ObservationMatrixRowItem::Single.create!(observation_object: otu8, observation_matrix: observation_matrix) }
    let!(:r9) { ObservationMatrixRowItem::Single.create!(observation_object: otu9, observation_matrix: observation_matrix) }
    let!(:r10) { ObservationMatrixRowItem::Single.create!(observation_object: collection_object, observation_matrix: observation_matrix) }

    let!(:c1) { ObservationMatrixColumnItem::Single::Descriptor.create!(descriptor: descriptor1, observation_matrix: observation_matrix) }
    let!(:c2) { ObservationMatrixColumnItem::Single::Descriptor.create!(descriptor: descriptor2, observation_matrix: observation_matrix) }
    let!(:c3) { ObservationMatrixColumnItem::Single::Descriptor.create!(descriptor: descriptor3, observation_matrix: observation_matrix) }
    let!(:c4) { ObservationMatrixColumnItem::Single::Descriptor.create!(descriptor: descriptor4, observation_matrix: observation_matrix) }
    let!(:c5) { ObservationMatrixColumnItem::Single::Descriptor.create!(descriptor: descriptor5, observation_matrix: observation_matrix) }
    let!(:c6) { ObservationMatrixColumnItem::Single::Descriptor.create!(descriptor: descriptor6, observation_matrix: observation_matrix) }
    let!(:c7) { ObservationMatrixColumnItem::Single::Descriptor.create!(descriptor: descriptor7, observation_matrix: observation_matrix) }

    # build the observations

    # 01  2   0   1   1-2   1 true
    # 1   1   1   0   2-3   2 false
    # 2   0   0   1   1-3   3 true
    # 0   2   -   -   3-4   4 false
    # 1   1   0   1   2-4   1 true
    # 2   0   1   0   1-2   2 false
    # 0   2   0   1   1-3   3 true
    # 1   1   1   0   2-3   4 false
    # 2   0   0   1   1-2   1 true
    # 0   2   1   0   1     2 #true

    let!(:o1 ) {Observation::Qualitative.create!(descriptor: descriptor1, observation_object: otu1, character_state: cs1) }
    let!(:o1a) {Observation::Qualitative.create!(descriptor: descriptor1, observation_object: otu1, character_state: cs2) }
    let!(:o2 ) {Observation::Qualitative.create!(descriptor: descriptor1, observation_object: otu2, character_state: cs2) }
    let!(:o3 ) {Observation::Qualitative.create!(descriptor: descriptor1, observation_object: otu3, character_state: cs3) }
    let!(:o4 ) {Observation::Qualitative.create!(descriptor: descriptor1, observation_object: otu4, character_state: cs1) }
    let!(:o5 ) {Observation::Qualitative.create!(descriptor: descriptor1, observation_object: otu5, character_state: cs2) }
    let!(:o6 ) {Observation::Qualitative.create!(descriptor: descriptor1, observation_object: otu6, character_state: cs3) }
    let!(:o7 ) {Observation::Qualitative.create!(descriptor: descriptor1, observation_object: otu7, character_state: cs1) }
    let!(:o8 ) {Observation::Qualitative.create!(descriptor: descriptor1, observation_object: otu8, character_state: cs2) }
    let!(:o9 ) {Observation::Qualitative.create!(descriptor: descriptor1, observation_object: otu9, character_state: cs3) }
    let!(:o10) {Observation::Qualitative.create!(descriptor: descriptor1, observation_object: collection_object, character_state: cs1) }

    let!(:o11) {Observation::Qualitative.create!(descriptor: descriptor2, observation_object: otu1, character_state: cs6) }
    let!(:o12) {Observation::Qualitative.create!(descriptor: descriptor2, observation_object: otu2, character_state: cs5) }
    let!(:o13) {Observation::Qualitative.create!(descriptor: descriptor2, observation_object: otu3, character_state: cs4) }
    let!(:o14) {Observation::Qualitative.create!(descriptor: descriptor2, observation_object: otu4, character_state: cs6) }
    let!(:o15) {Observation::Qualitative.create!(descriptor: descriptor2, observation_object: otu5, character_state: cs5) }
    let!(:o16) {Observation::Qualitative.create!(descriptor: descriptor2, observation_object: otu6, character_state: cs4) }
    let!(:o17) {Observation::Qualitative.create!(descriptor: descriptor2, observation_object: otu7, character_state: cs6) }
    let!(:o18) {Observation::Qualitative.create!(descriptor: descriptor2, observation_object: otu8, character_state: cs5) }
    let!(:o19) {Observation::Qualitative.create!(descriptor: descriptor2, observation_object: otu9, character_state: cs4) }
    let!(:o20) {Observation::Qualitative.create!(descriptor: descriptor2, observation_object: collection_object, character_state: cs6) }

    let!(:o21) {Observation::Qualitative.create!(descriptor: descriptor3, observation_object: otu1, character_state: cs7) }
    let!(:o22) {Observation::Qualitative.create!(descriptor: descriptor3, observation_object: otu2, character_state: cs8) }
    let!(:o23) {Observation::Qualitative.create!(descriptor: descriptor3, observation_object: otu3, character_state: cs7) }
    # no OTU 4
    let!(:o24) {Observation::Qualitative.create!(descriptor: descriptor3, observation_object: otu5, character_state: cs7) }
    let!(:o25) {Observation::Qualitative.create!(descriptor: descriptor3, observation_object: otu6, character_state: cs8) }
    let!(:o26) {Observation::Qualitative.create!(descriptor: descriptor3, observation_object: otu7, character_state: cs7) }
    let!(:o27) {Observation::Qualitative.create!(descriptor: descriptor3, observation_object: otu8, character_state: cs8) }
    let!(:o28) {Observation::Qualitative.create!(descriptor: descriptor3, observation_object: otu9, character_state: cs7) }
    let!(:o29) {Observation::Qualitative.create!(descriptor: descriptor3, observation_object: collection_object, character_state: cs8) }

    let!(:o30) {Observation::Qualitative.create!(descriptor: descriptor4, observation_object: otu1, character_state: cs10) }
    let!(:o31) {Observation::Qualitative.create!(descriptor: descriptor4, observation_object: otu2, character_state: cs9) }
    let!(:o32) {Observation::Qualitative.create!(descriptor: descriptor4, observation_object: otu3, character_state: cs10) }
    # no OTU 4
    let!(:o33) {Observation::Qualitative.create!(descriptor: descriptor4, observation_object: otu5, character_state: cs10) }
    let!(:o34) {Observation::Qualitative.create!(descriptor: descriptor4, observation_object: otu6, character_state: cs9) }
    let!(:o35) {Observation::Qualitative.create!(descriptor: descriptor4, observation_object: otu7, character_state: cs10) }
    let!(:o36) {Observation::Qualitative.create!(descriptor: descriptor4, observation_object: otu8, character_state: cs9) }
    let!(:o37) {Observation::Qualitative.create!(descriptor: descriptor4, observation_object: otu9, character_state: cs10) }
    let!(:o38) {Observation::Qualitative.create!(descriptor: descriptor4, observation_object: collection_object, character_state: cs9) }

    let!(:o39) {Observation::Sample.create!(descriptor: descriptor5, observation_object: otu1, sample_min: 1, sample_max: 2) }
    let!(:o40) {Observation::Sample.create!(descriptor: descriptor5, observation_object: otu2, sample_min: 2, sample_max: 3) }
    let!(:o41) {Observation::Sample.create!(descriptor: descriptor5, observation_object: otu3, sample_min: 1, sample_max: 3) }
    let!(:o42) {Observation::Sample.create!(descriptor: descriptor5, observation_object: otu4, sample_min: 3, sample_max: 4) }
    let!(:o43) {Observation::Sample.create!(descriptor: descriptor5, observation_object: otu5, sample_min: 2, sample_max: 4) }
    let!(:o44) {Observation::Sample.create!(descriptor: descriptor5, observation_object: otu6, sample_min: 1, sample_max: 2) }
    let!(:o45) {Observation::Sample.create!(descriptor: descriptor5, observation_object: otu7, sample_min: 1, sample_max: 3) }
    let!(:o46) {Observation::Sample.create!(descriptor: descriptor5, observation_object: otu8, sample_min: 2, sample_max: 3) }
    let!(:o47) {Observation::Sample.create!(descriptor: descriptor5, observation_object: otu9, sample_min: 1, sample_max: 2) }
    let!(:o48) {Observation::Sample.create!(descriptor: descriptor5, observation_object: collection_object, sample_min: 1) }

    let!(:o49) {Observation::Continuous.create!(descriptor: descriptor6, observation_object: otu1, continuous_value: 1) }
    let!(:o50) {Observation::Continuous.create!(descriptor: descriptor6, observation_object: otu2, continuous_value: 2) }
    let!(:o51) {Observation::Continuous.create!(descriptor: descriptor6, observation_object: otu3, continuous_value: 3) }
    let!(:o52) {Observation::Continuous.create!(descriptor: descriptor6, observation_object: otu4, continuous_value: 4) }
    let!(:o53) {Observation::Continuous.create!(descriptor: descriptor6, observation_object: otu5, continuous_value: 1) }
    let!(:o54) {Observation::Continuous.create!(descriptor: descriptor6, observation_object: otu6, continuous_value: 2) }
    let!(:o55) {Observation::Continuous.create!(descriptor: descriptor6, observation_object: otu7, continuous_value: 3) }
    let!(:o56) {Observation::Continuous.create!(descriptor: descriptor6, observation_object: otu8, continuous_value: 4) }
    let!(:o57) {Observation::Continuous.create!(descriptor: descriptor6, observation_object: otu9, continuous_value: 1) }
    let!(:o58) {Observation::Continuous.create!(descriptor: descriptor6, observation_object: collection_object, continuous_value: 2) }

    let!(:o59) {Observation::PresenceAbsence.create!(descriptor: descriptor7, observation_object: otu1, presence: true) }
    let!(:o60) {Observation::PresenceAbsence.create!(descriptor: descriptor7, observation_object: otu2, presence: false) }
    let!(:o61) {Observation::PresenceAbsence.create!(descriptor: descriptor7, observation_object: otu3, presence: true) }
    let!(:o62) {Observation::PresenceAbsence.create!(descriptor: descriptor7, observation_object: otu4, presence: false) }
    let!(:o63) {Observation::PresenceAbsence.create!(descriptor: descriptor7, observation_object: otu5, presence: true) }
    let!(:o64) {Observation::PresenceAbsence.create!(descriptor: descriptor7, observation_object: otu6, presence: false) }
    let!(:o65) {Observation::PresenceAbsence.create!(descriptor: descriptor7, observation_object: otu7, presence: true) }
    let!(:o66) {Observation::PresenceAbsence.create!(descriptor: descriptor7, observation_object: otu8, presence: false) }
    let!(:o67) {Observation::PresenceAbsence.create!(descriptor: descriptor7, observation_object: otu9, presence: true) }
    let!(:o68) {Observation::PresenceAbsence.create!(descriptor: descriptor7, observation_object: collection_object, presence: true) }

end

