# Methods for handling the "bulk" accession of collection objects
module Material
    
  def self.create_quick_verbatim(options  = {}) 
    # We could refactor this to use nested attributes, but it's not that much cleaner 
    opts = {
      'collection_objects' => {},
      'note' => nil,
      'biocuration_classes' => [],
    }.merge!(options)

    response = QuickVerbatimResponse.new

    objects = opts['collection_objects']
    stub_object_attributes = CollectionObject::BiologicalCollectionObject.new(opts['collection_object'])

    if opts['identifier'] && !opts['identifier']['namespace_id'].blank? && !opts['identifier']['identifier'].blank?
      identifier = Identifier::Local::CatalogNumber.new(
        namespace_id: opts['identifier']['namespace_id'],
        identifier: opts['identifier']['identifier']) 
    end

    container = Container::Virtual.new if objects.keys.count > 1 
    container.identifiers << identifier if container && identifier
   
    note = Note.new(opts['note']) if opts['note'] && !opts['note']['text'].blank? 

    objects.keys.each do |o|
      object = stub_object_attributes.dup
      object.total = objects[o]['total']

      if objects[o]['biocuration_classes'] 
        object.biocuration_classes << BiocurationClass.find(objects[o]['biocuration_classes'].keys) 
      end

      # repository is handled by _id
      object.notes << note.dup if note
      object.container = container if container
      object.identifiers << identifier if identifier && !container 

      response.collection_objects.push(object)
      object = nil
    end

    # Cache the values for next use !! test
    response.note = note if note
    response.identifier = identifier if identifier
    response.repository = Repository.find(opts['repository']['id']) if opts['repository'] && !opts['repository']['id'].blank?

    response 
  end

  # A Container to store results of create_quick_verbatim
  class QuickVerbatimResponse
    LOCKS = %w{namespace repository increment collecting_event buffered_determinations other_labels note}

    attr_accessor :params
    attr_accessor :collection_objects
    attr_accessor :identifier
    attr_accessor :repository
    attr_accessor :note

    def initialize(options = {})
      @params = options 
      @collection_objects = []
    end

    def identifier=(value)
      @identifier = value
    end

    def identifier
      @identifier ||= Identifier::Local::CatalogNumber.new
    end

    def repository=(value)
      @repository = value
    end

    def repository
      @repository ||= Repository.new
    end

    def note=(value)
      @note = value
    end

    def note 
      @note ||= Note.new
    end

    def save
      begin
        ActiveRecord::Base.transaction do
          @collection_objects.map(&:save!)
        end
        return true
      rescue ActiveRecord::RecordInvalid => invalid
        return false, invalid.record.errors 
      end
    end

    def locked?(name)
      !@params["lock_#{name}"].blank?
    end

    def duplicate_with_locks
      n = QuickVerbatimResponse.new
      n.params     = @params
      n.identifier = @identifier if locked?('identifier')
      n.identifier.identifier = next_identifier if locked?('increment')
      n.repository = @repository if locked?('repository')
      n.note       = @note if locked?('note')
      n 
    end

    def next_identifier
      return nil if !locked?('increment') 
      Utilities::Strings.increment_contained_integer(@identifier.identifier)
    end

  end
end
