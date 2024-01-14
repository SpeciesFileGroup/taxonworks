# Facilitate Batch updates using the pattern of
#   filter_query -> objects to update
#   stub object -> attributes/params to update
class QueryBatchRequest

  # @param object_params [Hash]
  #   update the records to these attributes
  attr_accessor :object_params

  # @param object_filter_params [Hash]
  #   The params to parameterize a Queries::*::Filter.
  #   Defines the objects to be updated
  attr_accessor :object_filter_params

  # @return Boolean
  #   true - rollback changes, can not be used with async
  attr_accessor :preview

  # @return Boolean
  #   processing is handled fully asyn if true, can not be used with preview = true
  attr_accessor :async

  # Number of records at which process is automatically made  async
  attr_accessor :async_cutoff

  # @return nil, Integer
  #   the max allowed records
  attr_accessor :cap

  # @return String, nil
  #   the reason the cap is why it is (not required)
  attr_accessor :cap_reason

  # @return String
  #   defines the Filter/Model to act on
  attr_accessor :klass

  # @return a Queries::<<klass>>::Filter instance
  attr_accessor :filter

  # Count of the records retured in filter.
  #   Not used in async
  attr_accessor :total_attempted

  def initialize(params)
    @async = params[:async]
    @async_cutoff = params[:async_cutoff]
    @cap = params[:cap]
    @cap_reason = params[:cap_reason]
    @klass = params[:klass]
    @object_filter_params = params[:object_filter_params]
    @object_params = params[:object_params]
    @preview = params[:preview]
  end

  def object_filter_params
    filter.params
  end

  def unprocessable?
    object_filter_params.blank? || object_params.blank? || (run_async? && preview)
  end

  def filter
    @filter ||= "Queries::#{klass}::Filter".safe_constantize.new(
      @object_filter_params
    )
    @filter
  end

  def total_attempted
    @total_attempted ||= filter.all.count
    @total_attempted
  end

  def response_params
    {
      klass:,
      async:,
      async_cutoff:,
      preview:,
      cap:,
      cap_reason:,
      total_attempted:
    }
  end

  def stub_response
    BatchResponse.new(response_params)
  end

  def capped?
    if total_attempted > cap
      @cap_reason = "Update to more objects than allowed (#{cap}) requested." if cap_reason.blank?
      return true
    else
      false
    end
  end

  def run_async?
    if async_cutoff 
      return total_attempted > async_cutoff
    end
  end

  # @return Boolean
  #   whether to run the job asyncronously
  def async
    if @async.nil? # force all not specified
      @async = run_async?
    end
    @async
  end

end
