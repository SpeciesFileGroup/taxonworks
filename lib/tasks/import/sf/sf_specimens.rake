namespace :tw do
  namespace :project_import do
    namespace :sf_import do
      require 'fileutils'
      require 'logged_task'
      namespace :specimens do

        desc 'time rake tw:project_import:sf_import:specimens:import_two_specimen_lists user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        LoggedTask.define :import_two_specimen_lists => [:data_directory, :environment, :user_id] do |logger|
          # Can be run independently at any time

          logger.info 'Running new specimen lists (hash, array)...'

          get_new_preserved_specimen_id = [] # array of SF.SpecimenIDs with BasisOfRecord = 0 (not stated) but with DepoID or specimen count
          get_sf_unique_id = {} # key = SF.SpecimenID, value = sfUniqueLocColEvents.UniqueID


          logger.info '1. Getting new preferred specimen ids'

          path = @args[:data_directory] + 'sfAddPreservedSpecimens.txt'
          file = CSV.read(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

          file.each do |row|
            get_new_preserved_specimen_id.push(row[0])
          end


          logger.info '2. Getting SF SpecimenID to UniqueID hash'

          count = 0

          path = @args[:data_directory] + 'sfSpecimenToUniqueIDs.txt'
          file = CSV.read(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

          file.each do |row|
            puts "SpecimenID = #{row['SpecimenID']}, count #{count += 1} \n"
            get_sf_unique_id[row['SpecimenID']] = row['UniqueLocColEventID']
          end


          import = Import.find_or_create_by(name: 'SpeciesFileData')
          import.set('SFNewPreservedSpecimens', get_new_preserved_specimen_id)
          import.set('SFSpecimenToUniqueIDs', get_sf_unique_id)

          puts 'SFNewPreservedSpecimens'
          ap get_new_preserved_specimen_id

          puts 'SFSpecimenToUniqueIDs'
          ap get_sf_unique_id

        end

      end
    end
  end
end

