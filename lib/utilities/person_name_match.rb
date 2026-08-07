module Utilities::PersonNameMatch

  # Score how closely a stored first name matches a parsed first name.
  # Parts are compared positionally: 2 points for exact word match, 1 for matching initial.
  def self.score_first_name_match(person_first_name, parsed_first_name)
    p_parts = normalize(parsed_first_name).gsub('.', ' ').split.reject(&:empty?)
    s_parts = normalize(person_first_name).gsub('.', ' ').split.reject(&:empty?)

    return 0 if p_parts.empty?
    return -1 if s_parts.empty?

    score = 0
    [p_parts.length, s_parts.length].min.times do |i|
      if p_parts[i] == s_parts[i]
        score += 2
      elsif p_parts[i][0] == s_parts[i][0]
        score += 1
      end
    end

    score
  end

  # Score how closely a stored last name matches a parsed last name.
  # 2 points per word in common.
  def self.score_last_name_match(person_last_name, parsed_last_name)
    p_words = normalize(parsed_last_name).split.to_set
    s_words = normalize(person_last_name).split.to_set

    return 0 if p_words.empty?
    return -1 if s_words.empty?

    score = 0
    p_words.each { |w| score += 2 if s_words.include?(w) }
    score
  end

  # Combined score: last name weighted 10x over first name.
  def self.score_match(person_first_name, person_last_name, parsed_first_name, parsed_last_name)
    score_last_name_match(person_last_name, parsed_last_name) * 10 +
      score_first_name_match(person_first_name, parsed_first_name)
  end

  # Sort people by descending match score against the parsed name.
  # people must respond to #first_name and #last_name.
  def self.sort_by_match(people, parsed_first_name, parsed_last_name)
    people.sort_by do |person|
      -score_match(person.first_name, person.last_name, parsed_first_name, parsed_last_name)
    end
  end

  def self.normalize(name)
    (name || '').downcase.strip.gsub(/\s+/, ' ')
  end
  private_class_method :normalize

end
