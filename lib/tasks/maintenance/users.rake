namespace :tw do
  namespace :maintenance do
    namespace :users do
      desc 'dump email addresses for all users of this instance in comma seperated file'
      task  :dump_emails =>  [:environment] do |t|
        puts "\n" + User.pluck(:email).join(',') + "\n\n"
      end
    end
  end
end


