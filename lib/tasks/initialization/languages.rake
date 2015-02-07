namespace :tw do
  namespace :initialization do

    desc 'call like "rake tw:initialization:build_languages[/Users/matt/Downloads/ISO-639-2_utf-8.txt]"'
    task :build_languages, [:data_directory] => [:environment, :user_id] do |t, args|
      args.with_defaults(:data_directory => './ISO-639-2_utf-8.txt')
     
      # TODO: check checksums of incoming files?

      raise 'There are existing languages, doing nothing.' if Language.all.count > 0

      begin
        ActiveRecord::Base.transaction do
          File.foreach(args[:data_directory]) do |row| 
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
        end
      rescue
        raise
      end

    end
  end
end
