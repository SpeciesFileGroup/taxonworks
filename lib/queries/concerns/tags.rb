# Helpers for queries that reference Tags
# Assumes `def table` in included record
module Queries::Concerns::Tags

  extend ActiveSupport::Concern

  included do
    # @return [Array]
    attr_accessor :keyword_ids

    # @return [Boolean, nil]
    # @params tags ['true', 'false', nil]
    attr_accessor :tags
  end

  def set_tags_params(params)
    @keyword_ids = params[:keyword_ids].blank? ? [] : params[:keyword_ids]
    @wtags = (params[:wtags]&.downcase == 'true' ? true : false) if !params[:wtags].nil?
  end

  # @return [Arel::Table]
  def tag_table 
    ::Tag.arel_table
  end

  def keyword_ids=(value = [])
    @keyword_ids = value
  end

  # a merge
  def matching_keyword_ids
    return nil if keyword_ids.empty?
    k = table.name.classify.safe_constantize
    t = ::Tag.arel_table
    k.where(
      ::Tag.where(
        t[:tag_object_id].eq(table[:id]).and(
          t[:tag_object_type].eq(table.name.classify)).and(
            t[:keyword_id].eq_any(keyword_ids)
          )
      ).arel.exists
    )
  end

  def tag_facet
    return nil if tags.nil?
    k = table.name.classify.safe_constantize

    if tags
      k.joins(:tags).distinct
    else
      k.left_outer_joins(:tags)
        .where(tags: {id: nil})
    end
  end

end
