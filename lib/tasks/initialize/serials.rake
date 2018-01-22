namespace :tw do
  namespace :initialize do

    desc 'call like "rake tw:initialize:load_serials", required data_directory'
    task :load_serials => [:data_directory, :environment] do |t|
      print 'Loading serials and related metadata...'

      [Serial, SerialChronology, Identifier, DataAttribute, AlternateValue].each do |klass|
        if klass.count > 0 
          puts "There are existing #{klass.name.humanize}, doing nothing.".red
          raise 
        end
      end

      database = ApplicationRecord.connection.current_database
      path = File.join(@args[:data_directory], 'serial_table.dump')

      # serial data
      `pg_restore -Fc --disable-triggers -c -d #{database} #{path}`
      raise "pg_restore failed with exit code #{$?.to_i}" unless $? == 0
     
      # metadata 
      path = File.join(@args[:data_directory], 'serial_metadata_tables.dump')
      `pg_restore -Fc -c -d #{database} #{path}` 
      raise "pg_restore failed with exit code #{$?.to_i}" unless $? == 0
      
      puts 'Completed serial data load from .dumps'.yellow
    end
  end
end
