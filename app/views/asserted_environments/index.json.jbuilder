if extend_response_with('citations')
  @asserted_environments = @asserted_environments.includes(:citations)
end

json.array! @asserted_environments, partial: 'attributes', as: :asserted_environment
