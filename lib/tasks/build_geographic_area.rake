# INIT tasks for RGeo, PostGIS, shape files (GADM and TDWG)

# TODO: Problems with GADM V2
#    28758: Not a valid geometry.
#   200655: Side location conflict at 33.489303588867358, 0.087361000478210826


# Jim:  Look into how to pass arguments to a rake task, then use this to point to an (external) directory that includes the data to import.
#   somthing like  :build_geographic_areas => [:environment] do |argv| and called like 
#   rake tw:init:build_geographic_areas data_path=/some/path
#
namespace :tw do
  namespace :init do

    desc 'Generate PostgreSQL/PostGIS records for shapefiles.'
    task :build_geographic_areas => :environment do

      place    = ENV['place']
      shapes   = ENV['shapes']

      # index is only expected to work for the GADM V2 shape file set: intended as a short-cut to a problem record.
      index    = ENV['index']

      # build csv file list from 'place'

      # GenTable: set to true to generate the GeographicAreaType table here
      GenTable = true
      # DoShape: set to true to include the reading of the shapes into the GeographicItem table;
      #          Otherwise, only the DBF files are used to populate the GeographicArea table
      DoShape  = false
      # BaseDir: where to find the tables to be used
      BaseDir  = '../shapes/'

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

  # make sure the earth record exists and is available

  earth = GeographicArea.where(name: 'Earth')
  if earth.count == 0
    # create the record
    earth                      = GeographicArea.new(parent_id: nil,
                                                    name:      'Earth')
    earth.geographic_area_type = GeographicAreaType.where(name: 'Planet').first
    # save this record for later
    earth.save
  else
    # use the (first) record we found
    earth = earth.first
  end

  iso, lvl1, lvl2, lvl3, lvl4 = nil, nil, nil, nil, nil

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
      when /gadm2/i
        gadm2 = DBF::Table.new(filename)
      else
    end
  }

  lvl1_items = {}
  lvl2_items = {}
  lvl3_items = {}
  lvl4_items = {}
  # global will be filled such that ga.name is the key for easier location later
  global     = {}

  gat1 = GeographicAreaType.where(name: 'Level I').first
  gat2 = GeographicAreaType.where(name: 'Level II').first
  gat3 = GeographicAreaType.where(name: 'Level III').first
  gat4 = GeographicAreaType.where(name: 'Level IV').first
  gat5 = GeographicAreaType.where(name: 'Country').first

  # processing the TDWG2 level files into memory

  lvl1.each { |item|
    puts item.attributes
    ga = GeographicArea.new(parent:               earth,
                            name:                 item['LEVEL1_NAM'].titlecase,
                            geographic_area_type: gat1)
    lvl1_items.merge!(item['LEVEL1_COD'] => ga)
    global.merge!(ga.name => ga)
  }

  lvl2.each { |item|
    puts item.attributes
    ga = GeographicArea.new(parent:               lvl1_items[item['LEVEL1_COD']],
                            name:                 item['LEVEL2_NAM'].titlecase,
                            geographic_area_type: gat2)
    lvl2_items.merge!(item['LEVEL2_COD'] => ga)
    global.merge!(ga.name => ga)
  }

  lvl3.each { |item|
    puts item.attributes
    ga = GeographicArea.new(parent:               lvl2_items[item['LEVEL2_COD']],
                            name:                 item['LEVEL3_NAM'].titlecase,
                            geographic_area_type: gat3)
    lvl3_items.merge!(item['LEVEL3_COD'] => ga)
    global.merge!(ga.name => ga)
  }

  # Before we process the lvl4 data, we will process the iso codes information, so that the iso codes in lvl4 will
  # have some meaning when we process *them*.

  # add, where possible, ISO 3166 country codes

  iso.each { |line|
    if line.strip!.length > 6 # minimum line size to contain useful data

      # break down the useful data
      parts = line.split(';')
      nation_code = parts[1].strip # clean off the line extraneous white space
      nation_name = parts[0].titlecase

      ga = global[nation_name]
      if ga.nil?
        # We will need to create new global records so that we can check for typing anomalies and
        # misplaced areas later, and so that we have the iso codes up to which to match during lvl4 processing.

        if !(nation_name =~ /Country Name/) # drop the headers on the floor
          puts "'#{nation_code}' for #{nation_name}\t\tAdded."
          ga = GeographicArea.new(parent:               earth,
                                  name:                 nation_name,
                                  iso_3166_1_alpha_2:   nation_code,
                                  geographic_area_type: gat5)

          ga.country = ga
          global.merge!(ga.name => ga)
        end
      else
        # found a record with the right name
        puts "'#{nation_code}' for #{nation_name}\t\tMatched."
        ga.iso_3166_1_alpha_2   = nation_code
        ga.geographic_area_type = gat5
        # the following may seem a bit redundant, but it is indicated the end of a national hierarchy
        ga.country              = ga
      end
    end
  }

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

    # have to hot-wire some country codes on the fly
    # when the TDWG country code differs from the ISO code,
    # convert TDWG to ISO
    case country_code
      when 'UK' # United Kingdom => Great Britain
        country_code = 'GB'

=begin
      when 'AN' # todo: check on Netherlands Leeward Is. belong to NETHERLANDS
        country_code = 'NL'
      when 'TP' # todo: check on East Timor refers to TIMOR-LESTE
        country_code = 'TL'
=end

      else
        # leave it alone
    end

    # find the nation by its country code
    nation         = nil
    global.each { |key, area|
      if area.iso_3166_1_alpha_2 == country_code
        nation = area
        break #
      end
    }

    # find the matching global record by name
    ga = global[this_area_name]
    if ga.nil?
      # failed to find an area by this name, so we need to create one
      # so we set the parent to the object pointed to by the level 3 code
      ga = GeographicArea.new(parent:               lvl3_items[item['Level3_cod']],
                              name:                 this_area_name,
                              geographic_area_type: gat4,
                              # even if nation is nil, this will do what we want.
                              country: nation)
      lvl4_items.merge!(item['Level4_cod'] => ga)
      global.merge!(ga.name => ga)
    else
      # ga is the named area we are looking for
      ga.country = nation
      nation
    end

    if nation.nil?

      puts "#{nation.nil? ? 'Unmatchable record' : nation.name}::#{item.attributes}"
    else
      # puts nation.name
    end
  }

  puts 'Saving Level 1 areas.'
  lvl1_items.each { |key, area|
    area.save
    global.delete(area.name)
  }

  puts 'Saving Level 2 areas.'
  lvl2_items.each { |key, area|
    area.save
    global.delete(area.name)
  }

  puts 'Saving Level 3 areas.'
  lvl3_items.each { |key, area|
    area.save
    global.delete(area.name)
  }

  puts 'Saving Level 4 areas.'
  lvl4_items.each { |key, area|
    area.save
    global.delete(area.name)
  }

  # what is left over?
  puts 'Saving non-Level( 1, 2, 3, 4 ) areas.'
  global.each { |key, area|
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

def build_gat_table
  ['Planet',
   'Continent',
   'Level I',
   'Subcontinent',
   'Level II',
   'Country',
   'Level III',
   'State',
   'Level IV',
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
   'Unknown',
   'Shire'].each { |item|

    area_type = GeographicAreaType.where(name: item)[0]
    if area_type.nil?
      at = GeographicAreaType.new(name: item)
      at.save
    end
  }
end
