# INIT tasks for RGeo, PostGIS, shape files (GADM and TDWG)

# TODO: Problems with GADM V2
#    28758: Not a valid geometry.
#   200655: Side location conflict at 33.489303588867358, 0.087361000478210826

SFG = 'SpeciesFile Group'

# ISO Country Codes:
# See http://www.iso.org/iso/home/standards/country_codes.htm

ISO_3166_1_2 = 'ISO 3166-1-alpha-2' # ISO 3166-1:2006 two-letter country abbreviations
ISO_3166_1_3 = 'ISO 3166-1-alpha-3' # ISO 3166-1:2006 three-letter country abbreviations
# Other current choices are:
ISO_3166_3   = 'ISO 3166-3:1999' # Country names which have been deleted from -1 since 1974
ISO_3166_2   = 'ISO 3166-2:2007' # State or Province level for country codes in 3166-1

TDWG2_L1 = 'TDWG2 Level 1'
TDWG2_L2 = 'TDWG2 Level 2'
TDWG2_L3 = 'TDWG2 Level 3'
TDWG2_L4 = 'TDWG2 Level 4'

GADM2 = 'GADM2'

NE_10  = 'NaturalEarth (10m)'
NE_50  = 'NaturalEarth (50m)'
NE_110 = 'NaturalEarth (110m)'

EXTRA = 'Extra'

#
namespace :tw do
  namespace :init do

    desc 'Generate PostgreSQL/PostGIS records for shapefiles.'
    task :build_geographic_areas => :environment do

      place     = ENV['place']
      shapes    = ENV['shapes']

      # index is only expected to work for the GADM V2 shape file set: intended *only* as a
      # short-cut to a problem record.
      index     = ENV['index']

      # divisions is used to select only the processing of the division names in the GADM file.
      Divisions = false

      divisions = ENV['divisions']

      # build csv file list from 'place'

      # GenTable: set to true to generate the GeographicAreaType table here
      GenTable  = true
      # DoShape: set to true to include the reading of the shapes into the GeographicItem table;
      #          Otherwise, only the DBF files are used to populate the GeographicArea table
      DoShape   = false
      # BaseDir: where to find the tables to be used
      BaseDir   = '../shapes/'

      if place.nil?
        base_dir = BaseDir
      else
        base_dir = place.gsub('\\', '/')
      end

      if shapes.nil?
        do_shape = DoShape
      else
        do_shape = (shapes == 'true')
      end

      index = index.nil? ? 0 : index.to_i

      if divisions.nil?
        @divisions = Divisions
      else
        @divisions = true
      end

      if GenTable
        build_gat_table
        if do_shape
          # we use the entire shape file constellation
          Dir.glob(base_dir + '**/*.shp').each { |filename|
            read_shape(filename, index)
          }
        else
          # process all available files at the same time
          read_dbf(Dir.glob(base_dir + '**/*.dbf') + (Dir.glob(base_dir + '**/*.txt')))
        end
      end
    end
  end
end

def read_shape(filename, index)

  # TODO: For some reason, Georeference::FACTORY does not seem to be the default factory, so we are being specific here, to get the lenient polygon tests.  This gets us past the problem polygons, but does not actually deal with the problem.
  # See http://dazuma.github.io/rgeo-shapefile/rdoc/RGeo/Shapefile/Reader.html for reader options.

  # ne10 = RGeo::Shapefile::Reader.open('G:\Share\Downloads\PostgreSQL\PostGIS\10m_cultural\10m_cultural\ne_10m_admin_0_countries.shp', factory: Georeference::FACTORY)
  # gadm = RGeo::Shapefile::Reader.open('G:\Share\rails\shapes\gadm_v2_shp\gadm2.shp', factory: Georeference::FACTORY)

  RGeo::Shapefile::Reader.open(filename, factory: Georeference::FACTORY) { |file|

    file.seek_index(index)
    count = file.num_records
    ess   = (count == 1) ? '' : 's'
    puts "#{Time.now.strftime "%H:%M:%S"}: #{filename} contains #{count} item#{ess}."

    # things to do before each file

    case filename
      when /adm1/i
        # since we are going to have to skip XXX_adm0, we need to build a master records for North America,
        # the USA by hand
        mr = GeographicArea.where(name: 'United States')
        if mr[0].nil?
          mr = GeographicArea.new(name:                 'United States',
                                  country_id:           240,
                                  parent_id:            0,
                                  geographic_area_type: GeographicAreaType.where(name: 'Country')[0])
          mr.save
        end
      when /level1/i
        record = GeographicArea.where(name: 'Earth')
        if record.count == 0
          record    = GeographicArea.new(parent_id: nil,
                                         name:      'Earth')
          area_type = GeographicAreaType.where(name: 'Planet')[0]
          # save this record for later
          earth     = record.save
        else
          earth = record[0]
        end
      else
        # nothing to do
    end

    # record    = GeographicArea.new
    # area_type = GeographicAreaType.new

    time_then = Time.now
    file.each { |item|
      record = nil

      # todo: This processing is *very* specific, and currently only handles the USA_adm shape file case: it must be made to handle a more general case of GADM, and/or TDWG

      case filename
        when /USA_adm0/
          record    = GeorgaphicArea.new(parent_id:  0,
                                         name:       item[:NAME_ENGLISH],
                                         country_id: item[:PID])
          area_type = GeographicAreaType.where(name: 'Country')[0]
        #if area_type.nil?
        #  at = GeographicAreaType.new(name: 'Country')
        #  at.save
        #  area_type = at
        #end
        when /USA_adm1/
          record    = GeographicArea.new(parent_id:  item[:ID_0],
                                         name:       item[:NAME_1],
                                         state_id:   item[:ID_1],
                                         country_id: item[:ID_0])
          area_type = GeographicAreaType.where(name: item[:TYPE_1])
        #if area_type.nil?
        #  at = GeographicAreaType.new(name: item[:TYPE_1])
        #  at.save
        #  area_type = at
        #end
        when /USA_adm2/
          record    = GeographicArea.new(parent_id:  item[:ID_1],
                                         name:       item[:NAME_2],
                                         state_id:   item[:ID_1],
                                         country_id: item[:ID_0],
                                         county_id:  item[:ID_2])
          area_type = GeographicAreaType.where(name: item[:TYPE_2])
        #if area_type.nil?
        #  at = GeographicAreaType.new(name: item[:TYPE_2])
        #  at.save
        #  area_type = at
        #end
        when /GADM/i
        when /level1/
          record = GeographicArea.new(parent_id: earth.id,
                                      name:      item['LEVEL1_NAM'])
          GeographicAreaType.where(name: item[''])
        when /level2/
        when /level3/
        when /level4/
        else
      end
      if !(record.nil?)
        record.geographic_area_type          = area_type[0]
        record.geographic_item               = GeographicItem.new
        record.geographic_item.multi_polygon = item.geometry
        record.save

        case filename
          when /USA_adm0/
            # when country, find parent continent
            # parent_record = GeographicArea.where({parent_id: 0, country_id: 0})[0]
            parent_record = GeographicArea.new(name:                 'North America',
                                               geographic_area_type: GeographicAreaType.where(name: 'Continent')[0])
          when /USA_adm1/
            # when state, find parent country
            parent_record = GeographicArea.where({state_id: nil, country_id: record.country_id})[0]
          when /USA_adm2/
            # when county, find parent state
            parent_record = GeographicArea.where({state_id: record.parent_id})[0]
          else

        end
        count = record.geographic_item.multi_polygon.num_geometries
        ess   = (count == 1) ? '' : 's'
        puts "#{'% 5d' % (item.index + 1)}:  #{record.geographic_area_type.name} of #{record.name} in the #{parent_record.geographic_area_type.name} of #{parent_record.name} => #{count} polygon#{ess}."
      else
        # this processing is specifically for GADM2
        if item.geometry.nil?
          item_type = 'Bad geometry'
          count_geo = 0
        else
          item_type = item.geometry.geometry_type
          count_geo = item.geometry.num_geometries
        end
        ess = (count_geo == 1) ? 'y' : 'ies'

        snap      = Time.now
        elapsed   = snap - time_then
        time_then = snap
        case filename
          when /GADM/i

            i5 = item['NAME_5']
            s5 = i5.empty? ? '' : (i5 + ', ')
            i4 = item['NAME_4']
            s4 = i4.empty? ? '' : (i4 + ', ')
            i3 = item['NAME_3']
            s3 = i3.empty? ? '' : (i3 + ', ')
            i2 = item['NAME_2']
            s2 = i2.empty? ? '' : (i2 + ', ')
            i1 = item['NAME_1']
            s1 = i1.empty? ? '' : (i1 + ', ')
            puts item.attributes
            puts "#{Time.at(time_then).strftime "%T"}: #{Time.at(elapsed).getgm.strftime "%H:%M:%S"}: #{item_type}#{'% 5d' % (item.index + 1)} (of #{count} items)(#{count_geo} geometr#{ess}) is called \'#{s5}#{s4}#{s3}#{s2}#{s1}#{item['NAME_0']}\'."
          when /level1/
            puts "#{Time.at(time_then).strftime "%T"}: #{Time.at(elapsed).getgm.strftime "%H:%M:%S"}: #{item['LEVEL1_COD']}, #{item['LEVEL1_NAM']}:  #{item_type}, (#{count_geo} geometr#{ess})"
          when /level2/
            puts "#{Time.at(time_then).strftime "%T"}: #{Time.at(elapsed).getgm.strftime "%H:%M:%S"}: #{item['LEVEL2_COD']}, #{item['LEVEL2_NAM']}, #{item['LEVEL1_NAM']}:  #{item_type}, (#{count_geo} geometr#{ess})"
          when /level3/
            o1 = Time.at(time_then).strftime "%T"
            o2 = Time.at(elapsed).getgm.strftime "%H:%M:%S"
            o3 = item['LEVEL2_COD']
            o4 = item['LEVEL3_COD']
            o5 = item['LEVEL3_NAM']
            o6 = item_type
            o7 = count_geo
            o8 = ess
            puts "#{o1}: #{o2}: #{o3}#{o4}, #{o5}:  #{o6}, (#{o7} geometr#{o8})"
          when /level4/
            # "ISO_Code","Level_4_Na","Level4_cod","Level4_2","Level3_cod","Level2_cod","Level1_cod"
            o1 = Time.at(time_then).strftime "%T"
            o2 = Time.at(elapsed).getgm.strftime "%H:%M:%S"
            o3 = item['ISO_Code']
            o9 = item['Level2_cod']
            o4 = item['Level4_cod']
            o5 = item['Level_4_Na']
            o6 = item_type
            o7 = count_geo
            o8 = ess

            puts "#{o1}: #{o2}: #{o3}: #{o9}#{o4},  #{o5}:  #{o6}, (#{o7} geometr#{o8})"
          else
        end

      end
    }
  } if !(filename =~ /[0]/)

end

def read_dbf(filenames)

  # things to do before any file

  divisions = false

  # make sure the earth record exists and is available

  earth     = GeographicArea.where(name: 'Earth')
  if earth.count == 0
    # create the record
    earth                      = GeographicArea.new(parent_id: nil,
                                                    data_origin: SFG,
                                                    name:      'Earth')
    earth.geographic_area_type = GeographicAreaType.where(name: 'Planet').first
    # save this record for later
    earth.save
  else
    # use the (first) record we found
    earth = earth.first
  end

  ne, iso, lvl1, lvl2, lvl3, lvl4, gadm2 = nil, nil, nil, nil, nil, nil, nil

  filenames.sort!

  filenames.each { |filename|

    puts filename

    case filename
      when /level1/i
        lvl1 = DBF::Table.new(filename)
      when /level2/i
        lvl2 = DBF::Table.new(filename)
      when /level3/i
        lvl3 = DBF::Table.new(filename)
      when /level4/i
        lvl4 = DBF::Table.new(filename)
      when /country_names_and_code_elements/i
        iso = File.open(filename)
      when /ne_/i
        ne = DBF::Table.new(filename)
      when /gadm2/i
        gadm2 = DBF::Table.new(filename)
      else
    end
  }

  @lvl0_items, @lvl1_items, @lvl2_items, @lvl3_items, @lvl4_items, @lvl5_items = {}, {}, {}, {}, {}, {}

  # @global will be filled such that ga.name is the key for easier location later
  iso_items, @global                                                           = {}, {}
  gat5                                                                         = GeographicAreaType.where(name: 'Country').first

  if lvl1 != nil

    gat1 = GeographicAreaType.where(name: 'Level 1').first
    gat2 = GeographicAreaType.where(name: 'Level 2').first
    gat3 = GeographicAreaType.where(name: 'Level 3').first
    gat4 = GeographicAreaType.where(name: 'Level 4').first


    # processing the TDWG2 level files into memory

    lvl1.each { |item|
      puts item.attributes
      ga = GeographicArea.new(parent:               earth,
                              tdwg_parent:          earth,
                              data_origin: TDWG2_L1,
                              name:                 item['LEVEL1_NAM'].titlecase,
                              geographic_area_type: gat1)
      @lvl1_items.merge!(item['LEVEL1_COD'] => ga)
      @global.merge!(ga.name => ga)
    }

    lvl2.each { |item|
      puts item.attributes
      ga = GeographicArea.new(parent:               @lvl1_items[item['LEVEL1_COD']],
                              tdwg_parent:          @lvl1_items[item['LEVEL1_COD']],
                              name:                 item['LEVEL2_NAM'].titlecase,
                              data_origin: TDWG2_L2,
                              geographic_area_type: gat2)
      @lvl2_items.merge!(item['LEVEL2_COD'] => ga)
      @global.merge!(ga.name => ga)
    }

    lvl3.each { |item|
      puts item.attributes
      ga = GeographicArea.new(parent:               @lvl2_items[item['LEVEL2_COD']],
                              tdwg_parent:          @lvl2_items[item['LEVEL2_COD']],
                              name:                 item['LEVEL3_NAM'].titlecase,
                              data_origin: TDWG2_L3,
                              geographic_area_type: gat3)
      lvl3_items.merge!(item['LEVEL3_COD'] => ga)
      @global.merge!(ga.name => ga)
    }

    # Before we process the lvl4 data, we will process the iso codes information, so that the iso codes in lvl4 will
    # have some meaning when we process *them*.

    # add, where possible, ISO 3166 country codes

    lvl4.each { |item|
      # When processing lvl4, there are two different ways we need to process the line data:
      #   If this entry has a sub-code of 'OO', it should be represented in one of the earlier levels

      # puts item.attributes

      # isolate the name
      this_area_name = item['Level_4_Na'].titlecase
      # and the iso code of this area
      country_code   = item['ISO_Code']

=begin
# here are spme problem level 4 records:
{"ISO_Code"=>"UK", "Level_4_Na"=>"Channel Is.", "Level4_cod"=>"FRA-CI", "Level4_2"=>"CI", "Level3_cod"=>"FRA", "Level2_cod"=>12, "Level1_cod"=>1}
{"ISO_Code"=>"UK", "Level_4_Na"=>"Great Britain", "Level4_cod"=>"GRB-OO", "Level4_2"=>"OO", "Level3_cod"=>"GRB", "Level2_cod"=>10, "Level1_cod"=>1}
{"ISO_Code"=>"UK", "Level_4_Na"=>"Northern Ireland", "Level4_cod"=>"IRE-NI", "Level4_2"=>"NI", "Level3_cod"=>"IRE", "Level2_cod"=>10, "Level1_cod"=>1}
{"ISO_Code"=>"AN", "Level_4_Na"=>"Netherlands Leeward Is.", "Level4_cod"=>"LEE-NL", "Level4_2"=>"NL", "Level3_cod"=>"LEE", "Level2_cod"=>81, "Level1_cod"=>8}
{"ISO_Code"=>"TP", "Level_4_Na"=>"East Timor", "Level4_cod"=>"LSI-ET", "Level4_2"=>"ET", "Level3_cod"=>"LSI", "Level2_cod"=>42, "Level1_cod"=>4}
{"ISO_Code"=>"AN", "Level_4_Na"=>"Bonaire", "Level4_cod"=>"NLA-BO", "Level4_2"=>"BO", "Level3_cod"=>"NLA", "Level2_cod"=>81, "Level1_cod"=>8}
{"ISO_Code"=>"AN", "Level_4_Na"=>"Curaçao", "Level4_cod"=>"NLA-CU", "Level4_2"=>"CU", "Level3_cod"=>"NLA", "Level2_cod"=>81, "Level1_cod"=>8}
{"ISO_Code"=>"PI", "Level_4_Na"=>"Paracel Is.", "Level4_cod"=>"SCS-PI", "Level4_2"=>"PI", "Level3_cod"=>"SCS", "Level2_cod"=>41, "Level1_cod"=>4}
{"ISO_Code"=>"SP", "Level_4_Na"=>"Spratly Is.", "Level4_cod"=>"SCS-SI", "Level4_2"=>"SI", "Level3_cod"=>"SCS", "Level2_cod"=>41, "Level1_cod"=>4}
{"ISO_Code"=>"YU", "Level_4_Na"=>"Kosovo", "Level4_cod"=>"YUG-KO", "Level4_2"=>"KO", "Level3_cod"=>"YUG", "Level2_cod"=>13, "Level1_cod"=>1}
{"ISO_Code"=>"YU", "Level_4_Na"=>"Montenegro", "Level4_cod"=>"YUG-MN", "Level4_2"=>"MN", "Level3_cod"=>"YUG", "Level2_cod"=>13, "Level1_cod"=>1}
{"ISO_Code"=>"YU", "Level_4_Na"=>"Serbia", "Level4_cod"=>"YUG-SE", "Level4_2"=>"SE", "Level3_cod"=>"YUG", "Level2_cod"=>13, "Level1_cod"=>1}
=end

      # find the nation by its country code
      nation         = nil
      @global.each { |key, area|
        if area.iso_3166_a2 == country_code
          nation = area
          break #
        end
      }

      # find the matching@global record by name
      ga =@global[this_area_name]
      if ga.nil?
        l3_code = item['Level3_cod']
        l3_ga   = lvl3_items[l3_code]
        # failed to find an area by this name in the TDWG data, so we need to create one
        # so we set the parent to the object pointed to by the level 3 code
        ga      = GeographicArea.new(parent:               l3_ga,
                                     tdwg_parent:          l3_ga,
                                     name:                 this_area_name,
                                     iso_3166_a2:          nil,
                                     data_origin: TDWG2_L4,
                                     # we show this is from the TDWG data, *not* the iso data
                                     geographic_area_type: gat4,
                                     # even if nation is nil, this will do what we want.
                                     country:              nation)
        @lvl4_items.merge!(item['Level4_cod'] => ga)
        @global.merge!(ga.name => ga)
      else
        # ga is the named area we are looking for
        ga.level0 = nation
        nation
      end

      if nation.nil?

        puts "#{nation.nil? ? 'Unmatchable record' : nation.name}::#{item.attributes}"
      else
        # puts nation.name
      end
    }

  else
    # we are processing non-TDWG data; right now, that is gadm data
    # this processing is specifically for GADM2

    gadm_example = {"OBJECTID"   => 1,
                    "ID_0"       => 1,
                    "ISO"        => "AFG",

                    "NAME_0"     => "Afghanistan",

                    "ID_1"       => 12,
                    "NAME_1"     => "Jawzjan",
                    "VARNAME_1"  => "Jaozjan|Jozjan|Juzjan|Jouzjan|Shibarghan",
                    "NL_NAME_1"  => "",
                    "HASC_1"     => "AF.JW",
                    "CC_1"       => "",
                    "TYPE_1"     => "Velayat",
                    "ENGTYPE_1"  => "Province",
                    "VALIDFR_1"  => "19640430",
                    "VALIDTO_1"  => "198804",
                    "REMARKS_1"  => "",

                    "ID_2"       => 129,
                    "NAME_2"     => "Khamyab",
                    "VARNAME_2"  => "",
                    "NL_NAME_2"  => "",
                    "HASC_2"     => "AF.JW.KM",
                    "CC_2"       => "",
                    "TYPE_2"     => "",
                    "ENGTYPE_2"  => "",
                    "VALIDFR_2"  => "Unknown",
                    "VALIDTO_2"  => "Present",
                    "REMARKS_2"  => "",

                    "ID_3"       => 0,
                    "NAME_3"     => "",
                    "VARNAME_3"  => "",
                    "NL_NAME_3"  => "",
                    "HASC_3"     => "",
                    "TYPE_3"     => "",
                    "ENGTYPE_3"  => "",
                    "VALIDFR_3"  => "",
                    "VALIDTO_3"  => "",
                    "REMARKS_3"  => "",

                    "ID_4"       => 0,
                    "NAME_4"     => "",
                    "VARNAME_4"  => "",
                    "TYPE4"      => "",
                    "ENGTYPE4"   => "",
                    "TYPE_4"     => "",
                    "ENGTYPE_4"  => "",
                    "VALIDFR_4"  => "",
                    "VALIDTO_4"  => "",
                    "REMARKS_4"  => "",

                    "ID_5"       => 0,
                    "NAME_5"     => "",
                    "TYPE_5"     => "",
                    "ENGTYPE_5"  => "",

                    "Shape_Leng" => 1.30495037416,
                    "Shape_Area" => 0.0798353069113}

    if divisions == true
      # this section is specifically, and only, for gathering the English names of the divisions from level_1 and level_2 named areas

      gadm2.each { |item|

        s0 = "#{item['OBJECTID']}: "

        lvl1_type = item['ENGTYPE_1']
        if lvl1_type != ''
          if @lvl0_items[lvl1_type].nil?
            @lvl0_items[lvl1_type] = 1
          else
            @lvl0_items[lvl1_type] += 1
          end
          s1 = "\'#{lvl1_type}\': #{@lvl0_items[lvl1_type]}, "
        else
          s1 = ''
        end

        lvl2_type = item['ENGTYPE_2']
        if lvl2_type != ''
          if @lvl0_items[lvl2_type].nil?
            @lvl0_items[lvl2_type] = 1
          else
            @lvl0_items[lvl2_type] += 1
          end
          s2 = "\'#{lvl2_type}\': #{@lvl0_items[lvl2_type]}, "
        else
          s2 = ''
        end

=begin
        lvl3_type = item['ENGTYPE_3']
        if lvl3_type != ''
          if @lvl0_items[lvl3_type].nil?
            @lvl0_items[lvl3_type] = 1
          else
            @lvl0_items[lvl3_type] += 1
          end
          s3 = "\'#{lvl3_type}\': #{@lvl0_items[lvl3_type]}, "
        else
          s3 = ''
        end

        lvl4_type = item['ENGTYPE_4']
        if lvl4_type != ''
          if @lvl0_items[lvl4_type].nil?
            @lvl0_items[lvl4_type] = 1
          else
            @lvl0_items[lvl4_type] += 1
          end
          s4 = "\'#{lvl4_type}\': #{@lvl0_items[lvl4_type]}, "
        else
          s4 = ''
        end

        lvl5_type = item['ENGTYPE_5']
        if lvl5_type != ''
          if @lvl0_items[lvl5_type].nil?
            @lvl0_items[lvl5_type] = 1
          else
            @lvl0_items[lvl5_type] += 1
          end
          s5 = "\'#{lvl5_type}\': #{@lvl0_items[lvl5_type]}, "
        else
          s5 = ''
        end
        puts "#{s0} #{item['NAME_0']} => #{s1}#{s2}#{s3}#{s4}#{s5}"
=end
        # puts "#{s0} #{item['NAME_0']} => #{s1}#{s2}"

      }

      @lvl0_items.sort_by { |name, count| count }.each { |item| puts "\"#{item[0]}\": #{item[1]}" }
      iso_items, @global, @lvl0_items, @lvl1_items, @lvl2_items, @lvl3_items, @lvl4_items, @lvl5_items = {}, {}, {}, {}, {}, {}, {}, {}
      breakpoint.save
    end

    iso.each { |line|
      # this section is for capturing country names and iso_a2 codes from the "country_names_and_code_elements" file.
      if line.strip!.length > 6 # minimum line size to contain useful data

        # break down the useful data
        parts       = line.split(';')
        nation_code = parts[1].strip # clean off the line extraneous white space
        nation_name = parts[0].titlecase

        ga = GeographicArea.where(name: nation_name, iso_3166_a2: nation_code).first
        if ga.nil?
          # We will need to create new@global records so that we can check for typing anomalies and
          # misplaced areas later, and so that we have the iso codes up to which to match during lvl4 processing.

          if !(nation_name =~ /Country Name/) # drop the headers on the floor
            puts "'#{nation_code}' for #{nation_name}\t\tAdded."
            ga = GeographicArea.new(parent:               earth,
                                    # if we create records here, they will specifically *not* be TDWG records
                                    # or GADM records
                                    tdwg_parent:          nil,
                                    name:                 nation_name,
                                    iso_3166_a2:          nation_code,
                                    geographic_area_type: gat5)

            ga.level0 = ga
          end
        else
          # found a record with the right name
          puts "'#{nation_code}' for #{nation_name}\t\tMatched."
          ga.iso_3166_a2          = nation_code
          ga.geographic_area_type = gat5
          # the following may seem a bit redundant, but it is indicated the end of a national hierarchy
          ga.level0               = ga
        end
        ga.data_orign = ISO_3166_1_2
        iso_items.merge!(ga.name => ga) if !(ga.nil?)
      end
    }

    puts 'Saving ISO-3166-1-alpha-2 countries and codes.'
    iso_items.each { |key, area|
      puts "#{area.name}"
      area.save
    }

    gadm2.each { |item|

      l0_name = item['NAME_0'].titlecase
      l0_iso  = item['ISO']
      l0_id   = item['ID_0']

      gadm_id = item['OBJECTID']
      l1_id   = item['ID_1']
      l2_id   = item['ID_2']
      l3_id   = item['ID_3']
      l4_id   = item['ID_4']
      l5_id   = item['ID_5']

      id_vector = [l0_id, l1_id, l2_id]

      # l0 always has a name
      l1_name   = item['NAME_1'].titlecase
      l2_name   = (l2_id == 0) ? '' : item['NAME_2'].titlecase
      l3_name   = (l3_id == 0) ? '' : item['NAME_3'].titlecase
      l4_name   = (l4_id == 0) ? '' : item['NAME_4'].titlecase
      l5_name   = (l5_id == 0) ? '' : item['NAME_5'].titlecase

      i5 = l5_name
      s5 = i5.empty? ? '' : ("\"" + i5 + "\", ")
      i4 = l4_name
      s4 = i4.empty? ? '' : ("\"" + i4 + "\", ")
      i3 = l3_name
      s3 = i3.empty? ? '' : ("\"" + i3 + "\", ")
      i2 = l2_name
      s2 = i2.empty? ? '' : ("\"" + i2 + "\", ")
      i1 = l1_name
      s1 = i1.empty? ? '' : ("\"" + i1 + "\", ")
      a1 = "#{s5}#{s4}#{s3}#{s2}#{s1}\"#{l0_name}\"."
      a1 = "#{s5}#{s2}#{s1}\"#{l0_name}\"."
      puts "#{gadm_id}: #{a1}"

      # build lvl0 key value from lvl0 data

      l0_key = {
        'ID_0'   => l0_id,
        'ISO'    => l0_iso,
        'NAME_0' => l0_name
      }

      # look in iso_items for an existing record by name
      ga     = iso_items[l0_name]
      if ga.nil?
        # no such iso record exists
        # look for a record with this l0_id in the zero level list
        ga = @lvl0_items[l0_key]

        if ga.nil?
          # create a record for the zero level, and the @global list
          ga = GeographicArea.new(parent:      earth,
                                  iso_3166_a3: l0_iso,
                                  name:        l0_name)
        else
          # l0 is the object we want
          l0 = ga
        end
      else
        # ga is the object we want
        # lets fix it up
        ga.iso_3166_a3 = l0_iso
        # we only want to fix the l0 record once, so we
        # remove the iso record from the search list
        iso_items.delete(l0_name)
      end
      ga.data_origin = GADM2

      if l1_name.empty?
        puts item.attributes
        ga.gadmID = gadm_id
      end

      # put the item in the lvl0 list
      place = {l0_key => ga}
      @lvl0_items.merge!(place)
      # and the @global list
      @global.merge!(place)
      # yes, this *is* the same as parent
      ga.level0 = ga
      l0        = ga

      if l1_name.empty?
        # nothing to do
        # make the parent of level 2 (extant?) the level 0 area
        # thereby skipping the level 1 emptiness
        l1 = l0

        # special case for Nepal
        if l2_name.empty?
          l1.gadmID = gadm_id
        end
      else

        # process level 1, using level 0 as parent

=begin
                    "ID_1"       => 12,
                    "NAME_1"     => "Jawzjan",
                    "VARNAME_1"  => "Jaozjan|Jozjan|Juzjan|Jouzjan|Shibarghan",
                    "NL_NAME_1"  => "",
                    "HASC_1"     => "AF.JW",
                    "CC_1"       => "",
                    "TYPE_1"     => "Velayat",
                    "ENGTYPE_1"  => "Province",
                    "VALIDFR_1"  => "19640430",
                    "VALIDTO_1"  => "198804",
                    "REMARKS_1"  => "",
=end

        l1_key = {
          'ID_1'      => l1_id,
          'NAME_1'    => l1_name,
          'VARNAME_1' => item['VARNAME_1'],
          'NL_NAME_1' => item['NL_NAME_1'],
          'HASC_1'    => item['HASC_1'],
          'CC_1'      => item['CC_1'],
          'TYPE_1'    => item['TYPE_1'],
          'ENGTYPE_1' => item['ENGTYPE_1'],
          'VALIDFR_1' => item['VALIDFR_1'],
          'VALIDTO_1' => item['VALIDTO_1'],
          'REMARKS_1' => item['REMARKS_1']
        }

        ga = @lvl1_items[l1_key]
        if ga.nil?
          # create a record for level 1, and the @global list
          ga    = GeographicArea.new(parent:               l0,
                                     name:                 l1_name,
                                     geographic_area_type: add_gat(item['ENGTYPE_1']))
          # put the item in the lvl0 list
          place = {l1_key => ga}
          @lvl1_items.merge!(place)
          # and the @global list
          @global.merge!(place)
        else
          # nothing to do
          l1 = ga
        end
        ga.gadm_valid_from = item['VALIDFR_1']
        ga.gadm_valid_to   = item['VALIDTO_1']

        if l2_name.empty?
          # if l2 is empty, this is the highest level, so this is the right shape
          ga.gadmID = gadm_id
        end

        ga.level0 = ga.parent
        ga.level1 = ga
      end
      l1 = ga

      if l2_name.empty?
        # nothing to do
        l1.gadmID = gadm_id
      else

        # process level 2, using level 1 as parent

        l2_key = {
          'ID_2'      => l2_id,
          'NAME_2'    => l2_name,
          'VARNAME_2' => item['VARNAME_2'],
          'NL_NAME_2' => item['NL_NAME_2'],
          'HASC_2'    => item['HASC_2'],
          'CC_2'      => item['CC_2'],
          'TYPE_2'    => item['TYPE_2'],
          'ENGTYPE_2' => item['ENGTYPE_2'],
          'VALIDFR_2' => item['VALIDFR_2'],
          'VALIDTO_2' => item['VALIDTO_2'],
          'REMARKS_2' => item['REMARKS_2']
        }

        l2 = @lvl2_items[l2_key]
        if l2.nil?
          # create a record for level 2, and the @global list
          ga = GeographicArea.new(parent:               l1,
                                  name:                 l2_name,
                                  geographic_area_type: add_gat(item['ENGTYPE_2']))

          ga.gadm_valid_from = item['VALIDFR_2']
          ga.gadm_valid_to   = item['VALIDTO_2']
          ga.level0          = ga.parent.parent
          ga.level1          = ga.parent
          ga.level2          = ga

          # put the item in the lvl2 list
          place              = {l2_key => ga}
          @lvl2_items.merge!(place)
          # and the @global list
          @global.merge!(place)

        else
          # nothing to do
          l2 = l2
        end

        if l3_name.empty?
          # if l3 is empty, this is the highest level, so this is the right shape
          ga.gadmID = gadm_id
        else
          # nothing to do
          l3_id = l3_id
        end

      end
      l2 = ga

=begin
      if l3_name.empty?
        # nothing to do
      else
        # process level 3, using level 2 as parent

        l3 = @lvl3_items[l2_name]
        if l3.nil?
          # create a record for level 3, and the @global list
          ga    = GeographicArea.new(parent:               l2,
                                     name:                 l3_name,
                                     iso_3166_a3:          item['ISO'],
                                     geographic_area_type: add_gat(item['ENGTYPE_3']))
          # put the item in the lvl0 list
          place = {l3_name => ga}
          @lvl3_items.merge!(place)
          # and the @global list
          @global.merge!(place)
          l3 = ga
        else
          # nothing to do
        end
      end

      if l4_name.empty?
        # nothing to do
      else
        # process level 4, using level 3 as parent

        l4 = @lvl4_items[l4_name]
        if l4.nil?
          # create a record for level 4, and the @global list
          ga    = GeographicArea.new(parent:               l3,
                                     name:                 l4_name,
                                     iso_3166_a3:          item['ISO'],
                                     geographic_area_type: add_gat(item['ENGTYPE_4']))
          # put the item in the lvl0 list
          place = {l4_name => ga}
          @lvl4_items.merge!(place)
          # and the @global list
          @global.merge!(place)
          l4 = ga
        else
          # nothing to do
        end
      end

      if l5_name.empty?
        # nothing to do
      else
        # process level 5, using level 4 as parent

        l5 = @lvl5_items[l5_name]
        if l5.nil?
          # create a record for level 5, and the @global list
          ga    = GeographicArea.new(parent:               l4,
                                     name:                 l5_name,
                                     iso_3166_a3:          item['ISO'],
                                     geographic_area_type: add_gat(item['ENGTYPE_5']))
          # put the item in the lvl0 list
          place = {l5_name => ga}
          @lvl5_items.merge!(place)
          # and the @global list
          @global.merge!(place)
          l5 = ga
        else
          # nothing to do
        end
      end
=end
    }
  end # of GADM processing

  # breakpoint.save

  puts 'Saving Level 0 areas.'
  @lvl0_items.each { |key, area|
    area.data_origin = GADM2
    area.save
    puts area.id
    @global.delete(area.name)
  }

  puts 'Saving Level 1 areas.'
  @lvl1_items.each { |key, area|
    area.save
    puts area.id
    @global.delete(area.name)
  }

  puts 'Saving Level 2 areas.'
  @lvl2_items.each { |key, area|
    area.save
    puts area.id
    @global.delete(area.name)
  }

=begin
  puts 'Saving Level 3 areas.'
  @lvl3_items.each { |key, area|
    area.save
    @global.delete(area.name)
  }

  puts 'Saving Level 4 areas.'
  @lvl4_items.each { |key, area|
    area.save
    @global.delete(area.name)
  }

  puts 'Saving Level 5 areas.'
  @lvl5_items.each { |key, area|
    area.save
    @global.delete(area.name)
  }
=end

  # what is left over?
  puts 'Saving non-Level(0, 1, 2) areas.'
  @global.each { |key, area|
    puts area.id
    area.save
  }

end

def read_csv(file)

  # data = CSV.open(file)

  data = CSV.read(file, options = {headers: true})

  record    = GeographicArea.new
  area_type = GeographicAreaType.new
  data.each { |row|

    puts row

    case file
      when /USA_adm0/
        record    = GeographicArea.new(parent_id:  0,
                                       name:       row.field('NAME_ENGLISH'),
                                       country_id: row.field('PID'))
        area_type = GeographicAreaType.where(name: 'Country')[0]
        if area_type.nil?
          at = GeographicAreaType.new(name: 'Country')
          at.save
          area_type = at
        end
      when /USA_adm1/
        record    = GeographicArea.new(parent_id:  row.field('ID_0'),
                                       name:       row.field('NAME_1'),
                                       state_id:   row.field('ID_1'),
                                       country_id: row.field('ID_0'))
        area_type = GeographicAreaType.where(name: row.field('TYPE_1'))[0]
        if area_type.nil?
          at = GeographicAreaType.new(name: row.field('TYPE_1'))
          at.save
          area_type = at
        end
      when /USA_adm2/
        record    = GeographicArea.new(parent_id:  row.field('ID_1'),
                                       name:       row.field('NAME_2'),
                                       state_id:   row.field('ID_1'),
                                       country_id: row.field('ID_0'),
                                       county_id:  row.field('ID_2'))
        area_type = GeographicAreaType.where(name: row.field('TYPE_2'))[0]
        if area_type.nil?
          at = GeographicAreaType.new(name: row.field('TYPE_2'))
          at.save
          area_type = at
        end
      else

    end
    record.geographic_area_type = area_type
    record.save
  }
end

def add_gat(gat)
  # extracted out to enable single insert

  area_type = @gat_list[gat]
  if area_type.nil?
    area_type = GeographicAreaType.new(name: gat)
    @gat_list.merge!(gat => area_type)
  end
  area_type
end

def build_gat_table

  # create our list
  l_var     = 'Unknown'
  @gat_list = {}

  ['Planet',
   'Level 0',
   'Continent',
   'Level 1',
   'Subcontinent',
   'Level 2',
   'Country',
   'Level 3',
   'State',
   'Level 4',
   'Federal District',
   'County',
   'Borough',
   'Census Area',
   'Municipality',
   'Municipality/Municipal Council',
   'City And Borough',
   'City And County',
   'District',
   'Water body',
   'Parish',
   'Independent City',
   'Province',
   'Ward',
   'Prefecture',
   l_var,
   'Shire'].each { |item|
    area_type = GeographicAreaType.where(name: item).first
    if area_type.nil?
      area_type = GeographicAreaType.new(name: item)
      area_type.save
    end
    @gat_list.merge!(item => area_type)
  }
  # add as required from GADM list
  gadm_divisions

  # make special cases
  @gat_list.merge!('' => @gat_list[l_var])
  @gat_list.merge!(nil => @gat_list[l_var])
end

def gadm_divisions
  ['Reef',
   'Metropolitan Borough (city)',
   'Autonomous Okurg',
   'Administrative Area',
   'Territorial Unit',
   'Autonomous Sector',
   'Conservancy',
   'City and County',
   'National District',
   'Capital City',
   'Autonomous Commune',
   'Commune and Prefecture',
   'Capital',
   'Capital Territory',
   'Unitary Authority (county)',
   'Autonomous Territory',
   'National Territory',
   'Neutral City',
   'Capital District',
   'City and Borough',
   'Outlying Island',
   'Island|Atoll',
   'Autonomous Monastic State',
   'Ward',
   'London Borough (royal)',
   'Directly Governed City',
   'Island Area',
   'London Borough (city)',
   'City Municipality',
   'Autonomous Island',
   'Territorial Authority',
   'Statutory city',
   'Metropolitan District',
   'Town Council',
   'Municipal District',
   'Autonomous City',
   'Economic Prefecture',
   'Préfecture',
   'Unitary District (city)',
   'Special Municipality',
   'Independent Town',
   'Lake',
   'Dependency',
   'Atoll',
   'Island Group',
   'Water Body',
   'Special region',
   'Area',
   'Metropolitan County',
   'Special Administrative Region',
   'Special Region|Zone',
   'Special City',
   'Special district',
   'National Park',
   'Reserve',
   'Island Council',
   'Emirate',
   'Urban',
   'Municipality|Prefecture',
   'Unitary Authority (city)',
   'Quarter',
   'Census Area',
   'Assembly',
   'Island',
   'United County',
   'Statutory City',
   'Centrally Administered Area',
   'Rural City',
   'Municipality / Mun. Council',
   'Automonous Region',
   'Borough',
   'United Counties',
   'Corregimiento Departamento',
   'Capital Region',
   'League',
   'Unitary Authority (wales',
   'Principality',
   'Waterbody',
   'Special Ward',
   'Capital Metropolitan City',
   'Unitary District',
   'Municipality/Municipal Council',
   'London Borough',
   'Commissiary',
   'Raion',
   'Municipality|Governarate',
   'Mukim',
   'Administrative County',
   'Community Government Council',
   'Sector',
   'Federal District',
   'Autonomous Republic',
   'Municipal district',
   'Unitary Authority',
   'Aboriginal Council',
   'Not Classified',
   'Metropolitan City',
   'Chef-Lieu-Wilaya',
   'Regional Municipality',
   'Independent City',
   'District Municipality',
   'Sub-prefecture',
   'Sub-Province',
   'District Council',
   'Metropolis',
   'Intendancy',
   'Headquarter',
   "Mis'ka Rada",
   'Ressort',
   'National Capital Area',
   'Neighbourhood Democratic',
   'District|Regencies',
   'Urban Prefecture',
   'State|Federal State',
   'Water body',
   'Union Territory',
   'Sub-district',
   'Indigenous Territory',
   'City council',
   'Constituency',
   'Commune-Cotiere',
   'Part',
   'Minor district',
   'Entity',
   'Kingdom',
   'Sub-region',
   'Village',
   'Subregion',
   'Circuit',
   'Town|Municipal',
   'Commune|Municipality',
   'Poblacion',
   'Arrondissement',
   'Autonomous region',
   'Autonomous Prefecture',
   'Delegation',
   'Statistical Region',
   'Sum',
   'Regency',
   'Magisterial District',
   'Voivodeship|Province',
   'Administrative Region',
   'Shire',
   'Regional Council',
   'Republic',
   'Municpality|City Council',
   'Administrative State',
   'Zone',
   'Governorate',
   'Territory',
   'Sub-chief',
   'Circle',
   'Unknown',
   'Local Authority',
   'Regional District',
   'City|Municipality|Thanh Pho',
   'Town',
   'Division',
   'Regional County Municipality',
   'Autonomous Province',
   'Autonomous Region',
   'Prefecture City',
   'Census Division',
   'Traditional Authority',
   'Prefecture',
   'Development Region',
   'Administrative Zone',
   'Canton',
   'Parish',
   'Autonomous Community',
   'City',
   'Commune',
   'County',
   'State',
   'District',
   'Department',
   'Municipality',
   'Region',
   'Province'].each { |item|
    area_type = GeographicAreaType.where(name: item).first
    if area_type.nil?
      area_type = GeographicAreaType.new(name: item)
      area_type.save
    end
    @gat_list.merge!(item => area_type)
  }

end
