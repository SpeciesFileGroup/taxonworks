namespace :tw do
  namespace :development do
    namespace :data do
      namespace :geo do 
        desc "Generate the GeographicAreaTypes table, storing results in an index @gat_list."
        task :build_geographic_area_types => [:environment, :geo_dev_init, :data_directory, :user_id] do
          @gat_list = {}
          GeographicAreaType.all.each { |gat|
            @gat_list.merge!({gat.name => gat})
          }
          build_gat_table
        end

        #noinspection RubyStringKeysInHashInspection
        def build_gat_table
          our_area_types = YAML.load(File.read(@args[:data_directory] + 'data/external/import_helpers/tw_geographic_area_types.yaml'))
          our_area_types.each { |item|
            area_type = GeographicAreaType.where(name: item).first
            if area_type.nil?
              area_type = GeographicAreaType.new(name: item)
              area_type.save!
            end
            @gat_list.merge!(item => area_type)
          }

          # add as required from NaturalEarth list
          ne_divisions

          # add as required from GADM list
          gadm_divisions

          # make special cases
          l_var = 'Unknown'
          @gat_list.merge!('' => @gat_list[l_var])
          @gat_list.merge!(nil => @gat_list[l_var])
        end

        #noinspection RubyStringKeysInHashInspection
        def ne_divisions
          ne_area_types = YAML.load(File.read(@args[:data_directory] + 'data/external/import_helpers/ne_geographic_area_types.yaml'))
          ne_area_types.each { |item|
            area_type = GeographicAreaType.where(name: item).first
            if area_type.nil?
              area_type = GeographicAreaType.new(name: item)
              area_type.save!
            end
            @gat_list.merge!(item => area_type)
          }
        end

        #noinspection RubyStringKeysInHashInspection
        def gadm_divisions
          gadm_division_area_types = YAML.load(File.read(@args[:data_directory] + 'data/external/import_helpers/gadm_divisions_geographic_area_types.yaml'))
          gadm_division_area_types.each { |item|
            area_type = GeographicAreaType.where(name: item).first
            if area_type.nil?
              area_type = GeographicAreaType.new(name: item)
              area_type.save!
            end
            @gat_list.merge!(item => area_type)
          }
        end
      end
    end
  end
end
