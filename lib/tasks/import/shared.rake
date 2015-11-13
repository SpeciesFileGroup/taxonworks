require 'fileutils'

namespace :tw do
  namespace :project_import do
    
    def initiate_project_and_users(project_name, user_email)
      user = User.create!(name: "Update #{user_email}", email: user_email, password: '3242341aas', password_confirmation: '3242341aas', self_created: true, is_flagged_for_password_reset: true)
      $user_id = user.id

      project = Project.find_or_create_by(name: project_name)
      $project_id = project.id

      project.users << user 
      [project, user]
    end      

    def column_values(fixed_line)
      CSV.parse(fixed_line, col_sep: "\t", encoding: "UTF-8").first
    end

    def fix_line(line)
      line.gsub(/\t\\N\t/, "\t\"NULL\"\t").gsub(/\\"/, '""') # .gsub(/\t/, '|')
    end

    def time_from_field(time)
      return nil if time.nil?
      if time =~ /\d+\/\d+\/\d+ \d+:\d+:\d+/
        Time.strptime("#{time} GMT", "%m/%d/%Y %H:%M:%S %Z")
      elsif time =~ /\d+\/\d+\/\d+/
        Time.strptime("#{time} 0:00:00 GMT", "%m/%d/%Y %H:%M:%S %Z")
      end
    end

    def year_from_field(time)
      time = time_from_field(time)
      time = time.nil? ? Time.now.year : time.year
      time
    end

    def find_or_create_user(id, data)
      if data.users[id]
        data.users[id]
      else
        u = User.new
        data.users.merge!(id => u) 
        u 
      end
    end

  end
end




