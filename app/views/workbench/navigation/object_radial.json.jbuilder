resource = @klass.tableize
json.type @klass

if @object
  json.id @object.id
  json.object_label object_tag(@object) 

  json.resource_path "/#{resource}/#{@object.id}" 
  json.global_id @object.to_global_id.to_s
else
  json.resource_path resource
end

if @data
  
  json.tasks do
    @data['tasks'].each do |t|
      json.set! t do
        json.name UserTasks::INDEXED_TASKS[t].name
        if @object
          json.path send("#{t}_path", "#{resource.singularize}_id" => @object.id)
        else
          json.path send("#{t}_path")
        end
      end
    end
  end

  json.config @data['config']

  if @data.dig('config', 'recent')
    json.recent_url resource + '?recent=true'
  end

  if @data['edit']
    json.edit send("#{@data['edit']}_path", "#{resource.singularize}_id" => @object.id)
  end

  if @data['home']
    json.home send("#{@data['home']}_path", "#{resource.singularize}_id" => @object.id)
  end

  if @data['new']
    json.new send("#{@data['new']}_path")
  end

  json.destroy @object.is_destroyable?(sessions_current_user)
end

json.partial! '/pinboard_items/pinned', object: @object
