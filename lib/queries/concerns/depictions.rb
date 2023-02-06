# Helpers and facets for queries that reference Depictions/Images 
#
module Queries::Concerns::Depictions
  extend ActiveSupport::Concern

  def self.params
    [ 
      :image_id,
      :images,
      image_id: []
    ]
  end

  included do
    # @return [Array]
    # @params image_id
    attr_accessor :image_id

    # @return [Boolean, nil]
    #  true - has images
    #  false - doesn't have images
    attr_accessor :images

    def image_id
      [@image_id].flatten.compact.uniq
    end
  end

  def set_depiction_params(params)
    @image_id = params[:image_id]
    @images = boolean_param(params, :images)
  end

  # @return
  #   all sources that match all _and ids OR any OR id
  def image_id_facet
    return nil if image_id.empty?
    referenced_klass.joins(:depictions).where(image_id: image_id)
  end

  def images_facet
    return nil if images.nil?
    if images
      return referenced_klass.joins(:depictions).distinct
    else
      return referenced_klass.where.missing(:depictions)
    end
  end

  def image_query_facet
    return nil if image_query.nil?
    s = 'WITH query_images AS (' + image_query.all.to_sql + ')' 

    s << ' ' + referenced_klass
    .joins(:citations)
    .joins('JOIN query_images as query_images1 on citations.image_id = query_images1.id')
    .to_sql

    referenced_klass.from('(' + s + ') as ' + referenced_klass.name.tableize) 
  end

  def self.merge_clauses
    [
      :image_query_facet,
      :image_id_facet,
      :images_facet
    ]
  end

end