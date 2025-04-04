module AttributionsHelper

  def attribution_tag(attribution)
    return nil if attribution.nil?
    a = [
      attribution_copyright_tag(attribution),
      attribution_creators_tag(attribution),
      attribution_editors_tag(attribution),
      attribution_owners_tag(attribution),
      attribution_license_tag(attribution),
    ]

    a.compact.join('. ').html_safe
  end

  # @return [String, nil]
  #   no html in _label
  # !! if _tag labels add HTML then they must be removed here
  def label_for_attribution(attribution)
    return nil if attribution.nil?

    a = [
      attribution_copyright_label(attribution),
      attribution_creators_tag(attribution),
      attribution_editors_tag(attribution),
      attribution_owners_tag(attribution),
      attribution_license_tag(attribution),
    ]

    a.compact.join('. ').html_safe
  end

  def attribution_license_tag(attribution)
    return nil if attribution.nil? || attribution.license.blank?
    'License: ' + CREATIVE_COMMONS_LICENSES[attribution.license][:name]
  end

  def attribution_nexml_label(attribution)
    return nil if attribution.nil?
    a = [
      attribution_creators_tag(attribution),
      attribution_owners_tag(attribution),
      attribution.copyright_year
    ]

    a.compact.join(', ').html_safe
  end

  # @return [String, nil]
  def attribution_copyright_label(attribution)
    a = attribution.copyright_year
    b = copyright_agents(attribution)

    return nil unless a or b.any?
    s = '©'
    s << [a, Utilities::Strings.authorship_sentence(b.collect{|c| c.name})].compact.join(' ')
    s
  end

  def attribution_copyright_tag(attribution)
    a = attribution.copyright_year
    b = copyright_agents(attribution)

    return nil unless a or b.any?
    s = '©'
    s << [a, Utilities::Strings.authorship_sentence(b.collect{|c| c.name})].compact.join(' ')
    s.html_safe
  end

  def copyright_agents(attribution)
    return [] if attribution.blank?
    attribution.copyright_holder_roles.eager_load(:organization, :person).collect{|b| b.agent}
  end


  def attribution_creators_tag(attribution)
    a = attribution.creator_roles.eager_load(:organization, :person).collect{|b| b.agent}
    return nil unless a.any?
    ('Created by ' + Utilities::Strings.authorship_sentence(a.collect{|b| b.name})).html_safe
  end

  def attribution_editors_tag(attribution)
    a = attribution.editor_roles.eager_load(:organization, :person).collect{|b| b.agent}
    return nil unless a.any?
    ('Edited by ' + Utilities::Strings.authorship_sentence(a.collect{|b| b.name})).html_safe
  end

  def attribution_owners_tag(attribution)
    a = attribution.owner_roles.eager_load(:organization, :person).collect{|b| b.agent}
    return nil unless a.any?
    ('Owned by ' + Utilities::Strings.authorship_sentence(a.collect{|b| b.name})).html_safe
  end

  # @return [String (html), nil]
  #   a ul/li of tags for the object
  def attribution_list_tag(object)
    return nil unless object.has_attribution? && object.attribution
    content_tag(:h3, 'Attribution') +
      attribution_tag(object.attribution)
  end

  # An attempt at a Human readable simplified response suitable
  # for JSON API responses.
  def attribution_to_json(attribution)
    return nil if attribution.nil?
    a = attribution

    h = a.attributes.select{|k,v| %w{copyright_year license}.include?(k)}

    if a.roles.load.any?
      ::Attribution::ATTRIBUTION_ROLES.each do |r|
        role = "#{r}_roles"
        h[r] = []

        if a.send(role).any?
          a.send(role).order('roles.position ASC').each do |role|
            b = { agent_type: role.agent_type }

            case role.agent_type
            when :person
              b.merge!({
                name: role.person.cached,
                orcid: role.person.orcid,
                wikidata_id: role.person.wikidata_id
              })
            when :organization
              b.merge! role.organization.attributes.select{|k,v| %w{ name alternate_name description disambiguating_description address email telephone duns global_location_number legal_name copyright_year license}.include?(k)}
            end

            h[r].push b.select{|c,d| !d.nil?}
          end

        end
      end
    end

    h
  end

end
