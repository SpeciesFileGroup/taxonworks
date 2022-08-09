
module Queries::Concerns::Polymorphic
  extend ActiveSupport::Concern

  included do
    attr_accessor :polymorphic_ids

    attr_accessor :object_global_id

    attr_accessor :global_object

    def self.polymorphic_klass(klass)
      define_singleton_method(:annotating_class){klass}
    end

    def polymorphic_ids=(hash)
      set_polymorphic_ids(hash)
    end

    def object_global_id=(value)
      @object_global_id = value
    end
  end

  def set_polymorphic_ids(hash)
    @polymorphic_ids = hash.select{|k,v| self.class.annotating_class.related_foreign_keys.include?(k.to_s)}
    @polymorphic_ids ||= {}
  end

  # @return [ActiveRecord object, nil]
  def object_for
    if @global_object = GlobalID::Locator.locate(object_global_id)
      @global_object
    else
      nil
    end
  end

  def global_object_id
    object_for&.id
  end

  def global_object_type
    if object_for
      object_for&.class.base_class.name
    else
      nil
    end
  end

  # TODO: Dry with polymorphic_params
  # @return [Arel::Node, nil]
  def matching_polymorphic_ids
    nodes = Queries::Annotator.polymorphic_nodes(polymorphic_ids, self.class.annotating_class)
    return nil if nodes.nil?
    a = nodes.shift
    nodes.each do |b|
      a = a.and(b)
    end
    a
  end

  # Not necessary, handled by splitting out id/type
  # TODO: remove paradigm from Notes facets
  def object_global_id_facet
    return nil if object_global_id.nil?
    o = GlobalID::Locator.locate(object_global_id)
    k = o.class.base_class.name
    id = o.id
    t = self.class.annotating_class.table_name.singularize + '_object'
    table["#{t}_id".to_sym].eq(o.id).and(table["#{t}_type".to_sym].eq(k))
  end

end
