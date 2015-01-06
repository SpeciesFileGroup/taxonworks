namespace :tw do
  namespace :initialization do

    desc 'call like "rake tw:initialization:build_repositories[/Users/matt/Downloads/biorepositories.csv] user_id=1"'
    task :build_repositories, [:data_directory] => [:environment, :user_id] do |t, args|
      args.with_defaults(:data_directory => './biorepositories.csv')
     
      # TODO: check checksums of incoming files?

      raise 'There are existing repositories, doing nothing.' if Repository.all.count > 0

      begin
        ActiveRecord::Base.transaction do
          f = CSV.open(args[:data_directory], :headers => true)
          #CSV.foreach(args[:data_directory]) do |row|
          #CSV.foreach(args[:data_directory],  return_headers: false) do |row|
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
        puts "Success!"
      rescue
        raise
      end

    end
  end
end
