module TypeMaterials::CatalogHelper

  # Return text only, no HTML. 
  # To be used in paper catalogs, this is to be human readable.
  #   If we need italics or bold use Markdown, and we will compile after that
  def type_material_catalog_label(type_material) # Possibly parameterize biocurations: true, repository: true, identifiers: true
    t = type_material
    return '[TODO: Add type material]' if t.nil? # Anticipate rendering in paper

    co = t.collection_object
    ce = co.collecting_event

    v = []

    # Holotype male, adult, INHS 12312, deposited: <repoo name>. <verbatim_label>.

    v.push t.type_type.capitalize + (co.total > 1 ? " (n= #{co.total})" : '')
    v.push co.biocuration_classes.collect{|a| a.name.downcase}.join(', ').presence
    
    v.push label_for_identifier(co.identifiers.first)

    if d = label_for_repository(co.repository)
      v.push "deposited at: #{d}" 
    else
      v.push "[TODO: Repository NOT PROVIDED]"
    end

    v.push type_material_collecting_event_label(type_material.collection_object.collecting_event)

    v.compact.join('; ')
  end

  # @return [String] 
  #   Must return a string, if no value then the wqrning is returned
  def type_material_collecting_event_label(collecting_event)
    missing_ce_msg = '[TODO: A document (preferred) or verbatim label in a collecting event must be provided]'
    if ce = collecting_event
      if ce.document_label
        document_label # process to linearize here.  See functions in Strings::Utilities, don't add content her
      elsif ce.verbatim_label
        ce.verbatim_label # process to linearize here
      else
        missing_ce_message
      end
    end
  end

end
