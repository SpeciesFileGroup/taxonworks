json.data do
  Project::MANIFEST.each do |k|
    next if %w{ProjectMember}.include?(k)
    j = k.safe_constantize

    c = j.count
    if c > 0
      json.set! k.tableize.humanize, j.count
    end
  end
end

json.metadata do
  json.set!'Days of curation', (User.sum(:time_active).seconds / 86400).round
  json.set!("Past week: Active curators", User.where('last_seen_at > ?', 1.week.ago).count)
  json.set!("Past week: New sources", Source.where('created_at > ?', 1.week.ago).count)
  json.set!("Past week: New taxon names", TaxonName.where('created_at > ?', 1.week.ago).count)
  json.set!("Past week: New collection objects", CollectionObject.where('created_at > ?', 1.week.ago).count)
end

