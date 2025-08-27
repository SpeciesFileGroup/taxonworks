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

  def lead_tag(lead)
    return nil if lead.nil?
    lead_id(lead) + ' ' + lead_truncated_text(lead)
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
    metadata = key_metadata(lead)

    t = tag.h1(lead.text)
    t << print_key_body(lead, metadata)
    t.html_safe
  end

  def print_key_table(lead)
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

        if label = data.dig(lid, :target_label)
          c = tag.b(label)
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

        if label = data.dig(lid, :target_label)
          c = tag.b(label)
        end

        c = 'TODO: PROVIDE ENDPOINT' if c.blank?

        x.push [a, b, '&mldr;', c, '<br/>']
      end
      x.push '<br/>'
    end

    x.flatten.join(' ').html_safe
  end

  # A depth-first traversal that numbers each entry. Renderers
  # navigate this list in order to draw the key.
  def key_metadata(lead, hsh: {}, depth: 1, couplet_number: { num: 0 }  )
    if lead.children.any?
      couplet_number[:num] += 1
      hsh[lead.id] = {
        children: [],
        parent_id: lead.parent_id,
        position: lead.position,
        couplet_number: lead.origin_label || couplet_number[:num],
        # depth_vector: [depth, lead.parent_id, lead.position],
        depth:
      }
    end

    lead.children.order(:position).each do |l|
      hsh[l.parent_id][:children].push l.id
      key_metadata(l, hsh:, depth: depth + 1, couplet_number:)
    end

    hsh
  end

  # An index of lead.id pointing to its content.
  # lead_items is for internal use only.
  def key_data(lead, metadata, lead_items: false, back_couplets: false)
    data = {}
    data[:back_couplets] = {} if back_couplets
    lead.self_and_descendants.find_each do |l|
      d = {
        text: l.text,
        parent_id: l.parent_id,
        position: l.position,
      }

      if metadata.dig(l.id, :children)&.any?
        couplet_number = metadata.dig(l.id, :couplet_number)
        d.merge!(
          target_label: couplet_number,
          target_type: :internal,
        )
        if back_couplets && (b = metadata.dig(l.parent_id, :couplet_number))
          data[:back_couplets][couplet_number] = b
        end
      elsif l.otu
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
      end

      if lead_items && d[:target_type] != :internal &&
         (lio = lead_item_otus(l)).present?
        d.merge!(
          target_type: 'lead_item_otus',
          lead_item_otus: lio,
          )
      end

      if l.depictions.load.any?
        d.merge!( figures: l.depictions.order(:position).collect{|d| depiction_to_json(d)}  )
      end

      data[l.id] = d
    end
    data
  end

  def lead_item_otus(lead)
    otu_ids = lead.lead_items.map(&:otu_id)
    if otu_ids.empty?
      return []
    end

    Otu.where(id: otu_ids).map { |o| label_for_otu(o) }.sort!
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
    metadata = key_metadata(lead)

    data = key_data(lead, metadata)

    t = ["# #{lead.text}\n\n"]

    # key is couplet number, value is which couplet was sent to that number
    backlinks = {}

    metadata.keys.each do |parent|
      metadata[parent][:children].each do |child|
        # Construct child lines of the form:
        # 1. Child 1 text ... [next couplet # | otu] OR
        # -- Child 2 text ... [next couplet # | otu]
        # a        b                   c          (a,b,c defined below)
        cplt_num = metadata.dig(parent, :couplet_number).to_s
        if data.dig(child, :position) == 0
          backlink = ''
          if p = backlinks[cplt_num]
            backlink = "([#{p}](#cplt-#{p}))"
          end
          # The empty <a> tag here provides an id object to link *to*.
          a = "#{cplt_num}#{backlink}\.<a id=\"cplt-#{cplt_num}\"></a>"

        else
          a = '--'
        end

        b = data.dig(child, :text)

        if (target = data.dig(child, :target_label))
          c = "**#{target}**"
          if data.dig(child, :target_type) == :internal # points to next couplet
            backlinks[target.to_s] = cplt_num
            c = "[#{c}](#cplt-#{target})"
          end
        end

        c = 'TODO: PROVIDE ENDPOINT' if c.blank?

        t.push [a, b, '...', c, " \n"].join(' ')
      end
      t.push "\n"
    end

    t.join.html_safe

  end

  def couplets_count(lead)
    # Couplets - which can have more than two options - are in 1-1
    # correspondence with nodes that have children (via 'couplet' <--> 'parent
    # of that couplet').
    lead.self_and_descendants.count - lead.leaves.count
  end

end
