# Shared code for Citations
#
module Shared::Citable
  extend ActiveSupport::Concern

  included do
    related_class = self.name
    related_table_name = self.table_name

    has_many :citations, as: :citation_object, validate: false, dependent: :destroy
    has_many :sources, -> { uniq }, through: :citations

    has_one :origin_citation, -> {where(is_original: true)}, as: :citation_object, class_name: 'Citation'
    has_one :source, through: :origin_citation

   # oldest first!
   #  scope :order_by_source_date, -> { 
   #    joins("LEFT OUTER JOIN citations c on #{related_table_name}.id = c.citation_object_id LEFT OUTER JOIN sources s ON c.source_id = s.id").
   #    group("#{related_table_name}.id, COALESCE(s.cached_nomenclature_date, Now())").
   #    where("c.citation_object_type = '#{related_class}'").
   #    order("(COALESCE(s.cached_nomenclature_date, Now()))")
   #  } 

    # yougest first!
    scope :order_by_yougest_source_date, -> { 
      joins("LEFT OUTER JOIN citations c on #{related_table_name}.id = c.citation_object_id LEFT OUTER JOIN sources s ON c.source_id = s.id").
      group("#{related_table_name}.id, COALESCE(s.cached_nomenclature_date, Now())").order("COALESCE(s.cached_nomenclature_date, Now()) DESC").
      where("c.citation_object_type = '#{related_class}'")
    } 


    accepts_nested_attributes_for :citations, reject_if: :reject_citations, allow_destroy: true
    accepts_nested_attributes_for :origin_citation, reject_if: :reject_citations, allow_destroy: true


  define_singleton_method "order_by_source_date" do
    d =  Arel::Attribute.new(Arel::Table.new(:sources), :cached_nomenclature_date)
    r  = Arel::Attribute.new(Arel::Table.new(related_table_name), :id)
    f1 = Arel::Nodes::NamedFunction.new('Now', [] )
    func = Arel::Nodes::NamedFunction.new('COALESCE', [d, f1])

    #  inner_joins = joins(:citations,  :sources).arel.join_sources
    #  left_joins = inner_joins.map do |join|
    #    Arel::Nodes::OuterJoin.new(join.left, join.right)
    #  end

    joins("LEFT OUTER JOIN citations on #{related_table_name}.id = citations.citation_object_id LEFT OUTER JOIN sources ON citations.source_id = sources.id").
      where("citations.citation_object_type = '#{related_class}'").
      group(r, func).
      order(func)
  end

    #  has_one :oldest_by_citation, -> { order_by_source_date.limit(1) } 
  end

  class_methods do

    def oldest_by_citation
      order_by_source_date.limit(1).to_a.first
    end

#   def most_recent_by_citation
#     order_by_source_date.limit(1).to_a.first
#   end



  end

  def cited?
    self.citations.any?
  end

  protected 

  def reject_citations(attributed)
    attributed['source_id'].blank? # || attributed['type'].blank?
  end

end
