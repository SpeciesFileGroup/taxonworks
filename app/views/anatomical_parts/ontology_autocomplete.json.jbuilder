
@term = @term.downcase

@parts_list.sort! do |a,b|
  a_equal = a[:label].downcase == @term
  b_equal = b[:label].downcase == @term
  if a_equal && !b_equal
    -1
  elsif !a_equal && b_equal
    1
  else
    a_starts = a[:label].downcase.start_with?(@term)
    b_starts = b[:label].downcase.start_with?(@term)
    if a_starts && !b_starts
      -1
    elsif !a_starts && b_starts
      1
    else
      a_include = a[:label].downcase.include?(@term)
      b_include = b[:label].downcase.include?(@term)
      if a_include && !b_include
        -1
      elsif !a_include && b_include
        1
      else
        a_prefix = a[:ontology_prefix]&.downcase
        b_prefix = b[:ontology_prefix]&.downcase
        if a_prefix.nil? || b_prefix.nil? || (a_prefix == b_prefix)
          a[:label] <=> b[:label]
        elsif a_prefix < b_prefix
          -1
        else # a_prefix > b_prefix
          1
        end
      end
    end
  end
end

json.array! @parts_list.map { |part|
  part.merge(ontology_label: anatomical_part_ontology_label(part))
}