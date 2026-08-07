
# rake db:seed 
#
raise 'not so fast' if Rails.env == 'production'

unless $matrix_seed_ran ||= false
  $matrix_seed_ran = true

  user_id = ENV['user_id'] || Current.user_id
  project_id = ENV['project_id'] || Current.project_id

  raise 'provide project_id=123' if project_id.blank?
  raise 'provide user_id=123' if user_id.blank?

  Current.user_id = user_id
  Current.project_id = project_id

  begin
    ApplicationRecord.transaction do
      n = "Seeded matrix #{Time.now.strftime("%h %d - %H:%M:%S")}"
      m = ObservationMatrix.create(name: n)

      d1 = Descriptor::Qualitative.create(name: 'Hair color')
      d2 = Descriptor::Qualitative.create(name: 'Head size')
      d3 = Descriptor::Qualitative.create(name: 'Foot smell')
      d4 = Descriptor::Continuous.create(name: 'Tooth count')
      d5 = Descriptor::Sample.create(name: 'Average speed')

      r1 = Otu.create(name: 'Big turtle')
      r2 = Otu.create(name: 'Little mouse')
      r3 = Otu.create(name: 'Titanosaurus')
      r4 = Specimen.create
      r5 = Lot.create(total: 42)

      cs1 = CharacterState.create(descriptor: d1, name: 'blue', label: '0')
      cs2 = CharacterState.create(descriptor: d1, name: 'purple', label: '1')

      cs3 = CharacterState.create(descriptor: d2, name: 'teeny tiny', label: 'a')
      cs4 = CharacterState.create(descriptor: d2, name: 'medium', label: 'b')
      cs5 = CharacterState.create(descriptor: d2, name: 'ginormous', label: 'c')

      cs6 = CharacterState.create(descriptor: d3, name: 'like talcum powder', label: '0')
      cs7 = CharacterState.create(descriptor: d3, name: 'ode de swamp', label: '1')
      cs8 = CharacterState.create(descriptor: d3, name: 'green cheese', label: '2')

      # row 1
      o1 = Observation::Qualitative.create(observation_object: r1, descriptor: d1, character_state: cs1)
      o2 = Observation::Qualitative.create(observation_object: r1, descriptor: d2, character_state: cs3)
      o3 = Observation::Qualitative.create(observation_object: r1, descriptor: d3, character_state: cs7)
      o4 = Observation::Continuous.create(observation_object: r1, continuous_value: 9)
      o5 = Observation::Continuous.create(observation_object: r1, sample_min: 1, sample_max: 3)

      # row 2
      o6 = Observation::Qualitative.create(observation_object: r2, descriptor: d1, character_state: cs2)
      o7 = Observation::Qualitative.create(observation_object: r2, descriptor: d2, character_state: cs4)
      o8 = Observation::Qualitative.create(observation_object: r2, descriptor: d3, character_state: cs7)
      o9 = Observation::Continuous.create(observation_object: r2, continuous_value: 8)
      o10 = Observation::Continuous.create(observation_object: r2, sample_min: 1)

      # row 3
      o11 = Observation::Qualitative.create(observation_object: r3, descriptor: d1, character_state: cs2)
      o12 = Observation::Qualitative.create(observation_object: r3, descriptor: d2, character_state: cs4)
      o13 = Observation::Qualitative.create(observation_object: r3, descriptor: d3, character_state: cs8)
      o14 = Observation::Continuous.create(observation_object: r3, continuous_value: 2)
      o15 = Observation::Continuous.create(observation_object: r3, sample_min: 9)

      # row 4
      o11 = Observation::Qualitative.create(observation_object: r4, descriptor: d1, character_state: cs2)
      o12 = Observation::Qualitative.create(observation_object: r4, descriptor: d2, character_state: cs4)
      o13 = Observation::Qualitative.create(observation_object: r4, descriptor: d3, character_state: cs8)
      o14 = Observation::Continuous.create(observation_object: r4, continuous_value: 2)
      o15 = Observation::Continuous.create(observation_object: r4, sample_min: 9)

      # row 5
      # is empty

      [d1, d2, d3, d4, d5].each do |d|
        m.observation_matrix_column_items << ObservationMatrixColumnItem::Single::Descriptor.new(descriptor: d)
      end

      [r1, r2, r3].each do |r|
        m.observation_matrix_row_items << ObservationMatrixRowItem::Single.new(observation_object: r)
      end

      [r4, r5].each do |r|
        m.observation_matrix_row_items << ObservationMatrixRowItem::Single.new(observation_object: r)
      end

      puts Rainbow("in Project #{Current.project_id}").purple
      puts Rainbow("Built matrix with id #{m.id}, '#{n}'.").blue
      puts Rainbow("Built otus with ids #{[r1, r2, r3].collect{|z| z.id}.join(',')}.").blue
      puts Rainbow("Built collection objects with ids #{[r4, r5].collect{|z| z.id}.join(',')}.").blue
      puts Rainbow("Built descriptors with ids #{[d1, d2, d3, d4, d5].collect{|z| z.id}.join(',')}.").blue
    end
  rescue => e
    puts Rainbow("Failed: #{e}").red
  end
end