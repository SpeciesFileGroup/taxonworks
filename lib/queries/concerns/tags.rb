# Helpers for queries that reference Identifier
module Queries::Concerns::Tags

  extend ActiveSupport::Concern

  included do
    # @return [Array]
    attr_accessor :keyword_ids
  end

  def set_tags_params(params)
    @keyword_ids = params[:keyword_ids].blank? ? [] : params[:keyword_ids]
  end

  # @return [Arel::Table]
  def tag_table 
    ::Tag.arel_table
  end

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

end
