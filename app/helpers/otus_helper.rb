module OtusHelper
  include RecordNavigationHelper

  # # OTU labels
  # def otu_tag(otu)
  #   return nil if otu.nil?
  #   a = []
  #   a.push(content_tag(:span, otu.name, class: :otu_name))  if !otu.name.blank?

  #   if otu.taxon_name
  #     a.push "in" if !otu.name.blank?

  #     b = [ content_tag(:span, full_original_taxon_name_tag(otu.taxon_name), class: :otu_written) ]

  #     if !otu.taxon_name.is_valid?
  #       b.push 'now'
  #       b.push content_tag(:span, full_taxon_name_tag(otu.taxon_name.valid_taxon_name), class: :otu_current)
  #     end

  #     a.push content_tag(:span, b.join(' ').html_safe, class: :otu_taxon_name)
  #     a.push taxon_name_type_short_tag(otu.taxon_name).html_safe
  #   end
  #
  #   tag.span( a.flatten.compact.join(' ').html_safe, class: :otu_tag )
  # end

  def otu_tag(otu)
    return nil if otu.nil?
    return  tag.span(tag.b(otu.name), class: :otu_tag) unless otu.taxon_name.present?

    if otu.taxon_name.is_combination?
      if otu.name?
        tag.span(
          [ tag.b(otu.name),
            otu.taxon_name.cached_html
          ].join(' ' + tag.em('==') + ' ').html_safe,
        class: :otu_tag
        )
      else
        tag.span(
          (otu.taxon_name.cached_html + ' ' + TaxonNamesHelper::COMBINATION_MARK).html_safe,
          class: :otu_tag
        )
      end

    else # protonym
      if otu.taxon_name.is_valid?
        if otu.name
          tag.span(
            [ otu.taxon_name.cached_html,
              tag.b(otu.name)
            ].compact.join('&nbsp;').html_safe,
          class: :otu_tag
          )
        else
          tag.span(
            full_taxon_name_tag(otu.taxon_name),
            class: :otu_tag
          )
        end

      else # invalid taxon name
        tag.span(
          [
            [ full_taxon_name_tag(otu.taxon_name),
              ( otu.name ? tag.b(otu.name) : nil )
            ].compact.join('&nbsp;'),

          [ full_taxon_name_tag(otu.taxon_name.valid_taxon_name),
            ( otu.name ? tag.b(otu.name) : nil )
          ].compact.join('&nbsp;')
          ].join(' ' + tag.em('now') + ' ').html_safe,
          class: :otu_tag
        )

      end
    end
  end

  def label_for_otu(otu)
    return nil if otu.nil?
    if otu.taxon_name
      if otu.taxon_name.is_combination?

        if otu.name?
          [
            otu.name,
            label_for_taxon_name(otu.taxon_name)
          ].compact.join(' == ').html_safe
        else
          label_for_taxon_name(otu.taxon_name) + ' [c]'
        end

      else # protonym
        if otu.taxon_name.is_valid?

          [ label_for_taxon_name(otu.taxon_name),
            otu.name
          ].compact.join(' ')

        else # invalid taxon name
          [
            [ label_for_taxon_name(otu.taxon_name),
              otu.name
            ].compact.join(' '),

            [ label_for_taxon_name(otu.taxon_name.valid_taxon_name),
              otu.name
            ].compact.join(' ')
          ].join(' now ')

        end
      end

    else
      otu.name
    end
  end

  def otu_autocomplete_tag(otu, term = nil)
    return nil if otu.nil?
    mark_tag(otu_tag(otu), term)
  end

  alias_method :otu_autoselect_tag, :otu_autocomplete_tag

  # # TODO: alias proper
  # # HTML label for the autoselect dropdown (left-justified).
  # def otu_autoselect_tag(otu, term = nil)
  #   return nil if otu.nil?
  #   mark_tag(otu_tag(otu), term)
  # end

  def otu_autoselect_info(otu)
    return [] if otu.taxon_name_id.blank?
    r = [ ]

    t = otu.taxon_name

    if t && t.is_protonym?
      if t.is_genus_or_species_rank?
        r.push taxon_name_original_combination_tag(t)
      end

    # if !t.is_valid?
    #   r.push taxon_name_now_tag(t.valid_taxon_name)
    # end
    else
      r.push t.type
    end
    r
  end


  def otu_tag_elements(otu)
    return nil if otu.nil?
    [
      ( otu.taxon_name ? tag.span(full_taxon_name_tag(otu.taxon_name).html_safe, class: :otu_tag_taxon_name, title: otu.taxon_name.id) : nil),
      ( otu.name ? content_tag(:span, otu.name, class: :otu_tag_otu_name, title: otu.id) : nil )
    ].compact
  end

  # Used exclusively in /api/v1/otus/autocomplete
  def otu_extended_autocomplete_tag(target, otu, common_names, term)
    if target.kind_of?(Otu)
      t = otu_tag(target)
    else # TaxonName
      a = [ tag.span( full_taxon_name_tag(target).html_safe, class: :otu_tag_taxon_name, title: target.id) ]
      a.push taxon_name_type_short_tag(target)
      t = tag.span( a.compact.join(' ').html_safe, class: :otu_tag )
    end

    if common_names.present? && otu.present? &&
       (common_names_label = otu_common_names_label(common_names, term)).present?
      tag.span( "#{common_names_label} (#{t})".html_safe )
    else
      t
    end
  end

  def otu_common_names_label(common_names, term = nil)
    return nil if common_names.nil? || common_names.empty?

    if term.empty?
      return common_names.map(&:name).sort.join(', ')
    end

    prefix_matches = []
    wildcard_matches = []
    non_matches = []

    term = term.downcase
    # Regexp.escape turns each space into '\\ '.
    wildcard_term = Regexp.escape(term).gsub(/(\\ )+/, '.*')

    common_names.each do |o|
      name = o.name.downcase
      if name.start_with?(term)
        prefix_matches << name
      elsif name =~ /#{wildcard_term}/
        wildcard_matches << name
      else
        non_matches << name
      end
    end

    (prefix_matches.sort + wildcard_matches.sort + non_matches.sort).join(', ')
  end

  # DEPRECATE
  # @return [String]
  #    no HTML inside <input>
  def otu_autocomplete_selected_tag(otu)
    return nil if otu.nil? || (otu.new_record? && !otu.changed?) # probably get rid of this
    label_for_otu(otu)
#   [otu.name,
#    Utilities::Strings.nil_wrap('[',taxon_name_autocomplete_selected_tag(otu.taxon_name), ']')&.html_safe
#   ].compact.join(' ')
  end

  def otu_link(otu)
    return nil if otu.nil?
    link_to(otu_tag_elements(otu).join(' ').html_safe, otu)
  end

  def otus_search_form
    render('/otus/quick_search_form')
  end

  def otus_link_list_tag(otus)
    otus.collect { |o| link_to(o.name, o) }.join(',')
  end

  # Stub a smart link to browse OTUs
  # @param object [an instance of TaxonName or Otu]
  #   if TaxonName is provided JS UI will disambiguate if more options are possible
  def browse_otu_link(object)
    return nil if object.nil?
    otu = object.metamorphosize
    content_tag(:div, '', 'data-taxon-name' => object_tag(otu), 'data-redirect' => 'true', 'data-id' => otu.id, 'data-klass' => object.class.base_class.name.to_s, 'data-otu-button' => 'true')
  end

  def otus_radial_disambiguate(object)
    otu = object.metamorphosize
    content_tag(:div, '', 'data-taxon-name' => object_tag(otu), 'data-redirect' => 'false', 'data-id' => otu.id, 'data-klass' => object.class.base_class.name.to_s, 'data-otu-button' => 'true')
  end

  def otus_radial(object)
    content_tag(:div, '', 'data-global-id' => object.to_global_id.to_s, 'data-otu-radial' => 'true')
  end

  # @return [Array]
  #   of OTUs
  def next_records(otu)
    if otu.taxon_name_id
      o = []
      t = otu.taxon_name.next_sibling
      unless t.nil?
        while o.empty?
          break if t.nil?
          o = t.otus.to_a
          t = t.next_sibling
        end
      end
      o
    else
      super
    end
  end

  # @return [Array]
  #   of OTUs
  # Some OTUs don't have TaxonName, skip along
            # until we hit one.
          def previous_records(otu)
            if otu.taxon_name_id
              o = []
              t = otu.taxon_name.previous_sibling
              unless t.nil?
                while o.empty?
                  break if t.nil?
                  o = t.otus.to_a
                  t = t.previous_sibling
                end
              end
              o
            else
              super
            end
          end

          def parent_records(otu)
            otu.taxon_name&.parent&.otus&.all || []
          end

          # See also otus#ancestor_otu_ids ?
          def parents_by_nomenclature(otu)
            above = [ ]
            if otu.taxon_name_id
              TaxonName.ancestors_of(otu.taxon_name)
                .select('taxon_names.*, taxon_name_hierarchies.generations')
                .that_is_valid.joins(:otus)
                .distinct
                .reorder('taxon_name_hierarchies.generations DESC, taxon_names.cached_valid_taxon_name_id').each do |t|
                  above.push [t.cached, t.otus.to_a] # TODO: to_a vs. pluck
                end
            end
            above
          end


          def ranked_otu_table(otus)
            d = TaxonName.ranked_otus(otu_scope: otus, project_id: sessions_current_project_id)

            tbl = %w{otu_id order family genus species otu_name taxon_name taxon_name_author_year}
            output = StringIO.new
            output.puts ::CSV.generate_line(tbl, col_sep: "\t", encoding: Encoding::UTF_8)

            d.each do |o|
              output.puts ::CSV.generate_line(
                [
                  o.id,
                  o['order'],
                  o['family'],
                  o['genus'],
                  o['species'],
                  o.name,
                  o.cached,
                  o.cached_author_year
                ],
                col_sep: "\t", encoding: Encoding::UTF_8)
            end

            output.string
          end

          # @return Hash
          #   { dwc_occurrence_id: [ image1, image2 ... ], ... }
          def dwc_gallery_data(otu, dwc_occurrence_id: [], pagination_headers: true)
            a = DwcOccurrence.scoped_by_otu(otu)
              .select(:id, :dwc_occurrence_object_id, :dwc_occurrence_object_type)

            dwc_ids = [dwc_occurrence_id].flatten.compact.uniq

            if dwc_ids.any?
              a = a.where(id: dwc_ids)
            end

            a = a.page(params[:page]).per(params[:per])

            # Somehwhat of a janky pattern, probably needs to be
            # moved into Controller.
            assign_pagination(a) if pagination_headers

            b = Image.with(dwc_scope: a)
              .joins('JOIN depictions d on d.image_id = images.id' )
              .joins("JOIN dwc_scope on d.depiction_object_id = dwc_scope.dwc_occurrence_object_id AND d.depiction_object_type = 'CollectionObject' AND dwc_scope.dwc_occurrence_object_type = 'CollectionObject'")
              .select('images.*, dwc_scope.id dwc_id')
              .distinct

            r = {}
            b.find_each do |o|
              r[o.dwc_id] ||= []
              r[o.dwc_id].push o
            end
            r
          end

          def serialize_matrices(scope)
            scope
              .where(is_public: true)
              .map do |m|
                {
                  id: m.id,
                  name: m.name,
                  is_media: m.is_media_matrix?
                }
              end
          end

          def otu_key_inventory(otu)
            return {
              observation_matrices: {
                scoped: serialize_matrices(otu.in_scope_observation_matrices),
                in: serialize_matrices(otu.observation_matrices)
              },
              leads: {
                scoped: otu.leads
                  .where(parent_id: nil, is_public: true)
                  .select(:id, :text)
                  .map { |l| { id: l.id, text: l.text } },

                in: Lead.public_root_leads_for_leaf_otus(otu)
                  .select(:id, :text)
                  .map { |l| { id: l.id, text: l.text } }
              }
            }
          end
        end
