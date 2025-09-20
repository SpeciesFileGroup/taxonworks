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

      if k == :origin_relationships
        json.origin_for do
          if @object.respond_to?(:valid_new_object_classes)
            @object.valid_new_object_classes.each do |j|
              l = j.split('::').first
              json.set! j, l.tableize
            end
          end
        end
        json.originates_from do
          if @object.respond_to?(:valid_old_object_classes)
            @object.valid_old_object_classes.each do |j|
              l = j.split('::').first
              json.set! j, l.tableize
            end
          end
        end
      end

    end
  end
end

json.object_tag object_tag(@object)


