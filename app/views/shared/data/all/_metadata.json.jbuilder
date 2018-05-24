klass ||= object.class.name

json.object_tag object_tag(object)
json.url url_for(only_path: false, format: :json) # radial annotator metamorphosize_if(object)) # , 
json.global_id object.to_global_id.to_s
json.type klass 

if object.respond_to?(:has_citations?) && object.has_citations?
  if object.source 
    json.source do 
      json.partial! '/sources/attributes', source: object.source
    end
  end
end

