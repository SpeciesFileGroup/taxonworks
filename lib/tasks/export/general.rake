namespace :tw do
  namespace :export do
    # TODO: lock this down to development 
    desc 'call with "rake tw:export:table table_name=./tmp/geographic_areas"'
    task :table => [:environment, :table_name] do
      result = $table_name.classify.safe_constantize.all.to_a
      Utilities::Csv.to_csv(result)
    end
  end

end
