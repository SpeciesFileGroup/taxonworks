namespace :tw do
  namespace :maintenance do
    namespace :users do

      desc 'dump email addresses for all users of this instance in comma seperated file'
      task  :dump_emails =>  [:environment] do |t|
        puts "\n" + User.pluck(:email).join(',') + "\n\n"
      end

      # rake tw:maintenance:users:send_maintenance:email file=some_file subject = 'Some subject'
      desc 'send an email to *all users* regarding pending maintenance - use sparingly' 
      task  :send_maintenance_email =>  [:environment, :file] do |t|
        subject = ENV['subject']
        subject ||= 'TaxonWorks maintenance'

        file = File.read(@args[:file]) 

        puts "Email preview (bcc recipients are hidden):\n\n"
        puts  UserMailer.maintenance_email(file, subject).to_s.magenta
        puts "\n\n"

        print "Send this email? Type 'SEND' (all caps) to confirm: " 
        confirm_send = STDIN.gets.strip 
        if confirm_send != 'SEND'
          puts 'Message NOT sent.'.bold.red
          exit 
        else
          UserMailer.maintenance_email(file, subject).deliver
          puts 'Email sent.'.bold.yellow
        end
      end
    end

    # Intent is Sandbox use 
    desc 'dump a users.yml file for all existing users' 
    task 'dump_users_yaml' => [:environment, :backup_directory] do
      users = {}
      User.order(:name).all.each do |u|
        users[u.email] = {
          password: Utilities::Strings.random_string(12 ),
          name: u.name,
          is_administrator: u.is_administrator ? true : false, 
          is_flagged_for_password_reset: true
        }
      end

      path = @args[:backup_directory] + '/users_dump.yml'
      # TODO: proper Ruby page_merge
      f = File.new( path, 'w' )
      f.puts users.to_yaml
      f.close
      puts "User metadata dumped to #{path}.".yellow
    end

  end
end


