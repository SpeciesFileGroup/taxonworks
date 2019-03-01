json.tasks do
  @data['tasks'].each do |t|
    json.set! t do
      json.name UserTasks::INDEXED_TASKS[t].name
      json.path send("#{t}_path")
    end
  end
end

json.options @data['config']  


