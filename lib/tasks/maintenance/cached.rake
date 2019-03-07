namespace :tw do
  namespace :maintenance do
    namespace :cached do

      desc 'rebuild cached original combinations for taxon names'
      task  rebuild_cached_original_combinations: [:environment, :project_id, :user_id] do |t|
        query = Protonym.is_species_or_genus_group.where(project_id: Current.project_id, cached_original_combination: nil)  
        
        if !ProjectMember.where(project_id: Current.project_id).pluck(:user_id).include?(Current.user_id)
          puts Rainbow("User is not a member of that project.").red.bold
          exit
        end

        puts Rainbow("Processing #{query.count} records").purple

        query.find_each do |p|
          print Rainbow( p.name + ' [' + p.id.to_s + ']' ).yellow
          begin
            if p.original_combination_relationships.load.any?
              p.update_cached_original_combinations
              puts Rainbow(' PROCESSED OK').green.bold
            else
              puts Rainbow(' NO METADA FOUND').orange.bold
            end
          rescue 
            puts Rainbow(' FAILED').red.bold
          end
        end
      end

    end

  end
end

