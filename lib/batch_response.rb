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

  # @return Hash
  #   a list of error messages summarized by times encountered (not the objects they were on)
  #
  attr_accessor :errors

  attr_accessor :total_attempted

  # #return nil, integer
  attr_accessor :cap

  # @return String
  attr_accessor :cap_reason

  def initialize(params)
    @updated = params[:updated] || []
    @not_updated = params[:not_updated] || []
    @async = params[:async] || false
    @preview = params[:preview] || false
    @errors = Hash.new(0)
    @total_attempted = params[:total_attempted] || 0
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
