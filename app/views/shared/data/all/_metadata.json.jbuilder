klass ||= object.class.name

json.object_tag object_tag(object)
json.url url_for(only_path: false, format: :json)
json.global_id object.to_global_id.to_s
json.type klass 

if object.has_citations?
  if object.source 
    json.source do 
      json.partial! '/sources/attributes', source: type_material.source
    end
  end
end

