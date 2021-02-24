json.annotation_target @object.to_global_id.to_s
json.url url_for(@object.metamorphosize)
json.object_type @object.class.base_class.name
json.object_id @object.id

json.endpoints do
  @object.class::GRAPH_ENTRY_POINTS.each do |k|
    json.set! k do
      if @object.send(k).respond_to?(:count)
        json.total @object.send(k).count
      else
        json.total @object.send(k) ? 1 : 0
      end
    end
  end 
end

json.object_tag object_tag(@object)

  
