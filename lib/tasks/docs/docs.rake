require 'ruby-graphviz'
require 'matrix'
require 'fileutils'

namespace :tw do
  namespace :docs do

    RDOC = 'https://rdoc.taxonworks.org/'
    DOCS = 'https://docs.taxonworks.org/'
    API = 'https://api.taxonworks.org/#/'

    # This code is specific to the site build of https://docs.taxonworks.org
    DOCS_OUTPUT_LOCATIONS =  {
      data_files: '/.vuepress/public/data',
      svg: '/.vuepress/public/images/model',
      markdown: '/develop/Data/'
    }

    #   | 3
    # 1 | 2
    #   | 1, 2, 3
    #   |---------
    #        0
    CORE_COORDS = {
      CollectingEvent: [5,1],
      CollectionObject: [5,3],
      Otu: [5, 5],
      TaxonName: [5,7],
      Descriptor: [7,4],
      Source: [3.5,1],

      AssertedDistribution: [4,6],
      BiologicalAssociation: [7,3],
      Observation: [7,5],
      Sequence: [7,7],
      ControlledVocabularyTerm: [5,8],
    }

    SUPPORTING_COORDS = {
      Image: [4, 9],
      TypeMaterial: [6,6],
      TaxonDetermination: [4,4],
      Georeference: [7,1],
      OriginRelationship: [7,9],
      Person: [8, 2],
      'Role:Collector':  [6, 2],
      # SequenceRelationship: [9,8],
    }

    ANNOTATOR_COORDS = {
      Citation: [2,1],
      Tag: [2,8],
      DataAttribute: [2,7],
      Note: [2,4],
      Identifier: [2,5],
      # Protocol: [2,3],
      Confidence:  [2,6],
      AlternateValue:  [2,2],
      Depiction: [2,9],
      ProtocolRelationship: [2,3],
      Attribution: [2, 10]
    }

    CORE_EDGES = [
      [ :Otu, :TaxonDetermination],
      [ :Otu, :Observation ],
      [ :Otu, :BiologicalAssociation ],
      [ :TaxonName, :Otu ],
      [ :CollectingEvent, :CollectionObject ],
      [ :CollectionObject, :TaxonDetermination ],
      [ :CollectionObject, :Observation ],
      [ :CollectionObject, :BiologicalAssociation ],
      [ :CollectionObject, :TypeMaterial],
      [ :TaxonName, :TypeMaterial],
      [ :Georeference, :CollectingEvent ],
      [ :Otu, :AssertedDistribution ],
      [ :Image, :Depiction],
      [ :Descriptor, :Observation ]
      # [ :Sequence, :SequenceRelationship]
    ]

    SUPPORTING_EDGES = [
      [ :Person, :'Role:Collector'],
      [ :'Role:Collector', :CollectionObject],
      [ :Sequence, :OriginRelationship],
      [ :ControlledVocabularyTerm, :Tag ],
      [ :ControlledVocabularyTerm, :DataAttribute ],
      [ :Otu, :Identifier ],
      [ :Source, :AlternateValue],
      [ :CollectionObject, :Source],
      [ :TaxonDetermination, :Note],
      [ :TaxonDetermination, :ProtocolRelationship],
      [ :AssertedDistribution, :Confidence],
      [ :Otu, :Depiction],
      [ :Image, :Attribution],
      # [ :Otu, :OriginRelationship],
      # [ :Citation, :AssertedDistribution],
    ]

    ANNOTATOR_EDGES = [
      [:Source, :Citation]
    ]

    # These force localization (puts nodes close to each other) of related nodes in graphviz/dot.
    # This is a "good enough" list, not a complete enumeration.
    # This doesn't describe edges that exist, but that will be added
    # and not shown.
    INVISIBLE_PAIRS = [
      [:Creator, :Updater],
      [:Project, :Creator],
      [:Role, :Verifier],
      [:Role, :AccessionProviderRole ],
      [:Role, :AccessionProvider],
      [:Role, :DeaccessionRecipientRole],
      [:Container, :ContainerItem],
      [:ContainerItem, :ParentContatinerItem],
      [:PreparationType, :BiocurationClassification],
      [:Source, :SubsequentCitation],
      [:Source, :OriginCitation],
      [:OriginRelationship, :RelatedOriginRelationship],
      [:ObservationMatrixRowItem, :ObservationMatrixRow],
      [:ObservationMatrixRowItem, :ObservationMatrixColumnItem],
      [:ObservationMatrixRow, :ObservationMatrixColumn],
      [:BiologicalAssociation, :RelatedBiologicalAssociation],
      [:Version, :PinboardItem],
      [:Observation, :ObservationMatrix],
    ]

    ER_NODE_STYLES = {
      core: {
        shape: :Mrecord,
        color: '#dddeee',
        style: 'filled',
        fillcolor: '#fedcba',
        group: :core,
      },
      supporting: {
        shape: :box,
        color: '#dddeee',
        style: 'filled',
        fillcolor: '#eeefff',
        group: :supporting,
      },
      annotator: {
        shape: :oval,
        color: '#dddeee',
        style: 'filled',
        fillcolor: '#abcdef',
        group: :annotator,
      },
      polymorphic: {
        shape: :hexagon,
        color: '#dedede',
        style: 'filled',
        fillcolor: '#cdabef',
        group: :polymorphic,
      },
      target: {
        shape: :doubleoctagon,
        color: '#dedede',
        style: 'filled',
        fillcolor: '#cdefab',
        group: :target,
      }
    }

    # TODO: scrape descriptions using RDOC processor, add as headers for ER
    # def model_description(table_name)
    #   byebug
    #   p = File.expand_path(table_name.singularize + '.rb', Rails.root.to_s + '/app/models/')
    #   if File.exists?(p)
    #     r = File.read(p)
    #     puts r
    #   else
    #     nil
    #   end
    # end

    # @return [Array]
    #   of table_names matching endpoints available on the API
    def api_models
      a = Rails.application.routes.routes
      a.collect{|b| b.path.spec.to_s}.select{|c| c =~ /api/}.collect{|d| d.split('/').fourth&.split('(')&.first}.compact.uniq
    end

    # @return String
    def node_pos(coords, scale = Matrix.scalar(2, 1) )
      (Matrix[coords] * scale).row(0).to_a.join(',') + '!'
    end

    # @return String
    def model_label(table_name)
      table_name.singularize.humanize
    end

    # @return String
    #   a URL out to https://rdoc.taxonworks.org
    def docs_url(table_name)
      RDOC + table_name.to_s.singularize.classify.to_s + '.html'
    end

    # @return String
    #   a URL out to https://api.taxonworks.org/
    #   format is `/#/taxon_names`
    def api_url(table_name)
      API + table_name
    end

    # @return String, nil
    #   a markdown link to the model at https://api.taxonworks.org
    #   only returned if there is a base link
    def api_link(table_name)
      if api_models.include?(table_name)
        "[api](#{api_url(table_name)})"
      else
        nil
      end
    end

    # @return String
    #   a relative path to the er diagram for the model in https://docs.taxonworks.org
    def er_url(target)
      "/develop/Data/models.html##{target.to_s.tableize.singularize.gsub('_', '-')}"
    end

    # @return String
    #   a relative path to the table definition in https://docs.taxonworks.org
    def table_url(table_name)
      '/develop/Data/tables.html#' + table_name
    end

    # @return String
    #   a markdown link to the model at https://rdoc.taxonworks.org
    def rdoc_link(table_name)
      "[rdoc](#{docs_url(table_name)})"
    end

    # @return String
    #   a markdown link to the table at https://docs.taxonworks.org
    def table_link(table_name)
      "[table](#{table_url(table_name.gsub('_', '-'))})"
    end

    # @return String
    #   a markdown link to the model er at https://docs.taxonworks.org
    def er_link(table_name)
      "[er](#{er_url(table_name)})"
    end

    # @param label [Symbpol]
    def node_style(label)
      if k = ER_NODE_STYLES[node_klass(label.to_sym)]
        k
      else
        ER_NODE_STYLES[:supporting]
      end
    end

    def edge_style(label)
    end

    def node_klass(label)
      return :core if !CORE_COORDS[label.to_sym].nil?
      return :annotator if !ANNOTATOR_COORDS[label.to_sym].nil?
      return :supporting
    end

    def markdown_row(array)
      '|' + array.join('|') + '|'
    end

    def column_markdown(column, data_tables)
      markdown_row( [column_url(column, data_tables), column.sql_type])
    end

    # @return [Array of columns]
    #   sorts columns placing id first, and other housekeeping last, with everything else alphabetical
    def sort_columns(columns)
      shared = [:id,  :created_by_id, :updated_by_id,  :created_at, :updated_at, :project_id]

      # Alpha first sort
      cols = columns.sort{|a,b| a.name <=> b.name}

      # Expand by index vs. shared (:id is 0, so sill always be first). If > 500 columns, bump constant (but you've got bigger problems then).
      cols.sort{|a,b| ( shared.index(a.name.to_sym) ? (shared.index(a.name.to_sym) * 500) : cols.index(a) + 1 ) <=> ( shared.index(b.name.to_sym) ? (shared.index(b.name.to_sym) * 500) : cols.index(b) + 1 )  }
    end

    def column_url(column, data_tables = [])
      n = column.name
      return n unless n =~ /_id$/
      m = n.dup.gsub(/_id$/, '')
      p = m.pluralize.gsub('_', '-')

      if data_tables.include?(p)
        return "[#{m}](##{p})_id"
      end

      case m
      when 'protonym' # badly named column
        "[#{m}](#taxon_name)_id"
      when 'biological_collection_object' # badly named column
        "[#{m}](#collection_objects)_id"
      when 'keyword', 'topic', 'predicate', 'biocuration_class' # less badly named
        "[#{m}](#controlled_vocabulary_terms)_id"
      when 'preceding_serial', 'succeeding_serial', 'translated_from_serial'
        "[#{m}](#serials)_id"
      when 'primary_language'
        "[#{m}](#languages)_id"
      when 'object_sequence', 'subject_sequence'
        "[#{m}](#sequences)_id"
      else
        column.name
      end
    end

    # @attr name [String]
    # @attr graph [Grapviz.new]
    # @attr nodes
    def add_node(name, graph, nodes, style = {}) # TODO: maybe target node here
      return nodes[name] if nodes[name]
      s = style
      l = er_url(name)
      n = graph.add_nodes(
        name.to_s,
        style: s[:style],
        fillcolor: s[:fillcolor],
        group: s[:group],
        color: s[:color],
        shape: s[:shape],
        target: :_top,
        href: (l ? l : ''),
      )
      nodes[name] = n
      n
    end

    def model_graph(model, label: false)
      m = model
      k = node_klass(m.name)

      g = GraphViz.new(
        m.name,
        #       ranksep: 1.5,
        #       nodesep: 0.05,
        #       packmode: 'array_c2',
        rankdir: "LR",
        outputorder: :edgesfirst,
        label: (label ? "Algorithmically generated relationships for #{m} based on assertions of 'has_many', 'has_one', 'belongs_to'. \nGenerated #{Time.now}." : nil),
      )

      nodes = {}
      edges = []

      # Make some subgraphs

      annotator_cluster = g.add_graph('annotator_cluster')
      annotator_cluster['rank'] = 'min'
      core_cluster = g.add_graph('core')
      supporting_cluster = g.add_graph('supporting')

      #     annotator_sub = g.cluster_annotator # subgraph{|c| c['label'] = 'annotator_cluster'; c['cluster'] = 'annotator' }
      #     core_sub = g.cluster_core # subgrap{|c| c['label'] = 'core_cluster' }
      #     supporting_sub = g.cluster_supporting #subgraph{|c| c['label'] = 'supporting_cluster' }

      graphs = {
        annotator: annotator_cluster,
        core: core_cluster,
        supporting: supporting_cluster
      }

      add_node(m.name, graphs[k], nodes, ER_NODE_STYLES[:target] )

      [:has_many, :belongs_to, :has_one].each do |t|
        ApplicationEnumeration.klass_reflections(m, t).each do |r|

          k = nil # klass of the right node
          left_name = m.name # TODO: overriddennil
          right_name = nil
          right_node = nil
          left_node = nil

          if r.polymorphic?
            right_name = 'Objects with ' + m.table_name.humanize

            # add_node prevents duplicates
            right_node = add_node(
              right_name,
              g, # Add to the base graph
              nodes,
              ER_NODE_STYLES[:polymorphic])
          else

            next if %w{User Project}.include?(right_name)

            through = r.options.include?(:through)

            # style throught relationship
            if t == :has_one
              right_name = r.name.to_s.classify
              j = node_klass(right_name)
              right_node = add_node(right_name, graphs[j], nodes, node_style(right_name))
            else
              if through

                left_name = r.options[:through].to_s.classify
                right_name = r.name.to_s.classify

                lj = node_klass(left_name)
                lk = node_klass(right_name)

                left_node = add_node(left_name, graphs[lj], nodes, node_style(left_name))
                right_node = add_node(right_name, graphs[lk], nodes, node_style(right_name))
              else
                right_name = r.name.to_s.classify
                j = node_klass(right_name)
                right_node = add_node(right_name, graphs[j], nodes, node_style(right_name))
              end
            end
          end

          # Don't add the edge 2x (shouldn't make a difference now)
          next if edges.include?([m.name, right_name])

          # puts "#{m.name} -> #{right_name}"

          edge_style = case t
                       when :has_many
                         if through
                           { style: 'dotted' }
                         else
                           {}
                         end
                       when :belongs_to
                         { style: "dashed", dir: 'back' }
                       when :has_one
                         if through
                           { style: 'dotted', dir: 'both', arrowhead: 'obox', arrowtail: 'obox'  }
                         else
                           { dir: 'both', arrowhead: 'obox', arrowtail: 'obox'  }
                         end
                       else
                         {}
                       end

          g.add_edges( nodes[left_name], right_node, edge_style)
          edges.push [ left_name, right_name ]
        end
      end

      INVISIBLE_PAIRS.each do |k,v|
        if nodes[k.to_s] && nodes[v.to_s]
          g.add_edges( nodes[k.to_s], nodes[v.to_s], style: 'invis')
        end
      end
      g
    end

    desc 'generate graphviz "ER" diagrams for models, "rake tw:docs:model_ers"'
    task model_ers: [:environment, :data_directory] do

      @target_path = ENV['TW_DOCS_PATH']
      @target_path ||= @args[:data_directory]

      # The index file
      i = File.open(File.expand_path('models.md', @args[:data_directory] + DOCS_OUTPUT_LOCATIONS[:markdown]), 'w')
      i.puts "---\n---\n"
      i.puts '# Models'
      i.puts "_This file auto-generated #{Time.now} via 'rake tw:docs:model_ers'. Do not hand-edit._"
      i.puts
      i.puts "Algorithmically generated ER diagrams. Node shapes: green octagons- the target model the ER perspective is drawn from; orange rounded rectangles- core models;  light purple rectangles- supporting models; blue ovals- annotating models; purple diamonds- polymorphic models (matches to many other models). Node edges (arrow points to many side): solid arrows- 'has many'; dotted arrows- *target model* 'has many' _through_ one side model; dashed arrows: *target model* 'has one'; dotted squared arrows: *target model* 'has one', but _through_ a corresponding dotted relationship. See also description in [Overview](/develop/Data/#concepts). Click a node to navigate (not all are linked)."
      i.puts

      models = []

      ApplicationEnumeration.data_models.each do |m|
        models.push m.table_name

         # TODO: integrate model_description
         # model_description(m.table_name)

         g = model_graph(m)
         # Generate output image
         g.output(svg: File.expand_path("#{m.table_name}_model_er.svg", @target_path + DOCS_OUTPUT_LOCATIONS[:svg]), use: :dot)

         # Generate raw, un-positioned .dot file
         g.output(dot: File.expand_path("#{m.table_name}_model_er.dot", @target_path + DOCS_OUTPUT_LOCATIONS[:data_files]))
      end

      i.puts models.sort.collect{|o| "[#{model_label(o)}](#{er_url(o)})" }.join(', ')

      models.sort.each do |m|
        i.puts "\n"
        i.puts "## #{model_label(m)}"
        i.puts [
          "[top](#models)",
          table_link(m),
          rdoc_link(m),
          api_link(m),
        ].compact.join(',')

        i.puts '<object data="/images/model/' + m + '_model_er.svg" type="image/svg+xml"></object>'
      end

      i.close
    end

    desc 'generate mardown description of tables, "rake tw:docs:table_markdown data_directory=/abc/"'
    task table_markdown: [:environment, :data_directory] do

      @target_path = ENV['TW_DOCS_PATH']
      @target_path ||= @args[:data_directory]

      # Array of data table names
      data_tables = ::ApplicationEnumeration.data_models.collect{|m| m.table_name}

      i = File.open(File.expand_path('tables.md', @target_path + DOCS_OUTPUT_LOCATIONS[:markdown]), 'w')

      i.puts "# Tables"
      i.puts "_This file auto-generated #{Time.now} via 'rake tw:docs:table_markdown'. Do not hand-edit._"
      i.puts

      i.puts ApplicationEnumeration.data_models.sort{|a,b| a.table_name <=> b.table_name}.collect{|m|
        "[#{m.table_name}](##{m.table_name.gsub('_', '-')})" # Markdown/Vuedoc header anchor format
      }.join(', ')

      ApplicationEnumeration.data_models.sort{|a,b| a.table_name <=> b.table_name}.each do |m|
        i.puts "## #{m.table_name}"
        i.puts [
          "[top](#tables)",
          er_link(m.name),
          rdoc_link(m.name),
          api_link(m.table_name),
        ].compact.join(',')
        i.puts
        headers = %w{Name Type}
        i.puts markdown_row(headers)

        # puts '|' + '-' * (headers.join.size + (headers.size - 1)) + '|'
        i.puts '|' + headers.collect{|h| ('-' * h.size) }.join('|') + '|'
        sort_columns(m.columns).each do |c|
          i.puts column_markdown(c, data_tables)
        end
      end

      i.close
    end

    # "All" nodes and edges, presently ugly
    desc 'call with "rake tw:docs:enumerated_er"'
    task enumerated_er: [:environment] do
      g = GraphViz.new(
        :G,
        type: :digraph,
        ranksep: 1.5,
        nodesep: 0.05,
        #  size: '2000,2000!',
        packmode: 'array_c2',
        outputorder: :edgesfirst,
        label: "Algorithmically generated classes and their relationships in TaxonWorks, based on assertions of 'has_many' in the underlying data models/classes. \nGenerated #{Time.now} via 'rake tw:docs:enumerated_er'.",
      )

      nodes = {}

      # Make some subgraphs
      annotator_sub = g.subgraph do |c|
        c['rank'] = 'same'
      end
      core_sub = g.subgraph {|c|  }
      supporting_sub = g.subgraph do |c|
      end

      ApplicationEnumeration.data_models.each do |m|
        name = m.name

        k = node_klass(name)
        s = node_style(name.to_sym)

        graph = case k
                when :annotator
                  annotator_sub
                when :core
                  core_sub
                else
                  supporting_sub
                end

        n = graph.add_nodes(
          name.to_s,
          style: s[:style],
          fillcolor: s[:fillcolor],
          group: s[:group],
          target: s[:target],
          color: s[:color],
          shape: s[:shape]
        )

        nodes[name] = n
      end

      edges = [ ]
      ApplicationEnumeration.data_models.each do |m|
        [:has_many].each do |t|
          ApplicationEnumeration.klass_reflections(m, t).each do |r|
            next if r.polymorphic? or r.options.include?(:through)
            next if nodes[m.name].nil?
            next if nodes[r.klass.name].nil?

            # Don't add the edge 2x (shouldn't make a difference now)
            next if edges.include?([m.name, r.klass.name])

            # puts "#{m.name} -> #{r.klass.name}"

            g.add_edges(nodes[m.name], nodes[r.klass.name])
            edges.push [
              m.name, r.klass.name,
            ]
          end
        end
      end

      # Generate output image
      g.output(svg: 'enumerated_er.svg', use: :dot)
      g.output(dot: 'enumerated_er.dot', use: :dot)
    end

    desc 'a customized, exemplar ER diagram, "rake tw:docs:er data_directory=/abc/"'
    task er: [:environment, :configure_output] do
      g = GraphViz.new(
        :G,
        type: :digraph,
        outputorder: :edgesfirst, # draw nodes on top of edges
        label: "Generated #{Time.now} via 'rake tw:docs:er'.")

      # No change when [1] is 1. Position is in inches.
      scale = Matrix.scalar(2, 1)

      nodes = {}

      CORE_COORDS.each do |label, coords|
        n = g.add_nodes(
          label.to_s,
          pos: node_pos(coords, scale),
          href: er_url(label),
          target: :_top,
          **ER_NODE_STYLES[:core]
        )
        nodes[label] = n
      end

      SUPPORTING_COORDS.each do |label, coords|
        n = g.add_nodes(
          label.to_s,
          pos: node_pos(coords, scale),
          href: er_url(label),
          target: :_top,
          **ER_NODE_STYLES[:supporting]
        )
        nodes[label] = n
      end

      ANNOTATOR_COORDS.each do |label, coords|
        n = g.add_nodes(
          label.to_s,
          pos: node_pos(coords, scale),
          href: er_url(label),
          target: :_top,
          **ER_NODE_STYLES[:annotator]
        )

        nodes[label] = n
      end

      CORE_EDGES.each do |e|
        g.add_edges(
          nodes[e[0]], nodes[e[1]]
        )
      end

      SUPPORTING_EDGES.each do |e|
        g.add_edges(
          nodes[e[0]], nodes[e[1]],
          style: "dashed"
        )
      end

      ANNOTATOR_EDGES.each do |e|
        g.add_edges(nodes[e[0]], nodes[e[1]])
      end

      @target_path = ENV['TW_DOCS_PATH']
      @target_path ||= @args[:data_directory]

      # Generate output image
      g.output(svg: File.expand_path('er.svg', @target_path + DOCS_OUTPUT_LOCATIONS[:svg]), use: :neato )

      # Generate raw, un-positioned .dot file
      g.output(dot: File.expand_path('er.dot', @target_path + DOCS_OUTPUT_LOCATIONS[:data_files]))
    end

    desc '"rake tw:docs:configure_output data_directory=/abc"'
    task configure_output: [:data_directory] do
      @target_path = ENV['TW_DOCS_PATH']
      @target_path ||= @args[:data_directory]

      dirs = DOCS_OUTPUT_LOCATIONS.values.collect{|l| @target_path + l}

      dirs.each do |d|
        if Dir.exists?(d)
          puts Rainbow('Found ' + d).green
        else
          puts Rainbow('Did not find ' + d).red
          puts Rainbow('Creating ' + d).orange
          FileUtils.mkdir_p d
        end
      end
    end

    # rake tw:docs:generate_docs data_directory=~/src/github/species_file_group/taxonworks_doc/docs
    desc "Generate Data related documentation for docs.taxonworks.org"
    task generate_docs: [:environment, :data_directory, :configure_output, :er, :table_markdown, :model_ers]

  end
end
