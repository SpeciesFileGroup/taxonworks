
json.set!('@context') do
  json.set!('@vocab', "http://www.nexml.org/2009/")
end

json.set!("version", "0.9")
json.set!("base", "http://example.org/")
json.set!( "schemaLocation": "http://www.nexml.org/2009 ../xsd/nexml.xsd")

json.set!(:otus) do
  json.set!('@id', "_otus_" + @observation_matrix.id.to_s)
  json.label 'RootTaxaBlock'
  json.otu do
    json.array! @observation_matrix.observation_matrix_rows do |r|
      json.set!('@type', 'otu')
      json.set!('@id', r.id)
      json.set!('label', object_tag(r.row_object))
    end
  end
end 

json.set!(:char) do

  json.set!('@id', "_chrs_" + @observation_matrix.id.to_s)
  json.label 'RootTaxaBlock'
  json.otus  "_otus_" + @observation_matrix.id.to_s

  json.set!(:format) do 

    # TODO: add unions of states for those matrices that need it
    json.states do
      json.set!('@type', 'states')
      json.set!('@id',  @observation_matrix.id.to_s + '_states')

      json.set!(:states) do
        json.array do
          @observation_matrix.observation_matrix_columns do |c|
            if c.descriptor.type == 'Descriptor::Qualitative'
              json.array! c.descriptor.character_states do |cs|
                json.set!('@id', "#{c.descriptor.id}_states_#{cs.id}")
                json.set!('@label', cs.name)
                json.set!('@symbol', cs.label)
              end
            end
          end
        end
      end
    end

    json.char do
      json.array! @observation_matrix.observation_matrix_columns do |c|
        json.set!('@type', 'char')
        json.set!('@id', c.id)
        json.label c.descriptor.name
        json.states  "#{c.descriptor.id}_states"
      end
    end
  end

end

