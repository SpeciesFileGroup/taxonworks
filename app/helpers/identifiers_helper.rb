module IdentifiersHelper

  def identifier_tag(identifier)
    return nil if identifier.nil?
    if identifier.new_record?
      nil  
    else
      "#{identifier.cached} (#{identifier.type.demodulize.titleize.humanize})"
    end
  end

  def identifiers_tag(object)
    if object.identifiers.any?
      object.identifiers.collect{|a| content_tag(:span, identifier_tag(a))}.join('; ').html_safe
    end
  end

  def add_identifier_link(object: nil)
    link_to('Add identifier', new_identifier_path(
                                identifier: {
                                    identifier_object_type: object.class.base_class.name,
                                    identifier_object_id: object.id})) if object.has_identifiers?
  end

  def identifier_link(identifier)
    return nil if identifier.nil?
    link_to(identifier_tag(identifier).html_safe, identifier.identifier_object.metamorphosize)
  end

  def identifiers_search_form
    render('/identifiers/quick_search_form')
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

  def identifier_list_tag(object)
    if object.identifiers.any?
      content_tag(:h3, 'Identifiers') +
      content_tag(:ul, class: 'identifier_list') do
        object.identifiers.collect{|a| content_tag(:li, identifier_tag(a)) }.join.html_safe 
      end
    end
  end

  
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
  def identifier_type_select_options
    Identifier::SHORT_NAMES.collect { |k, v| [k.to_s.humanize, v.name] }
  end



end
