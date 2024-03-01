module Vocabulary

  def self.words(model: nil, attribute: nil, min: 0, max: nil, limit: nil, begins_with: nil, contains: nil, project_id: [])

    # TODO: Check for project id

    klass = get_model(model)
    return {} if klass == {}

    c = "COUNT(\"#{attribute}\")"

    if klass.new.attributes.symbolize_keys.keys.include?(:project_id)
      words = klass.where(project_id:)
    else
      words = klass
    end

    words = words.where( "\"#{attribute}\" like '#{begins_with}%'") if begins_with
    words = words.where("\"#{attribute}\" like '%#{contains}%'") if contains
    words = words.having("#{c} > ?", min) if min
    words = words.having("#{c} < ?", max) if max
    words = words.limit(limit) if limit
    words.group(attribute).order(c + ' DESC').count
  end

  # @param model an ApplicationRecord model
  def self.attributes(model)
    ApplicationEnumeration.attributes(model.new)
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
