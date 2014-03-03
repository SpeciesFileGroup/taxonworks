# Methods for handling the "bulk" accession of collection objects
module Material

  def self.create_quick_verbatim(options  = {}) 
    opts = {
      collection_objects: {},
    }.merge!(options) 

    response = QuickVerbatimResponse.new

    stub_object = CollectionObject.new(opts[:collection_object])
    (stub_object.container ||= Container::Virtual.new) if opts[:collection_objects].size > 1

    opts[:collection_objects].keys.each do |o|
      object = stub_object.clone
      object.total = opts[:collection_objects][o][:total]
      response.collection_objects.push object
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
 
  end

end


