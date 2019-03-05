resource = params[:klass].tableize
id = params[:id]

json.tasks do
  @data['tasks'].each do |t|
    json.set! t do
      json.name UserTasks::INDEXED_TASKS[t].name
      if id
        json.path send("#{t}_path", "#{resource.singularize}_id" => id)
      else
        json.path send("#{t}_path")
      end
    end
  end
end

json.rest do
  if id
    json.member_path resource.singularize + "/#{id}"
  else
    json.member_path resource.singularize
  end
  
  json.collection_path resource

end

if @data['config']['recent']
  json.recent_url resource + '?recent=true'
end



json.config @data['config']  


