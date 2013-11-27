require 'fileutils'

namespace :tw do
  namespace :project_import do
    namespace :ucd do 

      desc 'the full loop' 
      task  :import_ucd, [:data_directory] => :environment do |t, args| 
        args.with_defaults(:data_directory => '.')
        puts args
      end


      task :sql_dump_script do
        %w{coll country dist famtrib fgnames genus h-fam hknew hostfam hosts journals keywords language master p-type refext refs relation reliable species status tran tstat wwwimaok}.each do |t|

          puts "SELECT * FROM `#{t}` INTO OUTFILE '/tmp/ucd/#{t}.csv' 
        FIELDS TERMINATED BY '\\t'
        ENCLOSED BY '\"'
        LINES TERMINATED BY '\\n';"
        end
      end

    end
  end
end



