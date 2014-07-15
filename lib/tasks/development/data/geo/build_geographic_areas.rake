namespace :tw do
  namespace :development do
    namespace :data do
      namespace :geo do 

        desc 'Rebuilds the awesome_nested_set lft,rgt indexing on GeographicAreas.'
        task :rebuild_geographic_areas_nesting => [:environment, :geo_dev_init] do
          puts "\n\n#{Time.now.strftime "%H:%M:%S"}."
          GeographicArea.rebuild!
          puts "\n\n#{Time.now.strftime "%H:%M:%S"}."
        end

        # !! It is recommended that you start from scratch prior to running this.
        #  rake db:drop RAILS_ENV=development && rake db:create RAILS_ENV=development && rake db:migrate RAILS_ENV=development && rake db:seed RAILS_ENV=development
        #  
        desc "Builds GeographicAreas, simultaneously builds GeographicAreaTypes if needed and stubs GeographicAreasGeographicItems.\n
                rake tw:development:data:geo:build_geographic_areas data_directory=/Users/matt/src/sf/tw/gaz/ user_id=1 database_role=matt NO_GEO_NESTING=1 NO_GEO_VALID=1"
        task :build_geographic_areas => [:environment, :geo_dev_init, :data_directory, :user_id, :build_temporary_shapefile_tables] do
          @connection = ActiveRecord::Base.connection
          @earth = build_earth # make sure the earth record exists and is available
          @data_index = GeoAreasIndex.new(@earth)

          build_areas_from_country_codes

          IMPORT_TABLES.keys.each do |source_table|
            self.send("build_areas_from_#{source_table}")        
          end

          @data_index.build_internal_nodes
          @data_index.create_areas

          puts "Collisions: #{@data_index.collision_count}"
          puts "Total geographic areas created: #{@data_index.index.count}"
        end

        def build_earth
          if e = GeographicArea.where(name: 'Earth').first
            e
          else
            GeographicArea.create(name: 'Earth', geographic_area_type: GeographicAreaType.find_or_create_by(name: 'Planet'))
          end
        end

        # An index structure for the data.
        class GeoAreasIndex
          attr_accessor :index, :collision_count, :duplicate_names

          def initialize(earth)
            @index = {}
            @collision_count = 0
            @duplicate_names = []

            i = add_item(
              name: earth.name, 
              parent_names: [],
              source_table: 'SFG',
              is_internal_node: true
            )
            @index[i.index].geographic_area = earth
          end

          def names
            @index.values.collect{|n| n.temp_area}
          end 

          # A setter method, all additions to the index must use this.
          def add_item(attribute_hash)
            i = TempArea.new(attribute_hash)
            if @index[i.index]
              @collision_count += 1 
              @duplicate_names.push(i)
              @index[i.index].temp_area.add_shape(attribute_hash) 
            else
              @index.merge!( i.index => RecordLink.new( temp_area: i, geographic_area: nil ) ) 
            end
            i
          end

          # Internal nodes presently do not build corresponding lvl records!  Not sure if this is an issue.
          def build_internal_nodes
            names.each do |tmp_geo_area|
              recurse_nodes(tmp_geo_area.parent_names, tmp_geo_area) 
            end
          end

          # Recursively builds internal nodes. 
          def recurse_nodes(parent_names, source_tmp_geo_area)
            if parent_names.count > 1 
              parents = parent_names.dup # Tricky! 
              name = parents.shift
              puts "building internal node: #{name} : #{parents} "
              add_item(
                name: name,
                parent_names: parents,
                source_table: source_tmp_geo_area.source_table,
                source_table_gid: source_tmp_geo_area.source_table_gid,
                is_internal_node: true
              )
              recurse_nodes(parents, source_tmp_geo_area)
            end
          end

          def create_areas
            build_individual_areas
            update_parents
            update_levels
            save_all
          end

          # If you add an attribute, it must be included here.
          def build_individual_areas
            @index.values.each do |n|
              geographic_area_type = (n.temp_area.geographic_area_type_name.blank? ? 'Unknown' : n.temp_area.geographic_area_type_name)
              n.geographic_area = GeographicArea.new(
                name: n.temp_area.name,    # Clean name at this point if needed.
                data_origin: n.temp_area.source_table,
                geographic_area_type: GeographicAreaType.find_or_create_by(name: geographic_area_type ),
                tdwgID: n.temp_area.tdwgID, 
                iso_3166_a2: n.temp_area.iso_3166_a2, 
                iso_3166_a3: n.temp_area.iso_3166_a3
              )   
            end
          end

          def update_parents
            @index.values.each do |n| 
              next if n.temp_area.name == 'Earth'  # This is a bit ugh, but let's us use fewer exceptions?
              n.geographic_area.parent = @index[n.temp_area.parent_index].geographic_area 
            end
          end

          def update_levels
            @index.values.each do |n| 
              next if n.temp_area.name == 'Earth'  
              l0, l1, l2 = n.temp_area.level0_index, n.temp_area.level1_index, n.temp_area.level2_index
              n.geographic_area.level0 = @index[l0].geographic_area if l0 != {}
              n.geographic_area.level1 = @index[l1].geographic_area if l1 != {}
              n.geographic_area.level2 = @index[l2].geographic_area if l2 != {}
            end
          end

          def save_all
            puts "Saving.."
            save_geographic_areas
            raise if names_not_saved.count > 0
            create_geographic_areas_geographic_items
            puts "\n...done.\n"
          end

          def create_geographic_areas_geographic_items
            @index.values.each do |n| 
              n.temp_area.shapes.each do |s|
                GeographicAreasGeographicItem.create!(geographic_area: n.geographic_area, data_origin: s[0], origin_gid: s[1], date_valid_from: s[2], date_valid_to: s[3])
              end
            end
          end

          def save_geographic_areas
            @index.values.each do |n| 
              recursively_save(n.geographic_area)
            end
          end

          def recursively_save(geographic_area)
            parent = geographic_area.parent
            if parent && parent.new_record?
              recursively_save(parent)
            end
            print "\r#{geographic_area.name}                                            "
            geographic_area.save!
          end

          # The following methods should not be used to handle/parse incoming data, 
          # they are for debugging/reporting only.

          def all_name_strings
            names.collect{|a| a.name}
          end

          def duplicate_name_strings
            @duplicate_names.collect{|a| a.name}.sort.uniq
          end

          def internal_names
            names.select{|n| n.is_internal_node}
          end  

          def names_with_multiple_shapes
            names.select{|n| n.shapes.count > 1 }
          end

          # These should be empty Arrays

          def names_not_indexed
            names.select{|n| !@index[n.index]}
          end

          def names_without_parent_arrays
            names.select{|n| n.parent_names.nil? || n.parent_names.count == 0}
          end

          def names_not_saved
            @index.values.collect{|i| i.geographic_area}.select{|a| a.new_record?}
          end
        end

        # A instance links indexed data to its model representation
        class RecordLink
          attr_accessor :temp_area, :geographic_area
          def initialize(params)
            @temp_area = params[:temp_area]
            @geographic_area = params[:geographic_area]
          end
        end

        # Instances store attributes of the to be created GeographicArea and related records
        class TempArea
          attr_accessor :name, :tdwgID, :iso_3166_a2, :source_table, :iso_3166_a3      # Base attributes, source_table is both GeographicArea#data_origin and GeographicAreasGeographicItem#data_origin
          attr_accessor :lvl0, :lvl1, :lvl2, :parent_names, :geographic_area_type_name # Used to build related records 
          attr_accessor :source_table_gid, :shapes, :date_valid_from, :date_valid_to   # GeographicAreasGeographicItem attributes
          attr_accessor :is_internal_node                                              # internal nodes have no shapes

          def initialize(attribute_hash)
            @shapes = []
            raise if attribute_hash[:name].strip.blank?
            attribute_hash.each do |k, v|
              self.send("#{k}=", v)
            end
            add_shape(attribute_hash) 
            true
          end

          # Handle the shape-related metadata
          def add_shape(attribute_hash)
            return false if attribute_hash[:is_internal_node]
            raise if attribute_hash[:source_table].blank? || attribute_hash[:source_table_gid].blank?
            @shapes.push [attribute_hash[:source_table], attribute_hash[:source_table_gid], attribute_hash[:date_valid_from], attribute_hash[:date_valid_to]] 
          end

          # All records are indexed by this hash.
          def index 
            {name: @name, parent_names: @parent_names } 
          end

          # Don't check Earth
          def parent_index
            {name: @parent_names.first, parent_names: @parent_names[1..(@parent_names.length)]}
          end

          # All of our data are presently only loded with @earth.name as parent
          def level0_index 
            return {} if @lvl0.nil?
            {name: @lvl0, parent_names: [@parent_names.last]}
          end

          def level1_index 
            return {} if @lvl1.nil?
            {name: @lvl1, parent_names: [@lvl0, @parent_names.last].delete_if{|n| n.blank?}}
          end

          def level2_index 
            return {} if @lvl2.nil?
            {name: @lvl2, parent_names: [@lvl1, @lvl0, @parent_names.last].delete_if{|n| n.blank?} }
          end
        end # End TempArea

        # Some query helpers

        # Return an Array of every record in the database MINUS its geom column.
        def all_records(table_name)
          @connection.execute("Select #{columns_minus_geom(table_name).collect{|c| "\"#{c}\""}.join(", ")} from #{table_name}")
        end

        # Return an Array of every column header MINUS its geom column.
        def columns_minus_geom(table_name)
          @connection.execute("select column_name from information_schema.columns where table_name = '#{table_name}';").collect{|a| a['column_name']}.delete_if{|b| b == 'geom' }
        end

        # Return a string capitalized except for 'and'
        def uncapitalize(name)
          raise if name.blank?
          name.downcase.titleize.gsub(/\sAnd\s/, ' and ')
        end

        # Build methods for individual sources.  Each source has its own method.

        def build_areas_from_country_codes
          CSV.read("#{@args[:data_directory]}data/external/country_names_and_code_elements.txt", options = {headers: true, col_sep: ';'}).each do |r|
            @data_index.add_item(
              name: uncapitalize(r['Country Name']),
              parent_names: [@earth.name],
              lvl0: uncapitalize(r['Country Name']), 
              source_table: 'country_names_and_code_elements',
              geographic_area_type_name: 'Country',
              is_internal_node: true,
              iso_3166_a2: r['ISO 3166-1-alpha-2 code']
            )
          end
        end

        def build_areas_from_gadm
          source_table = 'gadm'
          all_records(source_table).each do |r|
            # Only select records in levels 0-2
            next if !r['name_3'].blank? || !r['name_4'].blank? |!r['name_5'].blank?
            puts "#\r  #{r['gid']} #{gadm_name_from_row(r)} : #{gadm_parent_names_from_row(r)}"
            @data_index.add_item(
              name: gadm_name_from_row(r),
              parent_names: gadm_parent_names_from_row(r),
              lvl0: r['name_0'], 
              lvl1: r['name_1'], 
              lvl2: r['name_2'],
              source_table: source_table,
              source_table_gid: r['gid'], 
              geographic_area_type_name: gadm_geographic_area_type_from_row(r),
              date_valid_from: gadm_valid_from(r),
              date_valid_to: gadm_valid_to(r),
              geographic_area_type_name: gadm_geographic_area_type_from_row(r),
            )
          end 
        end

        def gadm_valid_from(row)
          r = gadm_level(row)
          return nil if r == 0
          row["validfr_#{r}"]
        end

        def gadm_valid_to(row)
          r = gadm_level(row)
          return nil if r == 0
          row["validto_#{r}"]
        end

        # Returns the assumed level the gadm record is for
        def gadm_level(row)
          return '2' if !row['name_2'].to_s.strip.blank?
          return '1' if !row['name_1'].to_s.strip.blank?
          '0' 
        end

        # TODO: Assumes all level0 entities are type Country, likely not fully true?
        def gadm_geographic_area_type_from_row(row)
          return row['engtype_2'] if !row['name_2'].blank?
          return row['engtype_1'] if !row['name_1'].blank?
          'Country'  
        end

        def gadm_names_from_row(row)
          [ row['name_2'], row['name_1'], row['name_0'], @earth.name ].delete_if{|a| a.blank?}
        end

        def gadm_parent_names_from_row(row)
          parents = gadm_names_from_row(row)
          parents.shift
          parents
        end

        def gadm_name_from_row(row)
          gadm_names_from_row(row).first
        end

        def gadm_parent_name_from_row(row)
          gadm_names_from_row(row)[1]
        end

        def build_areas_from_tdwg_l1
          puts "tdwg level 1"
          source_table = 'tdwg_l1'
          all_records(source_table).each do |r|
            @data_index.add_item(
              name: uncapitalize(r['level1_nam']),
              parent_names: [@earth.name],
              source_table: source_table,
              source_table_gid: r['gid'],
              geographic_area_type_name: 'TDWG Level 1',
              tdwgID: r['level1_cod'],
            )
          end
        end

        def build_areas_from_tdwg_l2
          puts "tdwg level 2"
          source_table = 'tdwg_l2'
          all_records(source_table).each do |r|
            @data_index.add_item(
              name: r['level2_nam'],
              parent_names: [uncapitalize(r['level1_nam']), @earth.name],
              source_table: source_table,
              source_table_gid: r['gid'],
              geographic_area_type_name: 'TDWG Level 2',
              tdwgID: r['level2_cod'],
            )
          end
        end

        def build_areas_from_tdwg_l3
          puts "tdwg level 3"
          source_table = 'tdwg_l3'
          all_records(source_table).each do |r|
            @data_index.add_item(
              name: r['level3_nam'],
              parent_names: [tdwg_level_2_name(r), tdwg_level_1_name(r), @earth.name],
              source_table: source_table,
              source_table_gid: r['gid'],
              geographic_area_type_name: 'TDWG Level 3',
              tdwgID: "#{r['level2_cod']}#{r['level3_cod']}",
            )
          end
        end

        def build_areas_from_tdwg_l4
          puts "tdwg level 4"
          source_table = 'tdwg_l4'
          all_records(source_table).each do |r|
            @data_index.add_item(
              name: r['level_4_na'],
              parent_names: [tdwg_level_3_name(r), tdwg_level_2_name(r), tdwg_level_1_name(r), @earth.name],
              source_table: source_table,
              source_table_gid: r['gid'],
              tdwgID: "#{r['level2_cod']}#{r['level4_cod']}",
              geographic_area_type_name: 'TDWG Level 4'
            )
          end
        end

        def tdwg_level_1_name(r)
          uncapitalize( @connection.execute("select level1_nam from tdwg_l1 where level1_cod = '#{r['level1_cod']}';").first['level1_nam'] )
        end

        def tdwg_level_2_name(r)
          @connection.execute("select level2_nam from tdwg_l2 where level1_cod =  '#{r['level1_cod']}' and level2_cod = '#{r['level2_cod']}';").first['level2_nam']
        end

        def tdwg_level_3_name(r)
          @connection.execute("select level3_nam from tdwg_l3 where level3_cod = '#{r['level3_cod']}' AND level2_cod = '#{r['level2_cod']}';").first['level3_nam']
        end

        def build_areas_from_ne_countries
          puts "indexing ne_countries"
          source_table = 'ne_countries'

          all_records(source_table).each do |r|
            # byebug if r['name'].blank?
            @data_index.add_item(
              name: r['name'],
              lvl0: r['name'],
              parent_names: [@earth.name],
              source_table: source_table,
              source_table_gid: r['gid'],
              geographic_area_type_name: 'Country',
              iso_3166_a3: r['iso_a3']
            )
          end
        end

        def build_areas_from_ne_states
          puts "indexing ne_states"
          source_table = 'ne_states'
          all_records(source_table).each do |r|
            @data_index.add_item(
              name: r['name'] ? r['name'] : 'UNKNOWN', # !@# 3285 has no name 
              lvl0: r['admin'],
              parent_names: [ r['admin'], @earth.name ],
              source_table: source_table,
              source_table_gid: r['gid'],
              geographic_area_type_name: r['type'].blank?
            )
          end
        end

        # The following may need to be reviewed for re-implementation, MAYBE. 
        #
        # @gadm_xlate = YAML.load(File.read(@args[:data_directory] + 'data/external/import_helpers/gadm_translations.yaml'))
        # @tdwg_xlate = YAML.load(File.read(@args[:data_directory] + 'data/external/import_helpers/tdwg_translations.yaml'))
        #
        # def name_fix(name)
        #   case name
        #   when /Jõgeva\r (commune)/
        #     name = 'Jõgeva (commune)'
        #   when /Põltsamaa\r\rPõltsamaa/
        #     name = 'Põltsamaa'
        #   when /Halmahera Tengah\rHalmahera Tengah/
        #     name = 'Halmahera Tengah'
        #   end
        #   name
        # end

      end
    end
  end
end
