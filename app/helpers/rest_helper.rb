module RestHelper
  # @return Boolean
  def extend_response_with(value)
    if p = params.dig(:extend)
      return p.include?(value)
    end
  end

  # @return Boolean
  def embed_response_with(value)
    if p = params.dig(:embed)
      return p.include?(value)
    end
  end

  def exclude_from_response(value)
    if p = params.dig(:exclude)
      return p.include?(value)
    end
  end

end
