json.partial! '/otus/api/v1/attributes', otu: @otu
if extend_response_with('parents')
  json.parents do
    parents_by_nomenclature(@otu).each do |a|
      next if a.second.blank?
      json.set! a.first do
        json.array! a.second, partial: '/otus/api/v1/attributes', as: :otu
      end
    end
  end
end
