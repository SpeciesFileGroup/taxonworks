klass ||= object.class.name

json.object_tag object_tag(object)
json.object_label label_for(object)

json.global_id object.persisted? ? object.to_global_id.to_s : nil
json.base_class klass 

json.url url_for(only_path: false, format: :json) # radial annotator metamorphosize_if(object)) # , 
json.object_url url_for(metamorphosize_if(object))



if object.respond_to?(:has_citations?) && object.has_citations?
  if object.source 
    json.source do 
      json.partial! '/sources/attributes', source: object.source
    end
  end
end

