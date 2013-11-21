# INIT tasks for RGeo, PostGIS, shape files (GADM and TDWG)

# TODO: Problems with GADM V2
#    nnnnn: Not a valid geometry.
#   200655: Side location conflict at 33.489303588867358, 0.087361000478210826

namespace :tw do
  namespace :init do

    desc 'Generate PostgreSQL/PostGIS records for shapefiles.'
    task :build_geographic_areas => :environment do

      place    = ENV['place']
      shapes   = ENV['shapes']

      # index is only expected to work for the GADM V2 shape file set: intended as a short-cut to a problem record.
      index = ENV['index']

      # build csv file list from 'place'

      # GenTable: set to true to generate the GeographicAreaType table here
      GenTable = true
      # DoShape: set to true to include the reading og the shapes into the GeographicItem table;
      #          Otherwise, only the CSV files are used to populate the GeographicArea table
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
        if do_shape
          Dir.glob(base_dir + '**/*.shp').each { |filename|
            read_shape(filename, index)
          }
        else
          Dir.glob(base_dir + '**/*.csv').each { |filename|
            read_csv(filename)
          }
        end
      end
    end
  end
end

def read_shape(filename, index)

  RGeo::Shapefile::Reader.open(filename) { |file|

    file.seek_index(index)
    count = file.num_records
    ess   = (count == 1) ? '' : 's'
    puts "#{filename} contains #{count} item#{ess}."

    record    = GeographicArea.new
    area_type = GeographicAreaType.new

    file.each { |item|
      record = nil

      # todo: This processing is *very* specific, and currently only handles the USA_adm shape file case: it must be made to handle a more general case of GADM, and/or TDWG

      case filename
        when /USA_adm0/
          record    = GeorgaphicArea.new(parent_id:  0,
                                         name:       item[:NAME_ENGLISH],
                                         country_id: item[:PID])
          area_type = GeographicAreaType.where(name: 'Country')[0]
          if area_type.nil?
            at = GeographicAreaType.new(name: 'Country')
            at.save
            area_type = at
          end
        when /USA_adm1/
          record    = GeographicArea.new(parent_id:  item[:ID_0],
                                         name:       item[:NAME_1],
                                         state_id:   item[:ID_1],
                                         country_id: item[:ID_0])
          area_type = GeographicAreaType.where(name: item[:TYPE_1])
          if area_type.nil?
            at = GeographicAreaType.new(name: item[:TYPE_1])
            at.save
            area_type = at
          end
        when /USA_adm2/
          record    = GeographicArea.new(parent_id:  item[:ID_1],
                                         name:       item[:NAME_2],
                                         state_id:   item[:ID_1],
                                         country_id: item[:ID_0],
                                         county_id:  item[:ID_2])
          area_type = GeographicAreaType.where(name: item[:TYPE_2])
          if area_type.nil?
            at = GeographicAreaType.new(name: item[:TYPE_2])
            at.save
            area_type = at
          end
        else
=begin
          record    = GeographicArea.new(parent_id:  item[:ID_1],
                                         name:       item[:NAME_2],
                                         state_id:   item[:ID_1],
                                         country_id: item[:ID_0],
                                         county_id:  item[:ID_2])
          area_type = GeographicAreaType.where(name: item[:TYPE_2])
          if area_type.nil?
            at = GeographicAreaType.new(name: item[:TYPE_2])
            at.save
            area_type = at
          end
=end
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
          item_type = 'Unk. geometry'
          count_geo = 0
        else
          item_type = item.geometry.geometry_type
          count_geo = item.geometry.num_geometries
        end
        ess       = (count_geo == 1) ? 'y' : 'ies'
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
        puts "#{item_type}#{'% 5d' % (item.index + 1)} (of #{count} items)(#{count_geo} geometr#{ess}) is called \'#{s5}#{s4}#{s3}#{s2}#{s1}#{item['NAME_0']}\'."
      end
    }
  } if !(filename =~ /[0]/)

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
  ['Continent',
   'Country',
   'State',
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
