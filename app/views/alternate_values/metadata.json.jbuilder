# We have to do things a little different here because our getters sometimes return objects 
ApplicationEnumeration.alternate_value_attributes(@object).each do |k, v|
  json.set!(k, @object.read_attribute(k)) 
end
