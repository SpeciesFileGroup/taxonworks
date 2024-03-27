module Vocabulary

  # TODO: differentiate between no data and bad request
  # @return nil (bad request), {} (good request)
  def self.words(model: nil, attribute: nil, min: 0, max: nil, limit: nil, begins_with: nil, contains: nil, project_id: [])

    klass = get_model(model)
    return nil if klass.nil?

    t = klass.columns_hash[attribute]&.type

    # Happens on bad request
    return nil if t.nil? || [:xml].include?(t)

    if klass.new.attributes.symbolize_keys.keys.include?(:project_id)
      words = klass.where(project_id:)
    else
      words = klass
    end

    if [:string, :text].include?(t)

      c = "COUNT(\"#{attribute}\")" # double quote to handle things like `group`

      words = words.where("\"#{attribute}\" like '#{begins_with}%'") if begins_with.presence
      words = words.where("\"#{attribute}\" like '%#{contains}%'") if contains.presence
      words = words.having("#{c} > ?", min) if min.presence
      words = words.having("#{c} < ?", max) if max.presence
      words = words.limit(limit) if limit
      return words.group("\"#{attribute}\"").order(c + ' DESC').count

    else

      c = "COUNT(#{attribute})"

      words = words.where( "#{attribute}::text like '#{begins_with}%'") if begins_with.presence
      words = words.where("#{attribute}::text like '%#{contains}%'") if contains.presence
      words = words.having("#{c} > ?", min) if min.presence
      words = words.having("#{c} < ?", max) if max.presence
      words = words.limit(limit) if limit
      return words.group(attribute).order(c + ' DESC').count

    end
  end

  # Concept is non-id, non-timestamp, non-hash attributes that
  # are reasonably human-visualized
  # @param model an ApplicationRecord model
  def self.attributes(model, mode: nil)
    xml_fields = %i{svg_clip} # for now just subtract known unprocessable fields across models.
    ApplicationEnumeration.attributes(model.new) - xml_fields
  end

  # From a String.
  def self.get_model(name)
    begin
      klass = ::ApplicationController.new().whitelist_constantize(name)
    rescue KeyError
      nil
    end
  end

  # WITH words_list AS (
  #   SELECT unnest(ARRAY['word1', 'word2', 'word3', ...]) AS word
  # )
  # SELECT
  #   w1.word AS word1,
  #   w2.word AS word2,
  #   levenshtein(w1.word, w2.word) AS levenshtein_distance
  # FROM
  #   words_list w1
  # CROSS JOIN
  #   words_list w2
  # WHERE
  #   w1.word != w2.word
  # ORDER BY
  #   levenshtein_distance;


end
