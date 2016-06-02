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
        puts  UserMailer.maintenance_email(file, subject).to_s.purple
        puts "\n\n"

        print "Send this email? Type 'SEND' (all caps) to confirm: " 
        confirm_send = STDIN.gets.strip 
        if confirm_send != 'SEND'
          puts 'Message NOT sent.'.red.bold
          exit 
        else
          UserMailer.maintenance_email(file, subject).deliver
          puts 'Email sent.'.yellow.bold
        end
      end
    end

  end
end


