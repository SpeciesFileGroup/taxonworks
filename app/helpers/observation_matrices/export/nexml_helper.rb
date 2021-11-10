module ObservationMatrices::Export::NexmlHelper

  def nexml_descriptors(options = {})
    opt = {target: ''}.merge!(options)
    xml = Builder::XmlMarkup.new(target: opt[:target])
    m = opt[:observation_matrix]
    # Multistate characters
    xml.characters(
      id: "multistate_character_block_#{m.id}",
      otus: "otu_block_#{m.id}",
      'xsi:type' => 'nex:StandardCells',
      label:  "Multistate characters for matrix #{m.name}"
    ) do

      descriptors = m.symbol_descriptors.load
      xml.format do
        descriptors.each do |c|
          xml.states(id: "states_for_chr_#{c.id}") do
            if c.qualitative?
              c.character_states.each_with_index do |cs,i|
                if cs.depictions.load.any?
                  xml.state(id: "cs#{cs.id}", label: cs.target_name(:key, nil), symbol: "#{i}") do
                    cs.depictions.each do |d|
                      xml.meta(
                        'xsi:type' => 'ResourceMeta',
                        'rel' => 'foaf:depiction',
                        'href' => short_url(d.image.image_file.url(:original)) # root_url + d.image.image_file.url(:original)[1..-1]
                      )
                    end
                  end
                else
                  xml.state(id: "cs#{cs.id}", label: cs.target_name(:key, nil), symbol: "#{i}")
                end
              end

              # Add a missing state for each character regardless of whether we use it or not
              xml.state(id: "missing#{c.id}", symbol: c.character_states.size, label: "?")

              # Poll the matrix for polymorphic/uncertain states
              uncertain = m.polymorphic_cells_for_descriptor(descriptor_id: c.id, symbol_start: c.character_states.size + 1)
              uncertain.keys.each do |pc|
                xml.uncertain_state_set(id: "cs#{c.id}unc_#{uncertain[pc].sort.join}", symbol: pc) do
                  uncertain[pc].collect{|m| xml.member(state: "cs#{m}") }
                end
              end

            elsif c.presence_absence?
              # like "cs_4_0'
              xml.state(id: "cs_#{c.id}_0", label: 'absent', symbol: "0")
              xml.state(id: "cs_#{c.id}_1", label: 'present', symbol: "1")

              xml.state(id: "missing#{c.id}", symbol: '2', label: "?")

              uncertain = m.polymorphic_cells_for_descriptor(descriptor_id: c.id, symbol_start: 2)
              uncertain.keys.each do |pc|
                xml.uncertain_state_set(id: "cs#{c.id}unc_#{uncertain[pc].sort.join}", symbol: pc) do
                  uncertain[pc].collect{|m| xml.member(state: "cs_#{m}") } # m is built in pcfd
                end
              end
            end # end states block

          end
        end  # end character loop for multistate states
        descriptors.collect{|c| xml.char(id: "c#{c.id}", states: "states_for_chr_#{c.id}", label: c.target_name(:key, nil))}
      end # end format

      include_multistate_matrix(opt.merge(descriptors: descriptors)) if opt[:include_matrix]

    end # end characters

    d = m.continuous_descriptors.order('observation_matrix_columns.position').load

    # continuous characters
    xml.characters(
      id: "continuous_character_block_#{m.id}",
      otus: "otu_block_#{m.id}",
      'xsi:type' => 'nex:ContinuousCells',
      label: "Continuous characters for matrix #{m.name}") do
        xml.format do
          d.collect{|c| xml.char(id: "c#{c.id}", label: c.target_name(:key, nil))}
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
    cells = m.observations_in_grid({})[:grid]
    p = m.observation_matrix_columns.order('observation_matrix_columns.position').map(&:descriptor_id)
    q = m.observation_matrix_rows.order('observation_matrix_rows.position').collect{|i| "#{i.otu_id}|#{i.collection_object_id}" }
    xml.matrix do
      m.observation_matrix_rows.each do |r|
        xml.row(id: "multistate_row#{r.id}", otu: "row_#{r.id}") do |row| # use row_id to uniquel identify the row ##  Otu#id to uniquely id the row

          # cell representation
          opt[:descriptors].each do |d|

            x = p.index(d.id) # opt[:descriptors].index(d)  #   .index(d)
            y = q.index("#{r.otu_id}|#{r.collection_object_id}")
            observations = cells[ x ][ y ]

            case observations.size
            when 0
              state = "missing#{d.id}"
            when 1
              o = observations.first
              if d.qualitative?
                state = "cs#{o.character_state_id}"
              elsif d.presence_absence?
                # WRONG
                state = "cs_#{o.descriptor_id}_#{o.presence ? '1' : '0'}"
              else
                state = "ERROR"
              end
            else # > 1
              if d.qualitative?
                state = "cs#{d.id}unc_#{observations.collect{|i| i.character_state_id}.sort.join}" # should just unify identifiers with above.
              elsif d.presence_absence?
                state = "cs_#{o.descriptor_id}_unc_#{ observations.collect{|i| i.character_state_id}.sort.join}"
              end
            end

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
    cells = m.observations_in_grid({})[:grid]

    z = m.observation_matrix_rows.map.collect{|i| "#{i.otu_id}|#{i.collection_object_id}"}

    xml.matrix do |mx|
      m.observation_matrix_rows.each do |o|
        xml.row(id: "continuous_row#{o.id}", otu: "row_#{o.id}") do |r| # use Otu#id to uniquely id the row

          # cell representation
          opt[:descriptors].each do |c|

            x = m.descriptors.index(c)
            y = z.index("#{o.otu_id}|#{o.collection_object_id}")

            observations = cells[ x ][ y ]
            if observations.size > 0  && !observations.first.continuous_value.nil?
              xml.cell(char: "c#{c.id}", state: observations.first.continuous_value)
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
          label: observation_matrix_row_label_nexml(r)
        ) do
          include_collection_objects(opt.merge(otu: r.row_object)) if opt[:include_collection_objects]
          # This is experimental only. Issues:
          # * It draws images and data from all matrices, # not just this one
          # * Depictions are on Observation::Media, not OTU, i.e. we could be more granular throughout
          # * Citations are on Image, not Depiction
          im =  ImageMatrix.new(project_id: r.project_id, otu_filter: r.otu_id.to_s)
          descriptors = im.list_of_descriptors.values
          if !im.blank? && !im.depiction_matrix.empty?
            object = im.depiction_matrix.first

            object[1][:depictions].each_with_index do |depictions, index|
              depictions.each do |depiction|
                lbl = []
                cit = im.image_hash[depiction[:image_id]][:citations].collect{|i| i[:cached]}.join('')
                lbl.push('<b>Taxon name:</b> ' + object[1][:object].otu_name) unless object[1][:object].otu_name.blank?
                lbl.push('<b>Label:</b> ' + descriptors[index][:name]) unless descriptors[index][:name].blank?
                lbl.push('<b>Caption:</b> ' + depiction[:caption]) unless depiction[:caption].blank?
                lbl.push('<b>Citation:</b> ' + cit) unless cit.blank?
                img_attr = Image.find(depiction[:image_id]).attribution
                lbl.push('<b>Attribution:</b> ' + attribution_tag(img_attr)) unless img_attr.nil?
                lbl = lbl.join('<br> ')

                xml.meta(
                  'xsi:type' => 'ResourceMeta',
                  'rel' => 'foaf:depiction',
                  'about' => "row_#{r.id}",
                  'href' => short_url(im.image_hash[depiction[:image_id]][:original_url]),
                  #'object' => object[1][:object].otu_name,
                  #'label' => descriptors[index][:name], ###
                  'label' => lbl
                  #'caption' => depiction[:caption],
                  #'citation' => im.image_hash[depiction[:image_id]][:citations].collect{|i| i[:cached]}.join('')
                )
              end
            end
          end


=begin
          Observation::Media.where(otu_id: r.otu_id).each do |o|
            o.depictions.each do |d|
              lbl = d.figure_label.blank? ? o.descriptor.name : d.figure_label
              dscr = d.figure_label.blank? ? '' : o.descriptor.name
                xml.meta(
                'xsi:type' => 'ResourceMeta',
                'rel' => 'foaf:depiction',
                'about' => "row_#{r.id}",
                'href' => short_url(d.image.image_file.url),  #  root_url + im.image_hash[depiction[:image_id]][:original_url],
                # 'object' => observation_matrix_row_label_nexml(r), # label_for_otu(o) #  o.otu.otu_name, #  object[1][:object].otu_name,  -- redundant with label=""
                'description' => dscr, #  descriptors[index][:name],
                'label' => lbl, # epiction[:figure_label],
                'citation' =>  d.image.source&.cached # depiction[:source_cached]
              )

            end
          end
=end


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

   #
   # NOT USED - current using inline approach to handle depictions
  def nexml_otu_depictions(options = {})
     opt = {target:  '', descriptors: []}.merge!(options)
     xml = Builder::XmlMarkup.new(target: opt[:target])
     m = opt[:observation_matrix]
     otus = m.otus
     im =  ImageMatrix.new(
       project_id: m.project_id,
       otu_filter: m.otus.pluck(:id).join('|'))
     descriptors = im.list_of_descriptors.values
     row_hash = m.observation_matrix_rows.map{|i| [i.otu_id, i.id]}.to_h

     xml.otu_depictions do |d|
       im.depiction_matrix.each do |object|
         object[1][:depictions].each_with_index do |depictions, index|
           depictions.each do |depiction|

             xml.meta(
               'xsi:type' => 'ResourceMeta',
               'rel' => 'foaf:depiction',
               'about' => "row_#{row_hash[object[1][:otu_id].to_i].to_s}",
               'href' => root_url + im.image_hash[depiction[:image_id]][:original_url],
               'object' => object[1][:object].otu_name,
               'description' => descriptors[index][:caption],
               'label' => depiction[:figure_label],
               'citation' => depiction[:source_cached]
             )
           end
         end
       end
     end
     return opt[:target]
   end


  # TODO: if semantics change we can add them as block later.
  # This is just character state depictions for now.
  def nexml_depictions(options = {})
    opt = {target: '', descriptors: []}.merge!(options)
    xml = Builder::XmlMarkup.new(target: opt[:target])
    m = opt[:observation_matrix]
    xml.depictions do
      if true # character state options

        xml.character_state_depictions(
          id: "character_state_depiction_block_#{m.id}",
          otus: "otu_block_#{m.id}",
          #   'xsi:type' => 'nex:StandardCells',
          label:  "Character state depictions for matrix #{m.name}"
        ) do
          ::Depiction.joins(image: [:character_states]).merge(m.character_states).each do |d|
            xml.meta(
              'xsi:type' => 'ResourceMeta',
              'rel' => 'foaf:depiction',
              'about' => "cs#{d.depiction_object_id}",
              'href' => short_url(d.image.image_file.url(:original)) # root_url + d.image.image_file.url(:original)[1..-1]
            )
          end
        end
      end
      opt[:target]
    end
  end

end
