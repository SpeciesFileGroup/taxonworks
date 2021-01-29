Project::MANIFEST.each do |k|
  j = k.safe_constantize

  json.set! k.tableize.humanize, j.count
end

