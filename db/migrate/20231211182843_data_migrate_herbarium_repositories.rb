class DataMigrateHerbariumRepositories < ActiveRecord::Migration[6.1]
  def change
 
   failed = [] 

    Repository.where("acronym ILIKE '%<%IH%>%'").find_each do |r|
      begin
        r.update!(
          is_index_herbariorum: true,
          acronym: r.acronym.gsub(/\<IH\>/, ''),
          by: 1 # somewhat fragile 
        )
      rescue ActiveRecord::RecordInvalid => e
        failed.push e.record
      end
    end

    ap failed

  end
end
