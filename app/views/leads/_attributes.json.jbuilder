if lead.nil?
  json.nil
else
  json.extract! lead, :id, :parent_id, :otu_id, :text, :origin_label,
    :description, :redirect_id, :link_out, :link_out_text, :position,
    :is_public, :project_id, :created_by_id, :updated_by_id, :created_at,
    :updated_at

  if lead[:otus_count]
    json.otus_count lead[:otus_count]
  end

  if lead[:couplet_count]
    json.couplet_count lead[:couplet_count]
  end

  if lead[:key_updated_at]
    json.key_updated_at lead[:key_updated_at]
    json.key_updated_at_in_words time_ago_in_words(lead[:key_updated_at])
  end

  if lead[:key_updated_by_id]
    json.key_updated_by_id lead[:key_updated_by_id]
  end

  if lead[:key_updated_by]
    json.key_updated_by lead[:key_updated_by]
  end

  json.partial! '/shared/data/all/metadata', object: lead

  if extend_response_with('otu')
    json.otu do
      if lead.otu_id.nil?
        json.nil!
      else
        json.partial! '/otus/attributes', otu: lead.otu, extensions: false
      end
    end
  end

  if extend_response_with('couplet_count')
    json.couplet_count (lead.self_and_descendants.count - 1) / 2
  end

  if extend_response_with('updater')
    json.updated_by lead.updater.name
  end

  if extend_response_with('updated_at_in_words')
    json.updated_at_in_words time_ago_in_words(lead.updated_at)
  end
end
