module Shared::IsData::Scopes
  extend ActiveSupport::Concern
 

  module ClassMethods
    # @return [Scope]
    # a where clause that excludes the present object from being selected
    def not_self(object)
      if object.nil? || object.id.blank?
        where(object.class.table_name => {id: '<> 0'})
      else
        where(object.class.arel_table[:id].not_eq(object.to_param))
      end
    end

    # @return [Scope]
    # @params [List of ids or list of AR instances]
    #   a where clause that excludes the records with id = ids 
    # ! Not built for collisions
    def not_ids(*ids)
      where.not(id: ids)
    end
  end

end
