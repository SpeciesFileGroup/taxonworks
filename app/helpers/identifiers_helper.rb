module IdentifiersHelper

  def add_identifier_link(object: object, attribute: nil, user: user)
    link_to('Add identifier', new_identifier_path(
        identifier: {
            identified_object_type: object.class.base_class.name,
            identified_object_id: object.id}))
  end

end
