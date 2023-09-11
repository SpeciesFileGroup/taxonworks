namespace :tw do
  namespace :maintenance do

    # !! All tasks here must be idempotent - https://en.wikipedia.org/wiki/Idempotence

    # See also lib/maintenance/cached
    namespace :geo do
      
      # Exectuted in db/migrate/20200326194426_data_refine_geographic_areas1.rb
      # https://github.com/SpeciesFileGroup/taxonworks/issues/1373
      desc 'refine geographic areas types'
      task refine_geographic_areas_1: [:environment] do |t|

        ApplicationRecord.transaction do

          # United States of America from data origin `ne_states`
          if a = GeographicArea.where(id: 33412).first

            # Make it a Country
            a.update_column(:geographic_area_type_id, 3)

            # States -> States 
            a.children.update_all(geographic_area_type_id: 63)
          end

          # District of Columbia -> District
          GeographicArea.where(id: 33452).first&.update_column(:geographic_area_type_id, 30)

        rescue ActiveRecord::RecordInvalid
          puts Rainbow('failed').red
        end
      end

    end
  end
end



