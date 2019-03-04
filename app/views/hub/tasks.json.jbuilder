@tasks.each do |t|
  json.set! t.prefix, t.to_h.merge(url: send("#{t.prefix}_path"))
end

