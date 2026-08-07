class DataMakeCommunityAnnotatatorsCommunity < ActiveRecord::Migration[6.1]

  # This updates all annotations to cross-project for the klasses listed.
  def change
    [Identifier::Global, AlternateValue].each do |k|
      %w{Serial Person Source GeographicArea Organization}.each do |m|
        n = k.base_class.table_name.singularize
        q = k.where("#{n}_object_type = '#{m}'")
        puts m + '/' + n + ': ' + q.count.to_s # .update_all(project_id: nil)
        q.update_all(project_id: nil)
      end
    end
    true
  end

end
