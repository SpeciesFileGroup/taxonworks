class BatchResponse

  # Name of the class called, if used
  attr_accessor :klass

  # Name of the method called
  attr_accessor :method

  # @return Boolean 
  #   no writes were made
  attr_accessor :preview

  # @return Boolean 
  #   processing is handled asyn
  attr_accessor :async

  # @return Array
  #   ids of the objects updated
  attr_accessor :updated

  # @return Array
  #   ids of the objects not update
  attr_accessor :not_updated

  # @return list of unique Error messages
  # encounterd, not per object!
  attr_accessor :errors

  attr_accessor :total_attempted

  # #return nil, integer
  attr_accessor :cap

  # @return String
  attr_accessor :cap_reason

  def initialize
    @updated = []
    @not_updated = []
    @async = false
    @preview = false
    @errors = []
    @total_attempted = 0
  end

  def to_json
    {
      klass:,
      method:,
      preview:,
      async:,
      updated:,
      not_updated:,
      errors:,
      total_attempted:,
      cap:,
      cap_reason:,
    }
  end

end
