namespace :tw do
  namespace :maintenance do
    namespace :projects do

      # rake tw:maintenance:projects:reset_preferences
      desc 'reset all preferences to default' 
      task reset_preferences: [:environment, :user_id] do
        begin
          Project.transaction do
            # deserializing bad json is hard, nuke it with raw sql
            puts Rainbow("Reseting project preferences").purple
            Project.connection.execute("UPDATE projects SET preferences = '{}';")
            Project.all.each do |p|
              p.reset_preferences
              p.save!
              puts Rainbow("  #{p.name}").yellow
            end
          end
        rescue ActiveRecord::RecordInvalid
          raise
        end
      end
    end
  end
end
