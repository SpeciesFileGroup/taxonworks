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

  def self.permit(params)
    params.permit(
      :user_id,
      :user_target,
      :user_date_start,
      :user_date_end,
      :updated_since
    )
  end

  included do

    # @param user_id [Array, Integer, String, nil]
    # @return [Array]
    attr_accessor :user_id

    # @return 'String'
    #   one of 'updated', 'created'
    attr_accessor :user_target

    # @param user_date_start [String]
    #  In format 'yyyy-mm-dd'
    attr_accessor :user_date_start

    # @return [String, nil]
    # @param user_date_end [String]
    #   In format 'yyyy-mm-dd'
    attr_accessor :user_date_end

    # @return [Date, nil] 
    # @param updated_since [String] in format yyyy-mm-dd
    #   Records updated (.updated_at) since this date
    attr_accessor :updated_since

    def user_id
      [@user_id].flatten.compact
    end

    def user_target
      @user_target&.to_s
    end

    def updated_since
      return nil if @updated_since.blank?
      Date.parse(@updated_since)
    end
  end

  def set_user_dates(params)
    @user_id = params[:user_id]
    @user_target = params[:user_target] # Add validation ?
    @user_date_start = params[:user_date_start]
    @user_date_end = params[:user_date_end]
    @updated_since = params[:updated_since]
  end

  def self.merge_clauses
    [ :created_updated_facet ]
  end

  def self.and_clauses
    [ :updated_since_facet ]
  end

  def updated_since_facet
    return nil if updated_since.blank?
    table[:updated_at].gteq(updated_since)
  end

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
