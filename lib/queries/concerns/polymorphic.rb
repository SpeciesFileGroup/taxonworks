# Used to handle params from shallow routes like /otus/123/data_attributes 
# These translate to `otu_id: 123`.
# !! Only include in annotating filters.
module Queries::Concerns::Polymorphic
  extend ActiveSupport::Concern

  def self.params
    [ 
#     :polymorphic_id,
#     :polymorphic_type
    ] 
  end

  included do
    # @return [id, nil] 
    attr_accessor :polymorphic_id
 
    # @return [ `type` like 'CollectionObject, nil]
    attr_accessor :polymorphic_type

    def self.polymorphic_klass(klass)
      define_singleton_method(:annotating_class){klass}
    end

    # @params Hash, already permitted
    def set_polymorphic_params(params)
      h  = params.select{|k,v| self.class.annotating_class.related_foreign_keys.include?(k.to_s)} 

      # If it's coming in some other way it's not polymorphic/shallow route handling
      return if h.size != 1
      @polymorphic_id = h.values.first
      
      k = h.keys.first
      @polymorphic_type = k.to_s.gsub('_id', '').camelize
    end
  end

  def polymorphic_id_facet
    return nil if polymorphic_id.blank?
    table[referenced_klass.annotator_id].eq(polymorphic_id).and(table[referenced_klass.annotator_type].eq(polymorphic_type))
  end

  def self.and_clauses
    [ :polymorphic_id_facet ]
  end

end
