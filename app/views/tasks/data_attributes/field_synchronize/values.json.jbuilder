json.array! @records do |record|
  json.id record.id
  json.object_tag object_tag(record)

  @attributes.each do |attr|
    if record.respond_to?(attr)
      json.set! attr, record.send(attr)
    end
  end
end