# Helpers and facets for queries that reference Tags.
#
# Test coverage is currently in spec/lib/queries/source/filter_spec.rb.
#
# You must define
#
#    def table
#      :;Model.arel_table
#    end
#
# in including modules.
#
module Queries::Concerns::Tags

  extend ActiveSupport::Concern

  included do

    # @return [Array]
    # @params keyword_id_and [:keyword_id_and | [keyword_id_and, .. ] ]
    attr_accessor :keyword_id_and

    # @return [Array]
    # @params keyword_id_or [:keyword_id_or | [keyword_id_or, .. ] ]
    attr_accessor :keyword_id_or

    # @return [Boolean, nil]
    # @params tags ['true', 'false', nil]
    attr_accessor :tags
  end

  def set_tags_params(params)
    @keyword_id_and = params[:keyword_id_and].blank? ? [] : params[:keyword_id_and]
    @keyword_id_or = params[:keyword_id_or].blank? ? [] : params[:keyword_id_or]

    @tags = (params[:tags]&.downcase == 'true' ? true : false) if !params[:tags].nil?
  end

  def keyword_id_and
    [@keyword_id_and].flatten
  end

  def keyword_id_or
    [@keyword_id_or].flatten
  end

  # @return [Arel::Table]
  def tag_table 
    ::Tag.arel_table
  end

  def keyword_ids=(value = [])
    @keyword_ids = value
  end

  # @return
  #   all sources that match all _and ids OR any OR id
  def keyword_id_facet
    return nil if keyword_id_or.empty? && keyword_id_and.empty?
    k = table.name.classify.safe_constantize
    

    a = matching_keyword_id_or
    b = matching_keyword_id_and

    if a.nil?
      b
    elsif b.nil?
      a
    else
      k.from("( (#{a.to_sql}) UNION (#{b.to_sql})) as sources")
    end
  end

  # merge
  def matching_keyword_id_or
    return nil if keyword_id_or.empty?
    k = table.name.classify.safe_constantize
    t = ::Tag.arel_table

    w = t[:tag_object_id].eq(table[:id]).and( t[:tag_object_type].eq(table.name.classify))
    w = w.and( t[:keyword_id].eq_any(keyword_id_or) ) if keyword_id_or.any? 

    k.where( ::Tag.where(w).arel.exists )
  end

  # merge
  def matching_keyword_id_and
    return nil if keyword_id_and.empty?
    l = table.name
    k = l.classify.safe_constantize
    t = ::Tag.arel_table

    a = table.alias("k_#{l}")

    b = table.project(a[Arel.star]).from(a)
      .join(t)
      .on(
        t[:tag_object_id].eq(a[:id]),
        t[:tag_object_type].eq(k.name)
      )

    i = 0

    keyword_id_and.each do |j|
      t_a = t.alias("tk_#{l[0..5]}_#{i}")
      b = b.join(t_a).on(
        t_a['tag_object_id'].eq(a['id']),
        t_a[:tag_object_type].eq(k),
        t_a[:keyword_id].eq(j)
      )

      i += 1
    end

    b = b.group(a[:id]).having(t[:keyword_id].count.gteq(keyword_id_and.count))
    b = b.as("#{l}_ai")

    k.joins(Arel::Nodes::InnerJoin.new(b, Arel::Nodes::On.new(b[:id].eq(table[:id]))))
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
