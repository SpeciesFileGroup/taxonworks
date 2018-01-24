# We have to do things a little different here because our getters sometimes return objects
ApplicationEnumeration.alternate_value_attributes(@object).each_key do |k|
  json.set!(k, @object.read_attribute(k))
end
