namespace :tw do
  namespace :maintenance do
    namespace :users do

      desc 'dump email addresses for all users of this instance (STDOUT/screen)'
      task  dump_emails: [:environment] do |t|
        puts "\n" + User.pluck(:email).join(',') + "\n\n"
      end

      # rake tw:maintenance:users:send_maintenance:email file=some_file subject = 'Some subject'
      desc "send an email to *all users* regarding pending maintenance, use sparingly - <file=some_file subject='some subject'>" 
      task  send_maintenance_email: [:environment, :file] do |t|
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

      # For downstream use of the file see also: 
      #   rake tw:initialize:validate_users
      #   rake tw:initialize:load_users
      desc 'dump a users.yml file with all existing users to backup_directory, intent is sandbox use' 
      task 'dump_yaml' => [:environment, :backup_directory] do
        users = {}
        User.order(:name).all.each do |u|
          users[u.email] = {
            password: Utilities::Strings.random_string(12), # generate a new, bogus password
            name: u.name,
            is_administrator: u.is_administrator ? true : false, 
            is_flagged_for_password_reset: true             # flag user for reset, they can do nothing until this is done
          }
        end

        path = File.join(@args[:backup_directory],  'users.yml')
        f = File.new( path, 'w' )
        f.puts users.to_yaml
        f.close
        puts "User metadata dumped to #{path}.".yellow
      end
    end
  end
end


