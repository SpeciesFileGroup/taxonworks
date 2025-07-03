# Users must have the helpers RecordNavigationHelper interface
object = object.metamorphosize

h = RecordNavigationHelper.for(object.class.name)

klass = object.class.name.underscore

json.current do
  json.partial! "/#{klass.pluralize}/attributes", klass.to_sym => object
end

json.parents do
  json.array! h.parent_records(object) do |o|
    json.id o.id
    json.object_tag send("#{klass}_tag", o)
    json.object_label send("label_for_#{klass}", o)
  end
end

json.previous do
  json.array! h.previous_records(object) do |o|
    json.id o.id
    json.object_tag send("#{klass}_tag", o)
    json.object_label send("label_for_#{klass}", o)
  end
end

json.next do
  json.array! h.next_records(object) do |o|
    json.id o.id
    json.object_tag send("#{klass}_tag", o)
    json.object_label send("label_for_#{klass}", o)
  end
end
