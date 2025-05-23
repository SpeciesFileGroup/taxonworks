module ObservationMatrices::Export::OtuContentsHelper

  include Lib::DistributionHelper

  def get_otu_contents(options = {})
    opt = {otus: []}.merge!(options)

    m = opt[:observation_matrix]

    otus = Otu.select('otus.*, observation_matrix_rows.id AS row_id').
      joins('INNER JOIN observation_matrix_rows ON observation_matrix_rows.observation_object_id = otus.id').
      where("observation_matrix_rows.observation_object_type = 'Otu'").
      where('observation_matrix_rows.observation_matrix_id = (?)', m.id).
      order(:observation_object_id) # Doesn't facilitate mixed object types

    otu_rows = {}

    otus.each do |i|
      otu_rows[i.id] = i.row_id
    end

    otu_ids = otu_rows.keys

    content_hash = {}
    content_columns = {}

    if options[:taxon_name] == 'true'
      protonyms = Protonym.select('taxon_names.*, otus.name AS otu_name, observation_matrix_rows.id AS row_id').
        joins(:otus).joins('INNER JOIN observation_matrix_rows ON observation_matrix_rows.observation_object_id = otus.id').
        where("observation_matrix_rows.observation_object_type = 'Otu'").
        where('otus.id IN (?)', otu_ids).where('observation_matrix_rows.observation_matrix_id = (?)', m.id).
        order(:observation_object_id)

      content_columns['Taxon name'] = true
      content_columns['Authority'] = true

      protonyms.each do |p|
        ##### csv << ['row_' + p.row_id.to_s, 'Taxon name', [p.otu_name, p.cached_html].compact.join(': ') ]
        content_hash['row_' + p.row_id.to_s] ||= {}
        content_hash['row_' + p.row_id.to_s]['Taxon name'] = [p.otu_name, p.cached_html].compact.join(': ')
        content_hash['row_' + p.row_id.to_s]['Authority'] = p.cached_author_year
      end
    end

    if options[:include_nomenclature] == 'true'
      protonyms = Protonym.select('taxon_names.*, observation_matrix_rows.id AS row_id').
        joins(:otus).joins('INNER JOIN observation_matrix_rows ON observation_matrix_rows.observation_object_id = otus.id').
        where("observation_matrix_rows.observation_object_type = 'Otu'").
        where('otus.id IN (?)', otu_ids).where('observation_matrix_rows.observation_matrix_id = (?)', m.id).
        order(:observation_object_id)

      protonyms.each do |p|
        h = p.nomeclatural_history
        unless h.empty?
          st = []
          h.each do |h|
            st.push( [h[:name], h[:author_year], h[:statuses]].join(' '))
          end
          content_columns['Nomenclature'] = true

          content_hash['row_' + p.row_id.to_s] ||= {}
          content_hash['row_' + p.row_id.to_s]['Nomenclature'] = st.join('<br>')
        end
      end

    end

    if options[:include_contents] == 'true'
      contents = Content.select('contents.*, controlled_vocabulary_terms.name, observation_matrix_rows.id AS row_id').
        joins(:topic).joins('INNER JOIN observation_matrix_rows ON observation_matrix_rows.observation_object_id = contents.otu_id').
        where("observation_matrix_rows.observation_object_type = 'Otu'").
        where('contents.otu_id IN (?)', otu_ids).where('observation_matrix_rows.observation_matrix_id = (?)', m.id).
        order(:otu_id, :topic_id)

      contents.each do |i|
        content_columns[i.name] = true
        content_hash['row_' + i.row_id.to_s] ||= {}
        content_hash['row_' + i.row_id.to_s][i.name] = i.text
      end
    end

    if options[:include_autogenerated_description] == 'true'
      otus = Otu.select('otus.*, observation_matrix_rows.id AS row_id').
        joins('INNER JOIN observation_matrix_rows ON observation_matrix_rows.observation_object_id = otus.id').
        where("observation_matrix_rows.observation_object_type = 'Otu'").
        where('observation_matrix_rows.observation_matrix_id = (?)', m.id).
        order(:observation_object_id)

      otus.each do |o|
        description = Tools::Description::FromObservationMatrix.new(project_id: m.project_id, observation_matrix_id: m.id, otu_id: o.id)
        content_columns['Description'] = true

        content_hash['row_' + o.row_id.to_s] ||= {}
        content_hash['row_' + o.row_id.to_s]['Description'] = description.generated_description
        ##### csv << ['row_' + o.row_id.to_s, 'Description', description.generated_description ]
      end
    end

    if options[:include_distribution] == 'true'
      ###### ad = AssertedDistribution.select('asserted_distributions.*, geographic_areas.name, observation_matrix_rows.id AS row_id').
      #  joins(:geographic_area).joins('INNER JOIN observation_matrix_rows ON observation_matrix_rows.observation_object_id = asserted_distributions.otu_id').
      #  where("observation_matrix_rows.observation_object_type = 'Otu'").
      #  where('asserted_distributions.otu_id IN (?)', otu_ids).where('observation_matrix_rows.observation_matrix_id = (?)', m.id).
      #  order(:otu_id, :geographic_area_id)
      #otu_ad = {}
      #ad.each do |i|
      #  otu_ad[i.row_id] = [] if otu_ad[i.row_id].nil?
      #  otu_ad[i.row_id].append(i.name)
      #end
      #otu_ad.each do |key, value|
      #  ##### csv << ['row_' + key.to_s, 'Distribution', value.join(', ') ]
      #end
      #
      protonyms = Protonym.select('taxon_names.*, observation_matrix_rows.id AS row_id').
        joins(:otus).joins('INNER JOIN observation_matrix_rows ON observation_matrix_rows.observation_object_id = otus.id').
        where("observation_matrix_rows.observation_object_type = 'Otu'").
        where('otus.id IN (?)', otu_ids).where('observation_matrix_rows.observation_matrix_id = (?)', m.id).
        order(:observation_object_id)
      protonyms.each do |p|
        content_columns['Distribution'] = true

        content_hash['row_' + p.row_id.to_s] ||= {}
        content_hash['row_' + p.row_id.to_s]['Distribution'] = paper_distribution_entry(p)
      end
    end

    if options[:include_type] == 'true'
      protonyms = Protonym.select('taxon_names.*, observation_matrix_rows.id AS row_id').
        joins(:otus).joins('INNER JOIN observation_matrix_rows ON observation_matrix_rows.observation_object_id = otus.id').
        where("observation_matrix_rows.observation_object_type = 'Otu'").
        where('otus.id IN (?)', otu_ids).where('observation_matrix_rows.observation_matrix_id = (?)', m.id).
        order(:observation_object_id)
      #p_ids = {}
      protonyms.each do |p|
        content_columns['Type'] = true

        content_hash['row_' + p.row_id.to_s] ||= {}

        content_hash['row_' + p.row_id.to_s]['Type'] = content_type_material(p)
        #next unless p_ids[p.id].nil?
        #stype = p.type_species
        #csv << ['row_' + p.row_id.to_s, 'Type species', stype.cached_html_original_name_and_author_year ] unless stype.nil?
        #gtype = p.type_genus
        #csv << ['row_' + p.row_id.to_s, 'Type genus', gtype.cached_html_original_name_and_author_year ] unless gtype.nil?
        #p_ids[p.id] = true
      end
      # protonyms = Protonym.select('taxon_names.*, observation_matrix_rows.id AS row_id').
      #  joins(:otus).joins('INNER JOIN observation_matrix_rows ON observation_matrix_rows.observation_object_id = otus.id').
      #  where("observation_matrix_rows.observation_object_type = 'Otu'").
      #  where('otus.id IN (?)', otu_ids).where('observation_matrix_rows.observation_matrix_id = (?)', m.id).
      #  where("rank_class LIKE '%Species%'").
      #  order(:observation_object_id)
      #p_ids = {}
      #protonyms.each do |p|
      #  next unless p_ids[p.id].nil?
      #  type = p&.type_materials&.primary&.first&.collection_object&.repository&.name
      #  csv << ['row_' + p.row_id.to_s, 'Type repository', type ] unless type.nil?
      #  p_ids[p.id] = true
      #end
      #p_ids = {}
      #protonyms.each do |p|
      #  next unless p_ids[p.id].nil?
      #  type = type = p&.type_materials&.primary&.first&.type_type
      #  csv << ['row_' + p.row_id.to_s, 'Type status', type ] unless type.nil?
      #  p_ids[p.id] = true
      #end
      #p_ids = {}
      #protonyms.each do |p|
      #  next unless p_ids[p.id].nil?
      #  type = p&.type_materials&.primary&.first&.collection_object&.buffered_collecting_event
      #  csv << ['row_' + p.row_id.to_s, 'Type locality', type ] unless type.nil?
      #  p_ids[p.id] = true
      #end
    end

    if options[:include_depictions] == 'true'
      tw_url = 'https://sfg.taxonworks.org'
      im = Tools::ImageMatrix.new(
        project_id: m.project_id,
        otu_filter: otu_ids.join('|'),
        per: 1000000)
      descriptors = im.list_of_descriptors.values
      im.depiction_matrix.each do |object|
        list = ''
        object[1][:depictions].each_with_index do |depictions, index|
          depictions.each do |depiction|
            lbl = []
            cit = im.image_hash[depiction[:image_id]][:citations].collect{|i| i[:cached]}.join('')
            lbl.push(descriptors[index][:name]) unless descriptors[index][:name].blank?
            lbl.push(depiction[:caption]) unless depiction[:caption].blank?
            #lbl.push('<b>Citation:</b> ' + cit) unless cit.blank?
            img_attr = Image.find(depiction[:image_id]).attribution
            #lbl.push(attribution_tag(img_attr).gsub('&#169;', '')) unless img_attr.nil?
            lbl.push(attribution_nexml_label(img_attr)) unless img_attr.nil?
            lbl = lbl.compact.join('; ')

            if im.image_hash[depiction[:image_id]][:image_file_content_type] == 'image/tiff'
              href = im.image_hash[depiction[:image_id]][:medium_url]
            else
              href = im.image_hash[depiction[:image_id]][:original_url]
            end

            list += "<span class='tw_depiction'><br>"
            list += "#{tag.img(src: short_url(href), class: 'tw_image')}<br>"
            list += "<b>Label:</b> #{lbl}<br>" unless lbl.blank?
            list += "<b>Citation:</b> #{cit}<br>" unless cit.blank?
            list += "</span>"
          end
        end
        content_columns['Illustrations'] = true

        content_hash['row_' + otu_rows[object[1][:otu_id]].to_s] ||= {}

        content_hash['row_' + otu_rows[object[1][:otu_id]].to_s]['Illustrations'] = list unless list.blank?
        ##### csv << ['row_' + otu_rows[object[1][:otu_id]].to_s, 'Illustrations', list ] unless list.blank?
      end
    end

    ::CSV.generate(col_sep: "\t") do |csv|
      row = ['otu_id'] + content_columns.keys # Headers
      csv << row
      content_hash.each do |k,v|
        row = [k]
        content_columns.keys.each do |c|
          row << v[c]
        end
        csv << row
      end
    end.html_safe
  end

  def content_type_material(t)
    return nil if t.type != 'Protonym'

    # Species type
    if t.is_species_rank?
      types = t.get_primary_type
      if types.any?
        return types.collect{|i| type_material_catalog_label(i)}.join('. ')
      else
        return nil
      end
    else
      if type_taxon_name_relationship = t&.type_taxon_name_relationship
        str = citations_tag(type_taxon_name_relationship)
        [ ' ' + type_taxon_name_relationship_label(t.type_taxon_name_relationship),
          (type_taxon_name_relationship.citations&.load&.any? ?  ' in ' : nil),
          str
        ].compact.join #.html_safe
      else
        nil
      end
    end
  end

end
