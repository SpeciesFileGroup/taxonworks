# Derived from mx
module Nexml

  class << self

    def serialize(options = {})
      opt = {
        observation_matrix: nil,                  # Takes a ObservationMatrix
        target: '',
        include_otus: true,
        include_collection_objects: true,
        include_descriptors: true,
        include_matrix: true, 
        include_trees: false,
        rdf: false
      }.merge!(options)

      # m = opt[:observation_matrix]

      xml = Builder::XmlMarkup.new(:target => opt[:target], :indent => 2)
      if opt[:rdf]
        xml.instruct!('xml-stylesheet', type: 'text/xsl', href: '/stylesheets/roger_messing.xsl')  
      else
        xml.instruct!
      end

      xml.nex(:nexml,  
              'version'            => '0.1',
              'generator'          => 'TaxonWorks',                    
              'xmlns:xsi'          => 'http://www.w3.org/2001/XMLSchema-instance',
              'xmlns:xml'          => 'http://www.w3.org/XML/1998/namespace',
              'xmlns:nex'          => 'http://www.nexml.org/2009',        
              'xmlns'              => 'http://www.nexml.org/2009',                  
              'xsi:schemaLocation' => 'http://www.nexml.org/2009 ../xsd/nexml.xsd',
              'xmlns:xsd'          => 'http://www.w3.org/2001/XMLSchema',
              'xmlns:dc'           => 'http://purl.org/dc/terms/',
              'xmlns:dwc'          => 'http://rs.tdwg.org/dwc/terms/',
              'xmlns:xi'           => 'http://www.w3.org/2003/XInclude' # IS THIS NECESSARY?
             )  do 

               include_otus(opt) if opt[:include_otus]
               include_descriptors(opt) if opt[:include_descriptors] 
               # include_trees(opt) if opt[:include_trees]
             end # end document
    end

    def include_descriptors(options = {})
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
            # TODO: expand to mx.chrs.that_are_continuous and mx.chrs.that_are_multistate
            m.descriptors.where(type: 'Descriptor::Qualitative').each do |c|
              # uncertain_cells = {}

              xml.states(id: "states_for_chr_#{c.id}") do

                c.character_states.each_with_index do |cs,i|
                  xml.state(id: "cs#{cs.id}", label: cs.name, symbol: "#{i}") 
                end

                # add a missing state for each character regardless of whether we use it or not
                xml.state(:id => "missing#{c.id}", :symbol => c.character_states.size, :label => "?")

                # poll the matrix for polymorphic/uncertain states
                uncertain = m.polymorphic_cells_for_chr(chr: c, symbol_start: c.character_states.size + 1)

                uncertain.keys.each do |pc|
                  xml.uncertain_state_set(id: "cs#{c.id}unc_#{uncertain[pc].sort.join}", symbol: pc) do |uss|
                    uncertain[pc].collect{|m| xml.member(:state => "cs#{m}") }
                  end
                end

                # uncertain_cells[c.id] = uncertain

              end # end states block
            end  # end character loop for multistate states 


            m.descriptors.where(type: 'Descriptor::Qualitative').each_with_index.collect{|c| xml.char(id: "c#{c.id}", states: "states_for_chr_#{c.id}", label: c.name)}

          end # end format

          include_multistate_matrix(opt.merge(descriptors: m.descriptors.where(type: 'Descriptor::Qualitative'))) if opt[:include_matrix] 
        end # end characters


        # continuous characters
        xml.characters(
          id: "continuous_character_block_#{m.id}",
          otus: "otu_block_#{m.id}",
          'xsi:type' => 'nex:ContinuousCells',
          label: "Continuous characters for matrix #{m.name}") do
            xml.format do
              m.chrs.that_are_continuous.collect{|c| xml.char(:id => "c#{c.id}",  :label => c.name)}
            end # end format

            include_continuous_matrix(opt.merge(:chrs => m.chrs.that_are_continuous)) if opt[:include_matrix] 
          end # end multistate characters


          return opt[:target]
    end


    def include_multistate_matrix(options = {})
      opt = {target: '', descriptors: []}.merge!(options)
      xml = Builder::XmlMarkup.new(target: opt[:target])
      m = opt[:observation_matrix]

      # the matrix 
      cells = m.codings_in_grid({})[:grid]

      xml.matrix do |m|
        m.otus.each do |o|
          xml.row(:id => "multistate_row#{o.id}", :otu => "otu_#{o.id}") do |r| # use Otu#id to uniquely id the row

            # cell representation
            opt[:descriptors].each do |c|

              codings = cells[m.chrs.index(c)][m.otus.index(o)]

              case codings.size
              when 0 
                state = "missing#{c.id}"
              when 1
                state = "cs#{codings[0].chr_state_id}"
              else # > 1 
                state = "cs#{c.id}unc_#{codings.collect{|i| i.chr_state_id}.sort.join}" # should just unify identifiers with above.
              end

              xml.cell(:char => "c#{c.id}", :state => state)
            end
          end # end the row
        end # end OTUs
      end # end matrix

      return opt[:target]
    end

    def include_continuous_matrix(options = {})
      opt = {:target => '', :chrs => []}.merge!(options)
      xml = Builder::XmlMarkup.new(:target => opt[:target])
      m = opt[:observation_matrix]

      # the matrix 
      cells = m.codings_in_grid({})[:grid]

      xml.matrix do |m|
        m.otus.each do |o|
          xml.row(:id => "continuous_row#{o.id}", :otu => "otu_#{o.id}") do |r| # use Otu#id to uniquely id the row

            # cell representation
            opt[:chrs].each do |c|

              codings = cells[m.chrs.index(c)][m.otus.index(o)]
              if codings.size > 0  && !codings.first.continuous_state.nil?
                xml.cell(:char => "c#{c.id}", :state => codings.first.continuous_state)
              end
            end
          end # end the row
        end # end OTUs
      end # end matrix

      return opt[:target]
    end

    def include_otus(options = {})
      opt = {target: ''}.merge!(options)
      xml = Builder::XmlMarkup.new(target: opt[:target])
      m = opt[:observation_matrix]

      xml.otus(
        id: "otu_block_#{m.id}",
        label: "Otus for matrix #{m.name}"
      ) do 
        m.otus.each do |otu|
          xml.otu(
            id: "otu_#{otu.id}", 
            about: "#otu_#{otu.id}", # technically only need this for proper RDFa extraction  
            label: otu_matrix_name(otu)  # otu.display_name(type: :matrix_name)
          ) do
            include_collection_objects(opt.merge(otu: otu)) if opt[:include_collection_objects]
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

    def otu_matrix_name(otu)
      'otu_' + otu.id.to_s # name.gsub(/[^\W]/, '_')
    end

  end
end
