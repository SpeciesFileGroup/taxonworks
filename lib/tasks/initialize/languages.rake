namespace :tw do
  namespace :initialize do

    desc 'call "rake tw:initialize:load_language", requires data_directory'
    task :load_languages => [:data_directory, :environment, :user_id] do |t|
  
      print "Loading languages..." 
      if Language.all.count > 0 
        puts 'There are existing languages, doing nothing.'.red.on_white 
        raise 
      end

      file = @args[:data_directory] + 'ISO-639-2_utf-8.txt'
       
      # TODO: check checksums of incoming files?
      begin
        ActiveRecord::Base.transaction do
          File.foreach(file) do |row| 
            v = row.split(/\|/) # Ugh CSV with pipes as delimiters is borked.
            r = Language.new(
              alpha_3_bibliographic: v[0],                       
              alpha_3_terminologic: v[1],                      
              alpha_2: v[2], 
              english_name: v[3],
              french_name: v[4],         
            )
            r.save!
          end
      print "success\n"
        end
      rescue
        puts 'Problem laoding languages'.red.on_white
        raise
      end

    end
  end
end
