namespace :tw do
  namespace :initialize do

    desc 'call like "rake tw:intialize:load_repositories", required data_directory'
    task load_repositories: [:data_directory, :environment, :user_id] do |t|

      print 'Loading repositories...'
      if Repository.all.count > 0 
        puts Rainbow('There are existing repositories, doing nothing.').red.on_white 
        raise 
      end

      file = @args[:data_directory] + 'biorepositories.csv'
       
      # TODO: check checksums of incoming files?

      begin
        ApplicationRecord.transaction do
          f = CSV.open(file, headers: true)
          f.each do |row|
            r = Repository.new(
              url: row['URL'],
              name: row['Name of Biorepository or Institution'],
              is_index_herbariorum: (row['Index Herbariorum Record'] == 'yes' ? true : false),
              acronym: row['Institutional ID/Acronym'],
              institutional_LSID: row['Institutional LSID'],
              status: row['Status of biorepository'],
            )
            r.save!
          end
        end
        print "success!\n"
      rescue
        puts Rainbow('Problem laoding repositories').red.on_white
        raise
      end
    end
  end
end
