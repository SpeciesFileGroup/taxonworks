module IdentifiersHelper

  def add_identifier_link(object: object, attribute: nil)
    link_to('Add identifier', new_identifier_path(
                                identifier: {
                                    identifier_object_type: object.class.base_class.name,
                                    identifier_object_id: object.id})) if object.has_identifiers?
  end

  def identifier_type_select_options
    Identifier::SHORT_NAMES.collect { |k, v| [k.to_s.humanize, v.name] }
    # SHORT_NAMES = {
    #     doi:   Identifier::Global::Doi,
    #     isbn:  Identifier::Global::Isbn,
    #     issn:  Identifier::Global::Issn,
    #     lccn:  Identifier::Global::Lccn,
    #     orcid: Identifier::Global::Orcid,
    #     uri:   Identifier::Global::Uri,
    #     uuid:  Identifier::Global::Uuid,
    #     catalog_number: Identifier::Local::CatalogNumber,
    #     trip_code: Identifier::Local::TripCode,
    #     import: Identifier::Local::Import,
    #     otu_utility: Identifier::Local::OtuUtility,
    #     accession_code: Identifier::Local::AccessionCode,
    #     unknown: Identifier::Unknown
    # }

  end

  def identifier_tag(identifier)
    return nil if identifier.nil?
    "#{identifier.cached} (#{identifier.type.demodulize.titleize.humanize})"
  end

  def identifier_link(identifier)
    return nil if identifier.nil?
    link_to(identifier_tag(identifier).html_safe, identifier.identifier_object.metamorphosize)
  end

  def identifiers_search_form
    render('/data_attributes/quick_search_form')
  end

  # @return [True]
  #   indicates a custom partial should be used, see list_helper.rb
  def identifiers_partial
    true 
  end

  # @return [True]
  #   indicates a custom partial should be used, see list_helper.rb
  def identifier_recent_objects_partial
    true 
  end




end
