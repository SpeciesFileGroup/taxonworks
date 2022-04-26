json.source do
  json.id source.id

  # Considered `name`  here, label seems more appropriate (a display value as used here)
  json.label label_for_source(source)

  json.global_id source.to_global_id.to_s
  if source.is_bibtex?
    json.author_year source_author_year_label(source)
  end
end
