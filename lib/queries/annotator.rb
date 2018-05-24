
module Queries
  module Annotator
    include Arel::Nodes

    
    # @params params [ActionController::Parameters]
    #    from controller, MUST BE the full, pre-permitted set
    # @params klass [ ApplicationRecord subclass]
    # @return [ Arel::Nodes ]
    #   translates params from requests like `otus/123/data_attributes` to a 
    #   Arel nodes clause equvialent to `DataAttribute.where(attribute_subject_type: 'Otu', attribute_subject_id: 123)`
    def self.polymorphic_params(params, klass)
      t = klass.arel_table
      h = params.permit(klass.related_foreign_keys).to_h
      return nil if h.size != 1 

      model = h.keys.first.gsub(/_id$/, '').camelize

      t[klass.annotator_id].eq(h.values.first).and(t[klass.annotator_type].eq(model))
    end

    # @params params [ActionController::Parameters]
    #    from controller
    # @params klass [ ApplicationRecord subclass]
    # @return [ Arel::Nodes ]
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
