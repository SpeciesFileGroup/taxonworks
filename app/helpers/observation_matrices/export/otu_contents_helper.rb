module ObservationMatrices::Export::OtuContentsHelper
  extend self

  def get_otu_contents(options = {})
    opt = {otus: []}.merge!(options)
    m = opt[:observation_matrix]

    otu_ids = m.otus.collect{|i| i.id}
    CSV.generate do |csv|
      csv << ['otu_id', 'topic', 'text']
      if options[:include_contents] == 'true'
        contents = Content.select('contents.*, controlled_vocabulary_terms.name, observation_matrix_rows.id AS row_id').
          joins(:topic).joins('INNER JOIN observation_matrix_rows ON observation_matrix_rows.otu_id = contents.otu_id').
          where('contents.otu_id IN (?)', otu_ids).where('observation_matrix_rows.observation_matrix_id = (?)', m.id).
          order(:otu_id, :topic_id)
        contents.each do |i|
          csv << ['row_' + i.row_id.to_s, i.name, i.text]
        end
      end

      if options[:include_nomenclature] == 'true'

      end

      if options[:include_distribution] == 'true'
        ad = AssertedDistribution.select('asserted_distributions.*, geographic_areas.name, observation_matrix_rows.id AS row_id').
          joins(:geographic_area).joins('INNER JOIN observation_matrix_rows ON observation_matrix_rows.otu_id = asserted_distributions.otu_id').
          where('asserted_distributions.otu_id IN (?)', otu_ids).where('observation_matrix_rows.observation_matrix_id = (?)', m.id).
          order(:otu_id, :geographic_area_id)
        otu_ad = {}
        ad.each do |i|
          otu_ad[i.row_id] = [] if otu_ad[i.row_id].nil?
          otu_ad[i.row_id].append(i.name)
        end
        otu_ad.each do |key, value|
          csv << ['row_' + key.to_s, 'Distribution', value.join(', ') ]
        end
      end

      if options[:include_depictions] == 'true'

      end

      if options[:include_type] == 'true'
        protonyms = Protonym.select('taxon_names.*, observation_matrix_rows.id AS row_id').
          joins(:otus).joins('INNER JOIN observation_matrix_rows ON observation_matrix_rows.otu_id = otus.id').
          where('otus.id IN (?)', otu_ids).where('observation_matrix_rows.observation_matrix_id = (?)', m.id).
          where("rank_class LIKE '%Family%' OR rank_class LIKE '%Genus%'").
          order(:otu_id)
        protonyms.each do |p|
          stype = p.type_species
          csv << ['row_' + p.row_id.to_s, 'Type species', stype.cached_html_original_name_and_author_year ] unless stype.nil?
          gtype = p.type_genus
          csv << ['row_' + p.row_id.to_s, 'Type genus', gtype.cached_html_original_name_and_author_year ] unless gtype.nil?
        end
      end

    end
  end

end