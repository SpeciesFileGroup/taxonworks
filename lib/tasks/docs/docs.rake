require 'ruby-graphviz'

namespace :tw do
  namespace :docs do

    desc 'call with "rake tw:docs:er"'
    task er: [:environment] do

      core_coords = {
        'CollectingEvent': [5,2],
        'Otu': [5, 7],
        'CollectionObject': [5,5],
        'TaxonDetermination': [2,6],
        'TaxonName': [5,10],
        'Sequence': [8,2],
        'BiologicalAssociation': [8,3],
        'Observation': [8,4],
        'Descriptor': [8,8],
        'Source': [1,5],
        'ControlledVocabularyTerm': [3,5]
      }

      annotator_coords = {
        'Citation': [2,1],
        'Tag': [2,2],
        'DataAttribute': [2,3],
        'Note': [2,4],
        'Identifier': [2,5],
        'ProtocolRelationship': [2,6],
        'Confidence': [2,7],
        'AlternateValue': [2,8],
      }

      ap ANNOTATION_TYPES
      ap DATA_MODELS.keys

      # Create a new graph
      g = GraphViz.new( :G, :type => :digraph )

      # Create two nodes
      hello = g.add_nodes( "Hello", pos: [] )
      world = g.add_nodes( "World" )

      # Create an edge between the two nodes
      g.add_edges( hello, world )

      # Generate output image
      g.output(svg: "hello_world.svg" )

      #  Utilities::Csv.to_csv(result)
    end

  end

end
