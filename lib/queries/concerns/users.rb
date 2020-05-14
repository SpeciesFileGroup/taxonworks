# Helpers for queries that reference created/updated fields
# 
# !! You must have `#base_query` defined in the module to use this
# !! You must call set_user_dates in initialize() # TODO -> how to super/patch this
# TODO: Isolate code to a gem
module Queries::Concerns::Users

  extend ActiveSupport::Concern

  included do

    attr_accessor :user_id

    # @return 'String'
    #   one of 'updated', 'created'
    attr_accessor :user_target

    # In format 'yyyy-mm-dd'
    attr_accessor :user_date_start

    # In format 'yyyy-mm-dd'
    attr_accessor :user_date_end
  end

  def set_user_dates(params)
    @user_id = params[:user_id]
    @user_target = params[:user_target] # Add validation ?
    @user_date_start = params[:user_date_start]
    @user_date_end = params[:user_date_end]
  end

  def user_target
    @user_target&.to_s
  end

  # @return [Scope]
  def created_updated_facet
    return nil if (user_date_start.nil? && user_date_end.nil?) || user_target.nil? || !['updated', 'created'].include?(user_target) # TODO - move to bad param raise
    s, e = Utilities::Dates.normalize_and_order_dates(
      user_date_start,
      user_date_end)

    s += ' 00:00:00' # adjust dates to beginning
    e += ' 23:59:59' # and end of date days

    case user_target
    when 'updated'
      q = base_query.updated_in_date_range(s, e)
      q = q.where(updated_by_id: user_id) if user_id
      q
    when 'created'
      q = base_query.created_in_date_range(s, e)
      q = q.where(created_by_id: user_id) if user_id
      q
    end
  end

end
