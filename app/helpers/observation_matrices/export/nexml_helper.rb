module ObservationMatrices::Export::NexmlHelper

  def nexml_descriptors(options = {})
    opt = {:target => ''}.merge!(options)
    xml = Builder::XmlMarkup.new(:target => opt[:target])
    m = opt[:observation_matrix]

    # multistate characters
    xml.characters(
      id: "multistate_character_block_#{m.id}",
      otus: "otu_block_#{m.id}", 
      'xsi:type' => 'nex:StandardCells', 
      label:  "Multistate characters for matrix #{m.name}") do

        xml.format do
          m.qualitative_descriptors.each do |c|
            # uncertain_cells = {}

            xml.states(id: "states_for_chr_#{c.id}") do
              c.character_states.each_with_index do |cs,i|
                xml.state(id: "cs#{cs.id}", label: cs.name, symbol: "#{i}") 
              end

              # add a missing state for each character regardless of whether we use it or not
              xml.state(id: "missing#{c.id}", symbol: c.character_states.size, label: "?")

              # poll the matrix for polymorphic/uncertain states
              uncertain = m.polymorphic_cells_for_chr(descriptor_id: c.id, symbol_start: c.character_states.size + 1)

              uncertain.keys.each do |pc|
                xml.uncertain_state_set(id: "cs#{c.id}unc_#{uncertain[pc].sort.join}", symbol: pc) do |uss|
                  uncertain[pc].collect{|m| xml.member(state: "cs#{m}") }
                end
              end

              # uncertain_cells[c.id] = uncertain
            end # end states block
          end  # end character loop for multistate states 

          # Why each with index
          m.qualitative_descriptors.load.collect{|c| xml.char(id: "c#{c.id}", states: "states_for_chr_#{c.id}", label: c.name)}
        end # end format

        include_multistate_matrix(opt.merge(descriptors: m.qualitative_descriptors)) if opt[:include_matrix] 
      end # end characters

      d = m.continuous_descriptors.load
      # continuous characters
      xml.characters(
        id: "continuous_character_block_#{m.id}",
        otus: "otu_block_#{m.id}",
        'xsi:type' => 'nex:ContinuousCells',
        label: "Continuous characters for matrix #{m.name}") do
          xml.format do
            d.collect{|c| xml.char(id: "c#{c.id}", label: c.name)}
          end # end format

          include_continuous_matrix(opt.merge(descriptors: d)) if opt[:include_matrix] 
        end # end multistate characters
        opt[:target]
  end


  def include_multistate_matrix(options = {})
    opt = {target: '', descriptors: []}.merge!(options)
    xml = Builder::XmlMarkup.new(target: opt[:target])

    m = opt[:observation_matrix]

    # the matrix 
    cells = m.codings_in_grid({})[:grid]

    p = m.observation_matrix_columns.order(:position).collect{|i| i.descriptor_id }
    q = m.observation_matrix_rows.order(:position).collect{|i| i.row_object.to_global_id }

    xml.matrix do |mx|
      m.observation_matrix_rows.each do |r|
        xml.row(id: "multistate_row#{r.id}", otu: "otu_#{r.id}") do |row| # use row_id to uniquel identify the row ##  Otu#id to uniquely id the row

          # cell representation
          opt[:descriptors].each do |d|
            x = p.index(d.id) # opt[:descriptors].index(d)  #   .index(d)
            y = q.index(r.row_object.to_global_id)

            observations = cells[ x ][ y ]

            case observations.size
            when 0 
              state = "missing#{d.id}"
            when 1
              state = "cs#{observations[0].character_state_id}"
            else # > 1 
              state = "cs#{d.id}unc_#{observations.collect{|i| i.character_state_id}.sort.join}" # should just unify identifiers with above.
            end

            byebug if state == 'cs' # d.id == 37 

            xml.cell(char: "c#{d.id}", state: state)
          end
        end # end the row
      end # end OTUs
    end # end matrix

    opt[:target]
  end

  def include_continuous_matrix(options = {})
    opt = {target:  '', descriptors: []}.merge!(options)
    xml = Builder::XmlMarkup.new(target: opt[:target])
    m = opt[:observation_matrix]

    # the matrix 
    cells = m.codings_in_grid({})[:grid]

    z = m.observation_matrix_rows.map.collect{|i| i.row_object.to_global_id}

    xml.matrix do |mx|
      m.observation_matrix_rows.each do |o|
        xml.row(id: "continuous_row#{o.id}", otu: "otu_#{o.id}") do |r| # use Otu#id to uniquely id the row

          # cell representation
          opt[:descriptors].each do |c|

            x = m.descriptors.index(c)
            y = z.index(o.row_object.to_global_id)

            codings = cells[ x ][ y ]
            if codings.size > 0  && !codings.first.continuous_value.nil?
              xml.cell(char: "c#{c.id}", state: codings.first.continuous_value)
            end
          end
        end # end the row
      end # end OTUs
    end # end matrix

    return opt[:target]
  end

  def nexml_otus(options = {})
    opt = {target: ''}.merge!(options)
    xml = Builder::XmlMarkup.new(target: opt[:target])
    m = opt[:observation_matrix]

    xml.otus(
      id: "otu_block_#{m.id}",
      label: "Otus for matrix #{m.name}"
    ) do
      m.observation_matrix_rows.each do |r|
        xml.otu(
          id: "row_#{r.id}",
          about: "#row_#{r.id}", # technically only need this for proper RDFa extraction  !!! Might need this to be different, is it about row, or row object!
          label: observation_matrix_row_label(r) # otu_matrix_name(otu)  # otu.display_name(type: :matrix_name)
        ) do
          include_collection_objects(opt.merge(otu: r.row_object)) if opt[:include_collection_objects]
        end
      end
    end 
    return opt[:target]
  end

  def include_collection_objects(options = {})
    opt = {target: ''}.merge!(options)
    xml = Builder::XmlMarkup.new(target: opt[:target])
    otu = opt[:otu] 

    # otu.collection_objects.with_identifiers.each do |s|
    otu.current_collection_objects.each do |s|
      xml.meta('xsi:type' => 'ResourceMeta', 'rel' => 'dwc:individualID') do
        if a = s.preferred_catalog_number
          xml.meta(a.namespace.name, 'xsi:type' => 'LiteralMeta', 'property' => 'dwc:collectionID') 
          xml.meta(a.identifier, 'xsi:type' => 'LiteralMeta', 'property' => 'dwc:catalogNumber') 
        else
          xml.meta('UNDEFINED', 'xsi:type' => 'LiteralMeta', 'property' => 'dwc:collectionID') 
          xml.meta(s.id, 'xsi:type' => 'LiteralMeta', 'property' => 'dwc:catalogNumber') 
        end
      end
    end # end specimens

    return opt[:target]
  end
end
