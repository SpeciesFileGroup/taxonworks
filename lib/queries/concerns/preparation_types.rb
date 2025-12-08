# Helpers and facets for queries that reference PreparationTypes.
#
module Queries::Concerns::PreparationTypes

  extend ActiveSupport::Concern

  def self.params
    [
      :preparation_type,
      :preparation_type_id,

      preparation_type_id: [],
    ]
  end

  included do
    # @return [Array]
    # @params preparation_type_id
    #   match any objects linked to any preparation_types referenced here
    attr_accessor :preparation_type_id

    # @return [Boolean, nil]
    # @params preparation_type ['true', 'false', nil]
    #   true - return objects that reference a preparation_type
    #   false - return objects that reference no preparation_type
    #   nil - ignored
    attr_accessor :preparation_type

    def preparation_type_id
      [@preparation_type_id].flatten.compact.uniq
    end

    def set_preparation_types_params(params)
      @preparation_type_id = params[:preparation_type_id]
      @preparation_type = boolean_param(params, :preparation_type)
    end
  end

  def preparation_type_id_facet
    return nil if preparation_type_id.empty?

    referenced_klass.joins(:preparation_type)
      .where(preparation_type: { id: preparation_type_id })
  end

  def preparation_type_facet
    return nil if preparation_type.nil?

    if preparation_type
      referenced_klass.joins(:preparation_type).distinct
    else
      referenced_klass.where.missing(:preparation_type)
    end
  end

  def self.merge_clauses
    [
      :preparation_type_id_facet,
      :preparation_type_facet
    ]
  end

end
