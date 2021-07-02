# Helpers for queries that reference created/updated fields
#
# !! You must have `#base_query` defined in the module to use this concern
# !! You must call set_user_dates in initialize()
# TODO: Isolate code to a gem
#
# Concern specs are in
#   spec/lib/queries/person/filter_spec.rb
module Queries::Concerns::Users

  extend ActiveSupport::Concern

  included do

    # @param user_id [Array, Integer, String, nil]
    # @return [Array]
    attr_accessor :user_id

    # @return 'String'
    #   one of 'updated', 'created'
    attr_accessor :user_target

    # @param user_date_start [String, nil]
    #  In format 'yyyy-mm-dd'
    attr_accessor :user_date_start

    # @param user_date_end [String, nil]
    #   In format 'yyyy-mm-dd'
    attr_accessor :user_date_end

    def user_id
      [@user_id].flatten.compact
    end

    def user_target
      @user_target&.to_s
    end
  end

  def set_user_dates(params)
    @user_id = params[:user_id]
    @user_target = params[:user_target] # Add validation ?
    @user_date_start = params[:user_date_start]
    @user_date_end = params[:user_date_end]
  end

  # @return [Scope]

  def created_updated_facet
    return nil if user_id.empty? && user_target.nil? && user_date_start.nil? && user_date_end.nil?
    s, e = Utilities::Dates.normalize_and_order_dates(
      user_date_start,
      user_date_end)

    # TODO: this is ultimately going to require hourly scope
    s += ' 00:00:00' # adjust dates to beginning
    e += ' 23:59:59' # and end of date days

    q = nil

    # hand date range

    # What date?
    if !user_date_start.nil? || !user_date_end.nil?
      case user_target
      when 'updated'
        q = base_query.updated_in_date_range(s, e)
      when 'created'
        q = base_query.created_in_date_range(s, e)
      else
        q = base_query.updated_in_date_range(s, e).or(base_query.created_in_date_range(s,e))
      end
    end

    q = base_query if q.nil?

    # handle user_id
    if !user_id.empty?
      case user_target
      when 'updated'
        q = q.where(updated_by_id: user_id)
      when 'created'
        q = q.where(created_by_id: user_id)
      else
        q = q.where(created_by_id: user_id).or(q.where(updated_by_id: user_id))
      end
    end
    q
  end

end
