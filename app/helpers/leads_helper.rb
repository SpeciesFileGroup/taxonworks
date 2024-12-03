module LeadsHelper
  def lead_id(lead)
    return nil if lead.nil?
    lead.origin_label ? "[#{lead.origin_label}]" : ''
  end

  def lead_no_text
    '(No text)'
  end

  def lead_truncated_text(lead)
    return nil if lead.nil?
    text = lead.text || lead_no_text
    text.slice(0..25) + (text.size > 25 ? '...' : '')
  end

  def lead_edges(lead)
    edges =
      (lead.parent_id ? '↑' : '') +
      (lead.children.size > 0 ? '↓' : '')
  end

  def lead_tag(lead)
    return nil if lead.nil?
    lead_edges(lead) + lead_id(lead) + ' ' + lead_truncated_text(lead)
  end

  def lead_link(lead)
    return nil if lead.nil?
    link_to(lead_tag(lead), lead)
  end

  def lead_autocomplete_tag(lead)
    lead_tag(lead)
  end

  def label_for_lead(lead)
    lead_tag(lead)
  end

  def leads_search_form
    render('/leads/quick_search_form')
  end

  # @return [True]
  #   indicates a custom partial should be used, see list_helper.rb
  def leads_recent_objects_partial
    true
  end

  def print_key(lead)
    @index = 0  # TODO: get this out of instance
    metadata = key_metadata(lead)

    t = tag.h1(lead.text)
    t <<  print_key_body(lead, metadata)
    t.html_safe
  end

  def print_key_table(lead)
    @index = 0  # TODO: get this out of instance
    metadata = key_metadata(lead)

    t = tag.h1(lead.text)
    t << tag.table(
      print_key_table_body(lead, metadata),
      id: 'key_table'
    )

    t
  end

  def print_key_table_body(lead, metadata)
    data = key_data(lead, metadata)
    x = []

    metadata.keys.each do |k|
      metadata[k][:children].each do |lid|
        a = data.dig(lid, :position) == 0 ? metadata.dig(k, :couplet_number).to_s : '&mdash;'
        b = data.dig(lid, :text)

        if y = tag.b(data.dig(lid, :target_label))
          c = y
        else
          c = metadata.dig(lid, :couplet_number)
        end

        c = 'TODO: PROVIDE ENDPOINT' if c.blank?

        x.push tag.tr(
          [ tag.td(a.html_safe),
            tag.td(b),
            tag.td(c)
          ].join.html_safe
        )
      end
    end

    x.join.html_safe
  end

  def print_key_body(lead, metadata)
    data = key_data(lead, metadata)
    x = []

    metadata.keys.each do |k|
      metadata[k][:children].each do |lid|
        a = data.dig(lid, :position) == 0 ? metadata.dig(k, :couplet_number).to_s + '.' : '&mdash;'
        b = data.dig(lid, :text)

        if y = tag.b(data.dig(lid, :target_label))
          c = y
        else
          c = metadata.dig(lid, :couplet_number)
        end

        c = 'TODO: PROVIDE ENDPOINT' if c.blank?

        x.push [a,b, '&mldr;', c, '<br/>']
      end
      x.push '<br/>'
    end

    x.flatten.join(' ').html_safe
  end

  # A depth-first traversal that numbers each entry. Renderers
  # navigate this list in order to draw the key.
  def key_metadata(lead, hsh: {}, depth: 1, couplet_number: 0  )
    @index ||= 0
    if lead.children.any?
      @index += 1
      hsh[lead.id] = {
        children: [],
        parent_id: lead.parent_id,
        position: lead.position,
        couplet_number: lead.origin_label || @index,
        # depth_vector: [depth, lead.parent_id, lead.position],
        depth:
      }
    end

    lead.children.order(:position).each_with_index do |l, i|
      hsh[l.parent_id][:children].push l.id
      key_metadata(l, hsh:, depth: depth + 1 )
    end

    hsh
  end

  # An index of lead.id poisting to it's content
  def key_data(lead, metadata)
    data = {}
    lead.self_and_descendants.find_each do |l|
      d = {
        text: l.text,
        parent_id: l.parent_id,
        position: l.position,
      }

      if l.otu
        d.merge!(
          target_label: ( l.otu ? label_for_otu(l.otu) : nil ),
          target_id: l.otu&.id,
          target_type: '/api/v1/otus',  # some concept of pointing to the
        )
      elsif l.link_out_text
        d.merge!(
          target_label: l.link_out_text,
          target_type: :link_out,
          target_link: l.link_out
        )
      else
        d.merge!(
          target_label: metadata.dig(l.id, :couplet_number),
          target_type: :internal,
        )
      end

      if l.depictions.load.any?
        d.merge!( figures: l.depictions.order(:position).collect{|d| depiction_to_json(d)}  )
      end

      data[l.id] = d
    end
    data
  end

  # Used to serve Keys to the API.
  # Targeting a "standard" for exchanging keys to be used in the
  # front end at https://github.com/SpeciesFileGroup/pinpoint
  def key_to_json(lead)
    m = key_metadata(lead)
    d = key_data(lead, m)
    return {
      metadata: {
        server: root_url,
        key_version: '0.0.1',
        title: lead.text,
        origin_citation: lead.source&.cached,
        attribution: attribution_to_json(lead.attribution),
        taxonomic_scope: label_for_otu(lead.otu) # perhaps extend with identifiers, probably ultimately nested, with IDs
      },
      data: {
        entries: m,
        leads: d
      }
    }
  end

  def print_key_markdown(lead)
  end

end
