require 'fileutils'

namespace :tw do
  namespace :project_import do

    def initiate_project_and_users(project_name, user_id)
      @project = FactoryGirl.create(:valid_project, name: project_name)

      # TODO: refactor to use user_id 
      @user = FactoryGirl.create(:user, email: 'john@bm.org', password: '3242341aas', password_confirmation: '3242341aas')
      $project_id = @project.id
      $user_id = @user.id
      return @project, @user
    end      

    def column_values(fixed_line)
      CSV.parse(fixed_line, col_sep: "\t", encoding: "UTF-8").first
    end

    def fix_line(line)
      line.gsub(/\t\\N\t/, "\t\"NULL\"\t").gsub(/\\"/, '""') # .gsub(/\t/, '|')
    end



  end
end




