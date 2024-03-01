# Helpers for queries that reference created/updated fields
#
# !! You must have `#base_query` defined in the module to use this concern
# !! You must call set_user_dates in initialize()
# * TODO: Isolate code to a gem
# * TODO: validate User/Project relationships
#
# Concern specs are in
#   spec/lib/queries/person/filter_spec.rb
#   spec/lib/queries/collection_object/filter_spec.rb (housekeeping extensions)
module Queries::Concerns::Users

  extend ActiveSupport::Concern

  def self.params
    [
      :user_id,
      :user_target,
      :user_date_start,
      :user_date_end,
      :updated_since,
      :extend_houskeeping,
      user_id: [],
    ]
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

    # @return [Boolean, nil]
    # @param extend_housekeeping
    #   if true and pertinent models have 'HOUSEKEEPING_EXTENSIONS = [:relation1, :relation2]'
    #     then include records that have changed in the extended models as well
    attr_accessor :extend_housekeeping

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
    @extend_housekeeping = boolean_param(params, :extend_housekeeping)
    @updated_since = params[:updated_since]
    @user_date_end = params[:user_date_end]
    @user_date_start = params[:user_date_start]
    @user_id = params[:user_id]
    @user_target = params[:user_target] # Add validation ?
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

  def created_updated_facet(target: base_query, disable_extension: false)
    return nil if user_id.empty? && user_target.nil? && user_date_start.nil? && user_date_end.nil?

    if !user_date_start.nil? || !user_date_end.nil?
      q = time_scope(target:)
    else
      q = target || base_query
    end

   if !user_id.empty?
     q = user_scope(target: q)
   end

   if !disable_extension && extend_housekeeping && !housekeeping_extensions.empty?
     q = referenced_klass_union( [q] + housekeeping_extensions )
   end

    q
  end

  # Defined in Filters
  def housekeeping_extensions
    []
  end

  # @param target [the joined class]
  # @param joins [Array] to add to join()
  def housekeeping_extension_query(target: nil, joins: [])
    raise 'no target' if target.nil?

    id_name = "hkx_#{target.name.downcase}_id"
    query_name = "query_#{target.name}_hkx"
    tbl = table.name

    b = created_updated_facet(
      target: target.all,
      disable_extension: true
    ).select("id #{id_name}")

    q = referenced_klass
    q = q.joins(joins) if !joins.empty?
    q = q.joins("JOIN #{query_name} as #{query_name}1 on #{query_name}1.#{id_name} = #{target.arel_table.name}.id")

    s = "WITH #{query_name} AS (" + b.to_sql + ') ' + q.to_sql

    referenced_klass.from('(' + s + ") as #{tbl}").distinct
  end

  def time_scope(target: base_query)
    return nil if user_date_start.nil? && user_date_end.nil?

    s, e = Utilities::Dates.normalize_and_order_dates(
      user_date_start,
      user_date_end)

    # TODO: this is ultimately going to require hourly scope
    s += ' 00:00:00' # adjust dates to beginning
    e += ' 23:59:59' # and end of date days

    q = nil

    # handle date range

    # What date?
    if !user_date_start.nil? || !user_date_end.nil?
      case user_target
      when 'updated'
        q = target.updated_in_date_range(s, e)
      when 'created'
        q = target.created_in_date_range(s, e)
      else
        # TODO: UNION !!!
        q = target.updated_in_date_range(s, e).or(target.created_in_date_range(s,e))
      end
    end

    q
  end

  def user_scope(target: base_user)
    return nil if user_id.empty? && user_target.nil?

    q = target

    # handle user_id
    if !user_id.empty?
      case user_target
      when 'updated'
        q = q.where(updated_by_id: user_id)
      when 'created'
        q = q.where(created_by_id: user_id)
      else
        # TODO: UNION
        q = q.where(created_by_id: user_id).or(q.where(updated_by_id: user_id))
      end
    end
    q
  end

end
