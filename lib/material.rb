# Methods for handling the "bulk" accession of collection objects
module Material

  def self.create_quick_verbatim(options  = {}) 
    opts = {
      collection_objects: {},
      note: nil,
      biocuration_classes: [],
    }.merge!(options) 

    response = QuickVerbatimResponse.new

    stub_object = CollectionObject::BiologicalCollectionObject.new(opts[:collection_object])
    container = Container::Virtual.new if stub_object.container.blank?
    note = Note.new(opts[:note]) if opts[:note]

    i = 1
    opts[:collection_objects].keys.each do |o|
     
      object = stub_object.dup
      object.total = opts[:collection_objects][o][:total]

      if opts[:collection_objects][o][:biocuration_classes] 
        object.biocuration_classes << BiocurationClass.find(opts[:collection_objects][o][:biocuration_classes]) 
      end

      # byebug 
      object.notes << note.dup if note
      object.container = container if container
      response.collection_objects.push object
      object = nil
    end
    response 
  end

    # A Container to store results
    class QuickVerbatimResponse
      attr_accessor :collection_objects
      attr_accessor :identifier
      attr_accessor :repository
      attr_accessor :note

      def initialize(options = {})
        @collection_objects = []
      end

      def identifier
        @identifier ? @identifier : Identifier.new
      end

      def repository
        @repository ? @repository : Repository.new
      end

      def note 
        @note ? @note : Note.new
      end

      def save
        # TODO
      end

    end

  end


