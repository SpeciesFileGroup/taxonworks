json.array!(@taxon_names) do |taxon_name|
    if extend_response_with('verbose') 
	json.partial! '/taxon_names/api/v1/attributes', taxon_name: taxon_name
    else
	json.partial! '/taxon_names/api/v1/base_attributes', taxon_name: taxon_name
    end
end
