module Queries::Helpers

  # @params params
  # @params attribute [Symbol]
  # @return [Boolean, nil]
  def boolean_param(params, attribute)
    return nil if attribute.nil? || params[attribute].nil?
    case params[attribute].class.name
    when 'TrueClass', 'FalseClass'
      params[attribute]
    when 'String'
      params[attribute].downcase == 'true' ? true : false
    when 'Symbol'
      params[attribute].to_s.downcase == 'true' ? true : false
    else
      puts Rainbow(params[attribute].class.name.to_s).purple
      raise
    end
  end

  # @params params
  # @params attribute [Symbol]
  # @return params
  def integer_param(params, attribute)
    return nil if attribute.nil? || params[attribute].nil?

    [params[attribute]].flatten.each do |v|
      next if v.kind_of?(Integer)
      next if Utilities::Strings.only_integer(v) # This rabbit hole feels a little janky
      raise TaxonWorks::Error::API, "values of #{attribute} must be integers (provided: #{params[attribute]})"
    end

    params[attribute]
  end

  def split_pairs(pairs)
    h = {}
    pairs.each do |p|
      k, v = p.split(':', 2)
      h[k] = v
    end
    h
  end

  def split_repeated_pairs(pairs)
    a = []
    pairs.each do |p|
      a << p.split(':', 2)
    end
    a
  end

  # @param values [Array]
  # @return [Array<Boolean, nil>]
  #   Converts array elements to boolean or nil values
  #   Accepts: true, false, nil, 'true', 'false', 'nil', ''
  def tri_value_array(values)
    return [] if values.nil?
    [values].flatten.map do |v|
      case v
      when true, 'true'
        true
      when false, 'false'
        false
      when nil, 'nil', ''
        nil
      else
        raise TaxonWorks::Error::API, "value must be boolean or nil (provided: #{v.inspect})"
      end
    end
  end

end
