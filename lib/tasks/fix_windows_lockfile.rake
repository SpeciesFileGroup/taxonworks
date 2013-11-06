# Culted from http://stackoverflow.com/questions/2139058/how-to-insert-a-string-into-a-textfile (thanks!)

require 'fileutils'

namespace :tw do
  namespace :development do

    desc 'Add mingw32 lines to the Gemfile.lock to support mysql and other problems in windows !! assumes particular gem versions !!'
    task  :fix_windows_gemfile_lock do |t|
      new_lockfile = File.new(Rails.root + 'tmp/temp_lockfile.tmp', 'w')
      old_lockfile = File.open(Rails.root + 'Gemfile.lock')

      not_done = true 
      old_lockfile.each do |line|
        new_lockfile << line

        if not_done
          if line =~ /bcrypt-ruby/
            new_lockfile <<  "    bcrypt-ruby (3.1.2-x64-mingw32)\n"
          end
          if line =~ /mysql2/
            new_lockfile <<  "    mysql2 (0.3.11)\n"
          end
        end

        not_done = false if line =~ /DEPENDENCIES/
      end

      old_lockfile.close
      new_lockfile.close

      FileUtils.mv("#{Rails.root}/tmp/temp_lockfile.tmp", "#{Rails.root}/Gemfile.lock")
      puts 'Added mingw32 lines to Gemfile.lock'
    end
  end
end
