
module Queries

  # Methods to facilitate permission and handling of polymorphic relationships
  module Annotator
    include Arel::Nodes
    
    # @params hash [Hash]
    #   derived from permitted parameters
    # @return [Array of Arel::Nodes::And]
    def self.polymorphic_nodes(hash, klass)
      return nil if hash.empty?
      t = klass.arel_table
      nodes = []
      hash.keys.each do |k|
        model = k.to_s.gsub(/_id$/, '').camelize
        nodes.push(
          t[klass.annotator_id].eq(hash[k]).and(t[klass.annotator_type].eq(model))
        )
      end
      nodes
    end

    # TODO: rename
    # @params params [ActionController::Parameters]
    #    from controller, MUST BE the full, pre-permitted set
    # @params klass [ ApplicationRecord subclass]
    # @return [Arel::Nodes::And]
    #   translates params from requests like `otus/123/data_attributes` to a 
    #   Arel::Nodes::And clause equvialent to `DataAttribute.where(attribute_subject_type: 'Otu', attribute_subject_id: 123)`
    def self.polymorphic_params(params, klass)
      t = klass.arel_table

      h = shallow_id(params, klass) 
      
      return nil if h.size != 1

      a = polymorphic_nodes(h, klass)
      n = a.shift
      a.each do |b|
        n = n.and(b)
      end
      n
    end

    # @return String
    #   name of the class being Annotated
    def self.annotated_class(params, klass)
      h = shallow_id(params, klass)
      return nil if h.size != 1
      h.keys.first.to_s.gsub(/_id$/, '').camelize
    end

    # @return Hash
    def self.shallow_id(params, klass)
      return {} unless params.class.name == 'ActionController::Parameters'
      params.permit(klass.related_foreign_keys).to_h
    end

    # @params params [ActionController::Parameters]
    #    from controller
    # @params klass [ ApplicationRecord subclass]
    # @return [ Arel::Nodes::And ]
    #   for use in SomeAnnotator.where() 
    def self.annotator_params(params, klass)
      t = klass.arel_table

      c = [ polymorphic_params(params, klass) ]

      c.push t[:created_at].lteq(Date.new(*params[:created_before].split('-').map(&:to_i))) if params[:created_before]
      c.push t[:created_at].gteq(Date.new(*params[:created_after].split('-').map(&:to_i))) if params[:created_after]

      c.push t[klass.annotator_type].eq_any(params[:on]) if params[:on]
      c.push t[:id].eq_any(params[:id]) if params[:id]
      c.push t[:created_by_id].eq_any(params[:by]) if params[:by]

      c.compact!

      w = c.pop

      c.each do |q|
        w = w.and(q)
      end

      w
    end

  end
end
