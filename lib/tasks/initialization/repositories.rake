# We'll add foreign keys with immigrant ultimately
# https://github.com/jenseng/immigrant

require 'fileutils'

namespace :tw do
  namespace :initialization do

    desc 'call like "rake tw:initialization:build_repositories[/Users/matt/Downloads/biorepositories.csv]"'
    task :build_repositories, [:data_directory] => [:environment] do |t, args|
      args.with_defaults(:data_directory => './biorepositories.csv')
     
      # TODO: check checksums of incoming files?

      raise 'There are existing repositories, doing nothing.' if Repository.all.count > 0

      begin
        ActiveRecord::Base.transaction do
          CSV.foreach(args[:data_directory],  return_headers: false) do |row|
            r = Repository.new(
              url: row[0],                       
              name: row[1],                      
              is_index_herbarioum_record: (row[2] == 'yes' ? true : false),
              acronym: row[3],
              institutional_LSID: row[8],         
              status: row[26],                    
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
