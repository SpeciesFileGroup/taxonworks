if lead.nil?
  json.nil
else
  json.extract! lead, :id, :parent_id, :otu_id, :text, :origin_label,
    :description, :redirect_id, :link_out, :link_out_text, :position,
    :project_id, :created_at,
    :updated_at, :observation_matrix_id

  if lead[:otus_count]
    json.otus_count lead[:otus_count]
  end

  if lead[:couplets_count]
    json.couplets_count lead[:couplets_count]
  end

  if lead[:key_updated_at]
    json.key_updated_at lead[:key_updated_at]
    json.key_updated_at_in_words time_ago_in_words(lead[:key_updated_at])
  end

  if !local_assigns[:has_descendant_lead_items].nil?
    json.has_descendant_lead_items has_descendant_lead_items
  end

end
