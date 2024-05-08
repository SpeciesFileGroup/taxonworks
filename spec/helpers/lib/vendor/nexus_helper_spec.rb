require 'rails_helper'

describe Lib::Vendor::NexusHelper, type: :helper do
  let!(:doc) {
    Document.create!(
      document_file: Rack::Test::UploadedFile.new(
        (Rails.root + 'spec/files/nexus/small_with_species.nex'),
        'text/plain'
      ))
  }
  let!(:nex_parsed) { Vendor::NexusParser.document_to_nexus(doc) }
  let!(:m) { FactoryBot.create(:valid_observation_matrix) }
  let(:otu_names) { ['Agonum', 'Carabus goryi'] }
  let(:descriptor_names) { ['head', 'foot', 'ribs'] }

  #CHARSTATELABELS
	#	1 head /  square pointy, 2 foot / toey heely, 3 ribs / spherical monodromic exact ;
	#MATRIX
	# Agonum              1?2
	# 'Carabus goryi'     -(0 1)1
  #;

  context 'with default options' do
    before(:each) do
      populate_matrix_with_nexus(
        doc.id,
        nex_parsed,
        m,
        {}
      )
    end

    specify 'default options creates otus' do
      expect(Otu.all.size).to be(2)
    end

    specify 'default options creates descriptors' do
      expect(Descriptor.all.size).to be(3)
    end

    specify 'default options creates matrix rows' do
      expect(ObservationMatrixRow.all.size).to be(2)
    end

    specify 'default options creates matrix columns' do
      expect(ObservationMatrixColumn.all.size).to be(3)
    end

    specify 'default options creates character states' do
      expect(CharacterState.all.size).to be(8)
    end

    specify 'created otus have the correct names' do
      # Note this is testing order as well.
      expect(
        m.observation_matrix_rows.map { |r| r.observation_object.name }
      ).to eq(otu_names)
    end

    specify 'created descriptors have the correct names' do
      # Note this is testing order as well.
      expect(
        m.observation_matrix_columns.map { |c| c.descriptor.name }
      ).to eq(descriptor_names)
    end

    specify 'creates observations' do
      expect(Observation.all.size).to be(6)
    end

    specify 'empty states are empty' do
      g = m.observations_in_grid[:grid]
      expect(g[1][0].size).to be(0)
    end

    specify 'gap states are imported' do
      g = m.observations_in_grid[:grid]
      expect(g[0][1][0].character_state.label).to eq('-')
      expect(g[0][1][0].character_state.name).to eq('gap')
    end

    specify 'multistate observations are imported to multistates' do
      g = m.observations_in_grid[:grid]
      expect(g[1][1].size).to eq(2)
    end

    specify 'observations are mapped to correct otus' do
      # Note this is testing order as well.
      g = m.observations_in_grid[:grid]
      g.each { |c|
        c.each_with_index { |r, i|
          r.each { |o|
            expect(o.observation_object.name).to eq(otu_names[i])
          }
        }
      }
    end

    specify 'observations are mapped to correct descriptors' do
      # Note this is testing order as well.
      g = m.observations_in_grid[:grid]
      g.each_with_index { |c, i|
        c.each { |r|
          r.each { |o|
            expect(o.descriptor.name).to eq(descriptor_names[i])
          }
        }
      }
    end

    specify 'observations are mapped to correct labels' do
      # Note this is testing order as well.
      g = m.observations_in_grid[:grid]
      expect(g[0][0][0].character_state.label).to eq('1')
      expect(g[0][1][0].character_state.label).to eq('-')
      # Multi-observations in g are unordered:
      expect(g[1][1].map{ |o| o.character_state.label }.to_set).to eq(Set['0', '1'])
      expect(g[2][0][0].character_state.label).to eq('2')
      expect(g[2][1][0].character_state.label).to eq('1')
    end

    specify 'observations are mapped to correct names' do
      # Note this is testing order as well.
      g = m.observations_in_grid[:grid]
      expect(g[0][0][0].character_state.name).to eq('pointy')
      expect(g[0][1][0].character_state.name).to eq('gap')
      # Multi-observations in g are unordered:
      expect(g[1][1].map{ |o| o.character_state.name }.to_set).to eq(Set['toey', 'heely'])
      expect(g[2][0][0].character_state.name).to eq('exact')
      expect(g[2][1][0].character_state.name).to eq('monodromic')
    end

    specify 'unused character states exist and have correct names and labels' do
      head_d = Descriptor.find_by(name: 'head')
      expect(CharacterState.where(
        name: 'square', label: '0', descriptor: head_d).size).to eq(1)

      ribs_d = Descriptor.find_by(name: 'ribs')
      expect(CharacterState.where(
        name: 'spherical', label: '0', descriptor: ribs_d).size).to eq(1)
    end
  end

  context 'with otu name matching option' do
    let!(:otu) { FactoryBot.create(:valid_otu, name: 'Agonum') }
    before(:each) {
      populate_matrix_with_nexus(
        doc.id,
        nex_parsed,
        m,
        { match_otu_to_name: true }
      )
    }

    specify 'no extra otus are created' do
      expect(Otu.all.size).to be(2)
    end

    specify 'matched row observations use the matched otu' do
      r = ObservationMatrixRow.find_by(observation_object: otu)
      r.observations.each { |o|
        expect(o.observation_object_id).to eq(otu.id)
      }
    end
  end

  context 'with otu taxon matching option' do
    let!(:otu) { FactoryBot.create(:valid_otu, name: nil,
      taxon_name: FactoryBot.create(:iczn_genus, name: 'Agonum'))
    }
    before(:each) {
      populate_matrix_with_nexus(
        doc.id,
        nex_parsed,
        m,
        { match_otu_to_taxonomy_name: true }
      )
    }

    specify 'no extra otus are created' do
      expect(Otu.all.size).to be(2)
    end

    specify 'matched row observations use the taxon-matched otu' do
      r = ObservationMatrixRow.find_by(observation_object: otu)
      r.observations.each { |o|
        expect(o.observation_object_id).to eq(otu.id)
      }
    end
  end

  context 'with otu taxon and otu name matching options' do
    let!(:otu_t) { FactoryBot.create(:valid_otu, name: nil,
      taxon_name: FactoryBot.create(:iczn_genus, name: 'Agonum'))
    }
    let!(:otu_n) { FactoryBot.create(:valid_otu, name: 'Carabus goryi') }
    before(:each) {
      populate_matrix_with_nexus(
        doc.id,
        nex_parsed,
        m,
        {
          match_otu_to_name: true,
          match_otu_to_taxonomy_name: true
        }
      )
    }

    specify 'no extra otus are created' do
      expect(Otu.all.size).to be(2)
    end

    specify 'matched row observations use the matched otu' do
      r = ObservationMatrixRow.find_by(observation_object: otu_t)
      r.observations.each { |o|
        expect(o.observation_object_id).to eq(otu_t.id)
      }

      r = ObservationMatrixRow.find_by(observation_object: otu_n)
      r.observations.each { |o|
        expect(o.observation_object_id).to eq(otu_n.id)
      }
    end
  end

  context 'with descriptor matching option' do
    let!(:d) { FactoryBot.create(:valid_descriptor_qualitative, name: 'head') }
    before(:each) {
      # Descriptors only match if character states match as well, so create
      # those.
      FactoryBot.create(:valid_character_state, descriptor: d,
        name: 'square', label: '0')
      FactoryBot.create(:valid_character_state, descriptor: d,
        name: 'pointy', label: '1')
      FactoryBot.create(:valid_character_state, descriptor: d,
        name: 'gap', label: '-')

      populate_matrix_with_nexus(
        doc.id,
        nex_parsed,
        m,
        { match_character_to_name: true }
      )
    }

    specify 'no extra descriptors are created' do
      expect(Descriptor.all.size).to eq(3)
    end

    specify 'matched column observations use the matched descriptor' do
      c = ObservationMatrixColumn.find_by(descriptor: d)
      c.observations.each { |o|
        expect(o.descriptor_id).to eq(d.id)
      }
    end
  end

  context 'Matching both otus and descriptors' do
    let!(:d) { FactoryBot.create(:valid_descriptor_qualitative, name: 'head') }
    let!(:otu) { FactoryBot.create(:valid_otu, name: 'Agonum') }
    before(:each) {
      # Descriptors only match if character states match as well, so create
      # those.
      FactoryBot.create(:valid_character_state, descriptor: d,
        name: 'square', label: '0')
      FactoryBot.create(:valid_character_state, descriptor: d,
        name: 'pointy', label: '1')
      FactoryBot.create(:valid_character_state, descriptor: d,
        name: 'gap', label: '-')
    }

    specify 'Matched existing observations get merged with newly created ones' do
      Observation::Qualitative.create!(
        observation_object: otu, descriptor: d,
        character_state: CharacterState.find_by(name: 'square'))

      # Observation 00 of nex_parsed is the just created Observation with
      # character state name 'pointy' instead of 'square'.
      populate_matrix_with_nexus(
        doc.id,
        nex_parsed,
        m,
        {
          match_character_to_name: true,
          match_otu_to_name: true
        }
      )

      g = m.observations_in_grid[:grid]
      expect(g[0][0].map { |o| o.character_state.name }).to eq(['square', 'pointy'])
    end
  end

  context 'Adding citations' do
    let!(:source) { FactoryBot.create(:valid_source) }

    specify 'cite new otus option only applies to new otus' do
      otu = FactoryBot.create(:valid_otu, name: 'Agonum')
      populate_matrix_with_nexus(
        doc.id,
        nex_parsed,
        m,
        {
          match_otu_to_name: true,
          cite_otus: true,
          citation: {
            source_id: source.id
          }
        }
      )

      expect(Citation.all.size).to eq(1)
      expect(Citation.first.citation_object_id).not_to eq(otu.id)
    end

    specify 'cite new descriptors option only applies to new descriptors' do
      d = FactoryBot.create(:valid_descriptor_qualitative, name: 'head')
      # Descriptors only match if character states match as well, so create
      # those.
      FactoryBot.create(:valid_character_state, descriptor: d,
        name: 'square', label: '0')
      FactoryBot.create(:valid_character_state, descriptor: d,
        name: 'pointy', label: '1')
      FactoryBot.create(:valid_character_state, descriptor: d,
        name: 'gap', label: '-')

      populate_matrix_with_nexus(
        doc.id,
        nex_parsed,
        m,
        {
          match_character_to_name: true,
          cite_descriptors: true,
          citation: {
            source_id: source.id
          }
        }
      )

      expect(Citation.all.size).to eq(2)
      expect(Citation.all.pluck(:citation_object_type).uniq).to eq(['Descriptor'])
      expect(Citation.all.pluck(:citation_object_id)).not_to include(d.id)
    end

    specify 'with cite observations option' do
      # TODO: do we need to test that only new observations get cited? Non-new
      # would require a matching descriptor and otu, which I'm not sure we
      # should support.
      populate_matrix_with_nexus(
        doc.id,
        nex_parsed,
        m,
        {
          cite_observations: true,
          citation: {
            source_id: source.id
          }
        }
      )

      expect(Citation.all.size).to eq(6)
      expect(Citation.all.pluck(:citation_object_type).uniq).to eq(['Observation'])
    end

    specify 'with cite matrix option' do
      populate_matrix_with_nexus(
        doc.id,
        nex_parsed,
        m,
        {
          cite_matrix: true,
          citation: {
            source_id: source.id
          }
        }
      )

      expect(Citation.all.size).to eq(1)
      expect(Citation.all.pluck(:citation_object_type).uniq).to eq(['ObservationMatrix'])
    end
  end
end
