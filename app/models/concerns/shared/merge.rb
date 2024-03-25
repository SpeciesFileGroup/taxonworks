
small hot sour
small chicken noodle soup

orange chicken
mongolian beef
chicken with garlic sauce
szeuan tofu, extra spicy


# Merge concepts
#   
#   When b merges to a the operation is: 
#     `complete` if b is left with no related data
#      `blocked` when merging is prevented by data validations
#     
#  
#
#
#
module Shared::Merge

  extend ActiveSupport::Concern

  included do
  end

  # Iterating thorugh all of these sh
  def merge_relations 
    []
  end

  #  When merging skip these relations
  def relation_exceptions
    []
  end

  # Methods to be called per Class before merge_relations are iterated
  def before_merge
    []
  end

  # Methods to be called per Class after merge_relations are iterated
  def after_merge
    []
  end

  # re-vist this concept from is_data?
  def used?
  end

  def merge(object_to_remove)
    o = object_to_remove

    # All related non-annotation objects, by default
    object.class.transaction do

      begin
        ApplicationEnumeration.data_models.each do |m|


        end
      rescue ActiveRecord::RecordInvalid
      end

    end




  end

end
