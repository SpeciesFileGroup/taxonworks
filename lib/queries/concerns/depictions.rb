# Helpers and facets for queries that reference Depictions/Images
#
module Queries::Concerns::Depictions
  extend ActiveSupport::Concern

  def self.params
    [
      :image_id,
      :images,
      :depictions,
      :data_depictions,
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

    # @return [Boolean, nil]
    # Alias/identical to images
    #  true - has images
    #  false - doesn't have images
    attr_accessor :depictions

    # @return [Boolean, nil]
    # Alias/identical to images
    #  true - has depicitions that are data depictions
    #  false - doesn't have depictions that are data depictions
    attr_accessor :data_depictions

    def image_id
      [@image_id].flatten.compact.uniq
    end
  end

  def set_depiction_params(params)
    @image_id = params[:image_id]

    @images = boolean_param(params, :images)
    @depictions = boolean_param(params, :depictions)
    @data_depictions = boolean_param(params, :data_depictions)
  end

  def image_id_facet
    return nil if image_id.empty?
    referenced_klass.joins(:depictions).where(depictions: {image_id:})
  end

  # !! Duplicate with images
  def depictions_facet
    return nil if depictions.blank?
    if depictions
      referenced_klass.joins(:depictions).distinct
    else
      referenced_klass.where.missing(:depictions)
    end
  end

  def data_depiction_facet
    return nil if data_depictions.blank?
    if data_depictions
      referenced_klass.joins(:depictions).where(depictions: {is_metadata_depiction: true}).distinct
    else
      a = referenced_klass.where.missing(:depictions)
      b = referenced_klass.joins(:depictions).where.not(depictions: {is_metadata_depiction: true})

      referenced_klass_union([a,b]).distinct
    end
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
    .joins(:depictions)
    .joins('JOIN query_images as query_images1 on depictions.image_id = query_images1.id')
    .to_sql

    referenced_klass.from('(' + s + ') as ' + referenced_klass.name.tableize)
  end

  def self.merge_clauses
    [
      :data_depiction_facet,
      :depictions_facet,
      :image_id_facet,
      :image_query_facet,
      :images_facet
    ]
  end

end
