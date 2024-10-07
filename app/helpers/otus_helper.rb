module OtusHelper

  def otu_tag(otu)
    return nil if otu.nil?
    a = otu_tag_elements(otu)
    a.push taxon_name_type_short_tag(otu.taxon_name)
    content_tag(:span, a.compact.join(' ').html_safe, class: :otu_tag)
  end

  def label_for_otu(otu)
    return nil if otu.nil?
    [otu.name,
     label_for_taxon_name(otu.taxon_name)
    ].compact.join(': ')
  end

  def otu_tag_elements(otu)
    return nil if otu.nil?
    [
      ( otu.name ? content_tag(:span, otu.name, class: :otu_tag_otu_name, title: otu.id) : nil ),
      ( otu.taxon_name ? content_tag(:span, full_taxon_name_tag(otu.taxon_name).html_safe, class: :otu_tag_taxon_name, title: otu.taxon_name.id) : nil)
    ].compact
  end

  # Used exclusively in /api/v1/otus/autocomplete
  def otu_extended_autocomplete_tag(target)
    if target.kind_of?(Otu)
      otu_tag(target)
    else # TaxonName
      a = [ tag.span( full_taxon_name_tag(target).html_safe, class: :otu_tag_taxon_name, title: target.id) ]
      a.push taxon_name_type_short_tag(target)
      tag.span( a.compact.join(' ').html_safe, class: :otu_tag )
    end
  end

  # @return [String]
  #    no HTML inside <input>
  def otu_autocomplete_selected_tag(otu)
    return nil if otu.nil? || (otu.new_record? && !otu.changed?)
    [otu.name,
     Utilities::Strings.nil_wrap('[',taxon_name_autocomplete_selected_tag(otu.taxon_name), ']')&.html_safe
    ].compact.join(' ')
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
  def next_otus(otu)
    if otu.taxon_name_id
      o = []
      t = otu.taxon_name.next_sibling
      unless t.nil?
        while o.empty?
          o = t&.otus.to_a
          break if t.nil?
          t = t.next_sibling
        end
      end
      o
    else
      Otu.where(project_id: otu.id).where('id > ?', otu.id).all
    end
  end

  # @return [Array]
  #   of OTUs
  # Some OTUs don't have TaxonName, skip along
  # until we hit one.
  def previous_otus(otu)
    if otu.taxon_name_id
      o = []
      t = otu.taxon_name.previous_sibling
      unless t.nil?
        while o.empty?
          o = t&.otus.to_a
          break if t.nil?
          t = t.previous_sibling
        end
      end
      o
    else
      Otu.where(project_id: otu.id).where('id < ?', otu.id).all
    end
  end

  def parent_otus(otu)
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

  # @return Hash
  #   A GeoJSON collection of distribution data in x parts
  #     need a `to_geo_json` for each object
  #
  #      :asserted_distributions
  #         with shape
  #         without shapes
  #      :collection_objects
  #           with georeferences
  #           with GeographicAreas
  #      :type material
  #           with georeferences
  #           with GeographicAreas
  # TODO:
  #
  #  * make properties universal
  #    type: 'Model',
  #    id: id,
  #    label: <label>
  # * merge origin_otu_id: id to reference coordinate OTUs
  #
  #  target:
  #    type: Otu
  #    label:
  #    id
  #
  #  base:   # one level above target (or one level below shape?!)
  #    type:
  #    id:
  #
  #  shape: # Either GeographicArea or Georeference
  #     type
  #     id
  #
  def otu_distribution(otu, children = true, cutoff = 200)
    return {} if otu.nil?
    otus = if children
             otu.coordinate_otus_with_children
           else
             Otu.coordinate_otus(otu.id)
           end

    h = {
      'type' => 'FeatureCollection',
      'features' => [],
      'properties' => {
        'target' => { # Top level target
          'id' => otu.id,
          'label' => label_for_otu(otu),
          'type' => 'Otu'
        }
      }
    }

    if otu.taxon_name && otu.taxon_name.is_protonym? && !otu.taxon_name.is_species_rank?
      add_aggregate_geo_json(otu, h)
    else
      otus.each do |o|
        add_distribution_geo_json(o, h)
      end
    end

    h
  end

  def add_aggregate_geo_json(otu, target)
    h = target

    if g = aggregate_geo_json(otu, h)
      t = {
        'id' => otu.id,
        'type' => 'Otu',
        'label' => label_for_otu(otu)
      }

      g['properties'] = {'aggregate': true}

      g['properties']['target'] = t
      h['features'].push g
    end

    h
  end

  # NOT USED
  # Caching the cached map
  def otu_cached_map(otu, target, cached_map_type = 'CachedMapItem::WebLevel1', cache = true, force = false)
    r = nil
    if force
      r = aggregate_geo_json(otu, target, cached_map_type)
    else
      # Check for map

      # TODO: extend with synced check
      if a = CachedMap.where(project_id: sessions_current_project_id).where(otu_id: otu.id, cached_map_type:  )
      end
    end
  end

  # TODO: cleanup
  def aggregate_geo_json(otu, target, cached_map_type = 'CachedMapItem::WebLevel1')
    h = target

    if gj = otu.cached_map_geo_json(cached_map_type)

     i =
       {
         **gj,
        # 'type' => gj['type'],  # 'Feature',

        'properties' => {
          'base' => {
            'type' => 'Otu',
            'id' => otu.id,
            'label' => label_for_otu(otu) },
    #     'shape' => {
    #       'type' => cached_map_type,
    #       'id' => 99999 }, # was nil
         'updated_at' => 'foo' # last updated at on CachedMapItem scope, possibly
        }
      }

     if gj.keys.include?('coordinates')
       i['coordinates'] = gj['coordinates'] # was 'coordinates' TODO: might not work
     elsif gj.keys.include?('geometries')
       i['geometries'] = gj['geometries'] # was 'coordinates' TODO: might not work
     end

      i

    else
      nil
    end

  end

  def add_distribution_geo_json(otu, target)
    h = target
    o = otu

    # internal target
    t = {
      'id' => o.id,
      'type' => 'Otu',
      'label' => label_for_otu(otu)
    }

    o.current_collection_objects.each do |c|
      if g = collection_object_to_geo_json_feature(c)
        g['properties']['target'] = t
        h['features'].push g
      end
    end

    o.asserted_distributions.each do |a|
      if g = asserted_distribution_to_geo_json_feature(a)
        g['properties']['target'] = t
        h['features'].push g
      end
    end

    o.type_materials.each do |e|
      if g = type_material_to_geo_json_feature(e)
        g['properties']['target'] = t
        h['features'].push g
      end
    end
    h
  end

  def ranked_otu_table(otus)
    d = TaxonName.ranked_otus(otu_scope: otus)
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
      .joins("JOIN depictions d on d.image_id = images.id" )
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

  def otu_key_inventory(otu, is_public: true)
    return {
      observation_matrices: {
        scoped: otu.in_scope_observation_matrices.where(is_public:).select(:id, :name).inject({}){|hsh, m| hsh[m.id] = m.name; hsh;} || {} ,
        in: otu.observation_matrices.where(is_public:).select(:id, :name).inject({}){|hsh, m| hsh[m.id] = m.name; hsh;} || {},
      },
      leads: {
        scoped: otu.leads.where(parent_id: nil, is_public:).select(:id, :text).inject({}){|hsh, m| hsh[m.id] = m.text; hsh;} || {},
        in:  otu.leads.where.not(parent_id: nil).where(is_public: true).select(:id, :text).inject({}){|hsh, m| hsh[m.id] = m.text; hsh;} || {},
      }
    }
  end

end
