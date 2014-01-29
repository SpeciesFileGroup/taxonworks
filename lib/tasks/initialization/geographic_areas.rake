namespace :tw do
  namespace :initialization do
    # Assumes input is from rake tw:export:table table_name=geographic_area
    desc 'call like "rake tw:initialization:build_geographic_areas[/Users/matt/Downloads/geographic_areas.csv]"'
    task :build_geographic_areas, [:data_directory] => [:environment] do |t, args|
      args.with_defaults(:data_directory => './geographic_areas.csv')
      raise 'There are existing geographic_areas, doing nothing.' if GeographicArea.all.count > 0
      begin
        ActiveRecord::Base.transaction do
          CSV.each(:data_directory, header: true, col_sep: "\t") do |row| 
            r = GeographicArea.new(row.to_h) 
            r.save!
          end
        end
      rescue
        raise
      end
    end
  end
end
