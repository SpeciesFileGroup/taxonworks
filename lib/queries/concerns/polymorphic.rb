
module Queries::Concerns::Polymorphic
  extend ActiveSupport::Concern

  included do
    attr_accessor :polymorphic_ids

    def self.polymorphic_klass(klass)
      define_singleton_method(:annotating_class){klass} 
    end
 
    def polymorphic_ids=(hash)
      set_polymorphic_ids(hash)
    end 
  end

   def set_polymorphic_ids(hash)
    @polymorphic_ids = hash.select{|k,v| self.class.annotating_class.related_foreign_keys.include?(k.to_s)} 
    @polymorphic_ids ||= {}
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

end
