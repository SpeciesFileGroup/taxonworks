# Helpers for queries that reference created/updated fields
#
# !! You must have `#base_query` defined in the module to use this concern
# !! You must call set_empty_params in initialize()
#
# TODO: Isolate code to a gem
#
# Concern specs are in
#   spec/lib/queries/source/filter_spec.rb
module Queries::Concerns::Empty

  extend ActiveSupport::Concern

  included do

    # @param user_id [Array, Integer, String, nil]
    # @return [Array]
    attr_accessor :empty

    attr_accessor :not_empty

    def empty 
      [@empty].flatten.compact
    end

    def not_empty 
      [@not_empty].flatten.compact
    end
  end

  def set_empty_params(params)
    @empty = params[:empty]
    @not_empty = params[:not_empty]
  end

  # @return [Scope]

  def empty_fields_facet
    return nil if empty.empty?

    a = base_query
    empty.each do |f|
      a = a.where(f => nil)
    end
    a
  end

  def not_empty_fields_facet
    return nil if empty.empty?

    a = base_query
    empty.each do |f|
      a = a.where.not(f => nil)
    end
    a
  end

end
