json.current_otu do
  json.partial! 'attributes', otu: @otu
end

json.parents do
  parents_by_nomenclature(@otu).each do |a|
    next if a.second.blank?
    json.set! a.first do
      json.array! a.second, partial: 'attributes', as: :otu
    end
  end
end
