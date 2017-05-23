module CollectionObjectCatalog

  # Is 1:1 with an event in the history of the object, as indexed by date (range) 
  class EntryItem 

    # The base object from which this event is derived, required
    attr_accessor :object

    # Arbitrary categorization of event as per EVENT_TYPES, required
    attr_accessor :type

    # The earliest point at which the event could have happened. 
    # If end_date is not provided *assumed* to be exact
    attr_accessor :start_date

    # The latest point at which the event could have happened.
    attr_accessor :end_date

    def initialize(object: nil, type: nil, start_date: nil, end_date: nil)
      raise TaxonWorks::Error, ':object is nil' if object.nil?
      raise TaxonWorks::Error, ':type is nil' if type.nil?
      raise TaxonWorks::Error, 'type is not in the list' if !CollectionObjectCatalog::EVENT_TYPES.include?(type)
      raise TaxonWorks::Error, 'start_date is not a DateTime' if start_date && !start_date.kind_of?(Time)
      raise TaxonWorks::Error, 'end_date is not a DateTime' if end_date && !end_date.kind_of?(Time)

      @object = object
      @start_date = start_date
      @type = type
      @end_date = end_date
    end

    def object_class
      object.class.name
    end
  end
end
