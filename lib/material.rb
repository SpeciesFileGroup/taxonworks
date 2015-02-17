# Methods for handling the "bulk" accession of collection objects
module Material
    
  def self.create_quick_verbatim(options  = {}) 
    # We could refactor this to use nested attributes, but it's not that much cleaner 
    opts = {
      'collection_objects' => {},
      'note' => nil,
      'biocuration_classes' => [],
      'repository' => {'id' => nil},
      'collection_object' => {}
    }.merge!(options)

    response = QuickVerbatimResponse.new(opts)

    objects = {}
    opts['collection_objects'].keys.each do |k|
      objects.merge!(k => opts['collection_objects'][k]) if !opts['collection_objects'][k]['total'].blank?
    end

    stub_object_attributes = CollectionObject::BiologicalCollectionObject.new(opts['collection_object'].merge('repository_id' => opts['repository']['id']))

    if opts['identifier'] && !opts['identifier']['namespace_id'].blank? && !opts['identifier']['identifier'].blank?
      identifier = Identifier::Local::CatalogNumber.new(
        namespace_id: opts['identifier']['namespace_id'],
        identifier: opts['identifier']['identifier']) 
    end

    container = Container::Virtual.new if objects.keys.count > 1 
    container.identifiers << identifier if container && identifier
    
    note = Note.new(opts['note']) if opts['note'] && !opts['note']['text'].blank? 
    repository = Repository.find(opts['repository']['id']) if opts['repository'] && !opts['repository']['id'].blank?

    objects.keys.each do |o|
      object = stub_object_attributes.dup
      object.total = objects[o]['total']

      if objects[o]['biocuration_classes'] 
        object.biocuration_classes << BiocurationClass.find(objects[o]['biocuration_classes'].keys) 
      end

      object.notes << note.dup if note
      object.container = container if container
      object.identifiers << identifier if identifier && !container 

      response.collection_objects.push(object)
      object = nil
    end

    # Cache the values for next use !! test
    response.note = note if note
    response.identifier = identifier if identifier
    response.repository = repository if repository

    response 
  end

  # A Container to store results of create_quick_verbatim
  class QuickVerbatimResponse
    LOCKS = %w{namespace repository increment collecting_event determinations other_labels note}

    attr_accessor :quick_verbatim_object
    attr_accessor :quick_verbatim_locks

    attr_accessor :form_params

    attr_accessor :collection_objects
    attr_accessor :namespace
    attr_accessor :identifier
    attr_accessor :repository
    attr_accessor :note

    def initialize(options = {})
      @form_params = options 
      build_models
      @collection_objects = []
    end

    def build_models
      @quick_verbatim_object = QuickVerbatimObject.new(@form_params['collection_object'])
      @quick_verbatim_locks = QuickVerbatimLocks.new(@form_params['locks'])
      @note       = Note.new(form_params['note'])
      @repository = Repository.find(form_params['repository']['id']) if (form_params['repository'] && !form_params['repository']['id'].blank?)
      @identifier = Identifier::Local::CatalogNumber.new(form_params['identifier'])
      @namespace =  @identifier.namespace 
    end

    def quick_verbatim_locks=(value)
      @quick_verbatim_locks = value
    end

    def quick_verbatim_object=(value)
      @quick_verbatim_object = value
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

    def namespace=(value)
      @namespace = value
    end

    def namespace 
      @namespace ||= Namespace.new
    end

    def note=(value)
      @note = value
    end

    def note 
      @note ||= Note.new
    end

    def save
      if @collection_objects.size == 0
        errors = ActiveModel::Errors.new('base')  
        errors.add(:total, 'No totals provided!')
        return false, errors
      end

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
      # these are coming off a form
      @quick_verbatim_locks.send(name) == '1' ? true : false
    end

    def duplicate_with_locks
      n = QuickVerbatimResponse.new(@form_params)
      # nullify if not locked
      n.repository = nil if !locked?('repository')
      n.namespace  = nil if !locked?('namespace')
      n.note       = nil if !locked?('note')
      
      n.collection_object.buffered_collecting_event = nil if !locked?('collecting_event')
      n.collection_object.buffered_determinations   = nil if !locked?('determinations')
      n.collection_object.buffered_other_labels     = nil if !locked?('other_labels')
      n.identifier.identifier = next_identifier
      n
    end

    def next_identifier
      return nil if !locked?('increment') 
      Utilities::Strings.increment_contained_integer(identifier.identifier)
    end

    def collection_object
      @quick_verbatim_object ||= QuickVerbatimObject.new
    end

    def locks_object
      @quick_verbatim_locks ||= QuickVerbatimLocks.new
    end
  end

  class QuickVerbatimObject
    # http://blog.plataformatec.com.br/2012/03/barebone-models-to-use-with-actionpack-in-rails-4-0/
    # http://api.rubyonrails.org/classes/ActiveModel/Model.html
    include ActiveModel::Model
    attr_accessor :buffered_other_labels, :buffered_collecting_event, :buffered_determinations
  end

  # Attributes are '1' (true) or '0' false (directly from form form_params)
  class QuickVerbatimLocks
    include ActiveModel::Model
    QuickVerbatimResponse::LOCKS.each do |l|
      attr_accessor l.to_sym
    end

    def initialize(attributes)
      super
      QuickVerbatimResponse::LOCKS.each do |l|
        send("#{l}=", '0') if send(l).blank?
      end
    end
  end
end
