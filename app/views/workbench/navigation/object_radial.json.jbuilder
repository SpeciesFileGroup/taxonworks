resource = @klass.tableize
member = resource.singularize

json.type @klass

if @object
  json.object_label object_tag(@object) 
end

json.tasks do
  @data['tasks'].each do |t|
    json.set! t do
      json.name UserTasks::INDEXED_TASKS[t].name
      if @object&.id
        json.path send("#{t}_path", "#{member}_id" => @object.id)
      else
        json.path send("#{t}_path")
      end
    end
  end
end

json.rest do
  if @object&.id
    json.member_path member + "/#{@object.id}"
  else
    json.member_path member 
  end
  
  json.collection_path resource
end

if @data['config']['recent']
  json.recent_url resource + '?recent=true'
end



json.config @data['config']  


