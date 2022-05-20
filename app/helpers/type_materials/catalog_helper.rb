module TypeMaterials::CatalogHelper

  # Return text only, no HTML.
  # To be used in paper catalogs, this is to be human readable.
  #   If we need italics or bold use Markdown, and we will compile after that
  def type_material_catalog_label(type_material, verbose = false) # Possibly parameterize biocurations: true, repository: true, identifiers: true
    t = type_material

    if t.nil? && verbose # Anticipate rendering in paper
      return '[TODO: Add type material]'
    elsif t.nil?
      return nil
    end

    co = t.collection_object
    ce = co.collecting_event

    v = []

    # Holotype male, adult, INHS 12312, deposited: <repoo name>. <verbatim_label>.

    v.push t.type_type.capitalize + (co.total > 1 ? " (n= #{co.total})" : '')
    v.push co.biocuration_classes.collect{|a| a.name.downcase}.join(', ').presence

    # TODO: add verbose warning when missing any identifier
    # TODO: add option(?) to render all identifiers
    v.push label_for_identifier(
      co.identifiers.prefer('Identifier::Local::CatalogNumber').first
    )

    if d = label_for_repository(co.repository)
      v.push "deposited at: #{d}"
    else
      if verbose
        v.push "[TODO: Repository NOT PROVIDED]"
      end
    end

    v.push type_material_collecting_event_label(type_material.collection_object.collecting_event, verbose)
    v.compact.join('; ')
  end

  # @return [String]
  #   Must return a string, if no value then the wqrning is returned
  def type_material_collecting_event_label(collecting_event, verbose = false)
    missing = '[TODO: A document (preferred) or verbatim label in a collecting event must be provided]'
    if ce = collecting_event
      if ce.document_label
        return ::Utilities::Strings.linearize(document_label)
      elsif ce.verbatim_label
        return  ::Utilities::Strings.linearize(ce.verbatim_label)
      end
    end
    verbose ? missing : nil
  end

end
