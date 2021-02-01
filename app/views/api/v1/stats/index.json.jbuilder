Project::MANIFEST.each do |k|
  next if %w{ProjectMember}.include?(k)
  j = k.safe_constantize

  c = j.count
  if c > 0
    json.set! k.tableize.humanize, j.count
  end
end

json.set!'Days of curation', (User.sum(:time_active).seconds / 86400).round

